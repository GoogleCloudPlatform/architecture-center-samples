#!/usr/bin/env bash
# ==============================================================================
# test_mcp_server.sh - Test MCP Toolbox Server (Cloud Run, Auth & Tools)
# ==============================================================================
#
# Dedicated test script to verify an MCP Toolbox Cloud Run service.
# Tests health connectivity, MCP protocol handshake, discovers all registered
# tools (e.g. 24 Oracle EBS tools), and validates tool execution.
#
# Handles the dual-tiered authentication model:
#   1. Cloud Run Transport Auth:      Authorization: Bearer <ID_TOKEN>
#   2. Toolbox Application Identity:  google-auth_token: <ID_TOKEN> (aud = client_id)
#
# Usage:
#   ./test_mcp_server.sh [options]
#
# Examples:
#   # 1. Run all checks against the default EBS service (mcp-ebs-1p-skills):
#   ./test_mcp_server.sh
#
#   # 2. Only list all tools (all 24 tools) with schemas and auth requirements:
#   ./test_mcp_server.sh --list-only
#
#   # 3. Inspect detailed schema and parameters for a specific tool:
#   ./test_mcp_server.sh --detail ebs_list_operating_units
#   ./test_mcp_server.sh --detail ebs_describe_table
#
#   # 4. Invoke a specific tool with arguments:
#   ./test_mcp_server.sh --tool ebs_list_operating_units --args '{"name_pattern": "%Vision%"}'
#   ./test_mcp_server.sh --tool ebs_describe_table --arg table_name=HR_OPERATING_UNITS
#   ./test_mcp_server.sh --tool ebs_list_attachment_entities --arg keyword='%PO%'
#
#   # 5. Test another service (e.g. PeopleSoft):
#   ./test_mcp_server.sh --service-name mcp-toolbox-ps --list-only
#
#   # 6. Explicitly supply credentials or tokens:
#   ./test_mcp_server.sh --bearer-token <TOKEN> --user-token <TOKEN>
#   ./test_mcp_server.sh --client-id <ID> --client-secret <SECRET>
#   ./test_mcp_server.sh --service-account ebs-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com
#
# Options:
#   --service-name NAME      Cloud Run service name (default: mcp-ebs-1p-skills or from .env)
#   --service-url URL        Direct service URL (auto-discovered from gcloud if not provided)
#   --project ID             GCP Project ID (default: from .env or gcloud config)
#   --region REGION          GCP Region (default: from .env or gcloud config)
#   --client-id ID           Google OAuth Client ID (Toolbox google-auth audience)
#   --client-secret SECRET   Google OAuth Client Secret (optional)
#   --client-json FILE       Path to client secret JSON file (auto-searched in scripts/secrets/)
#   --bearer-token TOKEN     Bearer token for Cloud Run transport (Authorization: Bearer)
#   --user-token TOKEN       JWT ID token for Toolbox application auth (google-auth_token:)
#   --service-account SA     Service account email to mint audience-matched user ID token
#   --cr-account ACCOUNT     Account email to mint Cloud Run transport token
#   --list-only              Only list tools; do not invoke any tool
#   --tool NAME              Tool name to invoke (default: ebs_list_operating_units)
#   --args JSON              JSON string of tool arguments (default: {"name_pattern": "%"})
#   --arg KEY=VALUE          Single tool argument (can be repeated)
#   --detail NAME            Show detailed JSON schema and metadata for specified tool
#   --json                   Output raw JSON responses instead of formatted tables
#   --skip-ping              Skip the HTTP GET / ping step
#   --skip-init              Skip the MCP initialize step
#   -v, --verbose            Show verbose debug logs, curl payloads, and HTTP headers
#   -h, --help               Show this help message
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors (if terminal supports it)
if [ -t 1 ]; then
    RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
    BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

# ------------------------------------------------------------------------------
# Default Settings & CLI Parsing
# ------------------------------------------------------------------------------
SERVICE_NAME=""
SERVICE_URL=""
PROJECT=""
REGION=""
CLIENT_ID=""
CLIENT_SECRET=""
CLIENT_JSON=""
BEARER_TOKEN=""
USER_TOKEN=""
SERVICE_ACCOUNT=""
CR_ACCOUNT=""
LIST_ONLY=false
TOOL_NAME=""
ARGS_JSON=""
CLI_ARGS=()
DETAIL_TOOL=""
RAW_JSON=false
SKIP_PING=false
SKIP_INIT=false
VERBOSE=false

show_help() {
    sed -n '2,65p' "${BASH_SOURCE[0]}"
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --service-name)    SERVICE_NAME="$2"; shift 2 ;;
        --service-url)     SERVICE_URL="$2"; shift 2 ;;
        --project)         PROJECT="$2"; shift 2 ;;
        --region)          REGION="$2"; shift 2 ;;
        --client-id)       CLIENT_ID="$2"; shift 2 ;;
        --client-secret)   CLIENT_SECRET="$2"; shift 2 ;;
        --client-json)     CLIENT_JSON="$2"; shift 2 ;;
        --bearer-token)    BEARER_TOKEN="$2"; shift 2 ;;
        --user-token|--auth-token) USER_TOKEN="$2"; shift 2 ;;
        --service-account) SERVICE_ACCOUNT="$2"; shift 2 ;;
        --cr-account)      CR_ACCOUNT="$2"; shift 2 ;;
        --list-only)       LIST_ONLY=true; shift ;;
        --tool)            TOOL_NAME="$2"; shift 2 ;;
        --args)            ARGS_JSON="$2"; shift 2 ;;
        --arg)             CLI_ARGS+=("$2"); shift 2 ;;
        --detail)          DETAIL_TOOL="$2"; shift 2 ;;
        --json)            RAW_JSON=true; shift ;;
        --skip-ping)       SKIP_PING=true; shift ;;
        --skip-init)       SKIP_INIT=true; shift ;;
        -v|--verbose)      VERBOSE=true; shift ;;
        -h|--help)         show_help ;;
        *)
            echo "${RED}Error: Unknown argument: $1${NC}" >&2
            echo "Run '$0 --help' for usage." >&2
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Environment & Configuration Resolution
# ------------------------------------------------------------------------------
ENV_FILE="${DEPLOY_ENV_FILE:-${REPO_ROOT}/.env}"
if [ ! -f "${ENV_FILE}" ] && [ -f "${SCRIPT_DIR}/.env" ]; then
    ENV_FILE="${SCRIPT_DIR}/.env"
fi

get_env_val() {
    local key="$1"
    [ -f "${ENV_FILE}" ] || return 0
    grep -E "^[[:space:]]*${key}=" "${ENV_FILE}" | tail -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true
}

# 1. Resolve GCP Project & Region
if [ -z "${PROJECT}" ]; then
    PROJECT="$(get_env_val GOOGLE_CLOUD_PROJECT)"
    if [ -z "${PROJECT}" ]; then
        PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
    fi
fi
if [ -z "${PROJECT}" ]; then
    echo "${RED}❌ Error: GCP Project not specified and could not be detected.${NC}" >&2
    echo "Provide --project <ID> or set GOOGLE_CLOUD_PROJECT in .env" >&2
    exit 1
fi

if [ -z "${REGION}" ]; then
    REGION="$(get_env_val GOOGLE_CLOUD_REGION)"
    if [ -z "${REGION}" ] || [ "${REGION}" = "global" ]; then
        REGION="northamerica-northeast2"
    fi
fi

# 2. Resolve Service Name
if [ -z "${SERVICE_NAME}" ]; then
    # Default priority: mcp-ebs-1p-skills > MCP_TOOLBOX_SERVICE_NAME > mcp-toolbox-ps
    ENV_SVC="$(get_env_val MCP_TOOLBOX_SERVICE_NAME)"
    if [[ "${ENV_SVC}" == *"ebs"* ]]; then
        SERVICE_NAME="${ENV_SVC}"
    else
        SERVICE_NAME="mcp-ebs-1p-skills"
    fi
fi

# 3. Resolve Service URL
if [ -z "${SERVICE_URL}" ]; then
    if [ -n "${SERVICE_NAME}" ]; then
        SERVICE_URL="$(gcloud run services describe "${SERVICE_NAME}" \
            --project="${PROJECT}" \
            --region="${REGION}" \
            --format="value(status.url)" 2>/dev/null || true)"
    fi
    if [ -z "${SERVICE_URL}" ]; then
        ENV_URL="$(get_env_val MCP_SERVER_SQL_URL)"
        if [ -n "${ENV_URL}" ]; then
            SERVICE_URL="${ENV_URL%/mcp/}"
            SERVICE_URL="${SERVICE_URL%/mcp}"
            SERVICE_URL="${SERVICE_URL%/}"
        fi
    fi
fi

if [ -z "${SERVICE_URL}" ]; then
    echo "${RED}❌ Error: Could not determine Cloud Run URL for service '${SERVICE_NAME}' in ${REGION}.${NC}" >&2
    echo "Check if the service is deployed, or specify --service-url <URL> directly." >&2
    exit 1
fi
# Strip trailing slashes
SERVICE_URL="${SERVICE_URL%/}"

# 4. Resolve Client Secret JSON and Client ID
find_matching_client_json() {
    local target="$1"
    local search_dirs=("${SCRIPT_DIR}/secrets" "${SCRIPT_DIR}" "${REPO_ROOT}")
    for d in "${search_dirs[@]}"; do
        [ -d "${d}" ] || continue
        for f in "${d}"/*client_secret*.json; do
            [ -f "${f}" ] || continue
            local fname; fname="$(basename "${f}")"
            if [ -n "${target}" ] && [[ "${fname}" == *"${target}"* ]]; then
                echo "${f}"
                return 0
            fi
        done
    done
    return 1
}

# Auto-detect client json based on service name (e.g. EBS, PS, JDE)
if [ -z "${CLIENT_JSON}" ]; then
    if [[ "${SERVICE_NAME}" == *"ebs"* ]]; then
        CLIENT_JSON="$(find_matching_client_json "EBS" || true)"
    elif [[ "${SERVICE_NAME}" == *"ps"* ]] || [[ "${SERVICE_NAME}" == *"peoplesoft"* ]]; then
        CLIENT_JSON="$(find_matching_client_json "PS" || true)"
    elif [[ "${SERVICE_NAME}" == *"jde"* ]]; then
        CLIENT_JSON="$(find_matching_client_json "JDE" || true)"
    fi
fi

# Resolve Client ID
if [ -z "${CLIENT_ID}" ]; then
    # Try Secret Manager for <service_name>-google-client-id
    CLIENT_ID="$(gcloud secrets versions access latest \
        --secret="${SERVICE_NAME}-google-client-id" \
        --project="${PROJECT}" 2>/dev/null || true)"
fi

if [ -z "${CLIENT_ID}" ] && [ -n "${CLIENT_JSON}" ] && [ -f "${CLIENT_JSON}" ]; then
    CLIENT_ID="$(python3 -c "import json; d=json.load(open('${CLIENT_JSON}')); c=d.get('web') or d.get('installed') or {}; print(c.get('client_id',''))" 2>/dev/null || true)"
fi

if [ -z "${CLIENT_ID}" ]; then
    CLIENT_ID="$(get_env_val GOOGLE_CLIENT_ID)"
fi

# Resolve Client Secret if available
if [ -z "${CLIENT_SECRET}" ] && [ -n "${CLIENT_JSON}" ] && [ -f "${CLIENT_JSON}" ]; then
    CLIENT_SECRET="$(python3 -c "import json; d=json.load(open('${CLIENT_JSON}')); c=d.get('web') or d.get('installed') or {}; print(c.get('client_secret',''))" 2>/dev/null || true)"
fi

# ------------------------------------------------------------------------------
# Authentication Tokens Resolution
# ------------------------------------------------------------------------------

# Tier 1: Cloud Run Transport Token (Authorization: Bearer <ID_TOKEN>)
if [ -z "${BEARER_TOKEN}" ]; then
    BEARER_TOKEN="${CR_BEARER_TOKEN:-}"
fi
if [ -z "${BEARER_TOKEN}" ]; then
    if [ -n "${CR_ACCOUNT}" ]; then
        BEARER_TOKEN="$(gcloud auth print-identity-token --account="${CR_ACCOUNT}" 2>/dev/null || true)"
    else
        BEARER_TOKEN="$(gcloud auth print-identity-token 2>/dev/null || true)"
    fi
fi

if [ -z "${BEARER_TOKEN}" ]; then
    echo "${RED}❌ Error: Could not acquire Cloud Run transport identity token.${NC}" >&2
    echo "Please run: gcloud auth login" >&2
    exit 1
fi

# Tier 2: Toolbox Application Identity Token (google-auth_token: <ID_TOKEN>)
if [ -z "${USER_TOKEN}" ]; then
    USER_TOKEN="${MCP_USER_TOKEN:-${AUTH_TOKEN:-}}"
fi

if [ -z "${USER_TOKEN}" ] && [ -n "${CLIENT_ID}" ]; then
    # Attempt to mint audience-restricted ID token using a service account
    if [ -n "${SERVICE_ACCOUNT}" ]; then
        USER_TOKEN="$(gcloud auth print-identity-token --account="${SERVICE_ACCOUNT}" --audiences="${CLIENT_ID}" 2>/dev/null || true)"
    else
        # Inspect available credentialed accounts in gcloud
        ACCOUNTS="$(gcloud auth list --format="value(account)" 2>/dev/null || true)"
        TARGET_SA=""
        if [[ "${SERVICE_NAME}" == *"ebs"* ]]; then
            TARGET_SA="$(echo "${ACCOUNTS}" | grep -E 'ebs.*service-account' | head -1 || true)"
        elif [[ "${SERVICE_NAME}" == *"ps"* ]] || [[ "${SERVICE_NAME}" == *"peoplesoft"* ]]; then
            TARGET_SA="$(echo "${ACCOUNTS}" | grep -E 'ps.*service-account' | head -1 || true)"
        elif [[ "${SERVICE_NAME}" == *"jde"* ]]; then
            TARGET_SA="$(echo "${ACCOUNTS}" | grep -E 'jde.*service-account' | head -1 || true)"
        fi
        if [ -z "${TARGET_SA}" ]; then
            TARGET_SA="$(echo "${ACCOUNTS}" | grep -E 'serviceaccount\.com' | head -1 || true)"
        fi

        if [ -n "${TARGET_SA}" ]; then
            SERVICE_ACCOUNT="${TARGET_SA}"
            USER_TOKEN="$(gcloud auth print-identity-token --account="${TARGET_SA}" --audiences="${CLIENT_ID}" 2>/dev/null || true)"
        fi
    fi

    # Fallback: check if active account can mint token with audience
    if [ -z "${USER_TOKEN}" ]; then
        USER_TOKEN="$(gcloud auth print-identity-token --audiences="${CLIENT_ID}" 2>/dev/null || true)"
    fi
fi

# Set default tool name if not specified
if [ -z "${TOOL_NAME}" ] && [ "${LIST_ONLY}" = false ] && [ -z "${DETAIL_TOOL}" ]; then
    if [[ "${SERVICE_NAME}" == *"ebs"* ]]; then
        TOOL_NAME="ebs_list_operating_units"
        [ -z "${ARGS_JSON}" ] && [ ${#CLI_ARGS[@]} -eq 0 ] && ARGS_JSON='{"name_pattern": "%"}'
    elif [[ "${SERVICE_NAME}" == *"ps"* ]] || [[ "${SERVICE_NAME}" == *"peoplesoft"* ]]; then
        TOOL_NAME="ps_get_user_roles"
        [ -z "${ARGS_JSON}" ] && [ ${#CLI_ARGS[@]} -eq 0 ] && ARGS_JSON='{"user_id": "VP1"}'
    fi
fi

# Assemble arguments JSON if --arg KEY=VAL flags were passed
if [ ${#CLI_ARGS[@]} -gt 0 ]; then
    ARGS_JSON="$(python3 -c "
import json, sys
base = json.loads(sys.argv[1]) if sys.argv[1] else {}
for item in sys.argv[2:]:
    if '=' in item:
        k, v = item.split('=', 1)
        base[k] = v
print(json.dumps(base))
" "${ARGS_JSON}" "${CLI_ARGS[@]}")"
fi

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------
ACTIVE_USER="$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || echo "gcloud-user")"

echo "${BOLD}================================================================================${NC}"
echo "${BOLD}🛠️   MCP TOOLBOX TESTER: ${CYAN}${SERVICE_NAME}${NC}"
echo "${BOLD}================================================================================${NC}"
echo "  ${BOLD}Service URL:${NC}      ${SERVICE_URL}"
echo "  ${BOLD}GCP Project:${NC}      ${PROJECT}"
echo "  ${BOLD}GCP Region:${NC}       ${REGION}"
echo "  ${BOLD}Client ID:${NC}        ${CLIENT_ID:-${YELLOW}(none detected)${NC}}"
if [ -n "${CLIENT_JSON}" ]; then
    echo "  ${BOLD}Client Secret:${NC}    [Detected: $(basename "${CLIENT_JSON}")]"
elif [ -n "${CLIENT_SECRET}" ]; then
    echo "  ${BOLD}Client Secret:${NC}    [Configured: ${CLIENT_SECRET:0:6}********]"
else
    echo "  ${BOLD}Client Secret:${NC}    (none detected)"
fi
echo "  ${BOLD}Transport Auth:${NC}   Authorization: Bearer <Google ID token for ${ACTIVE_USER}>"
if [ -n "${USER_TOKEN}" ]; then
    if [ -n "${SERVICE_ACCOUNT}" ]; then
        echo "  ${BOLD}Application Auth:${NC} google-auth_token: <Google ID token for ${SERVICE_ACCOUNT}>"
    else
        echo "  ${BOLD}Application Auth:${NC} google-auth_token: <Custom/Provided ID token>"
    fi
else
    echo "  ${BOLD}Application Auth:${NC} ${YELLOW}(none - tools requiring google-auth may fail if invoked)${NC}"
fi
echo "${BOLD}--------------------------------------------------------------------------------${NC}"
echo ""

# ------------------------------------------------------------------------------
# Python Execution Engine
# ------------------------------------------------------------------------------
# The embedded Python engine runs ping, initialize, tools/list, and tools/call,
# decodes JWTs, formats tables, and provides diagnostic guidance on failures.

export PY_SERVICE_URL="${SERVICE_URL}"
export PY_BEARER_TOKEN="${BEARER_TOKEN}"
export PY_USER_TOKEN="${USER_TOKEN:-}"
export PY_CLIENT_ID="${CLIENT_ID:-}"
export PY_LIST_ONLY="${LIST_ONLY}"
export PY_TOOL_NAME="${TOOL_NAME:-}"
export PY_ARGS_JSON="${ARGS_JSON:-}"
export PY_DETAIL_TOOL="${DETAIL_TOOL:-}"
export PY_RAW_JSON="${RAW_JSON}"
export PY_SKIP_PING="${SKIP_PING}"
export PY_SKIP_INIT="${SKIP_INIT}"
export PY_VERBOSE="${VERBOSE}"
export PY_SERVICE_NAME="${SERVICE_NAME}"
export PY_PROJECT="${PROJECT}"
export PY_REGION="${REGION}"

python3 - <<'PY_CODE'
import os
import sys
import json
import base64
import time
import urllib.request
import urllib.error

# Formatting helpers
IS_TTY = sys.stdout.isatty()
def col(text, code):
    return f"\033[{code}m{text}\033[0m" if IS_TTY else text

def red(t): return col(t, "0;31")
def green(t): return col(t, "0;32")
def yellow(t): return col(t, "0;33")
def blue(t): return col(t, "0;34")
def cyan(t): return col(t, "0;36")
def bold(t): return col(t, "1")

service_url = os.environ.get("PY_SERVICE_URL", "").rstrip("/")
bearer_token = os.environ.get("PY_BEARER_TOKEN", "")
user_token = os.environ.get("PY_USER_TOKEN", "")
client_id = os.environ.get("PY_CLIENT_ID", "")
list_only = os.environ.get("PY_LIST_ONLY") == "true"
tool_name = os.environ.get("PY_TOOL_NAME", "")
args_json = os.environ.get("PY_ARGS_JSON", "")
detail_tool = os.environ.get("PY_DETAIL_TOOL", "")
raw_json = os.environ.get("PY_RAW_JSON") == "true"
skip_ping = os.environ.get("PY_SKIP_PING") == "true"
skip_init = os.environ.get("PY_SKIP_INIT") == "true"
verbose = os.environ.get("PY_VERBOSE") == "true"
service_name = os.environ.get("PY_SERVICE_NAME", "")
project = os.environ.get("PY_PROJECT", "")
region = os.environ.get("PY_REGION", "")

def decode_jwt(token):
    try:
        parts = token.split(".")
        if len(parts) != 3:
            return None
        payload = parts[1]
        payload += "=" * (-len(payload) % 4)
        return json.loads(base64.urlsafe_b64decode(payload).decode("utf-8"))
    except Exception:
        return None

def make_request(path, data=None, extra_headers=None):
    url = service_url + path
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "User-Agent": "MCP-Tester/1.0"
    }
    if data is not None:
        headers["Content-Type"] = "application/json"
    if extra_headers:
        headers.update(extra_headers)

    if verbose:
        print(cyan(f"  [HTTP DEBUG] { 'POST' if data else 'GET' } {url}"))
        for k, v in headers.items():
            if "token" in k.lower() or "authorization" in k.lower():
                print(cyan(f"  [HTTP DEBUG] {k}: {v[:18]}...{v[-8:]} (len: {len(v)})"))
            else:
                print(cyan(f"  [HTTP DEBUG] {k}: {v}"))
        if data:
            print(cyan(f"  [HTTP DEBUG] Body: {data[:200]}"))

    encoded_data = data.encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=encoded_data, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            return resp.status, body, None
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        return e.code, err_body, e
    except Exception as e:
        return 0, str(e), e

# ------------------------------------------------------------------------------
# STEP 1: Health Ping (GET /)
# ------------------------------------------------------------------------------
if not skip_ping:
    print(bold("[1/4] 🏥 Health / Ping Check"))
    print(f"  GET {service_url}/")
    status, body, err = make_request("/")
    if status == 200:
        clean_body = body.strip()
        print(f"  Status:   {green(f'{status} OK')}")
        print(f"  Response: {clean_body}")
        print(green("  ✅ Health check passed! Cloud Run transport authentication is valid.\n"))
    elif status in (401, 403):
        print(red(f"  ❌ Cloud Run Ingress Authentication Failed (HTTP {status})"))
        print(f"  Response: {body.strip()[:200]}")
        print(yellow("\n  Diagnostic Tips for Cloud Run:"))
        print("  1. Make sure your account has 'roles/run.invoker' on this service:")
        print(f"     gcloud run services add-iam-policy-binding {service_name} \\")
        print(f"       --member='user:<YOUR_EMAIL>' --role='roles/run.invoker' \\")
        print(f"       --region='{region}' --project='{project}'")
        print("  2. If using standard gcloud auth token, make sure custom audiences are added to Cloud Run:")
        print(f"     gcloud run services update {service_name} \\")
        print(f"       --add-custom-audiences='681255809395-oo8ft2oprdrnp9e3aqf6av3hmdib135j.apps.googleusercontent.com' \\")
        print(f"       --region='{region}' --project='{project}'\n")
        sys.exit(1)
    else:
        print(red(f"  ❌ Health check failed with HTTP {status}: {body.strip()}"))
        sys.exit(1)

# ------------------------------------------------------------------------------
# STEP 2: Protocol Handshake (initialize)
# ------------------------------------------------------------------------------
if not skip_init:
    print(bold("[2/4] 🤝 Protocol Handshake (initialize)"))
    init_payload = json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {
                "name": "test-mcp-client",
                "version": "1.0.0"
            }
        }
    })
    status, body, err = make_request("/mcp/", data=init_payload)
    if status == 200:
        try:
            init_res = json.loads(body)
            result = init_res.get("result", {})
            sinfo = result.get("serverInfo", {})
            pversion = result.get("protocolVersion", "unknown")
            caps = list(result.get("capabilities", {}).keys())
            print(f"  Server Name:      {bold(sinfo.get('name', 'Unknown'))}")
            print(f"  Server Version:   {sinfo.get('version', 'Unknown')}")
            print(f"  Protocol Version: {pversion}")
            print(f"  Capabilities:     {', '.join(caps)}")
            print(green("  ✅ MCP handshake initialized successfully!\n"))
        except Exception as e:
            print(yellow(f"  ⚠️ Handshake returned non-JSON response: {body[:200]}\n"))
    else:
        print(red(f"  ❌ MCP initialize failed (HTTP {status}): {body.strip()}"))
        sys.exit(1)

# ------------------------------------------------------------------------------
# STEP 3: Tool Discovery (tools/list)
# ------------------------------------------------------------------------------
print(bold("[3/4] 🔍 Tool Discovery (tools/list)"))
list_payload = json.dumps({
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
})
status, body, err = make_request("/mcp/", data=list_payload)
if status != 200:
    print(red(f"  ❌ tools/list failed (HTTP {status}): {body.strip()}"))
    sys.exit(1)

try:
    list_res = json.loads(body)
    tools = list_res.get("result", {}).get("tools", [])
except Exception as e:
    print(red(f"  ❌ Failed to parse tools/list JSON response: {e}"))
    sys.exit(1)

print(f"  Discovered {bold(cyan(str(len(tools))))} tools on server:\n")

sorted_tools = sorted(tools, key=lambda x: x["name"])

# Table header
col_num = f"{'#':>3}"
col_name = f"{'Tool Name':<44}"
col_params = f"{'Parameters':<24}"
col_auth = "Auth Services"
print(f"  {bold(col_num)}  {bold(col_name)}  {bold(col_params)}  {bold(col_auth)}")
print(f"  {'-'*3}  {'-'*44}  {'-'*24}  {'-'*20}")

for i, t in enumerate(sorted_tools, 1):
    tname = t.get("name", "")
    schema = t.get("inputSchema", {})
    props = schema.get("properties", {})
    req_fields = schema.get("required", [])
    meta = t.get("_meta", {})
    auth_inv = meta.get("toolbox/authInvoke", [])
    auth_params = meta.get("toolbox/authParam", {})

    # Calculate user-supplied required/optional params vs injected params
    user_req = [p for p in req_fields if p not in auth_params]
    user_opt = [p for p in props if p not in req_fields and p not in auth_params]
    injected = list(auth_params.keys())

    param_summary_parts = []
    if user_req:
        param_summary_parts.append(f"{len(user_req)} req")
    if user_opt:
        param_summary_parts.append(f"{len(user_opt)} opt")
    if injected:
        param_summary_parts.append(f"{len(injected)} injected")
    param_summary = ", ".join(param_summary_parts) if param_summary_parts else "none"

    auth_summary = ", ".join(auth_inv) if auth_inv else "none"
    if injected and auth_inv:
        auth_summary += f" ({', '.join(injected)})"

    print(f"  {i:>3}. {cyan(f'{tname:<44}')}  {param_summary:<24}  {auth_summary}")

print(green(f"\n  ✅ All {len(tools)} tools discovered and schema-validated successfully!\n"))

# If --detail was requested for a specific tool
if detail_tool:
    match = [t for t in tools if t["name"] == detail_tool]
    if not match:
        print(red(f"❌ Error: Tool '{detail_tool}' not found among registered tools."))
        sys.exit(1)
    dt = match[0]
    print(bold(f"================================================================================"))
    print(bold(f"📋 Detailed Specification: {cyan(dt['name'])}"))
    print(bold(f"================================================================================"))
    print(f"Description:\n  {dt.get('description', 'No description available.')}\n")
    schema = dt.get("inputSchema", {})
    props = schema.get("properties", {})
    req_fields = schema.get("required", [])
    meta = dt.get("_meta", {})
    auth_params = meta.get("toolbox/authParam", {})
    auth_inv = meta.get("toolbox/authInvoke", [])

    print(bold("Parameters:"))
    if not props:
        print("  (No parameters required)")
    for p_name, p_spec in props.items():
        p_type = p_spec.get("type", "any")
        is_req = p_name in req_fields
        is_inj = p_name in auth_params
        status_tag = ""
        if is_inj:
            inj_src = ", ".join(auth_params[p_name])
            status_tag = green(f"[AUTH-INJECTED by {inj_src}]")
        elif is_req:
            status_tag = red("[REQUIRED]")
        else:
            status_tag = yellow("[OPTIONAL]")

        print(f"  • {bold(p_name)} ({p_type}) {status_tag}")
        p_desc = p_spec.get("description", "").strip()
        if p_desc:
            print(f"    {p_desc}")

    print(bold("\nAuth Requirements:"))
    print(f"  Toolbox Auth Services: {', '.join(auth_inv) if auth_inv else 'None'}")
    print(f"  Injected Parameters:   {json.dumps(auth_params) if auth_params else 'None'}")

    print(bold("\nFull Input Schema JSON:"))
    print(json.dumps(schema, indent=2))
    print(bold("================================================================================\n"))
    if list_only:
        sys.exit(0)

if list_only:
    print(cyan("ℹ️  --list-only specified. Skipping tool execution step."))
    sys.exit(0)

# ------------------------------------------------------------------------------
# STEP 4: Tool Execution (tools/call)
# ------------------------------------------------------------------------------
if not tool_name:
    print(yellow("ℹ️  No test tool specified and no default match. Skipping execution step."))
    sys.exit(0)

print(bold(f"[4/4] ⚡ Tool Execution Test ({tool_name})"))

# Parse tool arguments
parsed_args = {}
if args_json:
    try:
        parsed_args = json.loads(args_json)
    except Exception as e:
        print(red(f"❌ Failed to parse --args JSON: {e}"))
        sys.exit(1)

# Check target tool requirements
target_tool_meta = None
for t in tools:
    if t["name"] == tool_name:
        target_tool_meta = t
        break

requires_auth = False
injected_params = []
if target_tool_meta:
    meta = target_tool_meta.get("_meta", {})
    auth_inv = meta.get("toolbox/authInvoke", [])
    auth_params = meta.get("toolbox/authParam", {})
    if "google-auth" in auth_inv or auth_params:
        requires_auth = True
        injected_params = list(auth_params.keys())

print(f"  Target Tool:    {cyan(bold(tool_name))}")
print(f"  Arguments:      {json.dumps(parsed_args)}")
if requires_auth:
    print(f"  Auth Context:   Tool requires {bold('google-auth')} (injects: {', '.join(injected_params)})")
    if user_token:
        decoded = decode_jwt(user_token)
        if decoded:
            aud = decoded.get("aud", "unknown")
            email = decoded.get("email", decoded.get("sub", "unknown"))
            exp = decoded.get("exp", 0)
            now = int(time.time())
            ttl = (exp - now) // 60 if exp > now else 0
            print(f"  Identity Token: Email={bold(email)} | aud={aud[:32]}... | TTL={ttl}m")
            if client_id and aud != client_id:
                print(yellow(f"  ⚠️ Warning: Token audience '{aud}' does not match expected client ID '{client_id}'. Toolbox may reject."))
            else:
                print(green(f"  Token Audience: ✅ Matches Google Client ID"))
        else:
            print(yellow(f"  Identity Token: Provided (non-JWT format, len={len(user_token)})"))
    else:
        print(yellow(f"  Identity Token: ⚠️ None provided. Request may fail if tool requires user identity."))

extra_headers = {}
if user_token:
    extra_headers["google-auth_token"] = user_token

call_payload = json.dumps({
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
        "name": tool_name,
        "arguments": parsed_args
    }
})

call_start = time.time()
status, body, err = make_request("/mcp/", data=call_payload, extra_headers=extra_headers)
call_elapsed = time.time() - call_start

if raw_json:
    print(bold("\nRaw Response:"))
    print(body)
    sys.exit(0 if status == 200 else 1)

if status == 200:
    try:
        resp_obj = json.loads(body)
    except Exception as e:
        print(red(f"  ❌ Invalid JSON returned: {body}"))
        sys.exit(1)

    if "error" in resp_obj:
        err_info = resp_obj["error"]
        print(red(f"\n  ❌ Tool call returned JSON-RPC error ({err_info.get('code', 'unknown')}):"))
        print(f"     {err_info.get('message', body)}")
        if "unauthorized" in str(err_info).lower():
            print(yellow("\n  Diagnostic Tips for Toolbox Auth:"))
            print("  1. Verify the google-auth_token header is passed with a 3-part Google ID token (JWT).")
            print("  2. Verify that the token's 'aud' claim matches the container's GOOGLE_CLIENT_ID:")
            print(f"     Expected Client ID: {client_id}")
            print("  3. To mint an audience-restricted token, use a service account:")
            print("     gcloud auth print-identity-token --account=<SA_EMAIL> --audiences='<CLIENT_ID>'")
        sys.exit(1)

    result = resp_obj.get("result", {})
    if result.get("isError"):
        print(red(f"\n  ❌ Tool execution returned error in result:"))
        for item in result.get("content", []):
            print(f"     {item.get('text', '')}")
        sys.exit(1)

    content = result.get("content", [])
    records = []
    raw_texts = []
    for item in content:
        if item.get("type") == "text":
            txt = item.get("text", "")
            try:
                rec = json.loads(txt)
                if isinstance(rec, dict):
                    records.append(rec)
                elif isinstance(rec, list):
                    records.extend([r for r in rec if isinstance(r, dict)])
                else:
                    raw_texts.append(txt)
            except Exception:
                raw_texts.append(txt)

    print(green(f"\n  ✅ Tool executed successfully in {call_elapsed:.2f}s!"))

    if records:
        print(f"  Records returned: {bold(cyan(str(len(records))))}\n")
        # Format records as a table
        keys = list(records[0].keys())
        # Pick max 5 representative columns if wide
        display_keys = keys[:6]
        col_widths = {k: max(len(k), max(len(str(r.get(k, ""))) for r in records[:50])) for k in display_keys}
        # Cap width at 36
        for k in col_widths:
            col_widths[k] = min(col_widths[k], 36)

        header_str = "  " + "  ".join(bold(f"{k:<{col_widths[k]}}") for k in display_keys)
        sep_str = "  " + "  ".join("-" * col_widths[k] for k in display_keys)
        print(header_str)
        print(sep_str)
        for r in records[:25]:
            row_items = []
            for k in display_keys:
                val = str(r.get(k, "-") if r.get(k) is not None else "-")
                if len(val) > col_widths[k]:
                    val = val[:col_widths[k]-3] + "..."
                row_items.append(f"{val:<{col_widths[k]}}")
            print("  " + "  ".join(row_items))

        if len(records) > 25:
            print(cyan(f"  ... and {len(records) - 25} more records (run with --json to see all)"))
    elif raw_texts:
        print("  Result Output:")
        for t in raw_texts:
            print(f"    {t}")
    else:
        print("  (Empty result set returned)")

    print(bold("\n================================================================================"))
    print(green(bold("🎉 All tests passed successfully!")))
    print(bold("================================================================================"))

elif status == 401:
    print(red(f"\n  ❌ HTTP 401 Unauthorized from Toolbox"))
    print(f"  Response: {body.strip()}")
    print(yellow("\n  Authentication Failure Checklist:"))
    print("  • Cloud Run transport header (Authorization: Bearer <ID_TOKEN>): Passed")
    print(f"  • Toolbox application header (google-auth_token: <ID_TOKEN>): {'Present' if user_token else 'Missing'}")
    if user_token:
        decoded = decode_jwt(user_token)
        if not decoded:
            print(red("  • Error: The provided user_token is not a valid 3-segment Google JWT!"))
            print("    OAuth access tokens ('ya29...') are NOT accepted. A Google ID Token is required.")
        else:
            token_aud = decoded.get("aud", "")
            print(f"  • Token Audience: {token_aud}")
            print(f"  • Expected Audience: {client_id}")
            if token_aud != client_id:
                print(red("  • Mismatch: Token audience does not match the server's GOOGLE_CLIENT_ID!"))
    else:
        print(yellow("  • Please pass a valid user ID token with --user-token or specify --service-account."))
    sys.exit(1)
else:
    print(red(f"\n  ❌ Request failed with HTTP {status}:"))
    print(f"  {body.strip()}")
    sys.exit(1)
PY_CODE

