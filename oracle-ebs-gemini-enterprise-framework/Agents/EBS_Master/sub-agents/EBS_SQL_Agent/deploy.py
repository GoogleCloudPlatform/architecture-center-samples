from google.adk.plugins.logging_plugin import LoggingPlugin
from vertexai.preview.reasoning_engines import AdkApp
import vertexai
import os

# `root_agent` is defined in agent.py and contains the model, tools,
# instructions, and safety configuration used by Agent Engine.
from .agent import root_agent

# Initialize Vertex AI from environment variables expected by ADK deploy.
# Required at deploy/runtime: GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_LOCATION.
vertexai.init(
    project=os.environ.get("GOOGLE_CLOUD_PROJECT"),
    location=os.environ.get("GOOGLE_CLOUD_LOCATION")
  )

# `adk_app` is the exported application object discovered by:
# `--adk_app=deploy` during `adk deploy agent_engine`.
adk_app = AdkApp(agent=root_agent,
                 # Enables trace capture for request-level debugging/observability.
                 enable_tracing=True,
                 # Emits structured logs from agent execution to cloud logging.
                 plugins=[LoggingPlugin()])