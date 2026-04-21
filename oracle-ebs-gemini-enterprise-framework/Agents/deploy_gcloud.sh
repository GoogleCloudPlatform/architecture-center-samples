#!/bin/bash

# deploy adk app to GCP
# set -x
# Comment out the set -x for now as it can cause issues with logging and readability of the output,
# especially when running gcloud commands which can have a lot of output.
# We can always re-enable it later if needed for debugging.
# We want to keep set -e to ensure the script exits immediately if any command fails,
# which is important for deployment scripts to prevent partial or inconsistent deployments.
set -e

# Helper: list all deployable agent directories
_list_agents() {
  ls -d agents/*/ 2>/dev/null | while read d; do printf "  %s\n" "$(basename $d)"; done
  [ -d "EBS_Master" ] && printf "  EBS_Master  (master/orchestrator)\n"
}

# Validate AGENT_NAME argument
if [ -z "$1" ]; then
  printf "Usage: $(basename $0) AGENT_NAME [AGENT_ENGINE_ID]\n" >&2
  printf "Available agents:\n" >&2
  _list_agents >&2
  exit 1
fi

AGENT_NAME="$1"

# Check that gcloud is installed
if ! command -v gcloud &>/dev/null; then
  printf "Error: 'gcloud' CLI is not installed or not in PATH.\n" >&2
  printf "Install it from: https://cloud.google.com/sdk/docs/install\n" >&2
  exit 1
fi

# Check that the user is logged into GCP
ACTIVE_ACCOUNT=$(gcloud auth list --filter="status:ACTIVE" --format="value(account)" 2>/dev/null)
if [ -z "$ACTIVE_ACCOUNT" ]; then
  printf "Error: No active GCP account found. Please run 'gcloud auth login' first.\n" >&2
  exit 1
fi
printf "Authenticated as: %s\n" "$ACTIVE_ACCOUNT"

# Check that adk is installed
if ! command -v adk &>/dev/null; then
  printf "Error: 'adk' CLI is not installed or not in PATH.\n" >&2
  printf "Install it with: pip install google-adk\n" >&2
  exit 1
fi

ENV_FILE="${AGENT_NAME}/.env"
# Make sure we have no reference to localhost in the .env file for GCP deployments

if [ -f "$ENV_FILE" ] && grep -q "localhost" "$ENV_FILE"; then
  printf "Error: .env file for '%s' contains 'localhost' references, which is not valid for GCP deployments.\n" "$AGENT_NAME" >&2 
  printf "Please update '%s' to use the appropriate service URLs for GCP.\n" "$ENV_FILE" >&2
  exit 1
fi

# make sure we have the env vars in place
# check if .env exists, if not create it with default values
if [ ! -f "$ENV_FILE" ]; then
  cat <<EOL > "$ENV_FILE"
# Google Cloud project ID
GOOGLE_CLOUD_PROJECT="your-project-id"
# Google Cloud location
GOOGLE_CLOUD_LOCATION="your-location"
# GOOGLE_CLOUD_PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
#MCP_SERVER_SQL_URL="https://mcp-oracle-sql-${GOOGLE_CLOUD_PROJECT_NUMBER}.${GOOGLE_CLOUD_LOCATION}.run.app/mcp"
#MCP_SERVER_SQL_URL="http://localhost:8080/mcp"
#MCP_SERVER_EBS_URL="https://mcp-oracle-ebs-${GOOGLE_CLOUD_PROJECT_NUMBER}.${GOOGLE_CLOUD_LOCATION}.run.app/mcp"
MCP_SERVER_EBS_URL="http://localhost:8088/mcp"
EOL
printf ".env file created with default values. Please update it with your Google Cloud configuration.\n" | tee logs/create_env.log
exit 1
fi  

# load env vars from .env
. ./"$ENV_FILE"

mkdir -p logs

# Resolve the agent directory — check EBS_Master first, then agents/
if [ -d "EBS_Master" ] && [ "${AGENT_NAME}" = "EBS_Master" ]; then
  AGENT_DIR="EBS_Master"
elif [ -d "agents/${AGENT_NAME}" ]; then
  AGENT_DIR="agents/${AGENT_NAME}"
else
  printf "Error: '%s' is not a valid agent directory.\n" "${AGENT_NAME}" >&2
  printf "Available agents:\n" >&2
  _list_agents >&2
  exit 1
fi

LOG_FILE="logs/${AGENT_NAME}_deploy.log"

AGENT_ENGINE_ID_ARG=""
if [ ! -z "$2" ]; then
  AGENT_ENGINE_ID="$2"
  AGENT_ENGINE_ID_ARG="--agent_engine_id=$AGENT_ENGINE_ID"
fi

# Refresh shared utility from canonical source into the agent package before deploying
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../utils/logging_config.py" "${AGENT_DIR}/logging_config.py"

printf "Deploying '%s' from '%s'...\n" "${AGENT_NAME}" "${AGENT_DIR}"

adk deploy agent_engine \
--display_name="${AGENT_NAME}" \
--project=${GOOGLE_CLOUD_PROJECT} \
--region=${GOOGLE_CLOUD_LOCATION} \
--adk_app=deploy \
--trace_to_cloud \
--otel_to_cloud \
--description="Deployment of ${AGENT_NAME} using adk CLI" \
$AGENT_ENGINE_ID_ARG \
${AGENT_DIR} 2>&1 | tee ${LOG_FILE} 2>&1

ADK_EXIT_CODE=${PIPESTATUS[0]}

if [ ${ADK_EXIT_CODE} -ne 0 ]; then
  printf "Error: Deployment of '%s' failed with exit code %d.\n" "${AGENT_NAME}" "${ADK_EXIT_CODE}" | tee -a ${LOG_FILE} >&2
  printf "See full logs at: %s\n" "${LOG_FILE}" >&2
  exit ${ADK_EXIT_CODE}
fi

printf "Deployment of '%s' completed successfully.\n" "${AGENT_NAME}" | tee -a ${LOG_FILE}
printf "Deployment logs saved to: %s\n" "${LOG_FILE}"

#curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://${GOOGLE_CLOUD_LOCATION}-aiplatform.googleapis.com/v1beta1/projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_LOCATION}/reasoningEngines/${AGENT_ENGINE_ID}"
