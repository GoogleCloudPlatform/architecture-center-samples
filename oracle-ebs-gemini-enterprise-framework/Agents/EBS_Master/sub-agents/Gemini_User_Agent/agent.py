from google.adk import Agent
from google.genai.types import (SafetySetting,
                                HarmCategory,
                                HarmBlockThreshold,
                                GenerateContentConfig)
# from google.adk.tools import ToolContext
import google.oauth2.credentials as credentials
from google.oauth2.id_token import verify_oauth2_token
# from google.oauth2 import _GOOGLE_OAUTH2_TOKEN_INFO_ENDPOINT as TOKEN_INFO_ENDPOINT

from google.adk.tools import FunctionTool

# from google.adk import agents
# from google.adk import events
# from google.adk import graphics
# from google.adk import messages
# from google.adk.boot import run
# from google.adk.runtime import auth

from google.adk import auth

import sys
import json
import os
import logging
import urllib.request
import urllib.parse
import urllib.error

# from google.adk.tools import tool
from google.adk.tools.tool_context import ToolContext

# Configure logging — level controlled by the DEBUG environment variable.
# On Agent Engine, structured Cloud Logging is handled by LoggingPlugin in deploy.py.
_debug = os.environ.get("DEBUG", "false").lower() == "true"
logging.basicConfig(
    level=logging.DEBUG if _debug else logging.INFO,
    format="[%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("EBS_User_Agent")
# Set this logger's level directly so it works even when basicConfig is a no-op
# (i.e. when another module has already configured the root logger).
logger.setLevel(logging.DEBUG if _debug else logging.INFO)

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

# When deploying to Agent Engine, all code must be self-contained within the agent directory, 
# so we include the agent_config.py file in this directory which contains configuration variables for the agent.
if not os.path.exists(os.path.join(_BASE_DIR, "agent_config.py")):
    logger.warning("agent_config.py not found in agent directory. Creating a default one.")
    with open(os.path.join(_BASE_DIR, "agent_config.py"), "w") as f:
        f.write("""name='EBS_Agent'
model='gemini-2.5-flash'
instruction='Connect to the APPS_EBS database. ' \
'The agent can use tools to query an Oracle EBS database and retrieve relevant information to answer user questions. ' \
'The agent should understand the structure of the EBS database and be able to write SQL queries to retrieve the necessary data. ' \
'The agent should also be able to handle follow-up questions and provide accurate and concise answers based on the retrieved data.'
description='A helpful assistant for user questions about Oracle EBS data.'
""")
        logger.warning("Default agent_config.py created.")
        



# Try relative import first (works when deployed as a package via ADK);
# fall back to absolute import for direct script execution locally.
try:
    from . import agent_config
except ImportError:
    # Load directly from _BASE_DIR using importlib so we never accidentally
    # pick up another agent's agent_config from sys.path.
    try:
        import importlib.util as _ilu
        _spec = _ilu.spec_from_file_location(
            "agent_config", os.path.join(_BASE_DIR, "agent_config.py")
        )
        agent_config = _ilu.module_from_spec(_spec)  # type: ignore[no-redef]
        _spec.loader.exec_module(agent_config)  # type: ignore[union-attr]
        logger.debug("Loaded agent_config via importlib from %s", _BASE_DIR)
    except Exception as e:
        logger.error(f"Error importing agent_config: {e}", exc_info=True)
        import types
        agent_config = types.SimpleNamespace(  # type: ignore[assignment]
            name="EBS_User_Agent",
            model="gemini-2.5-flash",
            description="A helpful assistant for Oracle EBS SQL data questions.",
            instruction="Query the Oracle EBS database via SQL and return the results.",
        )
        logger.warning("Using fallback agent_config due to import error.")

def _error_envelope(
    *,
    error_code: str,
    message: str,
    retryable: bool,
    data=None,
) -> dict:
    return {
        "ok": False,
        "source_agent": "EBS_User_Agent",
        "error_code": error_code,
        "retryable": retryable,
        "message": message,
        "data": data,
    }


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
    "On failure return `{\"ok\": false, \"source_agent\": \"EBS_User_Agent\", "
    "\"error_code\": \"...\", \"retryable\": true|false, \"message\": \"...\", "
    "\"data\": {...}}`."
)
logger.debug(f"Agent Instruction: {agent_config.instruction} {_failure_contract}")


# 1. Define your wrapper with a clear docstring.
# The LLM uses this docstring to know WHEN to call this tool.
def check_state(tool_context: ToolContext):
    """
    Retrieves the current user's ID from the session context.
    This tool accesses the session information available in the ToolContext to extract the user ID of the caller.
        The session context is typically populated by the authentication mechanism in place (e.g., via an AuthConfig that handles user login and session management).
    Returns:        A string containing the user ID of the caller, or an appropriate message if the user ID cannot be retrieved.
    Note:        The exact structure of the session context and how the user ID is stored may depend on the authentication implementation and the environment in which the agent is running. 
    This tool assumes that the session context includes a user_id property that can be accessed to identify the caller.
    """
    # Access the session object from the context
    # session = tool_context.session

    state_dict = tool_context.state.to_dict()
    attributes = dir(tool_context.state)
    attrs = []
    for attr in attributes:
        attrs.append(f'{attr}: {tool_context.state.get(attr)}')
    dict_attrs = []
    for k, v in state_dict.items():
        dict_attrs.append(f'{k}: {v}')

    auth_key = next((k for k in tool_context.state.to_dict().keys() if k.startswith(agent_config.auth_id)), None)
    
    # google.adk.sessions.state.State object has a get() method 
    # that can be used to retrieve the value of a specific key from the state.

    user_token = tool_context.state.get(auth_key) if auth_key else "No auth key found in state"

    # Look up token info from Google's tokeninfo endpoint
    # TODO: isn't this already done by the ADK's auth system? 
    # Can we get this info from the session instead of making a separate HTTP request?
    token_info = None
    if user_token and user_token != "No auth key found in state":
        try:
            params = urllib.parse.urlencode({"access_token": user_token})
            url = f"{credentials._GOOGLE_OAUTH2_TOKEN_INFO_ENDPOINT}?{params}"
            with urllib.request.urlopen(url, timeout=10) as response:  
                token_info = json.loads(response.read().decode())
            logger.debug(f"Token info retrieved: {token_info}")
        except urllib.error.HTTPError as e:
            token_info = {"error": f"HTTP {e.code}: {e.reason}", "body": e.read().decode()}
            logger.warning(f"tokeninfo lookup failed: {token_info}")
        except Exception as e:
            token_info = {"error": str(e)}
            logger.error(f"Unexpected error during tokeninfo lookup: {e}", exc_info=True)

    return [auth_key, user_token, token_info, str(tool_context.state), '\n'.join(attrs), '\n'.join(dict_attrs), str(state_dict)]

_tools = [check_state]
logger.debug(f"Tools available to agent: {[getattr(tool, 'tool_name_prefix', getattr(tool, '__name__', str(tool))) for tool in _tools]}")

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=f"{agent_config.description} ",
    instruction=f"{agent_config.instruction} {_failure_contract}",
    tools=_tools,
    generate_content_config=GenerateContentConfig(
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
