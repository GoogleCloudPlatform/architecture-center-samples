from google.adk import Agent
from google.adk.tools.tool_context import ToolContext
from google.genai.types import (SafetySetting,
                                HarmCategory,
                                HarmBlockThreshold,
                                AutomaticFunctionCallingConfig,
                                GenerateContentConfig)
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset, StreamableHTTPConnectionParams
import sys
import os
import logging
import time
import uuid
from contextlib import contextmanager

import google.auth.transport.requests as _google_auth_requests
import google.oauth2.id_token as _google_id_token

from . import agent_config

# gemini 3 endpoints are currently only accessible in global, so we need to set this env var for the agent to work properly.
os.environ['GOOGLE_CLOUD_LOCATION'] = 'global'


try:
    from google.cloud import aiplatform
    _TELEMETRY_AVAILABLE = True
except ImportError:
    _TELEMETRY_AVAILABLE = False

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Telemetry Initialization
# ---------------------------------------------------------------------------
_TRACE_ID_STATE_KEY = "_telemetry.trace_id"
_TELEMETRY_CLIENT = None
if _TELEMETRY_AVAILABLE:
    try:
        telemetry_init = getattr(aiplatform.telemetry, "init", None)
        if callable(telemetry_init):
            _TELEMETRY_CLIENT = telemetry_init(
                service_name=os.environ.get("SERVICE_NAME", "ebs-sql-agent"),
                service_version=os.environ.get("SERVICE_VERSION", "dev"),
            )
            logger.info("Telemetry client initialized successfully.")
        else:
            logger.info(
                "Vertex AI telemetry init API is unavailable in the installed "
                "google-cloud-aiplatform package; custom telemetry is disabled."
            )
    except Exception as e:
        logger.warning(f"Failed to initialize telemetry: {e}")
        _TELEMETRY_CLIENT = None

@contextmanager
def _telemetry_span(name: str, attributes: dict = None):
    """Context manager for distributed tracing and performance metrics."""
    if not _TELEMETRY_CLIENT:
        yield None
        return
    
    start_time = time.perf_counter()
    try:
        with _TELEMETRY_CLIENT.span(name=name, attributes=attributes or {}) as span:
            yield span
    except Exception as e:
        logger.debug(f"Error in telemetry span {name}: {e}")
        yield None
    finally:
        duration_ms = (time.perf_counter() - start_time) * 1000
        logger.debug(f"Span '{name}' completed in {duration_ms:.2f}ms")

# Shared session-memory keys. These must match EBS_Master/agent.py.
_USER_ID_STATE_KEY = "ebs_master.user_id"
_USER_CONTEXT_STATE_KEY = "ebs_master.user_context"

# Compute once at module parse-time so it is always the real absolute directory
# of this file, regardless of cwd or how __file__ was set by the importer.
_BASE_DIR = os.path.dirname(os.path.realpath(__file__))

# Add the project root directory to Python path so we can import utility modules
# This allows importing from the utils directory two levels up from current file
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__),"..","..")))
sys.path.append(_BASE_DIR)

logger.debug(f"Current Python path: {sys.path}")
logger.debug(f"Current working directory: {os.getcwd()}")
logger.debug(f"Files in agent directory: {os.listdir(_BASE_DIR)}")
logger.debug(f"Absolute path of agent directory: {_BASE_DIR}") 

# Configure the MCP server connection URLs via environment variables
# with defaults for local development.
MCP_SERVER_SQL_URL = os.environ.get("MCP_SERVER_SQL_URL", "http://localhost:8082/mcp/")

def _error_envelope(
    *,
    error_code: str,
    message: str,
    retryable: bool,
    data=None,
) -> dict:
    return {
        "ok": False,
        "source_agent": "EBS_SQL_Agent",
        "error_code": error_code,
        "retryable": retryable,
        "message": message,
        "data": data,
    }


# Shared transport reused across token fetches — avoids a new HTTPS connection
# on every request.
_auth_request = _google_auth_requests.Request()


def _safe_state_get(state, key: str):
    """Best-effort getter for ADK state implementations."""
    if state is None:
        return None
    try:
        return state.get(key)
    except Exception:
        return None


def _extract_request_user_context(context) -> dict:
    """Resolve the end-user identity from the current ADK tool/request context."""
    if context is None:
        return {}

    direct_user_id = getattr(context, "user_id", None)
    if isinstance(direct_user_id, str) and direct_user_id.strip():
        return {
            "user_id": direct_user_id.strip(),
            "email": direct_user_id.strip(),
            "source": "tool_context.user_id",
        }

    session = getattr(context, "session", None)
    session_user_id = getattr(session, "user_id", None) if session is not None else None
    if isinstance(session_user_id, str) and session_user_id.strip():
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
    if isinstance(cached_user_id, str) and cached_user_id.strip():
        return {
            "user_id": cached_user_id.strip(),
            "email": cached_user_id.strip(),
            "source": "state_cache_fallback",
        }

    return {}


def _make_oidc_header_provider(audience: str):
    """Return a header_provider that fetches a fresh OIDC identity token per MCP request.

    The token is scoped to this service account and valid for 60 minutes.  Using
    header_provider (called per request) rather than static headers ensures tokens
    are always fresh.

    Falls back to no auth when run locally without a metadata server.
    """
    def provider(context) -> dict:
        headers = {}
        try:
            token = _google_id_token.fetch_id_token(_auth_request, audience)
            headers["Authorization"] = f"Bearer {token}"
        except Exception as exc:
            logger.warning(
                "Could not fetch OIDC token for MCP auth (running locally?): %s", exc
            )

        user_context = _extract_request_user_context(context)
        user_id = user_context.get("user_id")
        if user_id:
            headers["X-User-Id"] = user_id
            headers["X-User-Email"] = user_context.get("email", user_id)

        return headers
    return provider


# McpToolset connects to the running MCP server at startup, fetches every tool's
# full JSON Schema, and registers each one as a properly-typed ADK tool.
# This replaces the manual MCPSessionManager + list_mcp_capabilities + call_mcp_tool
# pattern, which gave Gemini no argument schemas and required an extra round-trip
# per agent turn just to discover what tools exist.
_mcp_sql_init_error = None
try:
    with _telemetry_span("mcp_sql_toolset_init", {"url": MCP_SERVER_SQL_URL}):
        mcp_sql_toolset = McpToolset(
            connection_params=StreamableHTTPConnectionParams(
                url=MCP_SERVER_SQL_URL,
                timeout=30.0,
                
            ),
            header_provider=_make_oidc_header_provider(MCP_SERVER_SQL_URL),
        )
        logger.info(f"Initialized Mcp SQL Toolset with URL: {MCP_SERVER_SQL_URL}")
        if _TELEMETRY_CLIENT:
            _TELEMETRY_CLIENT.log_event("mcp_sql_toolset_initialized", {
                "url": MCP_SERVER_SQL_URL
            })
except Exception as e:
    logger.error(f"Failed to initialize SQL MCP toolset: {e}", exc_info=True)
    mcp_sql_toolset = None
    _mcp_sql_init_error = str(e)
    if _TELEMETRY_CLIENT:
        _TELEMETRY_CLIENT.log_event("mcp_sql_toolset_init_failed", {
            "url": MCP_SERVER_SQL_URL,
            "error": str(e),
            "error_type": type(e).__name__
        })


def sql_backend_unavailable() -> dict:
    """Fallback tool when SQL MCP backend is unreachable during startup."""
    if _TELEMETRY_CLIENT:
        _TELEMETRY_CLIENT.log_event("mcp_sql_backend_unavailable", {
            "url": MCP_SERVER_SQL_URL,
            "error": _mcp_sql_init_error or "unknown"
        })
    return _error_envelope(
        error_code="MCP_UNAVAILABLE",
        message=(
            "SQL MCP backend is unavailable. "
            f"Configured URL: {MCP_SERVER_SQL_URL}. "
            f"Startup error: {_mcp_sql_init_error or 'unknown error'}"
        ),
        retryable=True,
        data={"mcp_url": MCP_SERVER_SQL_URL},
    )


def get_session_user_context(tool_context: ToolContext) -> dict:
    """Return the cached non-sensitive user context set by the master agent. 
    Always use this tool to retrieve user identity for session initialization, 
    rather than trying to parse it from raw tokens or other sources."""
    # Initialize or retrieve trace ID for request correlation
    trace_id = tool_context.state.get(_TRACE_ID_STATE_KEY)
    if not trace_id:
        trace_id = str(uuid.uuid4())
        try:
            tool_context.state[_TRACE_ID_STATE_KEY] = trace_id
        except Exception:
            pass  # Best-effort, state may not support direct assignment
    
    if _TELEMETRY_CLIENT:
        _TELEMETRY_CLIENT.set_trace_context(trace_id=trace_id)
    
    with _telemetry_span("get_session_user_context", {"component": "session_cache", "trace_id": trace_id}):
        cached_context = tool_context.state.get(_USER_CONTEXT_STATE_KEY)
        if isinstance(cached_context, dict) and cached_context.get("user_id"):
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_cache_hit", {
                    "user_id": cached_context.get("user_id"),
                    "trace_id": trace_id
                })
            return cached_context

        cached_user_id = tool_context.state.get(_USER_ID_STATE_KEY)
        if cached_user_id:
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_fallback_hit", {
                    "user_id": cached_user_id,
                    "trace_id": trace_id
                })
            return {
                "user_id": cached_user_id,
                "email": cached_user_id,
                "source": "state_cache_fallback",
            }

        direct_context = _extract_request_user_context(tool_context)
        if direct_context.get("user_id"):
            try:
                tool_context.state[_USER_ID_STATE_KEY] = direct_context["user_id"]
                tool_context.state[_USER_CONTEXT_STATE_KEY] = direct_context
            except Exception:
                pass
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_resolved_from_tool_context", {
                    "user_id": direct_context.get("user_id"),
                    "trace_id": trace_id
                })
            return direct_context

        if _TELEMETRY_CLIENT:
            _TELEMETRY_CLIENT.log_event("session_context_cache_miss", {
                "trace_id": trace_id
            })
        return {
            "ok": False,
            "source_agent": "EBS_SQL_Agent",
            "error_code": "MISSING_SESSION_USER_CONTEXT",
            "retryable": True,
            "message": "No cached user context found. Master agent should call get_user_id first.",
            "data": None,
        }

# Try relative import first (works when deployed as a package via ADK);
# fall back to absolute import for direct script execution locally.
try:
    from .semantic_mapping import load_semantic_maps, build_semantic_context
except ImportError:
    import importlib.util as _ilu
    _sm_spec = _ilu.spec_from_file_location(
        "semantic_mapping", os.path.join(_BASE_DIR, "semantic_mapping.py")
    )
    _sm_mod = _ilu.module_from_spec(_sm_spec)  # type: ignore[arg-type]
    _sm_spec.loader.exec_module(_sm_mod)  # type: ignore[union-attr]
    load_semantic_maps = _sm_mod.load_semantic_maps
    build_semantic_context = _sm_mod.build_semantic_context

with _telemetry_span("load_semantic_maps", {"agent": "SQL"}):
    semantic_maps = load_semantic_maps(_BASE_DIR)
    semantic_context = build_semantic_context(semantic_maps)
    if _TELEMETRY_CLIENT and semantic_maps:
        _TELEMETRY_CLIENT.log_event("semantic_maps_loaded", {
            "map_count": len(semantic_maps)
        })

# Load agent description and instructions with fallback
dir_path = _BASE_DIR
logger.debug(f"Agent directory path: {dir_path}")

logger.info("Initializing Agent with loaded configurations...")

logger.debug(f"Agent Name: {agent_config.name}")
logger.debug(f"Agent Model: {agent_config.model}")
logger.debug(f"Agent Description: {agent_config.description} ")
_failure_contract = (
    "\n\nError contract: Always return valid JSON. "
    "On success return `{\"ok\": true, \"data\": ...}`. "
    "On failure return `{\"ok\": false, \"source_agent\": \"EBS_SQL_Agent\", "
    "\"error_code\": \"...\", \"retryable\": true|false, \"message\": \"...\", "
    "\"data\": {...}}`."
)
logger.debug(f"Agent Instruction: {agent_config.instruction} \n\n{semantic_context}\n\n{_failure_contract}")

_tools = [get_session_user_context]
if mcp_sql_toolset is not None:
    _tools.append(mcp_sql_toolset)
else:
    _tools.append(sql_backend_unavailable)
logger.debug(f"Tools available to agent: {[getattr(tool, 'tool_name_prefix', getattr(tool, '__name__', str(tool))) for tool in _tools]}")

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=f"{agent_config.description} ",
    # Combine behavioral instructions with semantic grounding so SQL generation
    # aligns with Oracle EBS schema entities and known join paths.
    instruction=f"{agent_config.instruction} \n\n{semantic_context}\n\n{_failure_contract}",
    # instruction=f" {instruction_text}\n\n{semantic_context}",
    tools=_tools,
    generate_content_config=GenerateContentConfig(
        # automatic_function_calling=AutomaticFunctionCallingConfig(disable=True),
        temperature=0,
        safety_settings = [
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
