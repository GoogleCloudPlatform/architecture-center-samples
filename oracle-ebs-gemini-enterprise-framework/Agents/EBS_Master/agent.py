from google.adk.agents.llm_agent import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import (
    # AutomaticFunctionCallingConfig,
    GenerateContentConfig,
    HarmBlockThreshold,
    HarmCategory,
    SafetySetting,
)
# from pydantic import BaseModel, Field
# from typing import Optional, Dict, Any


import google.oauth2.credentials as credentials
from google.adk.tools.tool_context import ToolContext

import sys
import os
import importlib
import urllib.request
import urllib.parse
import urllib.error
import json
import time
import uuid
from datetime import datetime, timezone
from contextlib import contextmanager

# gemini 3 endpoints are currently only accessible in global, so we need to overwrite this env var 
# for the agent to work properly.
os.environ['GOOGLE_CLOUD_LOCATION'] = 'global'

try:
    from google.cloud import aiplatform
    _TELEMETRY_AVAILABLE = True
except ImportError:
    _TELEMETRY_AVAILABLE = False

try:
    from .logging_config import configure_logging
except ImportError:
    import sys, os as _os
    sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
    from logging_config import configure_logging

logger = configure_logging(__name__)

# ---------------------------------------------------------------------------
# 1. Telemetry Initialization
# ---------------------------------------------------------------------------
_TRACE_ID_STATE_KEY = "_telemetry.trace_id"
_TELEMETRY_CLIENT = None
if _TELEMETRY_AVAILABLE:
    try:
        telemetry_module = getattr(aiplatform, "telemetry", None)
        telemetry_init = getattr(telemetry_module, "init", None) if telemetry_module else None
        
        if callable(telemetry_init):
            _TELEMETRY_CLIENT = telemetry_init(
                service_name=os.environ.get("SERVICE_NAME", "ebs-master-agent"),
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

# ---------------------------------------------------------------------------
# 2. Logging & Path Configuration
# ---------------------------------------------------------------------------
# Resolve the real absolute directory of this file at module parse-time.
_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
# # _debug = os.environ.get("DEBUG", "false").lower() == "true"

# logging.basicConfig(
#     level=logging.INFO,
#     format="EBS_Master: [%(levelname)s] %(name)s: %(message)s",
# )
# logger = logging.getLogger(__name__)
# if _debug:
#     logger.setLevel(logging.DEBUG)

logger.debug(f"Initialised EBS_Master agent with base directory: {_BASE_DIR}")

# ---------------------------------------------------------------------------
# 3. Agent config
# ---------------------------------------------------------------------------

from . import agent_config


# ---------------------------------------------------------------------------
# 4. Import sub-agents
# ---------------------------------------------------------------------------
# Add this file's own directory to sys.path
sys.path.insert(0, _BASE_DIR)

_sub_agent_status = {}

# Shared session-memory keys used across master and sub-agents.
_USER_ID_STATE_KEY = "ebs_master.user_id"
_USER_CONTEXT_STATE_KEY = "ebs_master.user_context"

def _load_sub_agent(module_path: str, symbol_name: str, agent_name: str):
    # Check if the agent is enabled in the agent_config
    enabled_agents = getattr(agent_config, "enabled_agents", None)
    if enabled_agents is not None and agent_name not in enabled_agents:
        logger.info("Sub-agent %s is disabled in config, skipping load.", agent_name)
        _sub_agent_status[agent_name] = {
            "available": False,
            "error": "Disabled in config",
        }
        if _TELEMETRY_CLIENT:
            _TELEMETRY_CLIENT.log_event("sub_agent_disabled", {"agent_name": agent_name})
        return None
    
    with _telemetry_span("sub_agent_load", {"agent_name": agent_name, "module_path": module_path}):
        try:
            module = importlib.import_module(module_path)
            agent = getattr(module, symbol_name)
            _sub_agent_status[agent_name] = {"available": True, "error": None}
            logger.info("Loaded sub-agent: %s", agent_name)
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("sub_agent_loaded", {
                    "agent_name": agent_name,
                    "timestamp": datetime.now(timezone.utc).isoformat()
                })
            return agent
        except Exception as e:
            logger.error("Failed to load sub-agent %s: %s", agent_name, e, exc_info=True)
            _sub_agent_status[agent_name] = {
                "available": False,
                "error": str(e),
            }
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("sub_agent_load_failed", {
                    "agent_name": agent_name,
                    "error": str(e),
                    "error_type": type(e).__name__
                })
            return None

ebs_sql_agent = _load_sub_agent("sub-agents.EBS_SQL_Agent.agent", "root_agent", "EBS_SQL_Agent")
# ebs_api_agent = _load_sub_agent("sub-agents.EBS_API_Agent.agent", "root_agent", "EBS_API_Agent")
ebs_graphs_agent = _load_sub_agent("sub-agents.EBS_Graphs_Agent.agent", "root_agent", "EBS_Graphs_Agent")
mrgoogle_agent = _load_sub_agent("sub-agents.MrGoogle.agent", "root_agent", "MrGoogle")
# mrgooglemaps_agent = _load_sub_agent("sub-agents.MrGoogleMaps.agent", "root_agent", "MrGoogleMaps")

def get_sub_agent_health() -> dict:
    """Return availability and startup errors for each sub-agent."""
    return {
        "ok": True,
        "source_agent": "EBS_Master",
        "sub_agents": _sub_agent_status,
    }


def _set_state_value(tool_context: ToolContext, key: str, value) -> bool:
    """Best-effort state write for ADK state implementations with telemetry."""
    with _telemetry_span("state_write", {"state_key": key, "value_type": type(value).__name__}):
        state = tool_context.state
        try:
            state[key] = value
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("state_write_success", {
                    "backend": "dict",
                    "key": key
                })
            return True
        except Exception as e:
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("state_write_failed", {
                    "backend": "dict",
                    "key": key,
                    "error": str(e)
                })

        update_fn = getattr(state, "update", None)
        if callable(update_fn):
            try:
                update_fn({key: value})
                if _TELEMETRY_CLIENT:
                    _TELEMETRY_CLIENT.log_event("state_write_success", {
                        "backend": "update",
                        "key": key
                    })
                return True
            except Exception as e:
                if _TELEMETRY_CLIENT:
                    _TELEMETRY_CLIENT.log_event("state_write_failed", {
                        "backend": "update",
                        "key": key,
                        "error": str(e)
                    })

        set_fn = getattr(state, "set", None)
        if callable(set_fn):
            try:
                set_fn(key, value)
                if _TELEMETRY_CLIENT:
                    _TELEMETRY_CLIENT.log_event("state_write_success", {
                        "backend": "set",
                        "key": key
                    })
                return True
            except Exception as e:
                if _TELEMETRY_CLIENT:
                    _TELEMETRY_CLIENT.log_event("state_write_failed", {
                        "backend": "set",
                        "key": key,
                        "error": str(e)
                    })

        return False


def _build_safe_user_context(user_id: str) -> dict:
    """Build a minimal, non-sensitive user context for session reuse."""
    timestamp = datetime.now(timezone.utc).isoformat()
    return {
        "user_id": user_id,
        "email": user_id,
        "source": "session_or_oauth",
        "cached_at_utc": timestamp,
    }


def _extract_existing_session_user_id(tool_context: ToolContext):
    """Best-effort lookup of the authenticated end-user from the ADK context."""
    direct_user_id = getattr(tool_context, "user_id", None)
    if isinstance(direct_user_id, str) and direct_user_id.strip():
        return direct_user_id.strip()

    session = getattr(tool_context, "session", None)
    session_user_id = getattr(session, "user_id", None) if session is not None else None
    if isinstance(session_user_id, str) and session_user_id.strip():
        return session_user_id.strip()

    state = getattr(tool_context, "state", None)
    if state is not None:
        for key in ("user_id", "session_user_id", _USER_ID_STATE_KEY):
            try:
                value = state.get(key)
            except Exception:
                value = None
            if isinstance(value, str) and value.strip():
                return value.strip()

    return None


def get_session_user_context(tool_context: ToolContext):
    """
    Returns the cached, non-sensitive user context from ADK session state.
    Use this before delegating to sub-agents so USER_ID is consistently forwarded.
    """
    with _telemetry_span("get_session_user_context", {"component": "session_cache"}):
        cached_context = tool_context.state.get(_USER_CONTEXT_STATE_KEY)
        if isinstance(cached_context, dict) and cached_context.get("user_id"):
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_cache_hit", {
                    "user_id": cached_context.get("user_id")
                })
            return cached_context

        cached_user_id = tool_context.state.get(_USER_ID_STATE_KEY)
        if cached_user_id:
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_fallback_hit", {
                    "user_id": cached_user_id
                })
            return {
                "user_id": cached_user_id,
                "email": cached_user_id,
                "source": "state_cache_fallback",
            }

        session_user_id = _extract_existing_session_user_id(tool_context)
        if session_user_id:
            safe_context = _build_safe_user_context(session_user_id)
            _set_state_value(tool_context, _USER_ID_STATE_KEY, session_user_id)
            _set_state_value(tool_context, _USER_CONTEXT_STATE_KEY, safe_context)
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("session_context_resolved_from_tool_context", {
                    "user_id": session_user_id
                })
            return safe_context

        if _TELEMETRY_CLIENT:
            _TELEMETRY_CLIENT.log_event("session_context_cache_miss", {})
        return {"error": "No cached user context found. Call get_user_id first."}


# ---------------------------------------------------------------------------
# 5. Function tool definitions for master agent
# ---------------------------------------------------------------------------
def get_user_id(tool_context: ToolContext):
    """
    Retrieves the current user's USER_ID. Always call this tool at the start of the conversation to establish user context for routing and session management.
    This tool accesses the session information available in the ToolContext to extract the user ID of the caller.
    Returns:        A string containing the user ID of the caller, or an appropriate message if the user ID cannot be retrieved.
    Note:        The exact structure of the session context and how the user ID is stored may depend on the authentication implementation and the environment in which the agent is running. 
    This tool assumes that the session context includes a "user_id" property that can be accessed to identify the caller.
    """
    # Initialize or retrieve trace ID for request correlation
    trace_id = tool_context.state.get(_TRACE_ID_STATE_KEY)
    if not trace_id:
        trace_id = str(uuid.uuid4())
        _set_state_value(tool_context, _TRACE_ID_STATE_KEY, trace_id)
    
    if _TELEMETRY_CLIENT:
        _TELEMETRY_CLIENT.set_trace_context(trace_id=trace_id)
    
    with _telemetry_span("get_user_id", {"component": "oauth", "trace_id": trace_id}):
        cached_context = tool_context.state.get(_USER_CONTEXT_STATE_KEY)
        if isinstance(cached_context, dict) and cached_context.get("user_id"):
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("user_context_cache_hit", {
                    "user_id": cached_context.get("user_id"),
                    "trace_id": trace_id
                })
            return cached_context

        session_user_id = _extract_existing_session_user_id(tool_context)
        if session_user_id:
            safe_context = _build_safe_user_context(session_user_id)
            _set_state_value(tool_context, _USER_ID_STATE_KEY, session_user_id)
            _set_state_value(tool_context, _USER_CONTEXT_STATE_KEY, safe_context)
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("user_context_resolved_from_tool_context", {
                    "user_id": session_user_id,
                    "trace_id": trace_id
                })
            return safe_context

        try:
            state_dict = tool_context.state.to_dict()
        except Exception:
            try:
                state_dict = dict(tool_context.state)
            except Exception:
                state_dict = {}

        auth_id = os.environ.get("GOOGLE_CLOUD_AUTH_ID", "ebs-vision-master-auth")
        auth_key = next((k for k in state_dict.keys() if auth_id and k.startswith(auth_id)), None)
        
        # google.adk.sessions.state.State object has a get() method 
        # that can be used to retrieve the value of a specific key from the state.

        user_token = tool_context.state.get(auth_key) if auth_key else None

        # Look up token info from Google's tokeninfo endpoint
        token_info = None
        email = None
        if user_token:
            with _telemetry_span("tokeninfo_lookup", {"endpoint": "googleapis_tokeninfo", "trace_id": trace_id}):
                try:
                    params = urllib.parse.urlencode({"access_token": user_token})
                    url = f"{credentials._GOOGLE_OAUTH2_TOKEN_INFO_ENDPOINT}?{params}"
                    with urllib.request.urlopen(url, timeout=10) as response:  # nosec — fixed trusted URL
                        token_info = json.loads(response.read().decode())
                    logger.debug("Token info retrieved for user identity resolution.")
                    if _TELEMETRY_CLIENT:
                        _TELEMETRY_CLIENT.log_event("tokeninfo_lookup_success", {
                            "trace_id": trace_id
                        })
                except urllib.error.HTTPError as e:
                    token_info = {"error": f"HTTP {e.code}: {e.reason}", "body": e.read().decode()}
                    logger.warning(f"tokeninfo lookup failed: {token_info}")
                    if _TELEMETRY_CLIENT:
                        _TELEMETRY_CLIENT.log_event("tokeninfo_lookup_failed", {
                            "error_type": "http_error",
                            "http_code": e.code,
                            "trace_id": trace_id
                        })
                except Exception as e:
                    token_info = {"error": str(e)}
                    logger.error(f"Unexpected error during tokeninfo lookup: {e}", exc_info=True)
                    if _TELEMETRY_CLIENT:
                        _TELEMETRY_CLIENT.log_event("tokeninfo_lookup_failed", {
                            "error_type": type(e).__name__,
                            "error": str(e),
                            "trace_id": trace_id
                        })

        if isinstance(token_info, dict):
            email = token_info.get("email")
            if email:
                logger.debug("Resolved user email from token info.")
        else:
            email = None

        if not email:
            if _TELEMETRY_CLIENT:
                _TELEMETRY_CLIENT.log_event("user_context_resolution_failed", {
                    "trace_id": trace_id
                })
            return {"error": "user_id not found in token info response"}

        safe_context = _build_safe_user_context(email)
        _set_state_value(tool_context, _USER_ID_STATE_KEY, email)
        _set_state_value(tool_context, _USER_CONTEXT_STATE_KEY, safe_context)
        
        if _TELEMETRY_CLIENT:
            _TELEMETRY_CLIENT.log_event("user_context_resolved", {
                "user_id": email,
                "trace_id": trace_id
            })
        return safe_context


# ---------------------------------------------------------------------------
# 6. Master Response Schema (Pydantic)
# ---------------------------------------------------------------------------
# class MasterResponseSchema(BaseModel):
#     ok: bool = Field(description="True if the user's request was successfully fulfilled, False if an error occurred in routing or in a sub-agent.")
#     source_agent: str = Field(default="EBS_Master", description="Always 'EBS_Master' for the top-level response.")
#     error_code: Optional[str] = Field(default=None, description="The error code directly propagated from a failing sub-agent, or a routing error code.")
#     retryable: Optional[bool] = Field(default=None, description="True if the request can be retried.")
#     message: str = Field(description="The final contextual response, summary, or error explanation intended for the user.")
#     data: Optional[Dict[str, Any]] = Field(default=None, description="The raw data, retrieved payload, or tool outputs (like sub-agent health or chart data).")

# ---------------------------------------------------------------------------
# 7. Root / master agent
# ---------------------------------------------------------------------------
_tools = [get_sub_agent_health]
if ebs_sql_agent is not None:
    _tools.append(AgentTool(agent=ebs_sql_agent))
# #if ebs_api_agent is not None:
# #    _tools.append(AgentTool(agent=ebs_api_agent))
if ebs_graphs_agent is not None:
    _tools.append(AgentTool(agent=ebs_graphs_agent))
if mrgoogle_agent is not None:
    _tools.append(AgentTool(agent=mrgoogle_agent))
# if mrgooglemaps_agent is not None:
    # _tools.append(AgentTool(agent=mrgooglemaps_agent))
# if gemini_user_agent is not None:
#     _tools.append(AgentTool(agent=gemini_user_agent))
# if ebs_docs_agent is not None:
#     _tools.append(AgentTool(agent=ebs_docs_agent))

# The master agent needs access to the user session ID in order to route requests 
# to sub-agents on behalf of the user, so we add the `get_user_id` tool 
# to the master agent's toolset.

_tools.append(get_user_id)
_tools.append(get_session_user_context)

# We removed the redundant inline `_failure_handling_rules` since those 
# instructions are already beautifully documented in `agent_config.py`.
root_agent = Agent(
    model=agent_config.model,
    name=agent_config.name,
    description=agent_config.description,
    instruction=agent_config.instruction,
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
