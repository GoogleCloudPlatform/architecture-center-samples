from google.adk.plugins.logging_plugin import LoggingPlugin
from vertexai.preview.reasoning_engines import AdkApp
from vertexai import agent_engines
import vertexai
import os

# `root_agent` is the master orchestration agent defined in agent.py.
# It owns and delegates to the three sub-agents (EBS_Agent, EBS_API_Agent,
# EBS_Graphs_Agent) which are bundled in the agents/ subdirectory.
import sys
import os as _os
if __package__ is None:
    sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
    import agent
    import agent_config
else:
    from . import agent
    from . import agent_config

# Initialize Vertex AI from environment variables set at deploy time.
# Required: GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION.
vertexai.init(
    project=os.environ.get("GOOGLE_CLOUD_PROJECT"),
    location=os.environ.get("GOOGLE_CLOUD_LOCATION"),
)

# `adk_app` is discovered by `adk deploy agent_engine --adk_app=deploy`.
adk_app = AdkApp(
    agent=agent.root_agent,
    # Enables trace capture for request-level debugging / observability.
    enable_tracing=True,
    # Emits structured logs from agent execution to Cloud Logging.
    plugins=[LoggingPlugin()],
    # Specifies the agent engine configuration file.
    #agent_engine_config_file=os.environ.get("AGENT_ENGINE_CONFIG_FILE", "agent_engine_config.yaml"),

)