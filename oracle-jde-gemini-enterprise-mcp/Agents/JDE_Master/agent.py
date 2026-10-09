from google.adk.agents.llm_agent import Agent
from google.adk.tools.agent_tool import AgentTool
from google.genai.types import (
    GenerateContentConfig,
    HarmBlockThreshold,
    HarmCategory,
    SafetySetting,
)
from google.adk.tools.tool_context import ToolContext

import sys
import os
import importlib
from datetime import datetime, timezone

os.environ.setdefault("GOOGLE_CLOUD_LOCATION", "us-central1")

try:
    from .logging_config import configure_logging
except ImportError:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from logging_config import configure_logging

logger = configure_logging(__name__)

_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, _BASE_DIR)

try:
    from . import agent_config
except ImportError:
    import agent_config

_sub_agent_status = {}
_USER_ID_STATE_KEY = "jde_master.user_id"
_USER_CONTEXT_STATE_KEY = "jde_master.user_context"


def _load_sub_agent(module_path: str, symbol_name: str, agent_name: str):
    enabled_agents = getattr(agent_config, "enabled_agents", None)
    if enabled_agents is not None and agent_name not in enabled_agents:
        _sub_agent_status[agent_name] = {"available": False, "error": "Disabled in config"}
        return None
    try:
        module = importlib.import_module(module_path)
        sub_agent = getattr(module, symbol_name)
        _sub_agent_status[agent_name] = {"available": True, "error": None}
        logger.info("Loaded sub-agent: %s", agent_name)
        return sub_agent
    except Exception as e:
        logger.error("Failed to load sub-agent %s: %s", agent_name, e, exc_info=True)
        _sub_agent_status[agent_name] = {"available": False, "error": str(e)}
        return None


jde_mfg_agent = _load_sub_agent("sub_agents.JDE_Mfg_Agent.agent", "root_agent", "JDE_Mfg_Agent")
jde_graphs_agent = _load_sub_agent("sub_agents.JDE_Graphs_Agent.agent", "root_agent", "JDE_Graphs_Agent")
mrgoogle_agent = _load_sub_agent("sub_agents.MrGoogle.agent", "root_agent", "MrGoogle")


def get_sub_agent_health() -> dict:
    """Return availability and startup errors for each sub-agent."""
    return {
        "ok": True,
        "source_agent": "JDE_Master",
        "sub_agents": _sub_agent_status,
    }


def _set_state_value(tool_context: ToolContext, key: str, value) -> bool:
    if tool_context is None:
        return False
    state = getattr(tool_context, "state", None)
    if state is None:
        return False
    try:
        state[key] = value
        return True
    except Exception:
        pass
    update_fn = getattr(state, "update", None)
    if callable(update_fn):
        try:
            update_fn({key: value})
            return True
        except Exception:
            pass
    set_fn = getattr(state, "set", None)
    if callable(set_fn):
        try:
            set_fn(key, value)
            return True
        except Exception:
            pass
    return False


def _build_safe_user_context(user_id: str) -> dict:
    return {
        "user_id": user_id,
        "email": user_id,
        "source": "session_or_oauth",
        "cached_at_utc": datetime.now(timezone.utc).isoformat(),
    }


def _extract_existing_session_user_id(tool_context: ToolContext):
    if tool_context is None:
        return None
    direct_user_id = getattr(tool_context, "user_id", None)
    if isinstance(direct_user_id, str) and "@" in direct_user_id.strip():
        return direct_user_id.strip()
    session = getattr(tool_context, "session", None)
    session_user_id = getattr(session, "user_id", None) if session is not None else None
    if isinstance(session_user_id, str) and "@" in session_user_id.strip():
        return session_user_id.strip()
    state = getattr(tool_context, "state", None)
    if state is not None:
        for key in ("user_id", "session_user_id", _USER_ID_STATE_KEY):
            try:
                value = state.get(key)
            except Exception:
                value = None
            if isinstance(value, str) and "@" in value.strip():
                return value.strip()
    return None


def get_session_user_context(tool_context: ToolContext):
    """Returns the cached, non-sensitive user context from ADK session state."""
    state = getattr(tool_context, "state", None)
    cached_context = None
    if state is not None:
        try:
            cached_context = state.get(_USER_CONTEXT_STATE_KEY)
        except Exception:
            pass
    if isinstance(cached_context, dict) and cached_context.get("user_id"):
        return cached_context
    cached_user_id = None
    if state is not None:
        try:
            cached_user_id = state.get(_USER_ID_STATE_KEY)
        except Exception:
            pass
    if cached_user_id:
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
        return safe_context
    email = os.environ.get("DEFAULT_JDE_USER_EMAIL", "").strip()
    if not email:
        raise RuntimeError(
            "Unable to determine user identity from session state and DEFAULT_JDE_USER_EMAIL is not configured."
        )
    safe_context = _build_safe_user_context(email)
    _set_state_value(tool_context, _USER_ID_STATE_KEY, email)
    _set_state_value(tool_context, _USER_CONTEXT_STATE_KEY, safe_context)
    return safe_context


def get_user_id(tool_context: ToolContext):
    """Retrieves the current user's USER_ID at the start of the conversation."""
    return get_session_user_context(tool_context)


_tools = [get_sub_agent_health]
if jde_mfg_agent is not None:
    _tools.append(AgentTool(agent=jde_mfg_agent))
if jde_graphs_agent is not None:
    _tools.append(AgentTool(agent=jde_graphs_agent))
if mrgoogle_agent is not None:
    _tools.append(AgentTool(agent=mrgoogle_agent))
_tools.append(get_user_id)
_tools.append(get_session_user_context)

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
