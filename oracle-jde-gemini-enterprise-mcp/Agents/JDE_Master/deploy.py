from google.adk.plugins.logging_plugin import LoggingPlugin
from vertexai.preview.reasoning_engines import AdkApp
import vertexai
import os
import sys

if not __package__:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import agent
    import agent_config
else:
    from . import agent
    from . import agent_config

vertexai.init(
    project=os.environ.get("GOOGLE_CLOUD_PROJECT", ""),
    location=os.environ.get("GOOGLE_CLOUD_LOCATION", "us-central1"),
)

adk_app = AdkApp(
    agent=agent.root_agent,
    enable_tracing=True,
    plugins=[LoggingPlugin()],
)
