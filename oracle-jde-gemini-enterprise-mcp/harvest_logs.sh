#!/bin/bash

# --- Script to fetch logs from Agent Engine or Cloud Run ---
#
# Description:
# This script fetches logs from Google Cloud Logging using gcloud CLI.
# It supports:
# - Vertex AI Agent Engine (ReasoningEngine)
# - Cloud Run
#
# Existing Agent Engine usage is preserved for backward compatibility.
#
# Prerequisites:
# - Google Cloud SDK (`gcloud`) must be installed and authenticated.
#   (Run `gcloud auth login` and `gcloud config set project <PROJECT_ID>`)
# - You must have the necessary IAM permissions to read logs (e.g., roles/logging.viewer).

# --- Usage function ---
usage() {
  echo "Usage: $0 -p <PROJECT_ID> [TARGET OPTIONS] [OPTIONS]"
  echo ""
  echo "Required:"
  echo "  -p <PROJECT_ID>   Your Google Cloud project ID."
  echo "                    If omitted, defaults to env GOOGLE_CLOUD_PROJECT when set."
  echo ""
  echo "Target selection (default: agent):"
  echo "  -k <TARGET>       Target type: 'agent' or 'cloudrun'."
  echo ""
  echo "Agent Engine target options:"
  echo "  -r <AGENT_ID>     Deployed Reasoning Engine ID. Required when -k agent."
  echo ""
  echo "Cloud Run target options:"
  echo "  -c <SERVICE>      Cloud Run service name. Required when -k cloudrun."
  echo "  -i <REVISION>     Optional Cloud Run revision name."
  echo "  -l <REGION>       Optional Cloud Run region (matches resource.labels.location)."
  echo ""
  echo "Options:"
  echo "  -s <SEVERITY>     Filter by log severity (e.g., INFO, WARNING, ERROR, DEBUG)."
  echo "  -t <FRESHNESS>    Filter by time freshness (e.g., '1h', '30m', '1d')."
  echo "  -n <STREAM>       Filter by stream."
  echo "                    agent: stdout | stderr"
  echo "                    cloudrun: stdout | stderr | requests"
  echo "  -m <LIMIT>        Maximum number of log entries to return (default: 50)."
  echo "  -o <ORDER>        Sort order: desc or asc (default: desc)."
  echo "  -v                Enable verbose output (show command details; default: quiet)."
  echo "  -h                Display this help message."
  echo ""
  echo "Example:"
  echo "  # Agent Engine: get ERROR logs from the last hour"
  echo "  $0 -p my-gcp-project -k agent -r 1234567890 -s ERROR -t 1h"
  echo ""
  echo "  # Cloud Run: get stderr logs from service in the last 10 minutes"
  echo "  $0 -p my-gcp-project -k cloudrun -c my-service -n stderr -t 10m"
  exit 1
}

# --- Parse command-line arguments ---
# Reset OPTIND to ensure getopts works if the script is sourced
OPTIND=1
TARGET="agent"
PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-}"
AGENT_ID=""
SERVICE_NAME=""
REVISION_NAME=""
REGION=""
SEVERITY=""
FRESHNESS=""
LOG_STREAM=""
LIMIT="50"
ORDER="desc"
VERBOSE=0

while getopts ":p:k:r:c:i:l:s:t:n:m:o:vh" opt; do
  case ${opt} in
    p )
      PROJECT_ID=$OPTARG
      ;;
    k )
      TARGET=$OPTARG
      ;;
    r )
      AGENT_ID=$OPTARG
      ;;
    c )
      SERVICE_NAME=$OPTARG
      ;;
    i )
      REVISION_NAME=$OPTARG
      ;;
    l )
      REGION=$OPTARG
      ;;
    s )
      SEVERITY=$OPTARG
      ;;
    t )
      FRESHNESS=$OPTARG
      ;;
    n )
      LOG_STREAM=$OPTARG
      ;;
    m )
      LIMIT=$OPTARG
      ;;
    o )
      ORDER=$OPTARG
      ;;
    v )
      VERBOSE=1
      ;;
    h )
      usage
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid Option: -$OPTARG requires an argument." 1>&2
      usage
      ;;
  esac
done

# --- Validate required arguments ---
if [ -z "${PROJECT_ID}" ]; then
  echo "Error: Project ID is required. Provide -p or set GOOGLE_CLOUD_PROJECT."
  usage
fi

if [ "${TARGET}" != "agent" ] && [ "${TARGET}" != "cloudrun" ]; then
  echo "Error: Invalid target '-k ${TARGET}'. Use 'agent' or 'cloudrun'."
  exit 1
fi

if [ "${TARGET}" = "agent" ] && [ -z "${AGENT_ID}" ]; then
  echo "Error: Agent ID (-r) is required when -k agent."
  usage
fi

if [ "${TARGET}" = "cloudrun" ] && [ -z "${SERVICE_NAME}" ]; then
  echo "Error: Cloud Run service name (-c) is required when -k cloudrun."
  usage
fi

if ! [[ "${LIMIT}" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid limit '-m ${LIMIT}'. Use a positive integer."
  exit 1
fi

if [ "${ORDER}" != "desc" ] && [ "${ORDER}" != "asc" ]; then
  echo "Error: Invalid order '-o ${ORDER}'. Use 'desc' or 'asc'."
  exit 1
fi

# --- Construct the filter string ---
if [ "${TARGET}" = "agent" ]; then
  FILTER="resource.type=\"aiplatform.googleapis.com/ReasoningEngine\" AND resource.labels.reasoning_engine_id=\"${AGENT_ID}\""
else
  FILTER="resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${SERVICE_NAME}\""
  if [ -n "${REVISION_NAME}" ]; then
    FILTER+=" AND resource.labels.revision_name=\"${REVISION_NAME}\""
  fi
  if [ -n "${REGION}" ]; then
    FILTER+=" AND resource.labels.location=\"${REGION}\""
  fi
fi

if [ -n "${SEVERITY}" ]; then
  FILTER+=" AND severity>=${SEVERITY}"
fi

if [ -n "${LOG_STREAM}" ]; then
  if [ "${TARGET}" = "agent" ]; then
    if [ "${LOG_STREAM}" != "stdout" ] && [ "${LOG_STREAM}" != "stderr" ]; then
      echo "Error: Invalid stream name '-n ${LOG_STREAM}' for target=agent. Use 'stdout' or 'stderr'."
      exit 1
    fi
    LOG_NAME_SUFFIX="aiplatform.googleapis.com%2Freasoning_engine_${LOG_STREAM}"
  else
    if [ "${LOG_STREAM}" != "stdout" ] && [ "${LOG_STREAM}" != "stderr" ] && [ "${LOG_STREAM}" != "requests" ]; then
      echo "Error: Invalid stream name '-n ${LOG_STREAM}' for target=cloudrun. Use 'stdout', 'stderr', or 'requests'."
      exit 1
    fi
    LOG_NAME_SUFFIX="run.googleapis.com%2F${LOG_STREAM}"
  fi

  FILTER+=" AND logName=\"projects/${PROJECT_ID}/logs/${LOG_NAME_SUFFIX}\""
fi


# --- Construct and execute the gcloud command ---
if [ ${VERBOSE} -eq 1 ]; then
  echo "Constructing gcloud command..."
  echo "---------------------------------"
fi

# Use an array to safely handle arguments with spaces or special characters
GCLOUD_COMMAND=("gcloud" "logging" "read" "${FILTER}" "--project=${PROJECT_ID}" "--limit=${LIMIT}" "--order=${ORDER}")

if [ -n "${FRESHNESS}" ]; then
  GCLOUD_COMMAND+=("--freshness=${FRESHNESS}")
fi

if [ ${VERBOSE} -eq 1 ]; then
  echo "Executing command:"
  # Use "${GCLOUD_COMMAND[@]}" to correctly expand the array with proper quoting
  echo "${GCLOUD_COMMAND[@]}"
  echo "---------------------------------"
fi

# Execute the final command
"${GCLOUD_COMMAND[@]}"
