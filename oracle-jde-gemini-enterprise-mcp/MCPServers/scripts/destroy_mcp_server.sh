#!/usr/bin/env bash
# ==============================================================================
# Script:      destroy_mcp_server.sh
# Version:     1.0.0  (variable SCRIPT_VERSION below)
# Description: Delete an MCP Toolbox Cloud Run service made by deploy_mcp_server.sh, then its leftovers.
#
# Undo of deploy_mcp_server.sh for ONE system (and optional variant):
#   1. Deletes the Cloud Run service (if it exists).
#   2. Only when that succeeded (or the service is gone):
#        - deletes the Secret Manager secrets the service was using (found on the service itself,
#          plus the legacy <service>-secrets), and only those named <service>-*;
#        - deletes the config folder gs://<bucket>/<service>/ (the tools files, and the old tools.yaml).
#      The bucket itself is never deleted: it may be shared with other services.
#   3. Offers to blank MCP_SERVER_SQL_URL in mcp-toolbox-<system>/.env when it points at the deleted service.
#
# Only services marked as made by deploy_mcp_server.sh (label managed-by=oracle-mcp-1p-deploy, any name) are
# deleted; an unmarked one (deployed before the label existed, or by hand) needs --force.
# Not touched: the runtime service account and its IAM roles, enabled APIs, the VPC, the Toolbox image,
# the agent (deploy_agent.sh), the local files. If the service no longer exists, nothing is deleted
# (a re-run cannot find the secrets any more): the script says so and exits.
# Nothing is deleted without a 'yes' (-y/--yes skips it); -n/--dry-run prints the commands only.
# ==============================================================================

set -euo pipefail
SCRIPT_VERSION="1.0.0"
echo "destroy_mcp_server.sh v${SCRIPT_VERSION}" >&2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"          # ENV_FILE, env_value, info/warn/die

DEFAULT_REGION="us-central1"
VALID_SYSTEMS="ebs, peoplesoft (ps), jde"
SYSTEM=""; SYSTEM_SHORT=""; VARIANT=""
PROJECT=""; REGION=""; SERVICE_NAME=""; CONFIG_BUCKET=""
KEEP_SECRETS=false; KEEP_CONFIG=false; FORCE=false; ASSUME_YES=false; DRY_RUN=false; LIST_ONLY=false
CLI_SET=" "

usage() {
    cat <<EOF
Usage: ./scripts/destroy_mcp_server.sh --system {ebs|peoplesoft|jde} [OPTIONS]

Deletes the Toolbox Cloud Run service of ONE system and, if that worked, its secrets and its
config folder in Cloud Storage. The bucket, service account and IAM roles are left alone.

Required:
  --system SYSTEM         Target system: ebs | peoplesoft (alias: ps) | jde. No default.
  --variant NAME          Optional: the variant that was deployed (for example sec, agent).

Options:
  --project ID            GCP project ID     (default: mcp-toolbox-<system>/.env, then active gcloud project)
  --region REGION         Cloud Run region   (default: GOOGLE_CLOUD_REGION, then GOOGLE_CLOUD_LOCATION, then ${DEFAULT_REGION})
  --service-name NAME     Service to delete  (default: MCP_TOOLBOX_SERVICE_NAME, then mcp-toolbox-<ebs|ps|jde>[-<variant>])
  --bucket BUCKET         Bucket holding the config folder (default: the one mounted by the service)
  --force                 Also delete a service that lacks the label managed-by=oracle-mcp-1p-deploy
                          (services deployed before the label existed, or made by hand)
  --keep-secrets          Do not delete the secrets
  --keep-config           Do not delete gs://<bucket>/<service>/
  -y, --yes               Do not prompt; assume 'yes' (required when non-interactive)
  -n, --dry-run, --check  Show what would be deleted and the commands, without deleting anything
  -l, --list              List the Cloud Run services (all regions unless --region is given) and exit.
                          --system narrows it to that system's services (label mcp-system, or the default name mcp-toolbox-<ebs|ps|jde>-*); it
                          needs no --system otherwise (project: --project, then the active gcloud project)
  -h, --help              Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --system)        [ $# -ge 2 ] || die "--system needs a value ({${VALID_SYSTEMS}})"; SYSTEM="$2"; shift 2 ;;
        --variant)       [ $# -ge 2 ] || die "--variant needs a value (for example sec or agent)"; VARIANT="$2"; shift 2 ;;
        --project)       [ $# -ge 2 ] || die "--project needs a value"; PROJECT="$2"; CLI_SET+="project "; shift 2 ;;
        --region)        [ $# -ge 2 ] || die "--region needs a value"; REGION="$2"; CLI_SET+="region "; shift 2 ;;
        --service-name)  [ $# -ge 2 ] || die "--service-name needs a value"; SERVICE_NAME="$2"; CLI_SET+="service-name "; shift 2 ;;
        --bucket)        [ $# -ge 2 ] || die "--bucket needs a value"; CONFIG_BUCKET="${2#gs://}"; CONFIG_BUCKET="${CONFIG_BUCKET%/}"; CLI_SET+="bucket "; shift 2 ;;
        --force)         FORCE=true; shift ;;
        --keep-secrets)  KEEP_SECRETS=true; shift ;;
        --keep-config)   KEEP_CONFIG=true; shift ;;
        -y|--yes)        ASSUME_YES=true; shift ;;
        -n|--dry-run|--check) DRY_RUN=true; shift ;;
        -l|--list)       LIST_ONLY=true; shift ;;
        -h|--help)       usage ;;
        *) die "Unknown argument: $1 (see --help)" ;;
    esac
done

# --- --list: existing Cloud Run services, read-only; the system is optional here ---
if [ "${LIST_ONLY}" = true ]; then
    command -v gcloud >/dev/null 2>&1 || die "gcloud CLI not found in PATH."
    FILTER=()
    if [ -n "${SYSTEM}" ]; then
        use_system_env "${SYSTEM}" "${VARIANT}"
        [ -n "${PROJECT}" ] || PROJECT="$(env_value GOOGLE_CLOUD_PROJECT)"
        FILTER=(--filter="metadata.labels.mcp-system=${SYSTEM_SHORT} OR metadata.name~^mcp-toolbox-${SYSTEM_SHORT}-")
    fi
    [ -n "${PROJECT}" ] || PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
    [ -n "${PROJECT}" ] || die "No project: pass --project or run: gcloud config set project <ID>"
    info "Cloud Run services in ${PROJECT}${REGION:+/${REGION}}${SYSTEM:+ (system ${SYSTEM})}:"
    gcloud run services list --project "${PROJECT}" ${REGION:+--region "${REGION}"} "${FILTER[@]+"${FILTER[@]}"}" \
        --format='table(metadata.name:label=SERVICE,metadata.labels."cloud.googleapis.com/location":label=REGION,status.url:label=URL,status.conditions[0].status:label=READY,metadata.labels."managed-by":label=MANAGED_BY,spec.template.spec.serviceAccountName:label=SERVICE_ACCOUNT)' \
        || die "Could not list Cloud Run services: check 'gcloud auth list' and your permissions."
    echo "MANAGED_BY shows oracle-mcp-1p-deploy for services made by deploy_mcp_server.sh; others need --force to be destroyed." >&2
    echo "Delete one with: ./scripts/destroy_mcp_server.sh --system <system> [--variant <v>] [--service-name <name>] --check" >&2
    exit 0
fi

# --- Select the system (required) and its env file, as deploy_mcp_server.sh does ---
[ -n "${SYSTEM}" ] || die "--system is required: one of {${VALID_SYSTEMS}}. See --help."
use_system_env "${SYSTEM}" "${VARIANT}"
SYSARGS="--system ${SYSTEM}${VARIANT:+ --variant ${VARIANT}}"
source "${SCRIPT_DIR}/gcp_common.sh"   # confirm, env_set, approve (uses ASSUME_YES, DRY_RUN, ENV_FILE)
command -v gcloud >/dev/null 2>&1 || die "gcloud CLI not found in PATH."
command -v python3 >/dev/null 2>&1 || die "python3 not found in PATH."
info "System: ${SYSTEM}${VARIANT:+   Variant: ${VARIANT}}   Env file: ${ENV_FILE}"

# --- Settings: command line > .env > default ---
[ -n "${PROJECT}" ] || PROJECT="$(env_value GOOGLE_CLOUD_PROJECT)"
[ -n "${PROJECT}" ] || PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
[ -n "${PROJECT}" ] || die "No project: pass --project or set GOOGLE_CLOUD_PROJECT in ${ENV_FILE#${REPO_ROOT}/}."
if [ -z "${REGION}" ]; then
    REGION="$(env_value GOOGLE_CLOUD_REGION)"
    if [ -z "${REGION}" ]; then
        LOC="$(env_value GOOGLE_CLOUD_LOCATION)"
        [ -n "${LOC}" ] && [ "${LOC}" != "global" ] && REGION="${LOC}"
    fi
    [ -n "${REGION}" ] || REGION="${DEFAULT_REGION}"
fi
[ -n "${SERVICE_NAME}" ] || SERVICE_NAME="$(env_value MCP_TOOLBOX_SERVICE_NAME)"
[ -n "${SERVICE_NAME}" ] || SERVICE_NAME="mcp-toolbox-${SYSTEM_SHORT}${VARIANT:+-${VARIANT}}"
# The name is used in deletion patterns below: refuse anything that is not a plain Cloud Run name
[[ "${SERVICE_NAME}" =~ ^[a-z][a-z0-9-]{0,48}[a-z0-9]$ ]] || die "Service name '${SERVICE_NAME}' is not a valid Cloud Run service name."

echo "=================================================================="
echo "🗑️  Destroy MCP Toolbox '${SERVICE_NAME}' in ${PROJECT}/${REGION}"
echo "=================================================================="

# --- Does the service exist? ---
SVC_JSON="$(mktemp)"; trap 'rm -f "${SVC_JSON}"' EXIT
if gcloud run services describe "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" --format=json >"${SVC_JSON}" 2>/dev/null; then
    :
else
    # describe fails for "not found" and for errors alike: a list tells them apart
    found="$(gcloud run services list --project "${PROJECT}" --region "${REGION}" --filter="metadata.name=${SERVICE_NAME}" --format='value(metadata.name)')" \
        || die "Could not query Cloud Run in ${PROJECT}/${REGION}: check 'gcloud auth list' and your permissions."
    if [ -z "${found}" ]; then
        echo "ℹ️  Service '${SERVICE_NAME}' does not exist in ${PROJECT}/${REGION}. Nothing to delete."
        echo "   (Secrets and config files are only removed together with the service. If an earlier run stopped half way,"
        echo "    list leftovers with: gcloud secrets list --project ${PROJECT} --filter='name~${SERVICE_NAME}-')"
        exit 0
    fi
    die "Service '${SERVICE_NAME}' exists but could not be read."
fi

# --- Was it made by deploy_mcp_server.sh? It says so with a label (the name is free to choose) ---
MARKED="$(python3 -c "import json,sys; print((json.load(open(sys.argv[1])).get('metadata') or {}).get('labels',{}).get(sys.argv[2],''))" "${SVC_JSON}" "${DEPLOY_LABEL_KEY}")"
if [ "${MARKED}" != "${DEPLOY_LABEL_VALUE}" ]; then
    if [ "${FORCE}" = true ]; then
        warn "Service '${SERVICE_NAME}' does not carry the label ${DEPLOY_LABEL_KEY}=${DEPLOY_LABEL_VALUE}; deleting it anyway (--force)."
    else
        die "Service '${SERVICE_NAME}' does not carry the label ${DEPLOY_LABEL_KEY}=${DEPLOY_LABEL_VALUE}, so it was not deployed by deploy_mcp_server.sh (or before that label existed). Check it with --list, then pass --force to delete it anyway."
    fi
fi

# --- What it uses: secrets and the config bucket come from the service itself ---
PLAN="$(python3 - "${SVC_JSON}" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
spec = (d.get("spec") or {}).get("template", {}).get("spec", {}) or {}
secrets, buckets = [], []
for c in spec.get("containers") or []:
    for e in c.get("env") or []:
        ref = ((e.get("valueFrom") or {}).get("secretKeyRef") or {}).get("name")
        if ref: secrets.append(ref.split("/")[-1])
for v in spec.get("volumes") or []:
    s = (v.get("secret") or {}).get("secretName")
    if s: secrets.append(s.split("/")[-1])
    b = ((v.get("csi") or {}).get("volumeAttributes") or {}).get("bucketName")
    if b: buckets.append(b)
for s in dict.fromkeys(secrets): print("secret|" + s)
for b in dict.fromkeys(buckets): print("bucket|" + b)
print("url|" + str((d.get("status") or {}).get("url") or ""))
PY
)"
SERVICE_URL="$(sed -n 's/^url|//p' <<<"${PLAN}")"
SECRETS=(); while IFS= read -r s; do [ -n "${s}" ] && SECRETS+=("${s}"); done < <(sed -n 's/^secret|//p' <<<"${PLAN}")
[ -n "${CONFIG_BUCKET}" ] || CONFIG_BUCKET="$(sed -n 's/^bucket|//p' <<<"${PLAN}" | head -1)"
[ -n "${CONFIG_BUCKET}" ] || { CONFIG_BUCKET="$(env_value MCP_TOOLBOX_BUCKET)"; CONFIG_BUCKET="${CONFIG_BUCKET#gs://}"; CONFIG_BUCKET="${CONFIG_BUCKET%/}"; }

# The legacy single-secret layout, when present
LEGACY_SECRET="${SERVICE_NAME}-secrets"
if gcloud secrets describe "${LEGACY_SECRET}" --project "${PROJECT}" >/dev/null 2>&1; then
    printf '%s\n' "${SECRETS[@]+"${SECRETS[@]}"}" | grep -qx "${LEGACY_SECRET}" || SECRETS+=("${LEGACY_SECRET}")
fi
# Only secrets named after this service are ours; anything else may be shared
DEL_SECRETS=(); SKIP_SECRETS=()
for s in "${SECRETS[@]+"${SECRETS[@]}"}"; do
    if [[ "${s}" == "${SERVICE_NAME}-"* ]]; then DEL_SECRETS+=("${s}"); else SKIP_SECRETS+=("${s}"); fi
done
GCS_DIR=""; [ -z "${CONFIG_BUCKET}" ] || GCS_DIR="gs://${CONFIG_BUCKET}/${SERVICE_NAME}/"

echo "This will delete:"
echo "  ☁️  Cloud Run service ${SERVICE_NAME}${SERVICE_URL:+  (${SERVICE_URL})}"
if [ "${KEEP_SECRETS}" = true ]; then echo "  🔐 secrets: kept (--keep-secrets)"
elif [ ${#DEL_SECRETS[@]} -gt 0 ]; then printf '  🔐 secret %s\n' "${DEL_SECRETS[@]}"
else echo "  🔐 secrets: none found"; fi
for s in "${SKIP_SECRETS[@]+"${SKIP_SECRETS[@]}"}"; do echo "  ⚠️  secret ${s} is used by the service but not named ${SERVICE_NAME}-*; it is NOT deleted"; done
if [ "${KEEP_CONFIG}" = true ]; then echo "  🪣 config folder: kept (--keep-config)"
elif [ -n "${GCS_DIR}" ]; then echo "  🪣 ${GCS_DIR}  (everything under it; the bucket stays)"
else echo "  🪣 config folder: no bucket known (pass --bucket)"; fi
echo ""

if [ "${DRY_RUN}" = true ]; then
    echo "Executing: gcloud run services delete ${SERVICE_NAME} --project ${PROJECT} --region ${REGION} --quiet"
    [ "${KEEP_SECRETS}" = true ] || for s in "${DEL_SECRETS[@]+"${DEL_SECRETS[@]}"}"; do echo "Executing: gcloud secrets delete ${s} --project ${PROJECT} --quiet"; done
    [ "${KEEP_CONFIG}" = true ] || [ -z "${GCS_DIR}" ] || echo "Executing: gcloud storage rm --recursive ${GCS_DIR} --project ${PROJECT}"
    echo "[dry-run] Nothing was deleted. Run again without --dry-run/--check to delete."
    exit 0
fi
confirm "Permanently delete the items above? This cannot be undone." || { echo "Not confirmed. Nothing was deleted." >&2; exit 1; }

# --- 1. The service ---
echo "☁️  Deleting service ${SERVICE_NAME}..."
gcloud run services delete "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" --quiet \
    || die "Could not delete the service; its secrets and config folder were left in place."
if gcloud run services describe "${SERVICE_NAME}" --project "${PROJECT}" --region "${REGION}" >/dev/null 2>&1; then
    die "Service '${SERVICE_NAME}' still exists after the delete; secrets and config folder were left in place."
fi
echo "  ✅ service deleted"

# --- 2. Leftovers: a failure here is reported at the end, and the other cleanup still runs ---
FAILED=0
if [ "${KEEP_SECRETS}" = false ]; then
    for s in "${DEL_SECRETS[@]+"${DEL_SECRETS[@]}"}"; do
        if gcloud secrets delete "${s}" --project "${PROJECT}" --quiet >/dev/null; then echo "  ✅ secret ${s} deleted"
        else echo "  ❌ could not delete secret ${s}" >&2; FAILED=$((FAILED + 1)); fi
    done
fi
if [ "${KEEP_CONFIG}" = false ] && [ -n "${GCS_DIR}" ]; then
    if gcloud storage ls "${GCS_DIR}" --project "${PROJECT}" >/dev/null 2>&1; then
        if gcloud storage rm --recursive "${GCS_DIR}" --project "${PROJECT}" >/dev/null; then echo "  ✅ ${GCS_DIR} deleted"
        else echo "  ❌ could not delete ${GCS_DIR}" >&2; FAILED=$((FAILED + 1)); fi
    else
        echo "  ℹ️  ${GCS_DIR} is already empty"
    fi
fi

# --- 3. The recorded URL ---
CUR_URL="$(env_value MCP_SERVER_SQL_URL)"
if [ -n "${CUR_URL}" ] && [ -n "${SERVICE_URL}" ] && [[ "${CUR_URL}" == "${SERVICE_URL}"* || "${CUR_URL}" == "https://${SERVICE_NAME}-"*.run.app* ]]; then
    echo "MCP_SERVER_SQL_URL in ${ENV_FILE#${REPO_ROOT}/} still points at the deleted service (${CUR_URL})."
    if confirm "Blank MCP_SERVER_SQL_URL in ${ENV_FILE#${REPO_ROOT}/}?"; then
        env_set MCP_SERVER_SQL_URL ""; echo "  💾 MCP_SERVER_SQL_URL blanked"
    fi
fi

echo ""
if [ "${FAILED}" -gt 0 ]; then
    echo "⚠️  Service deleted, but ${FAILED} cleanup step(s) failed (see above). Delete the rest by hand."
    exit 1
fi
echo "🎉 ${SERVICE_NAME} destroyed. Redeploy with: ./scripts/deploy_mcp_server.sh ${SYSARGS}"
echo "   Left in place: the service account and its roles, the bucket, the agent (./scripts/deploy_agent.sh ${SYSARGS})."
