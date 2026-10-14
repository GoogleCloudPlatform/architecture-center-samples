from google.adk.agents.llm_agent import Agent
from google.adk.tools.tool_context import ToolContext
from google.genai.types import (
    SafetySetting,
    HarmCategory,
    HarmBlockThreshold,
    GenerateContentConfig,
)
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset, StreamableHTTPConnectionParams
import sys
import os
import logging
import threading
import time

import google.auth.transport.requests as _google_auth_requests
import google.oauth2.id_token as _google_id_token

from . import agent_config

os.environ.setdefault("GOOGLE_CLOUD_LOCATION", "us-central1")

logger = logging.getLogger(__name__)

_USER_ID_STATE_KEY = "jde_master.user_id"
_USER_CONTEXT_STATE_KEY = "jde_master.user_context"

_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.append(_BASE_DIR)

MCP_SERVER_JDE_URL = os.environ.get("MCP_SERVER_JDE_URL", "").strip()

_auth_request = _google_auth_requests.Request()


def _safe_state_get(state, key: str):
    if state is None:
        return None
    try:
        return state.get(key)
    except Exception:
        return None


def _extract_request_user_context(context) -> dict:
    if context is None:
        return {}
    direct_user_id = getattr(context, "user_id", None)
    if isinstance(direct_user_id, str) and "@" in direct_user_id.strip():
        return {
            "user_id": direct_user_id.strip(),
            "email": direct_user_id.strip(),
            "source": "tool_context.user_id",
        }
    session = getattr(context, "session", None)
    session_user_id = getattr(session, "user_id", None) if session is not None else None
    if isinstance(session_user_id, str) and "@" in session_user_id.strip():
        return {
            "user_id": session_user_id.strip(),
            "email": session_user_id.strip(),
            "source": "tool_context.session.user_id",
        }
    state = getattr(context, "state", None)
    cached_context = _safe_state_get(state, _USER_CONTEXT_STATE_KEY)
    if isinstance(cached_context, dict) and cached_context.get("user_id"):
        return cached_context
    cached_user_id = _safe_state_get(state, _USER_ID_STATE_KEY)
    if isinstance(cached_user_id, str) and "@" in cached_user_id.strip():
        return {
            "user_id": cached_user_id.strip(),
            "email": cached_user_id.strip(),
            "source": "state_cache_fallback",
        }
    default_email = os.environ.get("DEFAULT_JDE_USER_EMAIL", "").strip()
    if default_email:
        return {
            "user_id": default_email,
            "email": default_email,
            "source": "default_fallback",
        }
    return {}


def _make_oidc_header_provider(audience: str):
    _cached_token = None
    _cached_token_expiry = 0.0
    _token_lock = threading.Lock()

    def provider(context) -> dict:
        nonlocal _cached_token, _cached_token_expiry
        headers = {}
        env_token = os.environ.get("MCP_ID_TOKEN", "").strip()
        if env_token:
            headers["Authorization"] = f"Bearer {env_token}"
        else:
            with _token_lock:
                now = time.time()
                if _cached_token and now < _cached_token_expiry:
                    token = _cached_token
                else:
                    try:
                        audience_base = audience.split("/mcp")[0] if "/mcp" in audience else audience
                        token = _google_id_token.fetch_id_token(_auth_request, audience_base)
                        _cached_token = token
                        _cached_token_expiry = now + 3000  # Cache for 50 minutes
                    except Exception as exc:
                        logger.warning("Could not fetch OIDC token for MCP auth: %s", exc)
                        token = None
            if token:
                headers["Authorization"] = f"Bearer {token}"

        user_context = _extract_request_user_context(context)
        user_id = user_context.get("user_id")
        if user_id:
            headers["X-User-Id"] = user_id
            headers["X-User-Email"] = user_context.get("email", user_id)
        return headers
    return provider


_mcp_jde_init_error = None


def _create_mcp_jde_toolset():
    """Factory function to create the McpToolset without blocking module import with sleeps."""
    global _mcp_jde_init_error
    if not MCP_SERVER_JDE_URL:
        _mcp_jde_init_error = "MCP_SERVER_JDE_URL environment variable is not set"
        logger.error(_mcp_jde_init_error)
        return None
    try:
        toolset = McpToolset(
            connection_params=StreamableHTTPConnectionParams(
                url=MCP_SERVER_JDE_URL,
                timeout=30.0,
            ),
            header_provider=_make_oidc_header_provider(MCP_SERVER_JDE_URL),
        )
        logger.info(f"Initialized Mcp JDE Toolset with URL: {MCP_SERVER_JDE_URL}")
        _mcp_jde_init_error = None
        return toolset
    except Exception as e:
        _mcp_jde_init_error = str(e)
        logger.error(f"Failed to initialize JDE MCP toolset: {e}", exc_info=True)
        return None


mcp_jde_toolset = _create_mcp_jde_toolset()


def jde_backend_unavailable() -> dict:
    """Fallback tool when JDE MCP backend is unreachable during startup."""
    return {
        "ok": False,
        "source_agent": "JDE_Mfg_Agent",
        "error_code": "MCP_UNAVAILABLE",
        "retryable": True,
        "message": f"JDE MCP backend is unavailable at {MCP_SERVER_JDE_URL}: {_mcp_jde_init_error}",
    }


def get_session_user_context(tool_context: ToolContext) -> dict:
    """Return the cached non-sensitive user context set by JDE_Master."""
    state = getattr(tool_context, "state", None)
    cached_context = _safe_state_get(state, _USER_CONTEXT_STATE_KEY)
    if isinstance(cached_context, dict) and cached_context.get("user_id"):
        return cached_context
    cached_user_id = _safe_state_get(state, _USER_ID_STATE_KEY)
    if cached_user_id:
        return {
            "user_id": cached_user_id,
            "email": cached_user_id,
            "source": "state_cache_fallback",
        }
    direct_context = _extract_request_user_context(tool_context)
    if direct_context.get("user_id"):
        return direct_context
    default_email = os.environ.get("DEFAULT_JDE_USER_EMAIL", "").strip()
    if not default_email:
        return {
            "ok": False,
            "source_agent": "JDE_Mfg_Agent",
            "error_code": "AUTH_FAILED",
            "message": "Unable to determine user identity from session state and DEFAULT_JDE_USER_EMAIL is not configured.",
        }
    return {
        "user_id": default_email,
        "email": default_email,
        "source": "default_fallback",
    }


try:
    from .semantic_mapping import load_semantic_maps, build_semantic_context
except ImportError:
    from semantic_mapping import load_semantic_maps, build_semantic_context  # type: ignore[no-redef]

semantic_maps = load_semantic_maps(_BASE_DIR)
semantic_context = build_semantic_context(semantic_maps)

_tools = [get_session_user_context]
if mcp_jde_toolset is not None:
    _tools.append(mcp_jde_toolset)
else:
    _tools.append(jde_backend_unavailable)

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=f"{agent_config.description} ",
    instruction=f"{agent_config.instruction}\n\n{semantic_context}",
    tools=_tools,
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
    ),
)
