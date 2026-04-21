#!/bin/bash

# Colour codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Colour

# ==============================================================================
# Bash Script to Manage OAuth 2.0 Authorization Resources for Gemini Enterprise
#
# This script can create, patch (update), or delete an authorization resource,
# which allows ADK agents to use OAuth 2.0 to act on behalf of a user.
#
# Usage:
#   ./manage_oauth.sh create <auth-id>
#   ./manage_oauth.sh patch <auth-id>
#   ./manage_oauth.sh delete <auth-id>
#
# Prerequisites:
# 1. You have a Google Cloud Project.
# 2. You have created OAuth 2.0 credentials (Client ID and Secret) in Google Cloud.
# 3. You have added the following redirect URI to your OAuth client settings:
#    https://vertexaisearch.cloud.google.com/oauth-redirect
# 4. You have the `gcloud` CLI installed and authenticated.
# ==============================================================================

# --- Helper Functions ---

# Function to display usage instructions
usage() {
  echo "Usage: $0 {create|patch|delete|list} [auth-id]"
  echo "  create <auth-id> - Registers a new OAuth authorization resource."
  echo "  patch  <auth-id> - Updates the specified OAuth authorization resource."
  echo "  delete <auth-id> - Deletes the specified OAuth authorization resource."
  echo "  list             - Lists all OAuth authorization resources."
  exit 1
}

# --- Main Script ---

# Check if both arguments were provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: No command specified.${NC}"
  usage
fi
if [ "$1" != "list" ] && [ -z "$2" ]; then
  echo -e "${RED}Error: No AUTH_ID specified.${NC}"
  usage
fi

# Uncomment this line to print the curl commands instead of executing them (for debugging)
#CURL = "echo curl" 
# Use the actual curl command to execute the API calls
CURL="curl" 

# --- Configuration ---
# Replace the following placeholder values with your actual configuration details.

# Load configuration from .env if available, otherwise try a Google OAuth JSON credentials file.
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  # Search for a Google OAuth JSON credentials file (client_secret*.json or credentials.json).
  # You can also point to a specific file by setting OAUTH_CREDENTIALS_JSON before running.
  JSON_FILE=""
  if [ -n "${OAUTH_CREDENTIALS_JSON}" ] && [ -f "${OAUTH_CREDENTIALS_JSON}" ]; then
    JSON_FILE="${OAUTH_CREDENTIALS_JSON}"
  elif compgen -G "client_secret*.json" > /dev/null 2>&1; then
    JSON_FILE=$(ls client_secret*.json | head -1)
  elif [ -f "credentials.json" ]; then
    JSON_FILE="credentials.json"
  fi

  if [ -n "${JSON_FILE}" ]; then
    echo "ℹ️  .env not found. Loading credentials from ${JSON_FILE}..."
    if ! command -v jq &>/dev/null; then
      echo -e "${RED}Error: jq is required to parse the JSON credentials file but was not found. Install it with: brew install jq${NC}"
      exit 1
    fi
    export OAUTH_CLIENT_ID=$(jq -r '(.web // .installed).client_id // empty' "${JSON_FILE}")
    export GOOGLE_CLOUD_PROJECT_ID=$(jq -r '(.web // .installed).project_id // empty' "${JSON_FILE}")
    export OAUTH_AUTH_URI=$(jq -r '(.web // .installed).auth_uri // empty' "${JSON_FILE}")
    export OAUTH_TOKEN_URI=$(jq -r '(.web // .installed).token_uri // empty' "${JSON_FILE}")
    export OAUTH_CLIENT_SECRET=$(jq -r '(.web // .installed).client_secret // empty' "${JSON_FILE}")
  else
    echo -e "${YELLOW}Warning: No .env file or JSON credentials file found. Please set the required environment variables manually.${NC}"
  fi
fi


COMMAND="$1"

# AUTH_ID is taken from the second positional argument.
AUTH_ID="$2"

REQUIRES_OAUTH_CONFIG=0
if [ "$COMMAND" = "create" ] || [ "$COMMAND" = "patch" ]; then
  REQUIRES_OAUTH_CONFIG=1
fi

# Check if the expected variables are set for the selected command.
if [ -z "$GOOGLE_CLOUD_PROJECT" ] || ( [ "$COMMAND" != "list" ] && [ -z "$AUTH_ID" ] ); then
  echo -e "${RED}Error: One or more required environment variables are not set. Please set them in your environment or in the .env file.${NC}"
  echo "Required variables:"
  echo "  GOOGLE_CLOUD_PROJECT - Your Google Cloud Project ID (currently set to '${GOOGLE_CLOUD_PROJECT}')"
  echo "  AUTH_ID - A unique identifier for the authorization resource (e.g., 'my-whoami-auth') (currently set to '${AUTH_ID}')"
  exit 1
fi

if [ "$REQUIRES_OAUTH_CONFIG" -eq 1 ] && { [ -z "$OAUTH_CLIENT_ID" ] || [ -z "$OAUTH_CLIENT_SECRET" ] || [ -z "$OAUTH_AUTH_URI" ] || [ -z "$OAUTH_TOKEN_URI" ]; }; then
  echo -e "${RED}Error: OAuth environment variables are required for '${COMMAND}'.${NC}"
  echo "Required variables:"
  echo "  OAUTH_CLIENT_ID - The Client ID from your OAuth 2.0 credentials (currently set to '${OAUTH_CLIENT_ID}')"
  echo "  OAUTH_CLIENT_SECRET - The Client Secret from your OAuth 2.0 credentials (currently set to '${OAUTH_CLIENT_SECRET}')"
  echo "  OAUTH_AUTH_URI - The authorization URI (e.g., https://accounts.google.com/o/oauth2/v2/auth) (currently set to '${OAUTH_AUTH_URI}')"
  echo "  OAUTH_TOKEN_URI - The token URI (e.g., https://oauth2.googleapis.com/token) (currently set to '${OAUTH_TOKEN_URI}')"
  exit 1
fi

# The authorization URI that directs the user to a consent screen.
# This URI must include the scopes your agent needs, which should be URL-encoded.
#
# Example with multiple scopes (read-only access to Calendar and Drive):
# SCOPES_ENCODED="https://www.googleapis.com/auth/calendar.readonly%20https://www.googleapis.com/auth/drive.readonly"
# OAUTH_AUTH_URI="https://accounts.google.com/o/oauth2/v2/auth?client_id=${OAUTH_CLIENT_ID}&scope=${SCOPES_ENCODED}&include_granted_scopes=true&response_type=code&access_type=offline&prompt=consent"
#

#SCOPES is a space-separated list of scopes that your agent needs. You can modify this list based on your requirements.
if [ "$REQUIRES_OAUTH_CONFIG" -eq 1 ]; then
  SCOPES="https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"

  SCOPES_ENCODED=$(printf %s "$SCOPES" | jq -sRr @uri)
  echo $"ℹ️  Using the following scopes for OAuth authorization (URL-encoded): ${SCOPES_ENCODED}"

  OAUTH_AUTH_URI="https://accounts.google.com/o/oauth2/v2/auth?client_id=${OAUTH_CLIENT_ID}&scope=${SCOPES_ENCODED}&include_granted_scopes=true&response_type=code&access_type=offline&prompt=consent"

  # The token URI used to exchange an authorization code for an access token.
  OAUTH_TOKEN_URI="https://oauth2.googleapis.com/token"
fi

# --- End of Configuration ---

BASE_API_URL="https://discoveryengine.googleapis.com/v1alpha/projects/${GOOGLE_CLOUD_PROJECT}/locations/global/authorizations"
RESOURCE_URL="${BASE_API_URL}/${AUTH_ID}"

if [ "$REQUIRES_OAUTH_CONFIG" -eq 1 ]; then
  echo -e "${YELLOW}Auth URI: ${OAUTH_AUTH_URI}${NC}"
fi

# Main logic to handle the user's command
case "$COMMAND" in
  list)
    echo "▶️  Executing LIST"
    $CURL -X GET \
      -H "Authorization: Bearer $(gcloud auth print-access-token)" \
      -H "Content-Type: application/json" \
      -H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
      "${BASE_API_URL}" > /tmp/auth_list.json
    jq . /tmp/auth_list.json
    echo -e "\nTotal Authorizations: $(jq '.authorizations | length' /tmp/auth_list.json)"
    echo "Full response saved to /tmp/auth_list.json"  
    ;;

  create)
    echo "▶️  Executing CREATE for Auth ID: ${AUTH_ID}"
    $CURL -X POST \
      -H "Authorization: Bearer $(gcloud auth print-access-token)" \
      -H "Content-Type: application/json" \
      -H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
      -d @- \
      "${BASE_API_URL}?authorizationId=${AUTH_ID}" <<EOF
{
  "name": "projects/${GOOGLE_CLOUD_PROJECT}/locations/global/authorizations/${AUTH_ID}",
  "serverSideOauth2": {
    "clientId": "${OAUTH_CLIENT_ID}",
    "clientSecret": "${OAUTH_CLIENT_SECRET}",
    "authorizationUri": "${OAUTH_AUTH_URI}",
    "tokenUri": "${OAUTH_TOKEN_URI}"
  }
}
EOF
    ;;

  patch)
    echo "▶️  Executing PATCH for Auth ID: ${AUTH_ID}"
    # The 'updateMask' query parameter specifies which fields to update.
    $CURL -X PATCH \
      -H "Authorization: Bearer $(gcloud auth print-access-token)" \
      -H "Content-Type: application/json" \
      -H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
      -d @- \
      "${RESOURCE_URL}?updateMask=serverSideOauth2" <<EOF
{
  "serverSideOauth2": {
    "clientId": "${OAUTH_CLIENT_ID}",
    "clientSecret": "${OAUTH_CLIENT_SECRET}",
    "authorizationUri": "${OAUTH_AUTH_URI}",
    "tokenUri": "${OAUTH_TOKEN_URI}"
  }
}
EOF
    ;;

  delete)
    echo "▶️  Executing DELETE for Auth ID: ${AUTH_ID}"
    $CURL -X DELETE \
      -H "Authorization: Bearer $(gcloud auth print-access-token)" \
      -H "Content-Type: application/json" \
      -H "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
      "${RESOURCE_URL}"
    ;;

  *)
    echo -e "${RED}Error: Invalid command '${COMMAND}'.${NC}"
    usage
    ;;
esac

echo -e "\n\n✅  Script finished."
echo "If the command executed without errors, the '${COMMAND}' operation was successful."
