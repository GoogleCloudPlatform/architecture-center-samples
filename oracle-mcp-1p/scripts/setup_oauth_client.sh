#!/usr/bin/env bash
# ==============================================================================
# OAuth client setup helper (replaces create_oauth_app.sh).
#
# A Google Sign-in "Web application" OAuth client - the kind Gemini Enterprise
# needs - CANNOT be created from the command line:
#   * `gcloud iam oauth-clients` creates IAM (workforce-style) clients that do not
#     use accounts.google.com, so they do not work for this flow.
#   * The IAP OAuth Admin API that used to create web clients has been shut down.
# It must be created once in the Console. This script prints the steps, then
# validates the credentials JSON you download.
#
# Usage:
#   ./setup_oauth_client.sh                 # print instructions, validate any JSON found in scripts/
#   ./setup_oauth_client.sh FILE.json       # validate a specific file
#
# Exit status: 0 = valid, 1 = invalid or none found.
# Last stdout line on success: RESULT=<client_id>
# ==============================================================================
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

case "${1:-}" in -h|--help) sed -n '2,19p' "${BASH_SOURCE[0]}"; exit 0 ;; esac
require_cmd python3
resolve_project

REQUIRED_URI="https://vertexaisearch.cloud.google.com/oauth-redirect"
LEGACY_URI="https://vertexaisearch.cloud.google.com/static/oauth/oauth.html"

instructions() {
    cat >&2 <<EOT

Create the OAuth client in the Console (one-off):
  1. https://console.cloud.google.com/apis/credentials?project=${GOOGLE_CLOUD_PROJECT}
  2. Configure the OAuth consent screen first if prompted (Internal is fine for a single org).
  3. Create credentials -> OAuth client ID -> Application type: Web application.
  4. Authorized redirect URIs - add both:
       ${REQUIRED_URI}
       ${LEGACY_URI}
  5. Create, then 'Download JSON' and save it in ${LIB_DIR}/
     (the file name looks like client_secret_<id>.apps.googleusercontent.com.json).
  6. Re-run this script to validate it.
EOT
}

FILES=()
if [ -n "${1:-}" ]; then
    FILES=("$1")
else
    while IFS= read -r f; do [ -n "${f}" ] && FILES+=("${f}"); done < <(find_client_jsons)
fi

if [ ${#FILES[@]} -eq 0 ]; then
    warn "No usable OAuth client JSON found."
    instructions
    exit 1
fi

STATUS=1
for f in "${FILES[@]}"; do
    [ -f "${f}" ] || { warn "Not found: ${f}"; continue; }
    info "Checking ${f##*/}"
    CID="$(json_client_field "${f}" client_id)"
    URIS="$(json_client_field "${f}" redirect_uris)"
    PROBLEMS=0
    [ -n "${CID}" ] || { warn "  ✖ no client_id"; PROBLEMS=1; }
    [ -n "$(json_client_field "${f}" client_secret)" ] || { warn "  ✖ no client_secret"; PROBLEMS=1; }
    python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if 'web' in d else 1)" "${f}" 2>/dev/null \
        || { warn "  ✖ not a 'Web application' client (expected a top-level \"web\" key)"; PROBLEMS=1; }
    [[ "${CID}" == "${GOOGLE_CLOUD_PROJECT_NUMBER}-"* ]] \
        || warn "  ⚠ client belongs to project ${CID%%-*}, not ${GOOGLE_CLOUD_PROJECT_NUMBER} (${GOOGLE_CLOUD_PROJECT})"
    if grep -qF "${REQUIRED_URI}" <<<"${URIS}"; then info "  ✔ redirect URI registered: ${REQUIRED_URI}"
    else warn "  ✖ missing redirect URI: ${REQUIRED_URI}"; PROBLEMS=1; fi
    grep -qF "${LEGACY_URI}" <<<"${URIS}" || warn "  ⚠ legacy redirect URI not registered (optional): ${LEGACY_URI}"
    if [ ${PROBLEMS} -eq 0 ]; then
        info "  ✔ ${CID} looks good"
        echo "RESULT=${CID}"
        STATUS=0
    fi
done
[ ${STATUS} -eq 0 ] || instructions
exit ${STATUS}
