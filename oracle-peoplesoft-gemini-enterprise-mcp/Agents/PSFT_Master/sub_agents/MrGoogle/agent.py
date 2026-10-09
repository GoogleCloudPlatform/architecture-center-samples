import logging
import os
import sys

from google.adk.agents.llm_agent import Agent
from google.adk.tools import google_search
from google.genai.types import (
    GenerateContentConfig,
    HarmBlockThreshold,
    HarmCategory,
    SafetySetting,
)

# gemini 3 endpoints are currently only accessible in global, so we need to set this env var for the agent to work properly.
os.environ.setdefault('GOOGLE_CLOUD_LOCATION', 'us-central1')

_BASE_DIR = os.path.dirname(os.path.realpath(__file__))
if _BASE_DIR not in sys.path:
    sys.path.append(_BASE_DIR)
_DEBUG = os.environ.get("DEBUG", "false").lower() == "true"

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG if _DEBUG else logging.INFO)

try:
    from . import agent_config
except ImportError:
    import agent_config

_FAILURE_CONTRACT = (
    "\n\nOutput contract: Always return valid JSON. "
    "On success return "
    "{\"ok\": true, \"source_agent\": \"MrGoogle\", \"message\": \"...\", "
    "\"data\": {\"summary\": \"...\", \"sources\": [{\"title\": \"...\", \"url\": \"...\"}]}}. "
    "On failure return "
    "{\"ok\": false, \"source_agent\": \"MrGoogle\", \"error_code\": \"...\", "
    "\"retryable\": true|false, \"message\": \"...\", \"data\": {...}}."
)

logger.info("Initialising MrGoogle with model %s", agent_config.model)

root_agent = Agent(
    name=agent_config.name,
    model=agent_config.model,
    description=agent_config.description,
    instruction=f"{agent_config.instruction}{_FAILURE_CONTRACT}",
    tools=[google_search],
    generate_content_config=GenerateContentConfig(
        temperature=0.2,
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
