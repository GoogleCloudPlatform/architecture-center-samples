from google.adk import Agent
from google.genai.types import (SafetySetting,
                                HarmCategory,
                                HarmBlockThreshold,
                                GenerateContentConfig)
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset, StreamableHTTPConnectionParams
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import sys
import os
import logging
import time

import google.auth.transport.requests as _google_auth_requests
import google.oauth2.id_token as _google_id_token

# ---------------------------------------------------------------------------
# 1. Logging & Path Configuration
# ---------------------------------------------------------------------------
_debug = os.environ.get("DEBUG", "false").lower() == "true"
logging.basicConfig(
    level=logging.DEBUG if _debug else logging.INFO,
    format="[%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG if _debug else logging.INFO)

_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.abspath(_BASE_DIR))

# ---------------------------------------------------------------------------
# 2. Safe Configuration Loading (No Runtime File Writing)
# ---------------------------------------------------------------------------
# We strictly load the config in-memory. In a serverless container, 
# attempting to write `agent_config.py` to disk can cause permissions errors.
try:
    import importlib.util as _ilu
    _spec = _ilu.spec_from_file_location(
        "agent_config", os.path.join(_BASE_DIR, "agent_config.py")
    )
    agent_config = _ilu.module_from_spec(_spec)
    _spec.loader.exec_module(agent_config)
    logger.info("Successfully loaded agent_config via importlib.")
except Exception as e:
    logger.warning(f"Error importing agent_config: {e}. Falling back to in-memory defaults.")
    import types
    agent_config = types.SimpleNamespace(
        name="EBS_API_Agent",
        model="gemini-2.5-flash",
        description="A helpful assistant for Oracle EBS API operations.",
        instruction="Interact with the Oracle EBS web services and return the results.",
    )

# ---------------------------------------------------------------------------
# 3. Native Structured Output Schema (Pydantic)
# ---------------------------------------------------------------------------
# Replaces the brittle "_failure_contract" text prompt. This guarantees 
# Gemini will always return a structurally valid JSON matching this schema.
class AgentResponseSchema(BaseModel):
    ok: bool = Field(description="True if the API operation or query was successful, False otherwise.")
    source_agent: str = Field(default="EBS_API_Agent", description="The agent generating this response.")
    error_code: Optional[str] = Field(default=None, description="A recognizable error code if 'ok' is False.")
    retryable: Optional[bool] = Field(default=None, description="True if the user or master agent should retry.")
    message: Optional[str] = Field(default=None, description="Status message, error explanation, or brief factual summary.")
    data: Optional[Dict[str, Any]] = Field(default=None, description="The raw API response payload or retrieved data.")

# ---------------------------------------------------------------------------
# 4. Resilient MCP Initialization with Service-Account OIDC Auth
# ---------------------------------------------------------------------------
MCP_SERVER_EBS_URL = os.environ.get("MCP_SERVER_EBS_URL", "http://localhost:8081/mcp")
# Connection timeout in seconds (default: 30s — increase for slow/cold-start servers).
MCP_SERVER_EBS_TIMEOUT = float(os.environ.get("MCP_SERVER_EBS_TIMEOUT", "30.0"))

# Shared transport reused across token fetches to avoid creating a new HTTPS
# connection on every request.
_auth_request = _google_auth_requests.Request()


def _make_oidc_header_provider(audience: str):
    """Return a header_provider that fetches a fresh OIDC identity token per MCP request.

    The token is issued for the service account attached to the running container
    (Workload Identity / metadata server) and is valid for 60 minutes.  By using
    header_provider instead of static headers we ensure the token is always fresh
    and never causes a 401 after expiry.

    When running locally without a metadata server, falls back to no auth so
    developers can still connect to a locally running MCP server.
    """
    def provider(_context) -> dict:
        try:
            token = _google_id_token.fetch_id_token(_auth_request, audience)
            return {"Authorization": f"Bearer {token}"}
        except Exception as exc:
            logger.warning(
                "Could not fetch OIDC token for MCP auth (running locally?): %s", exc
            )
            return {}
    return provider


def initialize_mcp_with_retries(url: str, max_retries: int = 3, delay: int = 2):
    """Configure and return a McpToolset for the given URL.

    NOTE: McpToolset uses lazy connections — the actual HTTP session is opened
    the first time a tool is invoked, not at construction time.  This retry
    loop therefore catches configuration/parameter errors at startup.  Runtime
    errors such as 403 Forbidden or connection refused will surface when the
    agent calls a tool; they are reported through AgentResponseSchema so the
    master agent can decide whether to retry or escalate.
    """
    error_code = "MCP_UNAVAILABLE"
    is_retryable = True

    for attempt in range(max_retries):
        try:
            toolset = McpToolset(
                connection_params=StreamableHTTPConnectionParams(
                    url=url,
                    timeout=MCP_SERVER_EBS_TIMEOUT,
                ),
                header_provider=_make_oidc_header_provider(url),
            )
            logger.info(f"MCP toolset configured for {url} (attempt {attempt + 1})")
            return [toolset]
        except Exception as e:
            err_str = str(e).lower()
            is_auth_error = any(
                token in err_str
                for token in ("401", "403", "unauthorized", "forbidden")
            )
            logger.warning(
                f"MCP toolset setup failed (attempt {attempt + 1}/{max_retries}): {e}"
            )
            if is_auth_error:
                logger.error(
                    "Auth/permission error configuring MCP toolset — not retrying. "
                    "Verify the agent service account has roles/run.invoker on the MCP service."
                )
                error_code = "MCP_AUTH_ERROR"
                is_retryable = False
                break
            if attempt < max_retries - 1:
                time.sleep(delay)
    else:
        logger.error("Exhausted retries configuring MCP toolset.", exc_info=True)

    def api_backend_unavailable() -> dict:
        """Fallback tool emitted when the MCP backend cannot be reached."""
        return {
            "ok": False,
            "source_agent": "EBS_API_Agent",
            "error_code": error_code,
            "retryable": is_retryable,
            "message": (
                f"API MCP backend authentication failed at {url}. "
                "Verify the agent service account has roles/run.invoker on the MCP Cloud Run service."
                if error_code == "MCP_AUTH_ERROR"
                else f"API MCP backend is unavailable at {url}. "
                "Verify MCP_SERVER_EBS_URL and that the server is running."
            ),
            "data": None,
        }

    return [api_backend_unavailable]


_tools = initialize_mcp_with_retries(MCP_SERVER_EBS_URL)

# ---------------------------------------------------------------------------
# 5. Root Agent Definition
# ---------------------------------------------------------------------------
root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=agent_config.description,
    instruction=agent_config.instruction, # Clean instructions, no text-based JSON contract
    tools=_tools,
    # Enforce our Pydantic schema here natively so Gemini always returns structured, predictable output.
    output_schema=AgentResponseSchema,
    generate_content_config=GenerateContentConfig(
        temperature=0,
        safety_settings=[
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_HARASSMENT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
                threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            ),
        ],
    )
)
