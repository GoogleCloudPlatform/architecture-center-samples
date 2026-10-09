#!/usr/bin/env bash
# ==============================================================================
# mcp_toolbox_bridge.sh - Dynamic Stdio-to-HTTP Bridge for MCP Toolbox
# ==============================================================================
# Fetches fresh Google tokens on launch (Cloud Run Authorization header plus the
# Toolbox authService header google-auth_token) and bridges Antigravity/Gemini CLI's
# local stdio connection to the remote MCP Toolbox service.
# Run with --help for options and environment variables.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
    cat << 'USAGE'
Usage: mcp_toolbox_bridge.sh [OPTIONS] [URL]

Bridges a local stdio MCP connection (Gemini CLI, Antigravity) to the
deployed MCP Toolbox over Streamable HTTP, using `npx mcp-remote`. Sends two tokens:
  Authorization: Bearer <gcloud ID token>        Cloud Run transport auth
  google-auth_token: <ID token, aud = client ID>  Toolbox authService (fills :user_id)

Arguments:
  URL                       MCP server URL, e.g. https://<service>.run.app/mcp
                            (also: --url, MCP_SERVER_URL, or MCP_SERVER_SQL_URL in .env)

Options:
  --url URL                 Same as the positional URL
  --client-id ID            Google OAuth client ID (audience of google-auth_token)
                            (default: GOOGLE_CLIENT_ID from the environment or .env)
  --client-json FILE        OAuth client secret JSON; supplies the client ID and secret
                            for the browser login (default: searched in scripts/secrets/)
  --impersonate-sa EMAIL    Mint the token as this service account instead of signing in
  --auth-service NAME       authService name (header NAME_token); default google-auth,
                            or "none" if the server has no authService
  --redirect-uri URI        OAuth redirect URI registered on the client
                            (default http://ebs-mcp.com:8085/oauth2callback)
  --login                   Force a fresh browser sign-in (ignore the cached refresh token)
  --no-login                Never open the browser login (fall back to the gcloud token)
  --env-file FILE           .env to read (default: project root, script dir, then cwd)
  -h, --help                Show this help

Environment (each has a matching option): MCP_SERVER_URL, GOOGLE_CLIENT_ID,
MCP_AUTH_SERVICE, MCP_IMPERSONATE_SA, MCP_OAUTH_REDIRECT, MCP_ENV_FILE,
MCP_GOOGLE_LOGIN=no.

Token order for google-auth_token: service-account impersonation, gcloud --audiences,
browser login (scripts/google_login.py, refresh token cached in ~/.config/oracle-mcp-1p/),
then your default gcloud ID token (accepted only if its audience matches the server).
Tokens are fetched once at launch and last about an hour.
USAGE
}

ARG_URL=""
ARG_CLIENT_ID=""
CLIENT_JSON="${MCP_CLIENT_JSON:-}"
FORCE_LOGIN="no"
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --url|--client-id|--client-json|--impersonate-sa|--auth-service|--redirect-uri|--env-file)
            if [ $# -lt 2 ]; then echo "❌ [mcp_toolbox_bridge] $1 needs a value (see --help)." >&2; exit 1; fi
            case "$1" in
                --url) ARG_URL="$2" ;;
                --client-id) ARG_CLIENT_ID="$2" ;;
                --client-json) CLIENT_JSON="$2" ;;
                --impersonate-sa) export MCP_IMPERSONATE_SA="$2" ;;
                --auth-service) export MCP_AUTH_SERVICE="$2" ;;
                --redirect-uri) export MCP_OAUTH_REDIRECT="$2" ;;
                --env-file) export MCP_ENV_FILE="$2" ;;
            esac
            shift 2 ;;
        --login) FORCE_LOGIN="yes"; shift ;;
        --no-login) export MCP_GOOGLE_LOGIN=no; shift ;;
        -*) echo "❌ [mcp_toolbox_bridge] Unknown option: $1 (see --help)." >&2; exit 1 ;;
        *) if [ -n "${ARG_URL}" ]; then echo "❌ [mcp_toolbox_bridge] Unexpected argument: $1 (see --help)." >&2; exit 1; fi
           ARG_URL="$1"; shift ;;
    esac
done

# .env lookup: MCP_ENV_FILE > project root > next to this script > current directory.
# When none exists, ENV_FILE defaults to the project root (where a saved URL is written).
ENV_FILE="${MCP_ENV_FILE:-}"
if [ -z "${ENV_FILE}" ]; then
    for candidate in "${PROJECT_ROOT}/.env" "${SCRIPT_DIR}/.env" "${PWD}/.env"; do
        if [ -f "${candidate}" ]; then ENV_FILE="${candidate}"; break; fi
    done
fi
ENV_FILE="${ENV_FILE:-${PROJECT_ROOT}/.env}"

# Helper function to prompt user across tty or stdin
prompt_user() {
    local prompt_text="$1"
    local var_name="$2"
    if [ -c /dev/tty ] && [ -r /dev/tty ]; then
        read -rp "${prompt_text}" "${var_name}" < /dev/tty 2>/dev/null || return 1
    elif [ -t 0 ]; then
        read -rp "${prompt_text}" "${var_name}" || return 1
    else
        return 1
    fi
}

# 1. Resolve Service URL (Priority: CLI argument > MCP_SERVER_URL > .env)
SERVICE_URL="${ARG_URL:-${MCP_SERVER_URL:-}}"
if [ -z "${SERVICE_URL}" ] && [ -f "${ENV_FILE}" ]; then
    ENV_URL=$(grep -E '^[[:space:]]*(MCP_SERVER_SQL_URL|MCP_SERVER_URL)=' "${ENV_FILE}" | head -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true)
    if [ -n "${ENV_URL}" ]; then
        SERVICE_URL="${ENV_URL}"
    fi
fi

SAVE_TO_ENV="no"

# 2. If no MCP URL is provided or found in .env, prompt the user
if [ -z "${SERVICE_URL}" ]; then
    echo "⚠️ [mcp_toolbox_bridge] No MCP server URL provided or found in .env." >&2
    if prompt_user "Enter the MCP Toolbox Server URL (e.g. https://<service-url>/mcp): " SERVICE_URL; then
        SERVICE_URL="$(echo -n "${SERVICE_URL}" | tr -d '[:space:]')"
        if [ -n "${SERVICE_URL}" ]; then
            SAVE_TO_ENV="yes"
        fi
    fi
fi

if [ -z "${SERVICE_URL}" ]; then
    echo "❌ [mcp_toolbox_bridge] Error: No MCP server URL provided." >&2
    echo "Please set MCP_SERVER_SQL_URL in .env, export MCP_SERVER_URL, or pass it as an argument." >&2
    exit 1
fi

# 3. Check that the URL ends with "/mcp"
SERVICE_URL="${SERVICE_URL%/}"
if [[ "${SERVICE_URL}" != */mcp ]]; then
    PROMPT_HANDLED=false
    if prompt_user "⚠️ URL does not end with '/mcp': ${SERVICE_URL}
Would you like to append '/mcp'? [Y/n]: " APPEND_CHOICE; then
        PROMPT_HANDLED=true
        case "${APPEND_CHOICE}" in
            [nN]*)
                if prompt_user "Are you sure you want to proceed without '/mcp'? [y/N]: " CONFIRM_SURE; then
                    case "${CONFIRM_SURE}" in
                        [yY]*)
                            # User explicitly confirmed
                            ;;
                        *)
                            echo "❌ [mcp_toolbox_bridge] Aborted by user." >&2
                            exit 1
                            ;;
                    esac
                else
                    exit 1
                fi
                ;;
            *)
                SERVICE_URL="${SERVICE_URL}/mcp"
                ;;
        esac
    fi

    # Non-interactive fallback: append /mcp and log notice
    if [ "${PROMPT_HANDLED}" = false ]; then
        echo "ℹ️ [mcp_toolbox_bridge] Appending '/mcp' to service URL: ${SERVICE_URL}/mcp" >&2
        SERVICE_URL="${SERVICE_URL}/mcp"
    fi
fi

# 4. If URL was entered interactively, optionally save to the .env file
if [ "${SAVE_TO_ENV}" = "yes" ]; then
    if prompt_user "Would you like to save this URL to .env? [Y/n]: " SAVE_CHOICE; then
        case "${SAVE_CHOICE}" in
            [nN]*) ;;
            *)
                python3 - << EOF
import os
env_file = "${ENV_FILE}"
url = "${SERVICE_URL}"
lines = []
found = False
if os.path.exists(env_file):
    with open(env_file, "r") as f:
        for line in f:
            stripped = line.strip()
            if stripped.startswith("MCP_SERVER_SQL_URL=") or stripped.startswith("MCP_SERVER_URL="):
                if not found:
                    lines.append(f'MCP_SERVER_SQL_URL="{url}"\n')
                    found = True
            else:
                lines.append(line)
if not found:
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"
    lines.append(f'MCP_SERVER_SQL_URL="{url}"\n')
with open(env_file, "w") as f:
    f.writelines(lines)
EOF
                echo "✔ Saved MCP_SERVER_SQL_URL to ${ENV_FILE}" >&2
                ;;
        esac
    fi
fi

# 5. Acquire fresh Google tokens. The deployed Toolbox uses two layers of auth:
#      a) Cloud Run transport:  Authorization: Bearer <ID token>
#      b) Toolbox authService:  google-auth_token: <ID token, aud = OAuth client ID>
#    (b) is what fills :user_id for wrapped tools; the Toolbox returns 401 without it.
#    The client ID comes from --client-id / GOOGLE_CLIENT_ID / the .env file.
get_env_val() {
    [ -f "${ENV_FILE}" ] || return 0
    grep -E "^[[:space:]]*$1=" "${ENV_FILE}" | tail -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true
}

CLIENT_ID="${ARG_CLIENT_ID:-}"
if [ -z "${CLIENT_ID}" ] && [ -n "${CLIENT_JSON}" ]; then
    if [ ! -f "${CLIENT_JSON}" ]; then
        echo "❌ [mcp_toolbox_bridge] Client JSON not found: ${CLIENT_JSON}" >&2
        exit 1
    fi
    CLIENT_ID=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print((d.get('web') or d.get('installed') or {}).get('client_id',''))" "${CLIENT_JSON}" 2>/dev/null || true)
fi
CLIENT_ID="${CLIENT_ID:-${GOOGLE_CLIENT_ID:-$(get_env_val GOOGLE_CLIENT_ID)}}"
AUTH_SERVICE="${MCP_AUTH_SERVICE:-google-auth}"   # set to "none" if the server has no authService
IMPERSONATE_SA="${MCP_IMPERSONATE_SA:-}"          # optional: mint the audience-bound token as this service account

TOKEN=$(gcloud auth print-identity-token 2>/dev/null || gcloud auth print-access-token 2>/dev/null || true)
if [ -z "${TOKEN}" ]; then
    echo "❌ [mcp_toolbox_bridge] Error: Could not obtain Google token via 'gcloud auth'." >&2
    echo "Please ensure gcloud is logged in: gcloud auth login" >&2
    exit 1
fi

HEADER_ARGS=(--header "Authorization: Bearer ${TOKEN}")

if [ "${AUTH_SERVICE}" != "none" ]; then
    USER_TOKEN=""
    if [ -n "${CLIENT_ID}" ]; then
        if [ -n "${IMPERSONATE_SA}" ]; then
            USER_TOKEN=$(gcloud auth print-identity-token --impersonate-service-account="${IMPERSONATE_SA}" --audiences="${CLIENT_ID}" --include-email 2>/dev/null || true)
        else
            # --audiences only works for service-account credentials; user accounts fall through.
            USER_TOKEN=$(gcloud auth print-identity-token --audiences="${CLIENT_ID}" 2>/dev/null || true)
        fi
        if [ -z "${USER_TOKEN}" ] && [ "${MCP_GOOGLE_LOGIN:-yes}" != "no" ]; then
            # Sign in as the user with the OAuth client (browser once, then a cached refresh
            # token) so the ID token has aud = client ID and the user's own email.
            LOGIN_ARGS=(--client-id "${CLIENT_ID}")
            [ -n "${CLIENT_JSON}" ] && LOGIN_ARGS+=(--client-json "${CLIENT_JSON}")
            [ "${FORCE_LOGIN}" = "yes" ] && LOGIN_ARGS+=(--force-login)
            USER_TOKEN=$(python3 "${SCRIPT_DIR}/google_login.py" "${LOGIN_ARGS[@]}" || true)
        fi
    fi
    if [ -z "${USER_TOKEN}" ]; then
        # User credentials: the token's aud is gcloud's own client ID, so the Toolbox's
        # authServices.google-auth.clientId must equal that (local testing only).
        USER_TOKEN=$(gcloud auth print-identity-token 2>/dev/null || true)
        if [ -n "${CLIENT_ID}" ]; then
            echo "⚠️ [mcp_toolbox_bridge] Could not mint a token with audience ${CLIENT_ID}; sending your default gcloud ID token." >&2
            echo "   The server will reject it (401) unless its clientId matches that token's aud. Set MCP_IMPERSONATE_SA to a service account you can impersonate." >&2
        else
            echo "ℹ️ [mcp_toolbox_bridge] No GOOGLE_CLIENT_ID set; sending your default gcloud ID token as ${AUTH_SERVICE}_token." >&2
        fi
    fi
    if [ -n "${USER_TOKEN}" ]; then
        HEADER_ARGS+=(--header "${AUTH_SERVICE}_token: ${USER_TOKEN}")
    fi
fi

# 6. Exec mcp-remote to bridge stdio to remote Streamable HTTP
exec npx -y mcp-remote@latest "${SERVICE_URL}" "${HEADER_ARGS[@]}"
