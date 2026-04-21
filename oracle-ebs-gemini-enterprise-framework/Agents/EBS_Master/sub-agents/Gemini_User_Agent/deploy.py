from google.adk.plugins.logging_plugin import LoggingPlugin
from vertexai.preview.reasoning_engines import AdkApp
import vertexai
import os

# `root_agent` is the master orchestration agent defined in agent.py.
# It owns and delegates to the three sub-agents (EBS_Agent, EBS_API_Agent,
# EBS_Graphs_Agent) which are bundled in the agents/ subdirectory.
from .agent import root_agent

# Initialize Vertex AI from environment variables set at deploy time.
# Required: GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION.
vertexai.init(
    project=os.environ.get("GOOGLE_CLOUD_PROJECT"),
    location=os.environ.get("GOOGLE_CLOUD_LOCATION"),
)

# `adk_app` is discovered by `adk deploy agent_engine --adk_app=deploy`.
adk_app = AdkApp(
    agent=root_agent,
    # Enables trace capture for request-level debugging / observability.
    enable_tracing=True,
    # Emits structured logs from agent execution to Cloud Logging.
    plugins=[LoggingPlugin()],
)
