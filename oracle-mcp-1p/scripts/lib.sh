#!/usr/bin/env bash
# ==============================================================================
# Shared helpers for the scripts in this directory. Source it; do not execute.
#
# Conventions:
#   * Human-readable progress goes to STDERR.
#   * A script's machine-readable result is the LAST line on STDOUT: RESULT=<value>
#   * Values already present in the environment win over .env, so a caller
#     can pin the project it is working against.
# ==============================================================================

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/.." && pwd)"
ENV_FILE="${DEPLOY_ENV_FILE:-${REPO_ROOT}/.env}"

RED=$'\033[0;31m'; YELLOW=$'\033[0;33m'; NC=$'\033[0m'

# Select a system's env file. Call it before resolve_project so the project, project number and client ID
# come from <system>/.env (or <system>/.env.<variant>), never from the repo-root .env.
#   use_system_env SYSTEM [VARIANT]    sets SYSTEM, SYSTEM_SHORT, VARIANT and ENV_FILE
use_system_env() {
    SYSTEM="$(printf '%s' "${1:-}" | tr 'A-Z' 'a-z')"
    VARIANT="$(printf '%s' "${2:-}" | tr 'A-Z' 'a-z')"
    case "${SYSTEM}" in
        ebs)           SYSTEM_SHORT="ebs" ;;
        peoplesoft|ps) SYSTEM="peoplesoft"; SYSTEM_SHORT="ps" ;;
        jde)           SYSTEM_SHORT="jde" ;;
        *) die "--system {ebs|peoplesoft|jde} is required (got '${1:-}')." ;;
    esac
    [[ -z "${VARIANT}" || "${VARIANT}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "--variant '${VARIANT}': use lowercase letters, digits and single hyphens."
    ENV_FILE="${REPO_ROOT}/${SYSTEM}/.env${VARIANT:+.${VARIANT}}"
    [ -f "${ENV_FILE}" ] || die "${ENV_FILE} not found. Create it: ./scripts/deploy_mcp_server.sh --system ${SYSTEM}${VARIANT:+ --variant ${VARIANT}} --init-env"
}

# With an explicit --system the env file is authoritative: its values replace whatever the shell exports
# (an ambient GOOGLE_CLOUD_PROJECT must not send an ebs command to another project).
#   env_file_wins KEY...
env_file_wins() {
    local k v
    for k in "$@"; do
        v="$(env_value "${k}")"
        [ -z "${v}" ] || export "${k}=${v}"
    done
}

# OAuth client JSON files for the selected system first (scripts/secrets/<system>*.json), then any other
client_jsons_for_system() {
    local f seen=" "
    shopt -s nullglob
    for f in "${LIB_DIR}/secrets/${SYSTEM_SHORT}"*.json "${LIB_DIR}/secrets/${SYSTEM}"*.json; do
        [[ "${seen}" == *" ${f} "* ]] && continue
        seen+="${f} "; [ -s "${f}" ] && echo "${f}"
    done
    shopt -u nullglob
    find_client_jsons | while IFS= read -r f; do [[ "${seen}" == *" ${f} "* ]] || echo "${f}"; done
}

info() { echo "$*" >&2; }
warn() { echo "${YELLOW}$*${NC}" >&2; }
die()  { echo "${RED}Error: $*${NC}" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' is required but was not found in PATH.${2:+ $2}"
}

# Read KEY from the .env file (no sourcing, no eval). Prints nothing if absent/blank.
env_value() {
    [ -f "${ENV_FILE}" ] || return 0
    grep -E "^[[:space:]]*$1=" "${ENV_FILE}" | tail -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true
}

# Export KEY from .env unless it is already set in the environment.
load_env_var() {
    local key="$1" current="${!1:-}"
    [ -n "${current}" ] && return 0
    local v; v="$(env_value "${key}")"
    [ -n "${v}" ] && export "${key}=${v}"
    return 0
}

# Resolve GOOGLE_CLOUD_PROJECT / GOOGLE_CLOUD_PROJECT_NUMBER: environment > .env > gcloud.
# Never falls back to a hardcoded project.
resolve_project() {
    load_env_var GOOGLE_CLOUD_PROJECT
    load_env_var GOOGLE_CLOUD_PROJECT_NUMBER
    if [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
        GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
    fi
    [ -n "${GOOGLE_CLOUD_PROJECT:-}" ] || die "No project. Set GOOGLE_CLOUD_PROJECT in ${ENV_FILE} or run: gcloud config set project <ID>"
    if [ -z "${GOOGLE_CLOUD_PROJECT_NUMBER:-}" ]; then
        GOOGLE_CLOUD_PROJECT_NUMBER="$(gcloud projects describe "${GOOGLE_CLOUD_PROJECT}" --format='value(projectNumber)' 2>/dev/null || true)"
    fi
    [ -n "${GOOGLE_CLOUD_PROJECT_NUMBER:-}" ] || die "Could not determine the project number for '${GOOGLE_CLOUD_PROJECT}'."
    export GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_PROJECT_NUMBER
}

# Downloaded OAuth client JSON files usable for creating an authorization.
# Searches scripts/ and the repo root. Prints one path per line.
json_client_field() {
    python3 - "$1" "$2" <<'PY' 2>/dev/null || true
import json, sys
d = json.load(open(sys.argv[1]))
c = d.get("web") or d.get("installed") or {}
v = c.get(sys.argv[2], "")
print(",".join(v) if isinstance(v, list) else v)
PY
}
find_client_jsons() {
    local f
    shopt -s nullglob
    for f in "${LIB_DIR}"/secrets/*.json "${LIB_DIR}"/client_secret*.json "${REPO_ROOT}"/client_secret*.json; do
        [ -s "${f}" ] || continue
        [ -n "$(json_client_field "${f}" client_id)" ] && [ -n "$(json_client_field "${f}" client_secret)" ] && echo "${f}"
    done
    shopt -u nullglob
}

# Call a Discovery Engine endpoint. Usage: de_curl <curl args...> ; prints body to stdout.
access_token() { gcloud auth print-access-token 2>/dev/null || die "gcloud is not authenticated. Run: gcloud auth login"; }
