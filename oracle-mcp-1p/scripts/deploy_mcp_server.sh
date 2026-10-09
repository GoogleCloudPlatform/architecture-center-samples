#!/usr/bin/env bash
# ==============================================================================
# MCP Toolbox Deployment Script
#
# Deploys the MCP Toolbox to a private Cloud Run service:
#   1. Stores tools.yaml in Cloud Storage (gs://${CONFIG_BUCKET}/${SERVICE_NAME}/tools.yaml),
#      mounted directly into Cloud Run via Cloud Storage FUSE.
#   2. Stores the database credentials in Secret Manager, one secret per ${VARIABLE}
#      that tools.yaml references (user, password, connection string).
#   3. Deploys the Toolbox image with the Cloud Storage volume mounted at /config,
#      container pointing to /config/${SERVICE_NAME}/tools.yaml, and each credential
#      injected as an environment variable.
#   4. Offers to record the service URL as MCP_SERVER_SQL_URL in .env
#
# tools.yaml must NOT contain credentials. It references them as "${DB_PASSWORD}"
# etc.; the Toolbox substitutes them at startup. Secret values are read from the environment
# variable of the same name, then <system>/.env.database, then a silent prompt, and are sent to Secret Manager over stdin -
# never on a command line, in .env, or on screen. If tools.yaml still has hardcoded
# credentials, the script offers to move them into Secret Manager and rewrite the file.
#
# One isolated deployment per target system. --system {ebs,peoplesoft,jde} is REQUIRED (no
# default; 'ps' is accepted as an alias of peoplesoft) and selects:
#   - the env file        <system>/.env     (the repo-root .env is never read or written)
#   - the service name    mcp-toolbox-<ebs|ps|jde>
#   - the tools file      <system>/tools.yaml
#   - the secrets         <service-name>-<var>, and the GCS path <service-name>/tools.yaml
# so each system gets its own env file, Cloud Run service, secrets and config, and a deploy of
# one can never touch another. Blank settings are detected and fixed or explained, a read-only
# preflight verifies the GCP artefacts, and nothing changes without a 'yes'.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"          # ENV_FILE, env_value, info/warn/die
# --- Defaults (none of these are project-specific) ---
# Per-system defaults are derived once --system is known (see "Select the system" below).
DEFAULT_SERVICE_NAME=""
SYSTEM=""; SYSTEM_SHORT=""; VARIANT=""
VALID_SYSTEMS="ebs, peoplesoft (ps), jde"
DEFAULT_IMAGE="us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest"
DEFAULT_TOOLS_FILE=""
DEFAULT_REGION="us-central1"
DEFAULT_SA_NAME=""   # <ebs|ps|jde>-service-account, set once --system is known; full email is derived: <name>@<project>.iam.gserviceaccount.com

# Roles the Toolbox service account must hold on the project.
REQUIRED_SA_ROLES=("roles/secretmanager.secretAccessor")
# Missing-tolerant roles (--telemetry-gcp, logging): absence is a warning.
RECOMMENDED_SA_ROLES=("roles/logging.logWriter" "roles/cloudtrace.agent" "roles/monitoring.metricWriter")
REQUIRED_APIS=(
    "run.googleapis.com"
    "secretmanager.googleapis.com"
    "storage.googleapis.com"
    "compute.googleapis.com"
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "logging.googleapis.com"
    "monitoring.googleapis.com"
    "cloudtrace.googleapis.com"
)
# ${VARIABLES} in tools.yaml that are NOT secrets: injected as plain env vars from .env
# (anything else referenced as ${VAR} is a credential and comes from Secret Manager).
PLAIN_TEMPLATE_VARS=("GOOGLE_CLIENT_ID")
# Permissions the person running this script needs on the project.
REQUIRED_DEPLOYER_PERMS=(run.services.create run.services.update secretmanager.secrets.create secretmanager.versions.add)

# --- State ---
PROJECT=""; PROJECT_NUMBER=""; REGION=""; SERVICE_ACCOUNT=""
SERVICE_NAME=""; SECRET_NAME=""; CONFIG_BUCKET=""; IMAGE=""; TOOLS_FILE=""; NETWORK=""; SUBNET=""
GOOGLE_CLIENT_ID=""; MCP_SERVER_SQL_URL=""
SKIP_PREFLIGHT=false; PREFLIGHT_ONLY=false; FIX_MODE=false; ASSUME_YES=false; ROTATE_SECRETS=false; ROTATE_TOOLS=false; NO_RESTART=false; SECRETS_ROTATED=0
DRY_RUN=false; CHECK_STATUS=false; INIT_ENV=false
CLI_SET=" "

usage() {
    cat <<EOF
Usage: ./scripts/deploy_mcp_server.sh --system {ebs|peoplesoft|jde} [OPTIONS]

Deploys the MCP Toolbox for ONE target system to private Cloud Run. Each system has its own
env file (<system>/.env), service, secrets and tools file, so deployments are fully isolated.
Every action that changes anything asks for confirmation first (-y/--yes skips the prompts).

Required:
  --system SYSTEM         Target system: ebs | peoplesoft (alias: ps) | jde. No default.
  --variant NAME          Optional. Keep a separate deployment of the same system, for example
                          "sec" and "agent": its own <system>/.env.<NAME>, service name
                          mcp-toolbox-<ebs|ps|jde>-<NAME> and secrets. DB credentials fall back to
                          <system>/.env.database unless <system>/.env.<NAME>.database exists.
                          Reads ./<system>/.env (ebs/.env, peoplesoft/.env, jde/.env; the root
                          .env is never used). Create one with --init-env.

Options:
  --project ID            GCP project ID           (default: <system>/.env, then active gcloud project)
  --region REGION         Cloud Run region         (default: GOOGLE_CLOUD_REGION, then GOOGLE_CLOUD_LOCATION, then ${DEFAULT_REGION})
  --service-account SA    Runtime service account  (default: <ebs|ps|jde>-service-account@<project>.iam.gserviceaccount.com)
  --service-name NAME     Cloud Run service name   (default: mcp-toolbox-<ebs|ps|jde>)
  --bucket, --config-bucket BUCKET  GCS bucket for tools.yaml storage (default: MCP_TOOLBOX_BUCKET in <system>/.env, or auto-discovered)
  --secret-name NAME      [Legacy] Secret Manager secret holding tools.yaml (default: <service-name>-secrets)
  --image URL             Toolbox container image
  --tools-file PATH       tools.yaml to deploy     (default: <system>/tools.yaml, or <system>/tools_<variant>.yaml with --variant)
  --network NAME          VPC network for Direct VPC egress (to reach the database)
  --subnet NAME           Subnet in that network and region

Setup:
  --init-env              Create <system>/.env from .env.example, replacing its {{...}}
                          placeholders ({{SYSTEM}}, {{SYSTEM_SHORT}}, {{SYSTEM_UPPER}}) for the
                          chosen system, then exit. Asks before overwriting (-y to skip; -n previews).

Checks and fixes:
  --preflight, --check    Resolve blank settings and verify GCP artefacts only, then exit
  --skip-preflight        Skip blank-setting resolution and the preflight checks
  --rotate-secrets        Prompt for new values of the database credential secrets (adds new versions)
  --rotate-tools          Only replace the tools yaml in the Cloud Storage bucket (gs://<bucket>/<service>/tools.yaml)
                          with the local --tools-file, after confirmation. No deploy, no preflight. Afterwards it
                          offers to restart the service so it loads the new file (see --no-restart).
  --no-restart            After an actual rotation, do not restart the Cloud Run service (it keeps the old
                          tools or secret values until its instances restart). By default a restart is
                          offered after --rotate-tools and done after --rotate-secrets when the deploy did not
                          already start a new revision.
  --fix                   Apply fixes for missing APIs, service account and IAM roles
  -y, --yes               Do not prompt; assume 'yes' (required when non-interactive)
  -n, --dry-run           Print the commands without executing anything
  -s, --status            Show the current Cloud Run service and exit
  -h, --help              Show this help

Database credentials (DB_CONNECTION_STRING, DB_USER, DB_PASSWORD, ...) are read from the
environment, then <system>/.env.database (created by --init-env, mode 600), then a hidden prompt,
so a fully unattended deploy needs that file filled in.

Settings read from <system>/.env (written back when you agree):
  GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_PROJECT_NUMBER, GOOGLE_CLOUD_REGION,
  GOOGLE_CLOUD_SERVICE_ACCOUNT, GOOGLE_CLOUD_NETWORK, GOOGLE_CLOUD_SUBNET,
  MCP_TOOLBOX_SERVICE_NAME, MCP_TOOLBOX_BUCKET, MCP_TOOLBOX_SECRET_NAME,
  MCP_TOOLBOX_IMAGE, MCP_TOOLBOX_TOOLS_FILE, MCP_SERVER_SQL_URL (set after deploying)
EOF
    exit 0
}

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --system)          [ $# -ge 2 ] || die "--system needs a value ({${VALID_SYSTEMS}})"; SYSTEM="$2"; shift 2 ;;
        --variant)         [ $# -ge 2 ] || die "--variant needs a value (for example sec or agent)"; VARIANT="$2"; shift 2 ;;
        --project)         PROJECT="$2"; CLI_SET+="project "; shift 2 ;;
        --region)          REGION="$2"; CLI_SET+="region "; shift 2 ;;
        --service-account) SERVICE_ACCOUNT="$2"; CLI_SET+="service-account "; shift 2 ;;
        --service-name)    SERVICE_NAME="$2"; CLI_SET+="service-name "; shift 2 ;;
        --bucket|--config-bucket)
            CONFIG_BUCKET="${2#gs://}"
            CONFIG_BUCKET="${CONFIG_BUCKET%/}"
            CLI_SET+="bucket "
            shift 2 ;;
        --secret-name)     SECRET_NAME="$2"; CLI_SET+="secret-name "; shift 2 ;;
        --image)           IMAGE="$2"; CLI_SET+="image "; shift 2 ;;
        --tools-file)      TOOLS_FILE="$2"; CLI_SET+="tools-file "; shift 2 ;;
        --network)         NETWORK="$2"; CLI_SET+="network "; shift 2 ;;
        --subnet)          SUBNET="$2"; CLI_SET+="subnet "; shift 2 ;;
        --init-env)        INIT_ENV=true; shift ;;
        --preflight|--check) PREFLIGHT_ONLY=true; shift ;;
        --skip-preflight)  SKIP_PREFLIGHT=true; shift ;;
        --fix)             FIX_MODE=true; shift ;;
        --rotate-secrets)  ROTATE_SECRETS=true; shift ;;
        --rotate-tools)    ROTATE_TOOLS=true; shift ;;
        --no-restart)      NO_RESTART=true; shift ;;
        -y|--yes)          ASSUME_YES=true; shift ;;
        -n|--dry-run)      DRY_RUN=true; shift ;;
        -s|--status)       CHECK_STATUS=true; shift ;;
        -h|--help)         usage ;;
        *) die "Unknown argument: $1 (see --help)" ;;
    esac
done

# --- Select the system (required, no default) and its isolated env file ---
[ -n "${SYSTEM}" ] || die "--system is required: one of {${VALID_SYSTEMS}}. See --help."
SYSTEM="$(printf '%s' "${SYSTEM}" | tr 'A-Z' 'a-z')"
case "${SYSTEM}" in
    ebs)            SYSTEM_SHORT="ebs" ;;
    peoplesoft|ps)  SYSTEM="peoplesoft"; SYSTEM_SHORT="ps" ;;
    jde)            SYSTEM_SHORT="jde" ;;
    *) die "Unknown --system '${SYSTEM}'. Valid: {${VALID_SYSTEMS}}." ;;
esac
VARIANT="$(printf '%s' "${VARIANT}" | tr 'A-Z' 'a-z')"
[[ -z "${VARIANT}" || "${VARIANT}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "--variant '${VARIANT}': use lowercase letters, digits and single hyphens (for example sec, agent)."
VARIANT_SUFFIX="${VARIANT:+-${VARIANT}}"         # -sec   (service and secret names)
VARIANT_EXT="${VARIANT:+.${VARIANT}}"            # .sec   (env file names)
SYSARGS="--system ${SYSTEM}${VARIANT:+ --variant ${VARIANT}}"
DEFAULT_SERVICE_NAME="mcp-toolbox-${SYSTEM_SHORT}${VARIANT_SUFFIX}"
DEFAULT_SA_NAME="${SYSTEM_SHORT}-service-account"
# This repo keeps it in <system>/tools.yaml; the older layout used MCPServers/mcp-toolbox-<system>/.
# With --variant NAME the default is <system>/tools_NAME.yaml (generate it with
# sync_sql_to_yaml.py --system <system> --out tools_NAME.yaml).
DEFAULT_TOOLS_FILE="${SYSTEM}/tools${VARIANT:+_${VARIANT}}.yaml"
if [ -z "${VARIANT}" ]; then
    [ -f "${REPO_ROOT}/${DEFAULT_TOOLS_FILE}" ] || ! [ -f "${REPO_ROOT}/MCPServers/mcp-toolbox-${SYSTEM}/tools.yaml" ] \
        || DEFAULT_TOOLS_FILE="MCPServers/mcp-toolbox-${SYSTEM}/tools.yaml"
fi
# Existing <system>/tools*.yaml files, repo-relative: the default first, then tools.yaml, then the rest
tools_file_candidates() {
    local f rel seen=" "
    for f in "${REPO_ROOT}/${DEFAULT_TOOLS_FILE}" "${REPO_ROOT}/${SYSTEM}/tools.yaml" "${REPO_ROOT}/${SYSTEM}"/tools?*.yaml; do
        [ -f "${f}" ] || continue
        rel="${f#${REPO_ROOT}/}"
        [[ "${seen}" == *" ${rel} "* ]] && continue
        seen+="${rel} "; echo "${rel}"
    done
}
# Deliberately ignores DEPLOY_ENV_FILE and the plain .env: one env file per system.
ENV_FILE="${REPO_ROOT}/${SYSTEM}/.env${VARIANT_EXT}"
DB_ENV_FILE="${REPO_ROOT}/${SYSTEM}/.env${VARIANT_EXT}.database"   # DB_CONNECTION_STRING / DB_USER / DB_PASSWORD (optional)
# A variant without its own credentials file shares the system's
if [ -n "${VARIANT}" ] && [ ! -f "${DB_ENV_FILE}" ] && [ -f "${REPO_ROOT}/${SYSTEM}/.env.database" ]; then
    DB_ENV_FILE="${REPO_ROOT}/${SYSTEM}/.env.database"
fi
# Older layout kept these at the repo root as .env.<system> and .env.<system>.database
LEGACY_ENV_FILE="${REPO_ROOT}/.env.${SYSTEM}"
LEGACY_DB_ENV_FILE="${REPO_ROOT}/.env.${SYSTEM}.database"
source "${SCRIPT_DIR}/gcp_common.sh"   # confirm, env_set, offer_save, choose_from, pf_*

if [ "${INIT_ENV}" != true ] && [ -z "${VARIANT}" ]; then
    for _pair in "${LEGACY_ENV_FILE}|${ENV_FILE}" "${LEGACY_DB_ENV_FILE}|${DB_ENV_FILE}"; do
        _old="${_pair%%|*}"; _new="${_pair##*|}"
        if [ -f "${_old}" ] && [ ! -e "${_new}" ]; then
            if confirm "Move ${_old#${REPO_ROOT}/} to ${_new#${REPO_ROOT}/} (new location)?"; then
                mv "${_old}" "${_new}" && info "Moved ${_old#${REPO_ROOT}/} -> ${_new#${REPO_ROOT}/}"
            else
                die "${_old#${REPO_ROOT}/} is at its old location; move it to ${_new#${REPO_ROOT}/}."
            fi
        fi
    done
fi
if [ "${INIT_ENV}" = true ]; then
    TEMPLATE="${REPO_ROOT}/.env.example"
    [ -f "${TEMPLATE}" ] || die "${TEMPLATE} not found."
    info "Template: ${TEMPLATE}  ->  ${ENV_FILE}"
    if [ "${DRY_RUN}" = true ]; then
        info "[dry-run] would write ${ENV_FILE} with SYSTEM=${SYSTEM} SYSTEM_SHORT=${SYSTEM_SHORT}"
        exit 0
    fi
    if [ -e "${ENV_FILE}" ]; then
        confirm "${ENV_FILE#${REPO_ROOT}/} exists. Overwrite it?" || die "Not overwritten."
        ENV_BACKUP="${ENV_FILE}.bak.$(date +%Y%m%d%H%M%S)"
        cp -p "${ENV_FILE}" "${ENV_BACKUP}" && info "Previous file kept as ${ENV_BACKUP##*/}"
    fi
    SYSTEM_UPPER="$(printf '%s' "${SYSTEM}" | tr 'a-z' 'A-Z')"
    sed -e "s/{{VARIANT_SUFFIX}}/${VARIANT_SUFFIX}/g" \
        -e "s/{{SYSTEM_SHORT}}/${SYSTEM_SHORT}/g" \
        -e "s/{{SYSTEM_UPPER}}/${SYSTEM_UPPER}/g" \
        -e "s/{{SYSTEM}}/${SYSTEM}/g" "${TEMPLATE}" > "${ENV_FILE}"
    if grep -n '{{[A-Z_]*}}' "${ENV_FILE}" >&2; then die "Unreplaced placeholders remain in ${ENV_FILE}."; fi
    chmod 600 "${ENV_FILE}"
    DB_TEMPLATE="${REPO_ROOT}/.env.example.database"
    if [ -n "${VARIANT}" ] && [ ! -f "${REPO_ROOT}/${SYSTEM}/.env${VARIANT_EXT}.database" ]; then
        info "Variant '${VARIANT}' shares ${SYSTEM}/.env.database; create ${SYSTEM}/.env${VARIANT_EXT}.database only if it needs its own credentials."
    elif [ -f "${DB_ENV_FILE}" ]; then
        info "${DB_ENV_FILE##*/} already exists; left unchanged."
    elif [ -f "${DB_TEMPLATE}" ]; then
        sed -e "s/{{SYSTEM_UPPER}}/${SYSTEM_UPPER}/g" -e "s/{{SYSTEM}}/${SYSTEM}/g" "${DB_TEMPLATE}" > "${DB_ENV_FILE}"
        chmod 600 "${DB_ENV_FILE}"
        info "Created ${DB_ENV_FILE}: fill in DB_CONNECTION_STRING, DB_USER and DB_PASSWORD for unattended deploys."
    fi
    info "Created ${ENV_FILE}. Next: ./scripts/deploy_mcp_server.sh ${SYSARGS} --check"
    exit 0
fi
[ -f "${ENV_FILE}" ] || die "${ENV_FILE} not found. Create it first: ./scripts/deploy_mcp_server.sh ${SYSARGS} --init-env"
info "System: ${SYSTEM}${VARIANT:+   Variant: ${VARIANT}}   Env file: ${ENV_FILE}"

TMP_PF=$(mktemp)
trap 'rm -f "${TMP_PF}"' EXIT

command -v gcloud >/dev/null 2>&1 || die "gcloud CLI not found in PATH."
command -v python3 >/dev/null 2>&1 || die "python3 not found in PATH."

# --- Load settings: command line > .env > derived/default ---
from_env() {  # from_env VAR_NAME ENV_KEY CLI_NAME
    cli_set "$3" && return 0
    local v; v="$(env_value "$2")"
    [ -n "${v}" ] && printf -v "$1" '%s' "${v}"
    return 0
}
from_env PROJECT            GOOGLE_CLOUD_PROJECT          project
from_env PROJECT_NUMBER     GOOGLE_CLOUD_PROJECT_NUMBER   project-number
from_env REGION             GOOGLE_CLOUD_REGION           region
from_env SERVICE_ACCOUNT    GOOGLE_CLOUD_SERVICE_ACCOUNT  service-account
if ! cli_set network; then
    ENV_SVC="$(env_value MCP_TOOLBOX_SERVICE_NAME)"
    if ! cli_set service-name || { [ -n "${ENV_SVC}" ] && [ "${SERVICE_NAME}" = "${ENV_SVC}" ]; }; then
        from_env NETWORK            GOOGLE_CLOUD_NETWORK          network
        from_env SUBNET             GOOGLE_CLOUD_SUBNET           subnet
    fi
fi
from_env SERVICE_NAME       MCP_TOOLBOX_SERVICE_NAME      service-name
if ! cli_set secret-name; then
    ENV_SVC="$(env_value MCP_TOOLBOX_SERVICE_NAME)"
    if ! cli_set service-name || { [ -n "${ENV_SVC}" ] && [ "${SERVICE_NAME}" = "${ENV_SVC}" ]; }; then
        from_env SECRET_NAME MCP_TOOLBOX_SECRET_NAME secret-name
    fi
fi
if ! cli_set bucket; then
    ENV_SVC="$(env_value MCP_TOOLBOX_SERVICE_NAME)"
    if ! cli_set service-name || { [ -n "${ENV_SVC}" ] && [ "${SERVICE_NAME}" = "${ENV_SVC}" ]; }; then
        from_env CONFIG_BUCKET MCP_TOOLBOX_BUCKET bucket
        if [ -n "${CONFIG_BUCKET}" ]; then
            CONFIG_BUCKET="${CONFIG_BUCKET#gs://}"
            CONFIG_BUCKET="${CONFIG_BUCKET%/}"
        else
            gcs_fallback="$(env_value GOOGLE_CLOUD_STORAGE_BUCKET)"
            if [ -n "${gcs_fallback}" ]; then
                CONFIG_BUCKET="${gcs_fallback#gs://}"
                CONFIG_BUCKET="${CONFIG_BUCKET%/}"
            fi
        fi
    fi
fi
from_env IMAGE              MCP_TOOLBOX_IMAGE             image
from_env TOOLS_FILE         MCP_TOOLBOX_TOOLS_FILE        tools-file
GOOGLE_CLIENT_ID="$(env_value GOOGLE_CLIENT_ID)"
MCP_SERVER_SQL_URL="$(env_value MCP_SERVER_SQL_URL)"

# Region falls back to the model location, unless that is "global"
if [ -z "${REGION}" ]; then
    LOC="$(env_value GOOGLE_CLOUD_LOCATION)"
    [ -n "${LOC}" ] && [ "${LOC}" != "global" ] && REGION="${LOC}"
fi

# Project defaults come from the environment we are actually running against
[ -n "${PROJECT}" ] || PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
if [ -z "${PROJECT_NUMBER}" ] && [ -n "${PROJECT}" ]; then
    PROJECT_NUMBER="$(gcloud projects describe "${PROJECT}" --format='value(projectNumber)' 2>/dev/null || true)"
fi
[ -n "${SERVICE_ACCOUNT}" ] || { [ -z "${PROJECT}" ] || SERVICE_ACCOUNT="${DEFAULT_SA_NAME}@${PROJECT}.iam.gserviceaccount.com"; }
[ -n "${SERVICE_NAME}" ] || SERVICE_NAME="${DEFAULT_SERVICE_NAME}"
[ -n "${SECRET_NAME}" ]  || SECRET_NAME="${SERVICE_NAME}-secrets"
[ -n "${IMAGE}" ]        || IMAGE="${DEFAULT_IMAGE}"
[ -n "${TOOLS_FILE}" ]   || TOOLS_FILE="${DEFAULT_TOOLS_FILE}"
[ -n "${REGION}" ]       || REGION="${DEFAULT_REGION}"

# Resolve the tools file against the repo root when relative
tools_path() { case "${TOOLS_FILE}" in /*) echo "${TOOLS_FILE}" ;; *) echo "${REPO_ROOT}/${TOOLS_FILE}" ;; esac; }

# --- Status shortcut ---
if [ "${CHECK_STATUS}" = true ]; then
    [ -n "${PROJECT}" ] || die "No project selected."
    info "Cloud Run service '${SERVICE_NAME}' in ${PROJECT}/${REGION}:"
    gcloud run services describe "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" \
        --format='table(metadata.name,status.url,status.latestReadyRevisionName,status.conditions[0].status:label=READY,spec.template.spec.serviceAccountName)'
    exit $?
fi

# ==============================================================================
# Database credentials: ${VARIABLE} placeholders in tools.yaml <-> Secret Manager
# ==============================================================================
# Secret holding the value of placeholder VAR, e.g. DB_USER -> <service>-db-user
secret_for_var() { echo "${SERVICE_NAME}-$(tr 'A-Z_' 'a-z-' <<<"$1")"; }

# Roles granted to service account $2 on bucket $1
bucket_sa_roles() {
    local bkt="${1#gs://}"; bkt="${bkt%/}"
    local sa="$2"
    gcloud storage buckets get-iam-policy "gs://${bkt}" --format=json 2>/dev/null | \
        python3 -c "import json, sys; d=json.load(sys.stdin); print('\n'.join(b['role'] for b in d.get('bindings',[]) if f'serviceAccount:{sys.argv[1]}' in b.get('members',[])))" "${sa}" 2>/dev/null || true
}

# Distinct ${NAME} placeholders (with or without :default) used outside comments
yaml_placeholders() {
    python3 - "$(tools_path)" <<'PY'
import re, sys
seen = []
regex = re.compile(r"\$\{\s*([A-Za-z_][A-Za-z0-9_]*)(?::[^}]*)?\s*\}")
try:
    import yaml
    with open(sys.argv[1]) as f:
        d = yaml.safe_load(f)
    def walk(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(k, str):
                    for m in regex.finditer(k):
                        if m.group(1) not in seen:
                            seen.append(m.group(1))
                walk(v)
        elif isinstance(obj, list):
            for item in obj:
                walk(item)
        elif isinstance(obj, str):
            for m in regex.finditer(obj):
                if m.group(1) not in seen:
                    seen.append(m.group(1))
    walk(d)
except Exception:
    seen = []
    for line in open(sys.argv[1]):
        if line.lstrip().startswith("#"):
            continue
        line = line.split("#")[0]
        for m in regex.finditer(line):
            if m.group(1) not in seen:
                seen.append(m.group(1))
print("\n".join(seen))
PY
}

# Extract default value for a placeholder ${VAR:default} if defined in tools.yaml
yaml_default_for_var() {
    python3 - "$(tools_path)" "$1" <<'PY'
import re, sys
var = sys.argv[2]
regex = re.compile(r"\$\{\s*" + re.escape(var) + r":([^}]*)\}")
try:
    import yaml
    with open(sys.argv[1]) as f:
        d = yaml.safe_load(f)
    def walk(obj):
        if isinstance(obj, dict):
            for v in obj.values():
                res = walk(v)
                if res is not None: return res
        elif isinstance(obj, list):
            for item in obj:
                res = walk(item)
                if res is not None: return res
        elif isinstance(obj, str):
            m = regex.search(obj)
            if m: return m.group(1)
        return None
    val = walk(d)
    if val is not None:
        sys.stdout.write(val.lstrip("-="))
        sys.exit(0)
except Exception:
    pass
for line in open(sys.argv[1]):
    if line.lstrip().startswith("#"):
        continue
    m = regex.search(line.split("#")[0])
    if m:
        sys.stdout.write(m.group(1).lstrip("-="))
        break
PY
}

# Literal (non-placeholder) user/password/connectionString in sources: "source|key|ENVVAR|secret" per line. No values.
hardcoded_plan() {
    python3 - "$(tools_path)" "${SERVICE_NAME}" <<'PY'
import re, sys
try:
    import yaml
    d = yaml.safe_load(open(sys.argv[1])) or {}
except Exception:
    sys.exit(0)
ph = re.compile(r"^\$\{[A-Za-z_][A-Za-z0-9_]*(:[^}]*)?\}$")
names = {"connectionString": "CONNECTION_STRING", "user": "USER", "password": "PASSWORD"}
for src, cfg in (d.get("sources") or {}).items():
    for key, suffix in names.items():
        v = (cfg or {}).get(key)
        if v is not None and not ph.match(str(v).strip()):
            env = re.sub(r"[^A-Za-z0-9]", "_", src).upper() + "_" + suffix
            print("%s|%s|%s|%s-%s" % (src, key, env, sys.argv[2], env.lower().replace("_", "-")))
PY
}

# Print one literal value without a trailing newline (piped straight into gcloud)
yaml_literal() {
    python3 - "$(tools_path)" "$1" "$2" <<'PY'
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
sys.stdout.write(str(d["sources"][sys.argv[2]][sys.argv[3]]))
PY
}

is_plain_var() { local v; for v in "${PLAIN_TEMPLATE_VARS[@]}"; do [ "${v}" = "$1" ] && return 0; done; return 1; }
secret_placeholders() { local v; for v in $(yaml_placeholders); do is_plain_var "${v}" || echo "${v}"; done; }
plain_placeholders()  { local v; for v in $(yaml_placeholders); do ! is_plain_var "${v}" || echo "${v}"; done; }

# authServices clientId values that are literals rather than ${VARIABLES}: "name|clientId" per line
literal_client_ids() {
    python3 - "$(tools_path)" <<'PY'
import re, sys
try:
    import yaml
    d = yaml.safe_load(open(sys.argv[1])) or {}
except Exception:
    sys.exit(0)
ph = re.compile(r"^\$\{[A-Za-z_][A-Za-z0-9_]*(:[^}]*)?\}$")
for name, a in (d.get("authServices") or {}).items():
    cid = str((a or {}).get("clientId") or "").strip()
    if cid and not ph.match(cid):
        print("%s|%s" % (name, cid))
PY
}

# Replace a literal authServices clientId with ${GOOGLE_CLIENT_ID} (a plain env var fed from .env).
# .env stays the single source of truth, so it must hold the right value first.
parameterize_client_id() {
    local lits; lits="$(literal_client_ids)"
    [ -n "${lits}" ] || return 0
    local name cid
    while IFS='|' read -r name cid; do
        echo "     authService '${name}': clientId ${cid}  ->  \${GOOGLE_CLIENT_ID}"
    done <<<"${lits}"
    if [ "$(cut -d'|' -f2 <<<"${lits}" | sort -u | wc -l | tr -d ' ')" != "1" ]; then
        echo "     ✖ the authServices use different client IDs; parameterize them by hand" >&2; return 1
    fi
    local lit; lit="$(head -1 <<<"${lits}" | cut -d'|' -f2)"
    if [ -z "${GOOGLE_CLIENT_ID}" ] || [[ "${GOOGLE_CLIENT_ID}" != "${PROJECT_NUMBER}-"* ]]; then
        if [[ "${lit}" == "${PROJECT_NUMBER}-"* ]]; then
            if [ -n "${GOOGLE_CLIENT_ID}" ]; then echo "     ${ENV_FILE#${REPO_ROOT}/} GOOGLE_CLIENT_ID belongs to project ${GOOGLE_CLIENT_ID%%-*}; tools.yaml's client belongs to this project."
            else echo "     ${ENV_FILE#${REPO_ROOT}/} GOOGLE_CLIENT_ID is blank; tools.yaml's client belongs to this project."; fi
            offer_save GOOGLE_CLIENT_ID "${lit}" || { echo "     ✖ ${ENV_FILE#${REPO_ROOT}/} must hold the client ID before tools.yaml can use \${GOOGLE_CLIENT_ID}" >&2; return 1; }
            GOOGLE_CLIENT_ID="${OFFER_VALUE}"
        else
            echo "     ✖ neither ${ENV_FILE#${REPO_ROOT}/} nor tools.yaml has a client ID belonging to project ${PROJECT_NUMBER}" >&2; return 1
        fi
    elif [ "${GOOGLE_CLIENT_ID}" != "${lit}" ]; then
        echo "     ✖ ${ENV_FILE#${REPO_ROOT}/} GOOGLE_CLIENT_ID differs from tools.yaml's; decide which is right, then re-run" >&2; return 1
    fi
    approve "Rewrite tools.yaml to use \${GOOGLE_CLIENT_ID}?" || return 1
    python3 - "$(tools_path)" <<'PY'
import os, re, sys, tempfile
path = sys.argv[1]
out, top = [], None
for line in open(path).read().split("\n"):
    m = re.match(r"^([A-Za-z_][\w-]*):", line)
    if m:
        top = m.group(1)
    elif top == "authServices":
        m = re.match(r"^(    )clientId:\s*(.*)$", line)
        if m and not re.match(r"^\$\{", m.group(2).strip().strip("\"'")):
            line = '%sclientId: "${GOOGLE_CLIENT_ID}"' % m.group(1)
    out.append(line)
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path))
with os.fdopen(fd, "w") as f:
    f.write("\n".join(out))
os.chmod(tmp, os.stat(path).st_mode & 0o777)
os.replace(tmp, path)
PY
    echo "     ✅ tools.yaml now takes the client ID from \${GOOGLE_CLIENT_ID}"
}

secret_exists() { gcloud secrets describe "$1" --project "${PROJECT}" >/dev/null 2>&1; }

# Move hardcoded credentials into Secret Manager, then rewrite tools.yaml to use ${VARIABLES}.
# Secrets are created first; the file is only rewritten once every secret exists.
migrate_credentials() {
    local plan; plan="$(hardcoded_plan)"
    [ -n "${plan}" ] || return 0
    local src key envv secret
    echo "     tools.yaml has hardcoded database credentials (values are not shown):"
    while IFS='|' read -r src key envv secret; do
        echo "       source '${src}': ${key}  ->  \${${envv}}  (secret: ${secret})"
    done <<<"${plan}"
    approve "Store these in Secret Manager and rewrite tools.yaml to use \${VARIABLES}?" || return 1
    while IFS='|' read -r src key envv secret; do
        if secret_exists "${secret}"; then
            echo "     ℹ️  ${secret} already exists - keeping its value (not overwritten)"
        else
            yaml_literal "${src}" "${key}" | gcloud secrets create "${secret}" --data-file=- \
                --replication-policy=automatic --project "${PROJECT}" >/dev/null \
                || { echo "     ✖ could not create ${secret}; tools.yaml left unchanged" >&2; return 1; }
            echo "     🔐 created ${secret}"
        fi
    done <<<"${plan}"
    python3 - "$(tools_path)" <<'PY'
import os, re, sys, tempfile
path = sys.argv[1]
names = {"connectionString": "CONNECTION_STRING", "user": "USER", "password": "PASSWORD"}
ph = re.compile(r"^\$\{[A-Za-z_][A-Za-z0-9_]*(:[^}]*)?\}$")
out, top, src = [], None, None
for line in open(path).read().split("\n"):
    m = re.match(r"^([A-Za-z_][\w-]*):", line)
    if m:
        top, src = m.group(1), None
    elif top == "sources":
        m = re.match(r"^  ([A-Za-z_][\w.-]*):\s*$", line)
        if m:
            src = m.group(1)
        else:
            m = re.match(r"^(    )(connectionString|user|password):\s*(.*)$", line)
            if m and src and not ph.match(m.group(3).split(" #")[0].strip().strip("\"'")):
                env = re.sub(r"[^A-Za-z0-9]", "_", src).upper() + "_" + names[m.group(2)]
                line = '%s%s: "${%s}"' % (m.group(1), m.group(2), env)
    out.append(line)
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path))
with os.fdopen(fd, "w") as f:
    f.write("\n".join(out))
os.chmod(tmp, os.stat(path).st_mode & 0o777)
os.replace(tmp, path)
PY
    echo "     ✅ tools.yaml now references the secrets by \${VARIABLE}"
}

# Obtain the value for VAR: environment variable of the same name, else a silent prompt (with default from tools.yaml if present).
# Value of KEY from <system>/.env.database, read literally (never sourced or expanded); empty if absent.
db_file_value() {
    [ -f "${DB_ENV_FILE}" ] || return 0
    local line v
    line="$(grep -E "^[[:space:]]*(export[[:space:]]+)?$1=" "${DB_ENV_FILE}" | tail -1 || true)"   # "export KEY=..." is accepted too
    [ -n "${line}" ] || return 0
    v="${line#*=}"
    if [ "${#v}" -ge 2 ] && [ "${v:0:1}" = '"' ] && [ "${v: -1}" = '"' ]; then v="${v:1:${#v}-2}"; fi
    printf '%s' "${v}"
}

# Warn once when the credentials file is readable by other users
db_file_check_perms() {
    [ -f "${DB_ENV_FILE}" ] || return 0
    local mode; mode="$(stat -f '%Lp' "${DB_ENV_FILE}" 2>/dev/null || stat -c '%a' "${DB_ENV_FILE}" 2>/dev/null || echo 600)"
    case "${mode}" in
        *00) ;;
        *) echo "  ⚠️  ${DB_ENV_FILE##*/} has mode ${mode}; it holds credentials. Run: chmod 600 ${DB_ENV_FILE}" >&2 ;;
    esac
}

read_secret_value() {  # sets SECRET_VALUE: environment, then <system>/.env.database, then a prompt
    SECRET_VALUE="${!1-}"
    [ -n "${SECRET_VALUE}" ] && return 0
    SECRET_VALUE="$(db_file_value "$1")"
    [ -n "${SECRET_VALUE}" ] && return 0
    local def_val; def_val="$(yaml_default_for_var "$1")"
    if [ -t 0 ]; then
        local prompt_msg="     Enter value for ${1}"
        [ -n "${def_val}" ] && prompt_msg+=" [default: ${def_val}]"
        read -rs -p "${prompt_msg} (hidden): " SECRET_VALUE || return 1
        echo
        [ -z "${SECRET_VALUE}" ] && [ -n "${def_val}" ] && SECRET_VALUE="${def_val}"
    else
        [ -n "${def_val}" ] && SECRET_VALUE="${def_val}"
    fi
    [ -n "${SECRET_VALUE}" ]
}

# Restart the Cloud Run service by starting a new revision. A service-level annotation alone does not restart
# anything (it changes no revision), so a harmless environment variable carries the change, and an annotation
# records why and when. REASON must not contain commas.
restart_service() {  # restart_service REASON
    local reason="$1" stamp; stamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Executing: gcloud run services update ${SERVICE_NAME} --region ${REGION} --project ${PROJECT} --update-env-vars TOOLBOX_RESTART_AT=<now> --update-annotations restart-reason=\"${reason} ${stamp}\""
    if [ "${DRY_RUN}" = true ]; then echo "[dry-run] ${SERVICE_NAME} would be restarted."; return 0; fi
    gcloud run services update "${SERVICE_NAME}" --region "${REGION}" --project "${PROJECT}" \
        --update-env-vars "TOOLBOX_RESTART_AT=$(date +%s)" \
        --update-annotations "restart-reason=${reason} ${stamp}" >/dev/null \
        && echo "✅ ${SERVICE_NAME} restarted: a new revision is serving with the current tools and secrets."
}

# Create (or rotate) a secret per ${VARIABLE}; values travel over stdin only.
ensure_db_secrets() {
    local var secret exists
    for var in $(secret_placeholders); do
        secret="$(secret_for_var "${var}")"
        exists=false; secret_exists "${secret}" && exists=true
        if [ "${exists}" = true ] && [ "${ROTATE_SECRETS}" = false ]; then
            echo "  ✅ ${var}: secret ${secret} exists"; continue
        fi
        local verb="Create"; [ "${exists}" = true ] && verb="Add a new version of"
        echo "  🔐 ${var}: ${verb} secret ${secret}"
        if [ "${DRY_RUN}" = true ]; then echo "     [dry-run] value would come from \$${var}, ${DB_ENV_FILE##*/} or a hidden prompt"; continue; fi
        if [ "${exists}" = true ]; then
            # Rotation: read the new value first and compare it with the current version, byte for byte (only
            # hashes are compared; neither value is printed). An identical value is not worth a new version.
            read_secret_value "${var}" || { echo "❌ No value for ${var}: export ${var}=... or run interactively." >&2; exit 1; }
            local new_hash cur_hash cur_file
            new_hash="$(printf '%s' "${SECRET_VALUE}" | shasum -a 256 | cut -d' ' -f1)"
            cur_file="$(mktemp)"; chmod 600 "${cur_file}"
            if gcloud secrets versions access latest --secret "${secret}" --project "${PROJECT}" >"${cur_file}" 2>/dev/null; then
                cur_hash="$(shasum -a 256 <"${cur_file}" | cut -d' ' -f1)"
                if [ "${cur_hash}" = "${new_hash}" ]; then
                    rm -f "${cur_file}"
                    echo "     ⚠️  The new value of ${var} is IDENTICAL to the current version of ${secret}; no new version added."
                    SECRET_VALUE=""; continue
                fi
                # Same text but not the same bytes: only the trailing newline or whitespace differs
                if [ "$(cat "${cur_file}")" = "${SECRET_VALUE}" ]; then
                    echo "     ⚠️  The current version of ${secret} differs from the new value only by a trailing newline or whitespace;" \
                         "the new version removes it (a stray newline in a credential is a classic cause of ORA-01017)."
                fi
            else
                echo "     ℹ️  Could not read the current version of ${secret} to compare (needs roles/secretmanager.secretAccessor); adding the new value."
            fi
            rm -f "${cur_file}"
            confirm "${verb} secret '${secret}'?" || { echo "Secret not confirmed. Nothing was changed." >&2; exit 1; }
            printf '%s' "${SECRET_VALUE}" | gcloud secrets versions add "${secret}" --data-file=- --project "${PROJECT}" >/dev/null
            SECRETS_ROTATED=$((SECRETS_ROTATED + 1))
        else
            confirm "${verb} secret '${secret}'?" || { echo "Secret not confirmed. Nothing was changed." >&2; exit 1; }
            read_secret_value "${var}" || { echo "❌ No value for ${var}: export ${var}=... or run interactively." >&2; exit 1; }
            printf '%s' "${SECRET_VALUE}" | gcloud secrets create "${secret}" --data-file=- --replication-policy=automatic --project "${PROJECT}" >/dev/null
        fi
        SECRET_VALUE=""
        echo "     ✅ done"
    done
}

# ==============================================================================
# Blank-variable resolution: offer to create/discover, save to .env
# ==============================================================================
# Ask the user to type a value for KEY (sets ASKED; empty when skipped or non-interactive).
ASKED=""
ask_value() {  # ask_value LABEL
    ASKED=""
    [ -t 0 ] || return 1   # asked even with --yes: this value is not known from the env file or command line
    read -r -p "     ❓ Enter ${1} (blank to skip): " ASKED || return 1
    [ -n "${ASKED}" ]
}

howto_network() {
    cat <<EOT
     📖 The Toolbox needs a VPC network + subnet that can reach the database host in tools.yaml.
          List them:   gcloud compute networks list --project ${PROJECT}
                       gcloud compute networks subnets list --project ${PROJECT} --regions ${REGION}
          Create one:  gcloud compute networks create <name> --subnet-mode=custom --project ${PROJECT}
                       gcloud compute networks subnets create <subnet> --network <name> --region ${REGION} --range <CIDR> --project ${PROJECT}
          Then set GOOGLE_CLOUD_NETWORK and GOOGLE_CLOUD_SUBNET in ${ENV_FILE}.
EOT
}

howto_tools_file() {
    cat <<EOT
     📖 tools.yaml not found at $(tools_path).
          Put the Toolbox configuration there (sources, tools, authServices) or point to it with
          --tools-file / MCP_TOOLBOX_TOOLS_FILE in ${ENV_FILE}.
EOT
}

simple_blank() {  # simple_blank ENV_KEY VALUE CLI_NAME VAR  - blank in .env: propose the derived value (VAR gets the saved one)
    local key="$1" val="$2" cli="$3" var="${4:-}"
    if env_blank "${key}" && ! cli_set "${cli}"; then
        FOUND=true; echo "  ⚠️  ${key} is blank"
        if offer_save "${key}" "${val}" && [ -n "${var}" ]; then printf -v "${var}" '%s' "${OFFER_VALUE}"; fi
    fi
}

resolve_blank_vars() {
    echo "=================================================================="
    echo "🧩 Checking for blank settings in ${ENV_FILE}"
    echo "=================================================================="
    FOUND=false
    local cand
    if [ -z "$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -1)" ]; then
        echo "  ⚠️  gcloud is not logged in; skipping (run: gcloud auth login)"; echo ""; return 0
    fi

    if env_blank GOOGLE_CLOUD_PROJECT && ! cli_set project; then
        FOUND=true; echo "  ⚠️  GOOGLE_CLOUD_PROJECT is blank"
        cand="$(gcloud config get-value project 2>/dev/null || true)"
        if [ -n "${cand}" ]; then
            echo "     (active gcloud project)"
            offer_save GOOGLE_CLOUD_PROJECT "${cand}" && PROJECT="${OFFER_VALUE}" || true
        else
            echo "     📖 No active gcloud project. Run: gcloud config set project <PROJECT_ID>   (or set GOOGLE_CLOUD_PROJECT in ${ENV_FILE#${REPO_ROOT}/})"
        fi
    fi
    if [ -z "${PROJECT}" ]; then echo "  ❌ No project selected; cannot continue." >&2; exit 1; fi
    [ -n "${SERVICE_ACCOUNT}" ] || SERVICE_ACCOUNT="${DEFAULT_SA_NAME}@${PROJECT}.iam.gserviceaccount.com"

    if env_blank GOOGLE_CLOUD_PROJECT_NUMBER && ! cli_set project-number; then
        FOUND=true; echo "  ⚠️  GOOGLE_CLOUD_PROJECT_NUMBER is blank"
        cand="$(gcloud projects describe "${PROJECT}" --format='value(projectNumber)' 2>/dev/null || true)"
        if [ -n "${cand}" ]; then
            offer_save GOOGLE_CLOUD_PROJECT_NUMBER "${cand}" && PROJECT_NUMBER="${OFFER_VALUE}" || true
        else
            echo "     📖 Find it with: gcloud projects describe ${PROJECT} --format='value(projectNumber)'"
        fi
    fi

    simple_blank GOOGLE_CLOUD_REGION "${REGION}" region REGION

    if env_blank GOOGLE_CLOUD_SERVICE_ACCOUNT && ! cli_set service-account; then
        FOUND=true; echo "  ⚠️  GOOGLE_CLOUD_SERVICE_ACCOUNT is blank"
        if gcloud iam service-accounts describe "${SERVICE_ACCOUNT}" --project "${PROJECT}" >/dev/null 2>&1; then
            echo "     Service account ${SERVICE_ACCOUNT} already exists."
            offer_save GOOGLE_CLOUD_SERVICE_ACCOUNT "${SERVICE_ACCOUNT}" && SERVICE_ACCOUNT="${OFFER_VALUE}" || true
        else
            echo "     Service account ${SERVICE_ACCOUNT} does not exist."
            if do_change "Create service account ${SERVICE_ACCOUNT%%@*}?" gcloud iam service-accounts create "${SERVICE_ACCOUNT%%@*}" \
                --project "${PROJECT}" --display-name "MCP Toolbox"; then
                echo "     ✅ created (grant its roles with: --preflight --fix)"
                sleep 5
                offer_save GOOGLE_CLOUD_SERVICE_ACCOUNT "${SERVICE_ACCOUNT}" && SERVICE_ACCOUNT="${OFFER_VALUE}" || true
            else
                echo "     📖 Create it with: gcloud iam service-accounts create ${SERVICE_ACCOUNT%%@*} --project ${PROJECT}"
            fi
        fi
    fi

    # Network, then a subnet of that network in the deploy region
    local items=() f
    if [ -z "${NETWORK}" ] && ! cli_set network; then
        FOUND=true
        if ! cli_set service-name; then
            echo "  ⚠️  GOOGLE_CLOUD_NETWORK is blank"
        else
            echo "  ℹ️  VPC network not specified for ${SERVICE_NAME}"
        fi
        local net_items=()
        while IFS= read -r f; do [ -n "${f}" ] && net_items+=("${f}"); done < <(gcloud compute networks list --project "${PROJECT}" --format='value(name)' 2>/dev/null)
        local ranked_nets=() svc_kw=""
        svc_kw="${SYSTEM}"
        if [ ${#net_items[@]} -gt 0 ]; then
            for f in "${net_items[@]}"; do
                if [ -n "${svc_kw}" ] && [[ "${f}" =~ ${svc_kw} ]]; then
                    ranked_nets+=("${f}")
                fi
            done
            for f in "${net_items[@]}"; do
                if [ -z "${svc_kw}" ] || [[ ! "${f}" =~ ${svc_kw} ]]; then
                    ranked_nets+=("${f}")
                fi
            done
            if choose_from "VPC network in ${PROJECT}" "${ranked_nets[@]}"; then
                NETWORK="${CHOICE}"
                if ! cli_set service-name; then
                    offer_save GOOGLE_CLOUD_NETWORK "${NETWORK}" && NETWORK="${OFFER_VALUE}" || true
                fi
            fi
        else
            echo "     No VPC networks found in ${PROJECT}."
        fi
        if [ -z "${NETWORK}" ]; then
            if [ ${#net_items[@]} -eq 0 ] && ask_value "the VPC network name"; then
                NETWORK="${ASKED}"
                if ! cli_set service-name; then
                    offer_save GOOGLE_CLOUD_NETWORK "${NETWORK}" && NETWORK="${OFFER_VALUE}" || true
                fi
            else
                howto_network
            fi
        fi
    fi
    if [ -z "${SUBNET}" ] && ! cli_set subnet; then
        FOUND=true
        if ! cli_set service-name; then
            echo "  ⚠️  GOOGLE_CLOUD_SUBNET is blank"
        else
            echo "  ℹ️  Subnet not specified for ${SERVICE_NAME}"
        fi
        items=()
        if [ -n "${NETWORK}" ]; then
            while IFS= read -r f; do [ -n "${f}" ] && items+=("${f}"); done < <(gcloud compute networks subnets list --project "${PROJECT}" \
                --regions "${REGION}" --format='value(name,network.basename())' 2>/dev/null | awk -v n="${NETWORK}" '$2==n{print $1}')
        else
            echo "     (no network chosen; listing all subnets in ${REGION})"
            while IFS= read -r f; do [ -n "${f}" ] && items+=("${f}"); done < <(gcloud compute networks subnets list --project "${PROJECT}" \
                --regions "${REGION}" --format='value(name)' 2>/dev/null)
        fi
        [ ${#items[@]} -gt 0 ] || echo "     No subnets found${NETWORK:+ for network '${NETWORK}'} in ${REGION}."
        if [ ${#items[@]} -gt 0 ]; then
            choose_from "Subnet${NETWORK:+ of '${NETWORK}'} in ${REGION}" "${items[@]}" && SUBNET="${CHOICE}"
        elif ask_value "the subnet name"; then
            SUBNET="${ASKED}"
        fi
        if [ -n "${SUBNET}" ]; then
            if ! cli_set service-name; then
                offer_save GOOGLE_CLOUD_SUBNET "${SUBNET}" && SUBNET="${OFFER_VALUE}" || true
            fi
        else
            howto_network
        fi
    fi

    # Cloud Storage bucket for tools.yaml
    if [ -z "${CONFIG_BUCKET}" ] && ! cli_set bucket; then
        FOUND=true
        if ! cli_set service-name; then
            echo "  ⚠️  MCP_TOOLBOX_BUCKET is blank"
        else
            echo "  ℹ️  Cloud Storage bucket not specified for ${SERVICE_NAME}"
        fi
        local b_items=() b b_loc
        while IFS=$'\t' read -r b b_loc; do
            [ -n "${b}" ] || continue
            if [[ "${b}" =~ (tfstate|terraform) ]]; then continue; fi
            b_items+=("${b}")
        done < <(gcloud storage buckets list --project "${PROJECT}" --format='value(name,location)' 2>/dev/null)

        local ranked=() svc_kw=""
        svc_kw="${SYSTEM}"

        if [ ${#b_items[@]} -gt 0 ]; then
            for b in "${b_items[@]}"; do
                if [ -n "${svc_kw}" ] && [[ "${b}" =~ ${svc_kw} ]]; then
                    ranked+=("${b}")
                fi
            done
            for b in "${b_items[@]}"; do
                if [ -z "${svc_kw}" ] || [[ ! "${b}" =~ ${svc_kw} ]]; then
                    ranked+=("${b}")
                fi
            done
            if choose_from "Cloud Storage bucket in ${PROJECT} for tools.yaml" "${ranked[@]}"; then
                CONFIG_BUCKET="${CHOICE#gs://}"
                CONFIG_BUCKET="${CONFIG_BUCKET%/}"
                if ! cli_set service-name; then
                    offer_save MCP_TOOLBOX_BUCKET "${CONFIG_BUCKET}" && CONFIG_BUCKET="${OFFER_VALUE}" || true
                fi
            fi
        else
            echo "     No suitable Cloud Storage buckets found in project ${PROJECT}."
            local new_bucket="${PROJECT}-toolbox-config"
            if do_change "Create bucket gs://${new_bucket} in ${REGION}?" gcloud storage buckets create "gs://${new_bucket}" --location="${REGION}" --project="${PROJECT}"; then
                CONFIG_BUCKET="${new_bucket}"
                if ! cli_set service-name; then
                    offer_save MCP_TOOLBOX_BUCKET "${CONFIG_BUCKET}" && CONFIG_BUCKET="${OFFER_VALUE}" || true
                fi
            else
                echo "     📖 Create a bucket with: gcloud storage buckets create gs://<bucket-name> --location=${REGION} --project=${PROJECT}"
            fi
        fi
    elif env_blank MCP_TOOLBOX_BUCKET && ! cli_set bucket && [ -n "${CONFIG_BUCKET}" ] && ! cli_set service-name; then
        FOUND=true; echo "  ⚠️  MCP_TOOLBOX_BUCKET is blank in ${ENV_FILE}"
        offer_save MCP_TOOLBOX_BUCKET "${CONFIG_BUCKET}" && CONFIG_BUCKET="${OFFER_VALUE}" || true
    fi

    simple_blank MCP_TOOLBOX_SERVICE_NAME "${SERVICE_NAME}" service-name SERVICE_NAME
    simple_blank MCP_TOOLBOX_IMAGE        "${IMAGE}" image IMAGE
    if env_blank MCP_TOOLBOX_TOOLS_FILE && ! cli_set tools-file; then
        FOUND=true; echo "  ⚠️  MCP_TOOLBOX_TOOLS_FILE is blank"
        local tf_c=() tf_g
        while IFS= read -r tf_g; do tf_c+=("${tf_g}"); done < <(tools_file_candidates)
        if [ ${#tf_c[@]} -gt 0 ]; then
            if choose_from "tools file for ${SYSTEM}" "${tf_c[@]}"; then
                TOOLS_FILE="${CHOICE}"
                [ -f "$(tools_path)" ] && { offer_save MCP_TOOLBOX_TOOLS_FILE "${TOOLS_FILE}" && TOOLS_FILE="${OFFER_VALUE}" || true; }
            fi
        elif ask_value "the path to tools.yaml (absolute, or relative to ${REPO_ROOT})"; then
            TOOLS_FILE="${ASKED}"
            [ -f "$(tools_path)" ] && { offer_save MCP_TOOLBOX_TOOLS_FILE "${TOOLS_FILE}" && TOOLS_FILE="${OFFER_VALUE}" || true; }
        fi
    fi

    if [ ! -f "$(tools_path)" ]; then
        FOUND=true; echo "  ⚠️  tools.yaml is missing"
        howto_tools_file
        local tf_new="" tf_cands=() tf_f
        # <system>/tools*.yaml, with plain tools.yaml first
        while IFS= read -r tf_f; do tf_cands+=("${tf_f}"); done < <(tools_file_candidates)
        if [ ${#tf_cands[@]} -gt 0 ]; then
            choose_from "tools file for ${SYSTEM}" "${tf_cands[@]}" && tf_new="${CHOICE}"
        elif ask_value "the path to tools.yaml (absolute, or relative to ${REPO_ROOT})"; then
            tf_new="${ASKED}"
        fi
        if [ -n "${tf_new}" ]; then
            TOOLS_FILE="${tf_new}"
            if [ -f "$(tools_path)" ]; then
                offer_save MCP_TOOLBOX_TOOLS_FILE "${TOOLS_FILE}" && TOOLS_FILE="${OFFER_VALUE}" || true
            else
                echo "     ✖ $(tools_path) does not exist."
            fi
        fi
    fi

    if [ -f "$(tools_path)" ] && [ -n "$(hardcoded_plan)" ]; then
        FOUND=true; echo "  ⚠️  tools.yaml contains hardcoded database credentials"
        migrate_credentials || echo "     📖 Replace user/password/connectionString in tools.yaml with \${VARIABLE} references and create a secret per variable."
    fi

    if [ -f "$(tools_path)" ] && [ -n "$(literal_client_ids)" ]; then
        FOUND=true; echo "  ⚠️  tools.yaml has a hardcoded authService clientId"
        parameterize_client_id || echo "     📖 Set clientId to \"\${GOOGLE_CLIENT_ID}\" in tools.yaml and put the client ID in ${ENV_FILE#${REPO_ROOT}/}."
    fi

    # OAuth client ID for the google-auth authService (needed once authServices is enabled)
    GOOGLE_CLIENT_ID="$(env_value GOOGLE_CLIENT_ID)"
    if env_blank GOOGLE_CLIENT_ID; then
        FOUND=true; echo "  ⚠️  GOOGLE_CLIENT_ID is blank"
        if grep -qE '^[[:space:]]*clientId:' "$(tools_path)" 2>/dev/null; then
            echo "     Required: $(tools_path | sed "s#${REPO_ROOT}/##") has an active authServices block that uses \${GOOGLE_CLIENT_ID}."
        else
            echo "     Needed only once the google-auth authService is enabled in tools.yaml; skip it while authServices stays disabled."
        fi
        local cid_cands=() cid_f cid_v cid_seen=""
        # scripts/secrets/<system>*.json (downloaded OAuth client files; only client_id is read)
        shopt -s nullglob
        for cid_f in "${SCRIPT_DIR}/secrets/${SYSTEM_SHORT}"*.json "${SCRIPT_DIR}/secrets/${SYSTEM}"*.json; do
            [[ " ${cid_seen:-} " == *" ${cid_f} "* ]] && continue
            cid_seen="${cid_seen:-} ${cid_f}"
            cid_v="$(json_client_field "${cid_f}" client_id)"
            [ -n "${cid_v}" ] && echo "     found client ID in ${cid_f#${REPO_ROOT}/}"
            [ -n "${cid_v}" ] && cid_cands+=("${cid_v}")
        done
        shopt -u nullglob
        for cid_f in $(find_client_jsons || true); do
            cid_v="$(json_client_field "${cid_f}" client_id)"
            [ -n "${cid_v}" ] && cid_cands+=("${cid_v}")
        done
        cid_v="$(grep -h -E '^[[:space:]]*clientId:[[:space:]]*"?[0-9]+-' "$(tools_path)" 2>/dev/null | head -1 | sed -E 's/.*clientId:[[:space:]]*"?([^" ]+)"?.*/\1/' || true)"
        [ -z "${cid_v}" ] || cid_cands+=("${cid_v}")
        cid_v=""
        if [ ${#cid_cands[@]} -gt 0 ]; then
            local cid_uniq=() cid_x
            while IFS= read -r cid_x; do cid_uniq+=("${cid_x}"); done < <(printf '%s\n' "${cid_cands[@]}" | awk '!seen[$0]++')
            cid_cands=("${cid_uniq[@]}")
            choose_from "OAuth client ID for ${PROJECT_NUMBER:-this project}" "${cid_cands[@]}" && cid_v="${CHOICE}"
        elif ask_value "the OAuth client ID (<project-number>-xxxx.apps.googleusercontent.com)"; then
            cid_v="${ASKED}"
        fi
        if [ -n "${cid_v}" ]; then
            offer_save GOOGLE_CLIENT_ID "${cid_v}" && GOOGLE_CLIENT_ID="${OFFER_VALUE}" || true
        else
            echo "     📖 Create an OAuth client in the Cloud console (APIs & Services > Credentials), then set GOOGLE_CLIENT_ID in ${ENV_FILE}."
        fi
    fi

    [ "${FOUND}" = true ] || echo "  ✅ No blank settings"
    echo ""
}

# Every setting needed to deploy must be known by now
require_settings() {
    local missing=()
    [ -n "${PROJECT}" ] || missing+=(GOOGLE_CLOUD_PROJECT)
    [ -n "${PROJECT_NUMBER}" ] || missing+=(GOOGLE_CLOUD_PROJECT_NUMBER)
    [ -n "${SERVICE_ACCOUNT}" ] || missing+=(GOOGLE_CLOUD_SERVICE_ACCOUNT)
    [ -n "${NETWORK}" ] || missing+=(GOOGLE_CLOUD_NETWORK)
    [ -n "${SUBNET}" ] || missing+=(GOOGLE_CLOUD_SUBNET)
    [ -n "${CONFIG_BUCKET}" ] || missing+=(MCP_TOOLBOX_BUCKET)
    [ ${#missing[@]} -eq 0 ] || {
        echo "❌ Missing required settings: ${missing[*]}" >&2
        echo "   Set them in ${ENV_FILE} or on the command line, or run '$0 --preflight' to create/discover them." >&2
        [ "${DRY_RUN}" = true ] && return 0
        exit 1
    }
    [ -f "$(tools_path)" ] || {
        echo "❌ tools.yaml not found at $(tools_path)" >&2
        [ "${DRY_RUN}" = true ] && return 0
        exit 1
    }
}

# ==============================================================================
# Preflight: verify required GCP artefacts (read-only unless --fix)
# ==============================================================================
run_preflight() {
    echo "=================================================================="
    echo "🔎 Preflight: verifying GCP artefacts"
    echo "=================================================================="

    echo "[1/7] Tooling & credentials"
    local account token
    account=$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -1 || true)
    if [ -z "${account}" ]; then pf_fail "No active gcloud account"; pf_hint "gcloud auth login"; return; fi
    pf_ok "gcloud authenticated as ${account}"
    if gcloud projects describe "${PROJECT}" --format='value(projectNumber)' >"${TMP_PF}" 2>/dev/null; then
        local actual; actual=$(cat "${TMP_PF}")
        if [ "${actual}" = "${PROJECT_NUMBER}" ]; then pf_ok "Project ${PROJECT} accessible (number ${actual})"
        else pf_fail "Project ${PROJECT} has number ${actual}, but configured number is ${PROJECT_NUMBER}"; fi
    else
        pf_fail "Cannot access project '${PROJECT}'"; pf_hint "Check the project ID and your IAM access"; return
    fi
    token=$(gcloud auth print-access-token 2>/dev/null || true)
    [ -n "${token}" ] || { pf_fail "Could not mint an access token"; return; }

    echo "[2/7] Enabled APIs"
    local enabled api
    enabled=$(gcloud services list --enabled --project "${PROJECT}" --format='value(config.name)' 2>/dev/null || true)
    for api in "${REQUIRED_APIS[@]}"; do
        if grep -qx "${api}" <<<"${enabled}"; then pf_ok "${api}"
        else pf_fail "${api} is not enabled"; pf_remedy fail gcloud services enable "${api}" --project "${PROJECT}"; fi
    done

    echo "[3/7] Service account ${SERVICE_ACCOUNT}"
    local sa_disabled
    if sa_disabled=$(gcloud iam service-accounts describe "${SERVICE_ACCOUNT}" --project "${PROJECT}" --format='value(disabled)' 2>/dev/null); then
        if [ "${sa_disabled}" = "True" ]; then
            pf_fail "Service account exists but is DISABLED"
            pf_remedy fail gcloud iam service-accounts enable "${SERVICE_ACCOUNT}" --project "${PROJECT}"
        else pf_ok "Service account exists and is enabled"; fi
        local sa_roles role
        sa_roles=$(gcloud projects get-iam-policy "${PROJECT}" --flatten='bindings[].members' \
            --filter="bindings.members:serviceAccount:${SERVICE_ACCOUNT}" --format='value(bindings.role)' 2>/dev/null || true)
        for role in "${REQUIRED_SA_ROLES[@]}"; do
            if grep -qx "${role}" <<<"${sa_roles}"; then pf_ok "Has ${role}"
            else pf_fail "Missing ${role}"
                pf_remedy fail gcloud projects add-iam-policy-binding "${PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="${role}" --condition=None; fi
        done
        for role in "${RECOMMENDED_SA_ROLES[@]}"; do
            if grep -qx "${role}" <<<"${sa_roles}"; then pf_ok "Has ${role}"
            else pf_warn "Missing ${role} (recommended; logging / --telemetry-gcp)"
                pf_remedy warn gcloud projects add-iam-policy-binding "${PROJECT}" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="${role}" --condition=None; fi
        done
        # Cloud Storage permissions on gs://${CONFIG_BUCKET}
        if [ -n "${CONFIG_BUCKET}" ]; then
            local sa_has_storage=false
            if grep -qE "^(roles/storage\.objectViewer|roles/storage\.admin|roles/storage\.objectUser)$" <<<"${sa_roles}"; then
                sa_has_storage=true
                pf_ok "Has storage read access on project level"
            else
                local bucket_roles
                bucket_roles=$(bucket_sa_roles "${CONFIG_BUCKET}" "${SERVICE_ACCOUNT}")
                if grep -qE "^(roles/storage\.objectViewer|roles/storage\.admin|roles/storage\.objectUser|roles/storage\.legacyObjectReader)$" <<<"${bucket_roles}"; then
                    sa_has_storage=true
                    pf_ok "Has roles/storage.objectViewer on gs://${CONFIG_BUCKET}"
                fi
            fi
            if [ "${sa_has_storage}" = false ]; then
                pf_fail "Service account missing roles/storage.objectViewer on gs://${CONFIG_BUCKET}"
                pf_remedy fail gcloud storage buckets add-iam-policy-binding "gs://${CONFIG_BUCKET}" \
                    --member="serviceAccount:${SERVICE_ACCOUNT}" --role=roles/storage.objectViewer
            fi
        fi
        local perms
        perms=$(curl -s -X POST -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -H "X-Goog-User-Project: ${PROJECT}" \
            "https://iam.googleapis.com/v1/projects/${PROJECT}/serviceAccounts/${SERVICE_ACCOUNT}:testIamPermissions" \
            -d '{"permissions":["iam.serviceAccounts.actAs"]}' 2>/dev/null || true)
        if grep -q 'iam.serviceAccounts.actAs' <<<"${perms}"; then pf_ok "${account} can act as the service account"
        else pf_fail "${account} cannot act as the service account"
            pf_remedy fail gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" --member="user:${account}" --role=roles/iam.serviceAccountUser --project "${PROJECT}"; fi
    else
        pf_fail "Service account ${SERVICE_ACCOUNT} does not exist"
        pf_hint "gcloud iam service-accounts create ${SERVICE_ACCOUNT%%@*} --project ${PROJECT} --display-name 'MCP Toolbox'"
    fi

    echo "[4/7] Deployer permissions (${account})"
    local body granted p missing_perms=()
    body=$(python3 -c 'import json,sys; print(json.dumps({"permissions": sys.argv[1:]}))' "${REQUIRED_DEPLOYER_PERMS[@]}")
    granted=$(curl -s -X POST -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -H "X-Goog-User-Project: ${PROJECT}" \
        "https://cloudresourcemanager.googleapis.com/v1/projects/${PROJECT}:testIamPermissions" -d "${body}" 2>/dev/null || true)
    for p in "${REQUIRED_DEPLOYER_PERMS[@]}"; do
        if grep -q "\"${p}\"" <<<"${granted}"; then pf_ok "${p}"; else pf_fail "Missing permission ${p}"; missing_perms+=("${p}"); fi
    done
    [ ${#missing_perms[@]} -eq 0 ] || pf_hint "Ask a project admin for roles/run.admin and roles/secretmanager.admin (or equivalents)"
    if [ -n "${CONFIG_BUCKET}" ]; then
        local gcs_perms
        gcs_perms=$(curl -s -H "Authorization: Bearer ${token}" -H "X-Goog-User-Project: ${PROJECT}" \
            "https://storage.googleapis.com/storage/v1/b/${CONFIG_BUCKET}/iam/testPermissions?permissions=storage.objects.create&permissions=storage.objects.get" 2>/dev/null || true)
        for p in storage.objects.create storage.objects.get; do
            if grep -q "\"${p}\"" <<<"${gcs_perms}"; then pf_ok "${p} (gs://${CONFIG_BUCKET})"
            else pf_fail "Missing permission ${p} on gs://${CONFIG_BUCKET}"
                 pf_hint "Ask a project admin for roles/storage.objectUser or roles/storage.admin on gs://${CONFIG_BUCKET}"; fi
        done
    fi

    echo "[5/7] VPC network & subnet"
    local net_url
    if net_url=$(gcloud compute networks subnets describe "${SUBNET}" --region "${REGION}" --project "${PROJECT}" --format='value(network.basename())' 2>/dev/null); then
        pf_ok "Subnet ${SUBNET} exists in ${REGION}"
        if [ "${net_url}" = "${NETWORK}" ]; then pf_ok "Subnet belongs to network ${NETWORK}"
        else pf_fail "Subnet ${SUBNET} belongs to network '${net_url}', not '${NETWORK}'"; fi
    else
        pf_fail "Subnet ${SUBNET} not found in ${REGION}"
        pf_hint "gcloud compute networks subnets list --project ${PROJECT} --regions ${REGION}"
    fi

    echo "[6/7] tools.yaml, Cloud Storage & Secret Manager"
    local tf; tf="$(tools_path)"
    if [ ! -f "${tf}" ]; then
        pf_fail "tools.yaml not found: ${tf}"
    else
        pf_ok "tools.yaml found: ${tf#${REPO_ROOT}/}"
        # Structure, auth client ID, and database host project (never prints the password)
        local report
        report=$(python3 - "${tf}" "${GOOGLE_CLIENT_ID}" "${PROJECT}" "${ENV_FILE#${REPO_ROOT}/}" <<'PY' 2>&1 || true
import re, sys
try:
    import yaml
except ImportError:
    print("WARN yaml module unavailable; structure checks skipped"); sys.exit(0)
path, client_id, project, envname = sys.argv[1:5]
try:
    d = yaml.safe_load(open(path))
except Exception as e:
    print("FAIL tools.yaml is not valid YAML: %s" % str(e).splitlines()[0]); sys.exit(0)
if not isinstance(d, dict):
    print("FAIL tools.yaml is empty or not a mapping"); sys.exit(0)
srcs, tools, auths = d.get("sources") or {}, d.get("tools") or {}, d.get("authServices") or {}
print("OK valid YAML: %d source(s), %d tool(s), %d auth service(s)" % (len(srcs), len(tools), len(auths)))
if not srcs: print("FAIL no 'sources' defined")
if not tools: print("FAIL no 'tools' defined")
for name, t in tools.items():
    if t.get("source") not in srcs: print("FAIL tool '%s' references unknown source '%s'" % (name, t.get("source")))
    for a in t.get("authRequired") or []:
        if a not in auths: print("FAIL tool '%s' requires unknown authService '%s'" % (name, a))
for name, a in auths.items():
    cid = a.get("clientId", "")
    if re.match(r"^\$\{[A-Za-z_]", str(cid).strip()): print("OK authService '%s' clientId is %s (value comes from the environment)" % (name, cid))
    elif not cid: print("FAIL authService '%s' has no clientId" % name)
    elif client_id and cid != client_id: print("FAIL authService '%s' clientId (%s) differs from GOOGLE_CLIENT_ID in %s (%s); the Toolbox validates user tokens against it" % (name, cid, envname, client_id))
    else:
        print("OK authService '%s' clientId matches the OAuth client" % name)
        print("WARN authService '%s' clientId is hardcoded; use ${GOOGLE_CLIENT_ID} so it follows %s" % (name, envname))
ph = re.compile(r"^\$\{[A-Za-z_][A-Za-z0-9_]*(:[^}]*)?\}$")
for name, s in srcs.items():
    for k in ("connectionString", "user", "password"):
        v = s.get(k)
        if v is not None and not ph.match(str(v).strip()):
            print("FAIL source '%s' has a hardcoded %s; use a ${VARIABLE} backed by Secret Manager" % (name, k))
    m = re.search(r"\.c\.([a-z0-9-]+)\.internal", str(s.get("connectionString", "")) + str(s.get("host", "")))
    if m and m.group(1) != project: print("WARN source '%s' database host is in project '%s', not '%s'" % (name, m.group(1), project))
PY
)
        local line
        while IFS= read -r line; do
            case "${line}" in
                OK\ *)   pf_ok "${line#OK }" ;;
                WARN\ *) pf_warn "${line#WARN }" ;;
                FAIL\ *) pf_fail "${line#FAIL }" ;;
                "") ;;
                *)       pf_warn "tools.yaml check: ${line}" ;;
            esac
        done <<<"${report}"
        if grep -q "differs from GOOGLE_CLIENT_ID" <<<"${report}"; then
            pf_hint "Set authServices.<name>.clientId in ${tf#${REPO_ROOT}/} to ${GOOGLE_CLIENT_ID:-<your OAuth client ID>}"
        fi

        # Database credential secrets referenced as ${VARIABLE}
        local var
        for var in $(plain_placeholders); do
            local val="${!var-}"
            if [ -z "${val}" ]; then pf_fail "\${${var}} is used in tools.yaml but ${var} is blank in ${ENV_FILE#${REPO_ROOT}/}"
            elif [ "${var}" = "GOOGLE_CLIENT_ID" ] && [[ "${val}" != "${PROJECT_NUMBER}-"* ]]; then
                pf_fail "GOOGLE_CLIENT_ID in ${ENV_FILE#${REPO_ROOT}/} belongs to project ${val%%-*}, not ${PROJECT} (${PROJECT_NUMBER})"
            else pf_ok "\${${var}} = ${val} (from ${ENV_FILE#${REPO_ROOT}/}, plain environment variable)"; fi
        done
        for var in $(secret_placeholders); do
            if secret_exists "$(secret_for_var "${var}")"; then pf_ok "Credential secret exists: $(secret_for_var "${var}") (\${${var}})"
            else pf_warn "Credential secret $(secret_for_var "${var}") for \${${var}} does not exist - it will be created on deploy (value from \$${var}$([ -n "$(db_file_value "${var}")" ] && echo ", ${DB_ENV_FILE##*/} [found]" || echo ", ${DB_ENV_FILE##*/} [not set]") or a hidden prompt)"; fi
        done

        # Cloud Storage: does bucket exist, and does gs://${CONFIG_BUCKET}/${SERVICE_NAME}/tools.yaml exist/match?
        local gcs_dest="gs://${CONFIG_BUCKET}/${SERVICE_NAME}/tools.yaml"
        if gcloud storage buckets describe "gs://${CONFIG_BUCKET}" --project "${PROJECT}" >/dev/null 2>&1; then
            pf_ok "Cloud Storage bucket gs://${CONFIG_BUCKET} exists"
            if gcloud storage cp "${gcs_dest}" "${TMP_PF}" >/dev/null 2>&1; then
                if cmp -s "${tf}" "${TMP_PF}"; then
                    pf_ok "${gcs_dest} matches local tools.yaml"
                else
                    pf_warn "${gcs_dest} differs from local tools.yaml - will be updated on deploy"
                fi
            else
                pf_warn "${gcs_dest} does not exist - will be uploaded on deploy"
            fi
            : >"${TMP_PF}"
        else
            pf_fail "Cloud Storage bucket gs://${CONFIG_BUCKET} does not exist"
            pf_remedy fail gcloud storage buckets create "gs://${CONFIG_BUCKET}" --location="${REGION}" --project="${PROJECT}"
        fi
    fi

    echo "[7/7] Cloud Run service"
    local svc_json
    if svc_json=$(gcloud run services describe "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" --format=json 2>/dev/null); then
        local svc_url
        svc_url=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("status",{}).get("url",""))' "${svc_json}" 2>/dev/null || true)
        if [ -n "${svc_url}" ]; then
            pf_ok "Service ${SERVICE_NAME} exists: ${svc_url}"
        else
            pf_ok "Service ${SERVICE_NAME} exists"
        fi
        local pol
        pol=$(gcloud run services get-iam-policy "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" --format='value(bindings.members)' 2>/dev/null || true)
        if grep -qE "allUsers|allAuthenticatedUsers" <<<"${pol}"; then
            pf_fail "Service is publicly invokable (allUsers/allAuthenticatedUsers)"
            pf_remedy fail gcloud run services remove-iam-policy-binding "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" --member=allUsers --role=roles/run.invoker
        else
            pf_ok "Service is private (no public invoker)"
        fi
        local want="https://${SERVICE_NAME}-${PROJECT_NUMBER}.${REGION}.run.app/mcp/"
        if [ -n "${MCP_SERVER_SQL_URL}" ] && [ "${MCP_SERVER_SQL_URL}" != "${want}" ]; then
            pf_warn "MCP_SERVER_SQL_URL in ${ENV_FILE#${REPO_ROOT}/} (${MCP_SERVER_SQL_URL}) differs from this service (${want})"
        fi

        # Verify Cloud Run configuration: volume mount, execution environment, and variables
        local cr_report
        cr_report=$(python3 - "${CONFIG_BUCKET}" "${SERVICE_NAME}" "$(secret_placeholders | tr '\n' ' ')" "$(plain_placeholders | tr '\n' ' ')" "${svc_json}" <<'PY' 2>&1 || true
import json, sys

try:
    data = json.loads(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5] else {}
except Exception as e:
    print(f"WARN could not parse Cloud Run service JSON: {e}")
    sys.exit(0)

expected_bucket = sys.argv[1]
service_name = sys.argv[2]
expected_secrets = sys.argv[3].split() if len(sys.argv) > 3 else []
expected_plains = sys.argv[4].split() if len(sys.argv) > 4 else []

template_spec = data.get("spec", {}).get("template", {}).get("spec", {})
containers = template_spec.get("containers", [])
container = containers[0] if containers else {}
env_list = container.get("env", [])
args_list = container.get("args", [])
mounts = container.get("volumeMounts", [])
volumes = template_spec.get("volumes", [])
annotations = data.get("spec", {}).get("template", {}).get("metadata", {}).get("annotations", {})

secret_env = {}
plain_env = {}
for e in env_list:
    name = e.get("name")
    if not name:
        continue
    if "valueFrom" in e and "secretKeyRef" in e["valueFrom"]:
        secret_env[name] = e["valueFrom"]["secretKeyRef"].get("name", "")
    elif "value" in e:
        plain_env[name] = e.get("value")

# Check execution environment
exec_env = annotations.get("run.googleapis.com/execution-environment", "")
if exec_env == "gen2":
    print("OK Cloud Run execution environment is gen2")
else:
    print(f"WARN Cloud Run execution environment is '{exec_env}' (expected 'gen2' for Cloud Storage volumes) - redeploy will configure it")

# Check GCS volume
gcs_vol = None
for v in volumes:
    csi = v.get("csi", {})
    if csi.get("driver") == "gcsfuse.run.googleapis.com":
        bucket = csi.get("volumeAttributes", {}).get("bucketName")
        if bucket == expected_bucket:
            gcs_vol = v.get("name")
            break

if gcs_vol:
    print(f"OK Cloud Run volume mounts Cloud Storage bucket: gs://{expected_bucket}")
    mounted = any(m.get("name") == gcs_vol and m.get("mountPath") == "/config" for m in mounts)
    if mounted:
        print("OK Cloud Run volume is mounted at /config")
    else:
        print("WARN Cloud Run volume is not mounted at /config - redeploy to update")
else:
    print(f"WARN Cloud Run does not mount Cloud Storage bucket 'gs://{expected_bucket}' - redeploy to update")

expected_arg = f"--config=/config/{service_name}/tools.yaml"
has_arg = any(expected_arg in a for a in args_list)
if has_arg:
    print(f"OK Cloud Run args point to config: {expected_arg}")
else:
    print(f"WARN Cloud Run args do not point to {expected_arg} - redeploy to update")

for var in expected_secrets:
    sec_suffix = var.lower().replace("_", "-")
    expected_sec = f"{service_name}-{sec_suffix}"
    if var in secret_env:
        actual = secret_env[var]
        if actual != expected_sec:
            print(f"WARN Cloud Run secret env var ${{{var}}} is bound to '{actual}' (expected '{expected_sec}')")
        else:
            print(f"OK Cloud Run has secret env var configured: ${{{var}}} -> {actual}")
    else:
        print(f"WARN Cloud Run is missing secret env var for ${{{var}}} (expected secret: {expected_sec}) - redeploy to pass it")

for var in expected_plains:
    if var in plain_env or var in secret_env:
        print(f"OK Cloud Run has env var configured: ${{{var}}}")
    else:
        print(f"WARN Cloud Run is missing env var: ${{{var}}} - redeploy to pass it")
PY
)
        local line
        while IFS= read -r line; do
            case "${line}" in
                OK\ *)   pf_ok "${line#OK }" ;;
                WARN\ *) pf_warn "${line#WARN }" ;;
                FAIL\ *) pf_fail "${line#FAIL }" ;;
                "") ;;
                *)       pf_warn "${line}" ;;
            esac
        done <<<"${cr_report}"
    else
        pf_ok "Service ${SERVICE_NAME} does not exist yet (first deploy)"
    fi

    echo ""
    if [ ${PF_FAIL} -gt 0 ]; then echo "Preflight result: ❌ ${PF_FAIL} failure(s), ${PF_WARN} warning(s)"
    else echo "Preflight result: ✅ passed (${PF_WARN} warning(s))"; fi
    echo ""
}

# --- --rotate-tools: replace the yaml in the bucket and stop ---
if [ "${ROTATE_TOOLS}" = true ]; then
    [ -n "${PROJECT}" ]       || die "No project: set GOOGLE_CLOUD_PROJECT in ${ENV_FILE#${REPO_ROOT}/} or pass --project."
    [ -n "${CONFIG_BUCKET}" ] || die "No bucket: set MCP_TOOLBOX_BUCKET in ${ENV_FILE#${REPO_ROOT}/} or pass --bucket."
    [ -f "$(tools_path)" ]    || die "tools file not found: $(tools_path) (--tools-file, or generate it: python3 scripts/build_and_validate.py)"
    python3 -c 'import sys, yaml; d = yaml.safe_load(open(sys.argv[1])); sys.exit(0 if isinstance(d, dict) and d.get("tools") else 1)' "$(tools_path)" 2>/dev/null \
        || die "$(tools_path) is not a valid tools yaml (no 'tools:' mapping); not uploading it."
    ROT_DEST="gs://${CONFIG_BUCKET}/${SERVICE_NAME}/tools.yaml"
    ROT_TMP="$(mktemp)"; chmod 600 "${ROT_TMP}"
    info "Tools file:   $(tools_path | sed "s#${REPO_ROOT}/##")"
    info "Destination:  ${ROT_DEST}"
    if gcloud storage cp "${ROT_DEST}" "${ROT_TMP}" --project "${PROJECT}" >/dev/null 2>&1; then
        if cmp -s "$(tools_path)" "${ROT_TMP}"; then
            rm -f "${ROT_TMP}"
            echo "⚠️  The bucket already holds this exact file (identical to $(tools_path | sed "s#${REPO_ROOT}/##")); nothing was replaced."
            exit 0
        fi
        ROT_VERB="Replace"
    else
        ROT_VERB="Upload (no file there yet)"
    fi
    rm -f "${ROT_TMP}"
    echo "Executing: gcloud storage cp $(tools_path) ${ROT_DEST} --project ${PROJECT}"
    if [ "${DRY_RUN}" = true ]; then echo "[dry-run] ${ROT_VERB} would happen."; exit 0; fi
    confirm "${ROT_VERB} ${ROT_DEST}?" || die "Not confirmed. Nothing was changed."
    gcloud storage cp "$(tools_path)" "${ROT_DEST}" --project "${PROJECT}"
    echo ""
    echo "✅ ${ROT_DEST} updated."
    echo "   The Toolbox reads its config when an instance starts, so running instances keep the old tools until a restart."
    if [ "${NO_RESTART}" = true ]; then
        echo "   Not restarting (--no-restart). To restart later:"
        echo "   gcloud run services update ${SERVICE_NAME} --region ${REGION} --project ${PROJECT} --update-env-vars TOOLBOX_RESTART_AT=\$(date +%s)"
    elif ! gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --project "${PROJECT}" >/dev/null 2>&1; then
        echo "   Service ${SERVICE_NAME} does not exist yet; the first deploy will load this file."
    elif confirm "Restart ${SERVICE_NAME} now so it loads the new tools?"; then
        restart_service "tools rotated"
    else
        echo "   Not restarted. The new tools load when the service next restarts."
    fi
    exit 0
fi

db_file_check_perms
REQUIRED_CHECKED=false
if [ "${SKIP_PREFLIGHT}" = false ] && { [ "${DRY_RUN}" = false ] || [ "${PREFLIGHT_ONLY}" = true ]; }; then
    resolve_blank_vars
    require_settings
    REQUIRED_CHECKED=true
    run_preflight
    if [ ${PF_FAIL} -gt 0 ]; then
        echo "Aborting. Fix the failures above, or re-run with --skip-preflight to bypass." >&2
        exit 1
    fi
fi
[ "${REQUIRED_CHECKED}" = true ] || require_settings
[ "${PREFLIGHT_ONLY}" = false ] || exit 0

# ==============================================================================
# Execution summary
# ==============================================================================
TOOLS_ABS="$(tools_path)"
echo "=================================================================="
echo "🚀 MCP Toolbox Deployment"
echo "=================================================================="
echo "  Project:          ${PROJECT} (Number: ${PROJECT_NUMBER})"
echo "  Region:           ${REGION}"
echo "  Service:          ${SERVICE_NAME}"
echo "  Service account:  ${SERVICE_ACCOUNT}"
echo "  Image:            ${IMAGE}"
echo "  Config bucket:    gs://${CONFIG_BUCKET} (${SERVICE_NAME}/tools.yaml)"
echo "  Tools file:       ${TOOLS_ABS#${REPO_ROOT}/}"
echo "  VPC:              ${NETWORK} / ${SUBNET}"
echo "  Dry run:          $([ "${DRY_RUN}" = true ] && echo Yes || echo No)"
echo "=================================================================="
echo ""

# ------------------------------------------------------------------------------
# Step 1: Config (Cloud Storage) & Database credentials (Secret Manager)
# ------------------------------------------------------------------------------
echo "------------------------------------------------------------------"
echo "🔐 [Step 1/2] Syncing configuration and secrets..."
echo "------------------------------------------------------------------"
echo "Database credentials in Secret Manager:"
if [ -z "$(secret_placeholders)" ]; then
    echo "  (tools.yaml references no credential \${VARIABLES})"
else
    ensure_db_secrets
fi
echo ""
echo "Runtime service account Cloud Storage access:"
sa_has_storage=false
sa_proj_roles=$(gcloud projects get-iam-policy "${PROJECT}" --flatten='bindings[].members' \
    --filter="bindings.members:serviceAccount:${SERVICE_ACCOUNT}" --format='value(bindings.role)' 2>/dev/null || true)
if grep -qE "^(roles/storage\.objectViewer|roles/storage\.admin|roles/storage\.objectUser)$" <<<"${sa_proj_roles}"; then
    sa_has_storage=true
    echo "  ✅ Service account has storage read access on project level"
else
    sa_bkt_roles=$(bucket_sa_roles "${CONFIG_BUCKET}" "${SERVICE_ACCOUNT}")
    if grep -qE "^(roles/storage\.objectViewer|roles/storage\.admin|roles/storage\.objectUser|roles/storage\.legacyObjectReader)$" <<<"${sa_bkt_roles}"; then
        sa_has_storage=true
        echo "  ✅ Service account has roles/storage.objectViewer on gs://${CONFIG_BUCKET}"
    fi
fi
if [ "${sa_has_storage}" = false ]; then
    echo "  Service account needs roles/storage.objectViewer on gs://${CONFIG_BUCKET}"
    echo "Executing: gcloud storage buckets add-iam-policy-binding gs://${CONFIG_BUCKET} --member=serviceAccount:${SERVICE_ACCOUNT} --role=roles/storage.objectViewer"
    if [ "${DRY_RUN}" = true ]; then
        echo "  [dry-run] IAM binding would be added."
    elif confirm "Grant roles/storage.objectViewer on gs://${CONFIG_BUCKET} to ${SERVICE_ACCOUNT}?"; then
        gcloud storage buckets add-iam-policy-binding "gs://${CONFIG_BUCKET}" \
            --member="serviceAccount:${SERVICE_ACCOUNT}" --role=roles/storage.objectViewer
    else
        echo "IAM binding not confirmed. Cloud Run may fail to mount the bucket." >&2
    fi
fi

echo ""
echo "tools.yaml in Cloud Storage:"
GCS_DEST="gs://${CONFIG_BUCKET}/${SERVICE_NAME}/tools.yaml"
GCS_ACTION=""
TMP_GCS="$(mktemp)"; chmod 600 "${TMP_GCS}"
if gcloud storage cp "${GCS_DEST}" "${TMP_GCS}" >/dev/null 2>&1; then
    if cmp -s "${TOOLS_ABS}" "${TMP_GCS}"; then
        echo "tools.yaml has not changed in ${GCS_DEST}. Skipping upload."
    else
        GCS_ACTION="update"
    fi
else
    GCS_ACTION="upload"
fi
rm -f "${TMP_GCS}"

if [ "${GCS_ACTION}" = "upload" ]; then
    echo "Executing: gcloud storage cp ${TOOLS_ABS} ${GCS_DEST}"
    if [ "${DRY_RUN}" = true ]; then echo "[dry-run] tools.yaml would be uploaded to ${GCS_DEST}."
    elif confirm "Upload tools.yaml to ${GCS_DEST}?"; then
        gcloud storage cp "${TOOLS_ABS}" "${GCS_DEST}"
    else echo "Upload not confirmed. Nothing was changed." >&2; exit 1; fi
elif [ "${GCS_ACTION}" = "update" ]; then
    echo "tools.yaml differs from the version in Cloud Storage."
    echo "Executing: gcloud storage cp ${TOOLS_ABS} ${GCS_DEST}"
    if [ "${DRY_RUN}" = true ]; then echo "[dry-run] tools.yaml would be updated in ${GCS_DEST}."
    elif confirm "Update tools.yaml in ${GCS_DEST}?"; then
        gcloud storage cp "${TOOLS_ABS}" "${GCS_DEST}"
    else echo "Upload update not confirmed. Nothing was changed." >&2; exit 1; fi
fi
echo ""

# ------------------------------------------------------------------------------
# Step 2: Cloud Run
# ------------------------------------------------------------------------------
echo "------------------------------------------------------------------"
echo "☁️  [Step 2/2] Deploying Cloud Run service..."
echo "------------------------------------------------------------------"
# tools.yaml is mounted from Cloud Storage at /config/${SERVICE_NAME}/tools.yaml;
# each ${VARIABLE} secret is injected as an environment variable
SET_SECRETS=""
for var in $(secret_placeholders); do
    sec="$(secret_for_var "${var}")"
    SET_SECRETS+="${SET_SECRETS:+,}${var}=${sec}:latest"
done

SET_ENV_VARS=""
for var in $(plain_placeholders); do
    [ -n "${!var-}" ] || { echo "❌ \${${var}} is used in tools.yaml but ${var} is blank in ${ENV_FILE#${REPO_ROOT}/}" >&2; exit 1; }
    SET_ENV_VARS+="${SET_ENV_VARS:+,}${var}=${!var}"
done

DEPLOY_CMD=(
    gcloud run deploy "${SERVICE_NAME}"
    --project "${PROJECT}"
    --image "${IMAGE}"
    --service-account "${SERVICE_ACCOUNT}"
    --region "${REGION}"
    --execution-environment gen2
    --add-volume "name=tools-config,type=cloud-storage,bucket=${CONFIG_BUCKET},readonly=true"
    --add-volume-mount "volume=tools-config,mount-path=/config"
    "--args=--config=/config/${SERVICE_NAME}/tools.yaml,--address=0.0.0.0,--port=8080,--log-level=DEBUG,--telemetry-gcp"
    --network "${NETWORK}"
    --subnet "${SUBNET}"
    --no-allow-unauthenticated
)
[ -z "${SET_SECRETS}" ] || DEPLOY_CMD+=(--set-secrets "${SET_SECRETS}")
[ -z "${SET_ENV_VARS}" ] || DEPLOY_CMD+=(--set-env-vars "${SET_ENV_VARS}")
echo "Executing: ${DEPLOY_CMD[*]}"   # holds secret NAMES only, never values
echo ""
if [ "${DRY_RUN}" = true ]; then
    echo "[dry-run] Deploy command printed above."
    exit 0
fi
if ! confirm "Deploy '${SERVICE_NAME}' to Cloud Run in project '${PROJECT}' now?"; then
    echo "Deployment not confirmed. Nothing was changed." >&2
    exit 1
fi
REV_BEFORE="$(gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --project "${PROJECT}" --format='value(status.latestReadyRevisionName)' 2>/dev/null || true)"
"${DEPLOY_CMD[@]}"
echo ""
echo "✅ Deployment finished."
if [ "${SECRETS_ROTATED}" -gt 0 ] && [ -n "${REV_BEFORE}" ]; then
    REV_AFTER="$(gcloud run services describe "${SERVICE_NAME}" --region "${REGION}" --project "${PROJECT}" --format='value(status.latestReadyRevisionName)' 2>/dev/null || true)"
    if [ "${REV_AFTER}" = "${REV_BEFORE}" ] && [ "${NO_RESTART}" = false ]; then
        echo "${SECRETS_ROTATED} secret(s) were rotated but the deploy kept revision ${REV_BEFORE}, which still holds the old values."
        restart_service "secrets rotated"
    elif [ "${REV_AFTER}" = "${REV_BEFORE}" ]; then
        echo "⚠️  ${SECRETS_ROTATED} secret(s) were rotated, but ${SERVICE_NAME} still runs revision ${REV_BEFORE} with the old values (--no-restart)."
    fi
fi
echo "If the service fails to start, check its logs for an unresolved \${VARIABLE}: gcloud run services logs read ${SERVICE_NAME} --region ${REGION} --project ${PROJECT}"

# Offer to record the service URL for MCP clients
NEW_URL="https://${SERVICE_NAME}-${PROJECT_NUMBER}.${REGION}.run.app/mcp/"
if ! cli_set service-name; then
    if [ "${MCP_SERVER_SQL_URL}" != "${NEW_URL}" ]; then
        echo ""
        echo "MCP_SERVER_SQL_URL in ${ENV_FILE#${REPO_ROOT}/} is '${MCP_SERVER_SQL_URL:-<blank>}'."
        offer_save MCP_SERVER_SQL_URL "${NEW_URL}" && MCP_SERVER_SQL_URL="${OFFER_VALUE}" || true
        echo "Update your MCP client configuration with the new URL."
    fi
else
    echo ""
    echo "Deployed service URL: ${NEW_URL}"
fi
echo ""
echo "=================================================================="
echo "🎉 MCP Toolbox deployed: ${NEW_URL}"
echo "   Caller service accounts need roles/run.invoker to invoke this service."
echo "=================================================================="
