#!/bin/bash
set -eo pipefail # CRITICAL: Force the script to fail and halt if any command or pipeline crashes

# Ensure we're running from the script's directory
cd "$(dirname "$0")" || exit 1

# Source .env file if present (allows overriding via exported environment variables as well)
if [ -f .env ]; then
    source .env
else
    echo "Notice: .env file not found in $(pwd); reading configuration from environment variables."
fi

# MCP_TOOLBOX specific configuration
MCP_TOOLBOX_SERVICE_NAME="${SERVICE_NAME:-mcp-toolbox-ebs}"
AR_REPO_NAME="${AR_REPO_NAME:-ebs-mcp-repo}"
BUILD_AR_IMAGE="${BUILD_AR_IMAGE:-true}"
BASE_TOOLBOX_IMAGE="us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest"
MCP_TOOLBOX_SECRET_NAME="${SECRET_NAME:-${MCP_TOOLBOX_SERVICE_NAME}-secret}"
INGRESS="${INGRESS:-all}"
VPC_EGRESS="${VPC_EGRESS:-private-ranges-only}"
CLOUD_BUILD_SERVICE_ACCOUNT="${CLOUD_BUILD_SERVICE_ACCOUNT:-}"

# Make sure required variables are set
REQUIRED_VARS=(PROJECT_ID REGION SERVICE_ACCOUNT_EMAIL VPC_NAME SUBNET_NAME)
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "Error: $VAR is not set in .env or environment."
        exit 1
    fi
done

echo "========================================================================"
echo "Deploying Oracle EBS MCP Server ($MCP_TOOLBOX_SERVICE_NAME) to Cloud Run"
echo "  Project ID:            $PROJECT_ID"
echo "  Region:                $REGION"
echo "  Service Account:       $SERVICE_ACCOUNT_EMAIL"
echo "  VPC / Subnet:          $VPC_NAME / $SUBNET_NAME"
echo "  Build AR Image:        $BUILD_AR_IMAGE ($AR_REPO_NAME)"
echo "========================================================================"

# Helper functions to create or update secrets in Google Cloud Secret Manager
_emit_secret_data() {
    local mode="$1"
    local payload="$2"
    if [ "$mode" = "file" ]; then
        if [ ! -r "$payload" ]; then
            echo "Error: Secret source file '$payload' not found or not readable." >&2
            return 1
        fi
        cat -- "$payload"
    else
        printf "%s" "$payload"
    fi
}

_upsert_secret() {
    local secret_name="$1"
    local mode="$2"
    local payload="$3"
    if [ "$mode" = "file" ] && [ ! -r "$payload" ]; then
        echo "Error: Secret source file '$payload' not found or not readable." >&2
        return 1
    fi
    if gcloud secrets describe "$secret_name" --project="$PROJECT_ID" >/dev/null 2>&1; then
        if gcloud secrets versions access latest --secret="$secret_name" --project="$PROJECT_ID" 2>/dev/null | cmp -s - <(_emit_secret_data "$mode" "$payload"); then
            echo "Secret '$secret_name' is unchanged. Skipping new version."
            return 0
        fi
        echo "Updating existing Secret Manager secret '$secret_name'..."
        _emit_secret_data "$mode" "$payload" | gcloud secrets versions add "$secret_name" --data-file=- --project="$PROJECT_ID" >/dev/null
    else
        echo "Creating Secret Manager secret '$secret_name' in region '$REGION'..."
        # Official gcloud CLI syntax (verified via 'gcloud secrets create --help'):
        # requires --replication-policy="user-managed" and --locations="$REGION" (note: --replication is not a valid gcloud flag).
        _emit_secret_data "$mode" "$payload" | gcloud secrets create "$secret_name" \
            --replication-policy="user-managed" \
            --locations="$REGION" \
            --data-file=- \
            --project="$PROJECT_ID" >/dev/null
    fi
}

upsert_secret_from_file() {
    local secret_name="$1"
    local file_path="$2"
    _upsert_secret "$secret_name" "file" "$file_path"
}

upsert_secret_from_value() {
    local secret_name="$1"
    local secret_val="$2"
    _upsert_secret "$secret_name" "value" "$secret_val"
}

# 1. Ensure tools.yaml exists locally (copy from tools.yaml.example if needed)
if [ ! -f tools.yaml ]; then
    if [ -f tools.yaml.example ]; then
        echo "Copying tools.yaml.example to tools.yaml..."
        cp tools.yaml.example tools.yaml
    else
        echo "Error: tools.yaml not found in $(pwd)."
        exit 1
    fi
fi

# 2. Store Oracle EBS DB credentials in Secret Manager (if provided via .env or environment)
SECRET_ENV_BINDINGS=""
if [ -n "${EBS_DB_CONNECTION_STRING:-}" ] && [ "${EBS_DB_CONNECTION_STRING}" != "apps.example.com:1521/EBSDB" ]; then
    if [ -z "${EBS_DB_PASSWORD:-}" ] || [ "${EBS_DB_PASSWORD}" = "REPLACE_WITH_APPS_AI_PASSWORD" ]; then
        echo "Error: EBS_DB_PASSWORD is empty or set to the default placeholder 'REPLACE_WITH_APPS_AI_PASSWORD'." >&2
        echo "Please configure a valid database password in your .env file." >&2
        exit 1
    fi
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-conn" "$EBS_DB_CONNECTION_STRING"
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-user" "${EBS_DB_USER:-apps_ai}"
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-pass" "$EBS_DB_PASSWORD"
    SECRET_ENV_BINDINGS=",EBS_DB_CONNECTION_STRING=${MCP_TOOLBOX_SERVICE_NAME}-db-conn:latest,EBS_DB_USER=${MCP_TOOLBOX_SERVICE_NAME}-db-user:latest,EBS_DB_PASSWORD=${MCP_TOOLBOX_SERVICE_NAME}-db-pass:latest"
fi

# Upload tools.yaml to Secret Manager so tool definitions can also be updated without rebuilding
upsert_secret_from_file "$MCP_TOOLBOX_SECRET_NAME" "tools.yaml"

# Ensure the Cloud Run service account has Secret Manager Secret Accessor permission on the configured secrets
ACTIVE_SECRETS=("$MCP_TOOLBOX_SECRET_NAME")
if [ -n "$SECRET_ENV_BINDINGS" ]; then
    ACTIVE_SECRETS+=("${MCP_TOOLBOX_SERVICE_NAME}-db-conn" "${MCP_TOOLBOX_SERVICE_NAME}-db-user" "${MCP_TOOLBOX_SERVICE_NAME}-db-pass")
else
    echo "Notice: EBS_DB_CONNECTION_STRING is not configured or is set to the default placeholder. Database secrets will not be bound to the Cloud Run service."
fi
for SECRET_ID in "${ACTIVE_SECRETS[@]}"; do
    if ! gcloud secrets add-iam-policy-binding "$SECRET_ID" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/secretmanager.secretAccessor" \
        --project="$PROJECT_ID" \
        --quiet >/dev/null; then
        echo "Warning: Failed to bind Secret Manager Secret Accessor role to $SERVICE_ACCOUNT_EMAIL for secret $SECRET_ID. Please ensure the service account has access." >&2
    fi
done

# 3. Build & Push Pre-Configured EBS MCP Image to Customer's Artifact Registry (Phase 1)
if [ "$BUILD_AR_IMAGE" = "true" ] && [ -f Dockerfile ]; then
    echo "Checking Artifact Registry repository '$AR_REPO_NAME' in $REGION..."
    if ! gcloud artifacts repositories describe "$AR_REPO_NAME" --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
        echo "Creating Artifact Registry Docker repository '$AR_REPO_NAME' in $REGION..."
        gcloud artifacts repositories create "$AR_REPO_NAME" \
            --repository-format=docker \
            --location="$REGION" \
            --project="$PROJECT_ID" \
            --description="Oracle EBS Gemini Enterprise MCP Server Container Repository"
    fi

    MCP_TOOLBOX_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO_NAME}/${MCP_TOOLBOX_SERVICE_NAME}:latest"
    echo "Building and publishing pre-configured EBS MCP image to Artifact Registry in region '$REGION':"
    echo "  $MCP_TOOLBOX_IMAGE"
    BUILD_ARGS=(
        --tag "$MCP_TOOLBOX_IMAGE"
        --project "$PROJECT_ID"
        --region "$REGION"
        --default-buckets-behavior=regional-user-owned-bucket
        --quiet
    )
    if [ -n "$CLOUD_BUILD_SERVICE_ACCOUNT" ]; then
        BUILD_ARGS+=(--service-account "$CLOUD_BUILD_SERVICE_ACCOUNT")
    fi
    # Ensure sensitive .env file is not uploaded to Cloud Build
    if [ ! -f .gcloudignore ]; then
        if [ -f .gitignore ]; then
            cp .gitignore .gcloudignore
        else
            printf "%s\n" ".git" ".gcloudignore" > .gcloudignore
        fi
    fi
    if ! grep -Fxq ".env" .gcloudignore; then
        printf "\n%s\n" ".env" >> .gcloudignore
    fi
    gcloud builds submit . "${BUILD_ARGS[@]}"
else
    MCP_TOOLBOX_IMAGE="${IMAGE_URL:-$BASE_TOOLBOX_IMAGE}"
    echo "Using base Toolbox container image: $MCP_TOOLBOX_IMAGE"
fi

# 4. Deploy to Google Cloud Run with Direct VPC Egress
echo "Deploying Cloud Run service '$MCP_TOOLBOX_SERVICE_NAME'..."
gcloud run deploy "$MCP_TOOLBOX_SERVICE_NAME" \
    --project "$PROJECT_ID" \
    --image "$MCP_TOOLBOX_IMAGE" \
    --service-account "$SERVICE_ACCOUNT_EMAIL" \
    --region "$REGION" \
    --set-secrets "/app/tools.yaml=${MCP_TOOLBOX_SECRET_NAME}:latest${SECRET_ENV_BINDINGS}" \
    --args="--config=/app/tools.yaml","--address=0.0.0.0","--port=8080","--log-level=DEBUG" \
    --network "$VPC_NAME" \
    --subnet "$SUBNET_NAME" \
    --vpc-egress "$VPC_EGRESS" \
    --ingress "$INGRESS" \
    --no-allow-unauthenticated

SERVICE_URL=$(gcloud run services describe "$MCP_TOOLBOX_SERVICE_NAME" --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
echo "========================================================================"
echo "Deployment complete!"
echo "  Cloud Run Service URL: $SERVICE_URL"
echo "  MCP Endpoint URL:      ${SERVICE_URL}/mcp"
echo "========================================================================"