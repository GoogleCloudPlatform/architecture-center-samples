#!/usr/bin/env bash
# ==============================================================================
# Print `export KEY=value` lines for a system's local settings, for eval:
#
#   eval "$(./scripts/env_export.sh --system ebs)"      # replaces `source ebs.env`
#
# Reads <system>/.env.database (every KEY="value" in it: DB_CONNECTION_STRING, DB_USER,
# DB_PASSWORD, JDE_DATA_SCHEMA, ...) and, from <system>/.env, only GOOGLE_CLIENT_ID and the
# JDE schema names. Values are taken literally (one pair of surrounding double quotes is
# removed, nothing is expanded) and shell-quoted on output, so passwords with $, # or spaces
# survive. Empty values are skipped (an empty JDE_*_SCHEMA must never be exported).
# Nothing is printed to the terminal except the export lines; problems go to stderr.
#
# Same files and format the deploy script uses (README section 3.7).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SYSTEM=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --system) [ $# -ge 2 ] || { echo "--system needs a value" >&2; exit 2; }; SYSTEM="$2"; shift 2 ;;
        -h|--help) sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; exit 2 ;;
    esac
done
SYSTEM="$(printf '%s' "${SYSTEM}" | tr 'A-Z' 'a-z')"
case "${SYSTEM}" in
    ebs|jde) ;;
    ps|peoplesoft) SYSTEM="peoplesoft" ;;
    *) echo "--system {ebs|peoplesoft|jde} is required" >&2; exit 2 ;;
esac

DB_FILE="${REPO_ROOT}/${SYSTEM}/.env.database"
ENV_FILE="${REPO_ROOT}/${SYSTEM}/.env"
LEGACY="${REPO_ROOT}/${SYSTEM}.env"
if [ ! -f "${DB_FILE}" ] && [ -f "${LEGACY}" ]; then
    echo "env_export: ${SYSTEM}/.env.database not found; using the legacy ${SYSTEM}.env. Move its DB_* values to ${SYSTEM}/.env.database." >&2
    printf 'source %q\n' "${LEGACY}"
    exit 0
fi
if [ ! -f "${DB_FILE}" ]; then
    echo "env_export: ${DB_FILE} not found. Create it: ./scripts/deploy_mcp_server.sh --system ${SYSTEM} --init-env" >&2
    exit 1
fi

python3 - "${DB_FILE}" "${ENV_FILE}" <<'PY'
import os, re, shlex, sys

def read(path, allow=None):
    out = {}
    if not os.path.isfile(path):
        return out
    for line in open(path, encoding="utf-8"):
        m = re.match(r'^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*?)\s*$', line.rstrip("\n"))
        if not m or (allow is not None and m.group(1) not in allow):
            continue
        v = m.group(2)
        if len(v) >= 2 and v[0] == v[-1] == '"':
            v = v[1:-1]
        if v:
            out[m.group(1)] = v
    return out

values = read(sys.argv[2], {"GOOGLE_CLIENT_ID", "JDE_DATA_SCHEMA", "JDE_CTL_SCHEMA"})
values.update(read(sys.argv[1]))
for k, v in values.items():
    print("export %s=%s" % (k, shlex.quote(v)))
PY
