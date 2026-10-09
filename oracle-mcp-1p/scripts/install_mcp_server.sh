#!/usr/bin/env bash
# ==============================================================================
# install_mcp_server.sh - Configure MCP Toolbox Server for Gemini CLI / Antigravity
# ==============================================================================
# Installs and registers the MCP Toolbox for Databases server either:
#   1. Locally in the current project (.agents/mcp_config.json)
#   2. Globally for all user projects (~/.gemini/config/mcp_config.json)
#
# Uses safe JSON merging so existing MCP server configurations are never wiped out.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BRIDGE_SCRIPT="${SCRIPT_DIR}/mcp_toolbox_bridge.sh"
DEFAULT_SERVER_NAME="toolbox-db"
CLI_NAME=""

# Color helpers
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Configure the MCP Toolbox for Databases server for Antigravity and Gemini CLI.

Options:
  --local       Install configuration in this project (.agents/mcp_config.json)
  --global      Install configuration globally (~/.gemini/config/mcp_config.json)
  --url URL     MCP Toolbox server URL
  --name NAME   Custom server name (default: toolbox-db)
  -h, --help    Show this help message

If no option is provided, an interactive prompt will ask where to install.
EOF
    exit 0
}

TARGET_MODE=""
CLI_URL=""
CLI_NAME=""
while [ $# -gt 0 ]; do
    case "$1" in
        --local)  TARGET_MODE="local"; shift ;;
        --global) TARGET_MODE="global"; shift ;;
        --url)    CLI_URL="$2"; shift 2 ;;
        --url=*)  CLI_URL="${1#*=}"; shift ;;
        --name)   CLI_NAME="$2"; shift 2 ;;
        --name=*) CLI_NAME="${1#*=}"; shift ;;
        http://*|https://*) CLI_URL="$1"; shift ;;
        -h|--help) show_help ;;
        *)
            echo -e "${RED}Error: Unknown argument: $1${NC}" >&2
            show_help
            ;;
    esac
done

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}  MCP Toolbox for Databases - Antigravity / Gemini CLI Installer  ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# 1. Verify Prerequisites
echo -e "\n🔍 Checking prerequisites..."

if ! command -v gcloud &>/dev/null; then
    echo -e "${RED}❌ 'gcloud' CLI not found.${NC} Please install Google Cloud SDK." >&2
    exit 1
fi

ACTIVE_ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)"
if [ -z "${ACTIVE_ACCOUNT}" ]; then
    echo -e "${YELLOW}⚠️  No active gcloud authentication detected.${NC}"
    echo "   Please run: gcloud auth login"
else
    echo -e "   ${GREEN}✔${NC} gcloud authenticated as: ${ACTIVE_ACCOUNT}"
fi

if ! command -v npx &>/dev/null; then
    echo -e "${RED}❌ 'npx' not found.${NC} Node.js and npm/npx are required to run mcp-remote." >&2
    exit 1
else
    echo -e "   ${GREEN}✔${NC} npx found: $(which npx)"
fi

if ! command -v python3 &>/dev/null; then
    echo -e "${RED}❌ 'python3' not found.${NC} Python 3 is required for safe JSON configuration updates." >&2
    exit 1
else
    echo -e "   ${GREEN}✔${NC} python3 found: $(which python3)"
fi

# Ensure bridge script is executable
if [ ! -f "${BRIDGE_SCRIPT}" ]; then
    echo -e "${RED}❌ Bridge script not found at ${BRIDGE_SCRIPT}${NC}" >&2
    exit 1
fi
chmod +x "${BRIDGE_SCRIPT}"
echo -e "   ${GREEN}✔${NC} Bridge script ready: ${BRIDGE_SCRIPT}"

# Helper function to save/update URL in root .env
save_url_to_env() {
    local target_url="$1"
    python3 - << EOF
import os
env_file = os.path.join("${PROJECT_ROOT}", ".env")
url = "${target_url}"
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
    echo -e "   ${GREEN}✔${NC} Saved MCP_SERVER_SQL_URL to ${PROJECT_ROOT}/.env"
}

# 2. Resolve MCP Server URL (CLI flag > env var > root .env > prompt user)
echo -e "\n🔍 Resolving MCP Server URL..."
MCP_URL="${CLI_URL:-${MCP_SERVER_URL:-}}"
OVERWRITE_ENV=false
PROMPT_SAVE_ENV=false
APPENDED_MCP=false

# If not provided via CLI flag or env var, check .env
if [ -z "${MCP_URL}" ] && [ -f "${PROJECT_ROOT}/.env" ]; then
    ENV_URL=$(grep -E '^[[:space:]]*(MCP_SERVER_SQL_URL|MCP_SERVER_URL)=' "${PROJECT_ROOT}/.env" | head -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true)
    if [ -n "${ENV_URL}" ]; then
        echo -e "   ${GREEN}✔${NC} Found MCP server URL in .env: ${BLUE}${ENV_URL}${NC}"
        if [ -t 0 ]; then
            echo -e "   Press ${GREEN}Enter${NC} to keep this URL, or enter a new URL:"
            read -rp "   URL [default: ${ENV_URL}]: " INPUT_CHOICE
            INPUT_CHOICE="$(echo -n "${INPUT_CHOICE}" | tr -d '[:space:]')"
            case "${INPUT_CHOICE}" in
                ""|[yY]|[yY][eE][sS])
                    MCP_URL="${ENV_URL}"
                    ;;
                [nN]|[nN][oO])
                    while true; do
                        read -rp "   Enter the new MCP Toolbox Server URL (e.g. https://<service-url>/mcp): " NEW_URL
                        NEW_URL="$(echo -n "${NEW_URL}" | tr -d '[:space:]')"
                        if [ -n "${NEW_URL}" ]; then
                            MCP_URL="${NEW_URL}"
                            OVERWRITE_ENV=true
                            break
                        fi
                        echo -e "   ${RED}URL cannot be empty.${NC}"
                    done
                    ;;
                *)
                    # User directly typed or pasted a URL
                    MCP_URL="${INPUT_CHOICE}"
                    OVERWRITE_ENV=true
                    ;;
            esac
        else
            MCP_URL="${ENV_URL}"
        fi
    fi
fi

# If still empty (no CLI flag, no env var, and no .env):
if [ -z "${MCP_URL}" ]; then
    if [ ! -t 0 ]; then
        echo -e "${RED}❌ Error: No MCP server URL provided or found in .env.${NC}" >&2
        echo "Please specify --url <URL> or configure MCP_SERVER_SQL_URL in .env." >&2
        exit 1
    fi

    echo -e "\n${YELLOW}No MCP server URL provided or found in root .env.${NC}"
    while true; do
        read -rp "Enter the MCP Toolbox Server URL (e.g. https://<service-url>/mcp): " INPUT_URL
        INPUT_URL="$(echo -n "${INPUT_URL}" | tr -d '[:space:]')"
        if [ -n "${INPUT_URL}" ]; then
            MCP_URL="${INPUT_URL}"
            PROMPT_SAVE_ENV=true
            break
        fi
        echo -e "${RED}URL cannot be empty. Please enter a valid URL.${NC}"
    done
fi

# Check if URL ends with "/mcp" (runs for ALL URLs: CLI, .env, or newly entered!)
MCP_URL="${MCP_URL%/}"
if [[ "${MCP_URL}" != */mcp ]]; then
    if [ -t 0 ]; then
        echo -e "   ${YELLOW}⚠️  Configured URL does not end with '/mcp': ${MCP_URL}${NC}"
        read -rp "   Would you like to append '/mcp'? [Y/n]: " APPEND_CHOICE
        case "${APPEND_CHOICE}" in
            [nN]*)
                read -rp "   Are you sure you want to proceed without '/mcp'? [y/N]: " CONFIRM_SURE
                case "${CONFIRM_SURE}" in
                    [yY]*) ;;
                    *)
                        echo -e "${RED}Aborted by user.${NC}" >&2
                        exit 1
                        ;;
                esac
                ;;
            *)
                MCP_URL="${MCP_URL}/mcp"
                echo -e "   ${GREEN}✔${NC} Using URL: ${BLUE}${MCP_URL}${NC}"
                APPENDED_MCP=true
                ;;
        esac
    else
        echo -e "   ℹ️ Appending '/mcp' to service URL: ${MCP_URL}/mcp"
        MCP_URL="${MCP_URL}/mcp"
        APPENDED_MCP=true
    fi
fi

# Save / update .env if applicable
if [ -t 0 ]; then
    if [ "${OVERWRITE_ENV}" = true ]; then
        read -rp "   Save this new URL to .env? [Y/n]: " SAVE_ENV
        case "${SAVE_ENV}" in
            [nN]*) ;;
            *)
                save_url_to_env "${MCP_URL}"
                ;;
        esac
    elif [ "${PROMPT_SAVE_ENV}" = true ]; then
        read -rp "   Would you like to save this URL to .env? [Y/n]: " SAVE_ENV
        case "${SAVE_ENV}" in
            [nN]*) ;;
            *)
                save_url_to_env "${MCP_URL}"
                ;;
        esac
    elif [ -n "${CLI_URL}" ] && [ -f "${PROJECT_ROOT}/.env" ]; then
        ENV_URL=$(grep -E '^[[:space:]]*(MCP_SERVER_SQL_URL|MCP_SERVER_URL)=' "${PROJECT_ROOT}/.env" | head -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true)
        ENV_URL="${ENV_URL%/}"
        if [ -n "${ENV_URL}" ] && [ "${ENV_URL}" != "${MCP_URL}" ]; then
            echo -e "   ℹ️ Found existing MCP server URL in .env: ${BLUE}${ENV_URL}${NC}"
            read -rp "   Overwrite .env with the provided URL (${MCP_URL})? [Y/n]: " SAVE_ENV
            case "${SAVE_ENV}" in
                [nN]*) ;;
                *)
                    save_url_to_env "${MCP_URL}"
                    ;;
            esac
        fi
    elif [ "${APPENDED_MCP}" = true ] && [ -f "${PROJECT_ROOT}/.env" ]; then
        ENV_URL=$(grep -E '^[[:space:]]*(MCP_SERVER_SQL_URL|MCP_SERVER_URL)=' "${PROJECT_ROOT}/.env" | head -1 | cut -d '=' -f2- | tr -d '"'\'' ' || true)
        ENV_URL="${ENV_URL%/}"
        if [ "${ENV_URL}" != "${MCP_URL}" ]; then
            read -rp "   Update appended '/mcp' in .env? [Y/n]: " SAVE_ENV
            case "${SAVE_ENV}" in
                [nN]*) ;;
                *)
                    save_url_to_env "${MCP_URL}"
                    ;;
            esac
        fi
    fi
fi

# 3. Select Installation Target (Interactive if not passed as flag)
if [ -z "${TARGET_MODE}" ]; then
    echo -e "\n${YELLOW}Where would you like to install the MCP configuration?${NC}"
    echo "  1) Local project (.agents/mcp_config.json) [Recommended for team repositories]"
    echo "  2) Global for all projects (~/.gemini/config/mcp_config.json)"
    echo ""
    read -rp "Select an option [1 or 2]: " CHOICE
    case "${CHOICE}" in
        1|local|l)  TARGET_MODE="local" ;;
        2|global|g) TARGET_MODE="global" ;;
        *)
            echo -e "${RED}Invalid selection. Aborting.${NC}" >&2
            exit 1
            ;;
    esac
fi

# Determine target config file path
if [ "${TARGET_MODE}" = "local" ]; then
    CONFIG_DIR="${PROJECT_ROOT}/.agents"
    CONFIG_FILE="${CONFIG_DIR}/mcp_config.json"
    echo -e "\n🎯 Target: ${GREEN}Project-Local Configuration${NC} (${CONFIG_FILE})"
else
    CONFIG_DIR="${HOME}/.gemini/config"
    CONFIG_FILE="${CONFIG_DIR}/mcp_config.json"
    echo -e "\n🎯 Target: ${GREEN}Global Configuration${NC} (${CONFIG_FILE})"
fi

# 4. Configure Server Identifier / Name (Interactive prompt if not passed via --name)
SERVER_NAME="${CLI_NAME:-}"
if [ -z "${SERVER_NAME}" ]; then
    if [ -t 0 ]; then
        echo -e "\n${YELLOW}MCP Server Identifier / Name${NC}"
        read -rp "Enter server name [default: ${DEFAULT_SERVER_NAME}]: " INPUT_NAME
        INPUT_NAME="$(echo -n "${INPUT_NAME}" | tr -d '[:space:]')"
        SERVER_NAME="${INPUT_NAME:-${DEFAULT_SERVER_NAME}}"
    else
        SERVER_NAME="${DEFAULT_SERVER_NAME}"
    fi
fi
echo -e "   ${GREEN}✔${NC} Server identifier: ${BLUE}${SERVER_NAME}${NC}"

# 5. Safely inject / merge into mcp_config.json using Python (atomic rewrite)
python3 - << EOF
import json, os, sys, tempfile

config_path = os.path.expanduser("${CONFIG_FILE}")
bridge_path = "${BRIDGE_SCRIPT}"
target_mode = "${TARGET_MODE}"
server_name = "${SERVER_NAME}"

os.makedirs(os.path.dirname(config_path), exist_ok=True)

data = {"mcpServers": {}}
if os.path.exists(config_path):
    try:
        with open(config_path, "r") as f:
            data = json.load(f)
    except Exception as e:
        print(f"⚠️ Warning: Existing config could not be parsed ({e}). Creating new structure.")
        data = {"mcpServers": {}}

servers = data.setdefault("mcpServers", {})

# Check if other servers exist to give friendly reassurance
existing_other = [k for k in servers.keys() if k != server_name]
if existing_other:
    print(f"ℹ️  Preserving existing servers: {', '.join(existing_other)}")

# Merge/Update target server entry
# Always use the absolute path to the bridge script so agy finds it regardless of current working directory
servers[server_name] = {
    "command": bridge_path
}

# Atomic write to avoid file truncation
dir_name = os.path.dirname(config_path)
with tempfile.NamedTemporaryFile("w", dir=dir_name, delete=False) as tf:
    json.dump(data, tf, indent=2)
    temp_path = tf.name

os.replace(temp_path, config_path)
print(f"✅ Configured '{server_name}' successfully in {config_path}")
EOF

# If local, also ensure symlink at project root for tools expecting root mcp_config.json
if [ "${TARGET_MODE}" = "local" ]; then
    ln -sf ".agents/mcp_config.json" "${PROJECT_ROOT}/mcp_config.json"
    echo -e "   ${GREEN}✔${NC} Symlinked root 'mcp_config.json' -> '.agents/mcp_config.json'"
fi

# 6. Optional quick connection test
echo -e "\n🧪 Testing MCP server connection via bridge..."
if python3 -c "
import subprocess, json, time, sys

proc = subprocess.Popen(
    ['${BRIDGE_SCRIPT}', '${MCP_URL}'],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

init_req = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
        'protocolVersion': '2024-11-05',
        'capabilities': {},
        'clientInfo': {'name': 'installer-test', 'version': '1.0.0'}
    }
}

time.sleep(2)
try:
    proc.stdin.write(json.dumps(init_req) + '\n')
    proc.stdin.flush()
    time.sleep(2)
    proc.terminate()
    stdout, stderr = proc.communicate(timeout=3)
    if 'serverInfo' in stdout:
        sys.exit(0)
    else:
        sys.exit(1)
except Exception:
    proc.kill()
    sys.exit(1)
" 2>/dev/null; then
    echo -e "   ${GREEN}✔ Remote MCP server handshake succeeded!${NC}"
else
    echo -e "   ${YELLOW}⚠️ Handshake test did not return immediately (server may be warming up or credentials need refresh).${NC}"
fi

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}🎉 MCP Server '${SERVER_NAME}' successfully installed!${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo -e "  • Server Name : ${BLUE}${SERVER_NAME}${NC}"
echo -e "  • Service URL : ${BLUE}${MCP_URL}${NC}"
echo -e "  • Config File : ${BLUE}${CONFIG_FILE}${NC}"
echo -e "  • Target Scope: ${BLUE}${TARGET_MODE}${NC}"
echo ""
echo "You can now use database tools directly in Antigravity or Gemini CLI."
echo "In Antigravity IDE, inspect discovered tools under: Additional Options (...) > MCP Servers."
