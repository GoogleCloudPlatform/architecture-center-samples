#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SYSTEM="jde"
CONFIG_FILE="../jde/tools_sec.yaml"
TOOLBOX_URL="http://jde-mcp.com:8082/mcp"
HOSTS_FILE="${HOSTS_FILE:-/etc/hosts}"
PORT=8082

# Check for --toolbox-url in arguments
HAS_URL_ARG=false
for ((i=1; i<=$#; i++)); do
  if [[ "${!i}" == "--toolbox-url" ]]; then
    next=$((i+1))
    TOOLBOX_URL="${!next}"
    HAS_URL_ARG=true
  elif [[ "${!i}" == --toolbox-url=* ]]; then
    TOOLBOX_URL="${!i#--toolbox-url=}"
    HAS_URL_ARG=true
  fi
done

# 1. Load the system's credentials from <system>/.env.database (and GOOGLE_CLIENT_ID from <system>/.env)
if ! ENV_EXPORTS="$("$SCRIPT_DIR/env_export.sh" --system "$SYSTEM")"; then
  echo "Error: could not load the environment for '$SYSTEM'." >&2
  exit 1
fi
eval "$ENV_EXPORTS"

# 2. Test if the hostname in the toolbox-url exists in the local hosts file
HOST="${TOOLBOX_URL#*://}"
HOST="${HOST%%/*}"
HOST="${HOST#*@}"
HOST="${HOST%%:*}"

if [[ ! -r "$HOSTS_FILE" ]]; then
  echo "Error: Local hosts file '$HOSTS_FILE' not found or not readable." >&2
  exit 1
fi

if ! awk -v host="$HOST" '
  sub(/#.*/, "") {}
  {
    for (i = 2; i <= NF; i++) {
      if (tolower($i) == tolower(host)) {
        found = 1
        exit 0
      }
    }
  }
  END {
    if (!found) exit 1
  }
' "$HOSTS_FILE" 2>/dev/null; then
  echo "Error: Hostname '$HOST' from toolbox-url not found in $HOSTS_FILE." >&2
  echo "Please add an entry to $HOSTS_FILE, for example:" >&2
  echo "  127.0.0.1  $HOST" >&2
  exit 1
fi

if [[ "$HAS_URL_ARG" == true ]]; then
  toolbox --config "$CONFIG_FILE" --port "$PORT" --log-level DEBUG --ui "$@"
else
  toolbox --config "$CONFIG_FILE" --toolbox-url "$TOOLBOX_URL" --port "$PORT" --log-level DEBUG --ui "$@"
fi
