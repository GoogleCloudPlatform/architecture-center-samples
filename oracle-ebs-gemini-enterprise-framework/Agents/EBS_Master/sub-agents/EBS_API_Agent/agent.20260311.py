from google.adk import Agent
from google.genai.types import (SafetySetting,
                                HarmCategory,
                                HarmBlockThreshold,
                                GenerateContentConfig)
from google.adk.tools.mcp_tool.mcp_toolset import McpToolset, StreamableHTTPConnectionParams
import sys
import os
import logging


# Configure logging — level controlled by the DEBUG environment variable.
# On Agent Engine, structured Cloud Logging is handled by LoggingPlugin in deploy.py.
_debug = os.environ.get("DEBUG", "false").lower() == "true"
logging.basicConfig(
    level=logging.DEBUG if _debug else logging.INFO,
    format="[%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)
# Set this logger's level directly so it works even when basicConfig is a no-op
# (i.e. when another module has already configured the root logger).
logger.setLevel(logging.DEBUG if _debug else logging.INFO)

# Compute once at module parse-time so it is always the real absolute directory
# of this file, regardless of cwd or how __file__ was set by the importer.
_BASE_DIR = os.path.dirname(os.path.realpath(__file__))

# Add the project root directory to Python path so we can import utility modules
# This allows importing from the utils directory two levels up from current file
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__),"..","..")))
sys.path.append(os.path.abspath(_BASE_DIR))

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
        


# TODO: For better organization, we could move the `load_instructions_file` function and any related 
# utilities to a separate module in the utils directory (e.g., `utils/file_loader.py`) and import
# TODO: sort out the agent configuration variables into a separate `agent_config.py` file. 
# This would keep the main agent code cleaner and more focused on agent logic, while utility functions 
# and configuration are modularized. For now, they are included directly in this file for simplicity 
# and to ensure all necessary code is present in one place for Agent Engine deployment.
# Importing config variables from separate file for cleaner organization


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
            name="EBS_API_Agent",
            model="gemini-2.5-flash",
            description="A helpful assistant for Oracle EBS API operations.",
            instruction="Interact with the Oracle EBS web services and return the results.",
        )
        logger.warning("Using fallback agent_config due to import error.")





# # Import utility function to load instruction files from text files
# try:
#     from utils.file_loader import load_instructions_file  # Helper to read instruction text files
# except ImportError as e:
#     logger.error(f"Error importing utils.file_loader: {e}", exc_info=True)
#     # Define a fallback if import fails
#     def load_instructions_file(path):
#         return f"Error: Could not load instructions from {path}"

# Configure the MCP server connection URLs via environment variables
# with defaults for local development.
MCP_SERVER_EBS_URL = os.environ.get("MCP_SERVER_EBS_URL", "http://localhost:8081/mcp")

def _error_envelope(
    *,
    error_code: str,
    message: str,
    retryable: bool,
    data=None,
) -> dict:
    return {
        "ok": False,
        "source_agent": "EBS_API_Agent",
        "error_code": error_code,
        "retryable": retryable,
        "message": message,
        "data": data,
    }


# McpToolset connects to the running MCP server at startup, fetches every tool's
# full JSON Schema, and registers each one as a properly-typed ADK tool.
# This replaces the manual MCPSessionManager + list_mcp_capabilities + call_mcp_tool
# pattern, which gave Gemini no argument schemas and required an extra round-trip
# per agent turn just to discover what tools exist.
_mcp_api_init_error = None
try:
    mcp_sql_toolset = McpToolset(
        connection_params=StreamableHTTPConnectionParams(
            url=MCP_SERVER_EBS_URL,
        )
    )
    logger.info(f"Initialized McpToolset with URL: {MCP_SERVER_EBS_URL}")
except Exception as e:
    logger.error(f"Failed to initialize API MCP toolset: {e}", exc_info=True)
    mcp_sql_toolset = None
    _mcp_api_init_error = str(e)


def api_backend_unavailable() -> dict:
    """Fallback tool when API MCP backend is unreachable during startup."""
    return _error_envelope(
        error_code="MCP_UNAVAILABLE",
        message=(
            "API MCP backend is unavailable. "
            f"Configured URL: {MCP_SERVER_EBS_URL}. "
            f"Startup error: {_mcp_api_init_error or 'unknown error'}"
        ),
        retryable=True,
        data={"mcp_url": MCP_SERVER_EBS_URL},
    )


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
    "On failure return `{\"ok\": false, \"source_agent\": \"EBS_API_Agent\", "
    "\"error_code\": \"...\", \"retryable\": true|false, \"message\": \"...\", "
    "\"data\": {...}}`."
)
logger.debug(f"Agent Instruction: {agent_config.instruction} \n\n{_failure_contract}")

_tools = [mcp_sql_toolset] if mcp_sql_toolset is not None else [api_backend_unavailable]
logger.debug(f"Tools available to agent: {[getattr(tool, 'tool_name_prefix', getattr(tool, '__name__', str(tool))) for tool in _tools]}")

ebs_api_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=f"{agent_config.description} ",
    # Combine behavioral instructions with semantic grounding so SQL generation
    # aligns with Oracle EBS schema entities and known join paths.
    # instruction=f"{agent_config.instruction} \n\n{semantic_context}",
    instruction=f"{agent_config.instruction}\n\n{_failure_contract}",
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
