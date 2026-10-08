#!/bin/bash
set -e # CRITICAL: Force the script to fail and halt if any command crashes

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

# Helper function to create or update a secret in Google Cloud Secret Manager
upsert_secret_from_file() {
    local secret_name="$1"
    local file_path="$2"
    local tmp_secret
    tmp_secret=$(mktemp)

    set +e
    gcloud secrets describe "$secret_name" --project="$PROJECT_ID" >/dev/null 2>&1
    local secret_exists=$?
    set -e

    if [ $secret_exists -eq 0 ]; then
        set +e
        gcloud secrets versions access latest --secret="$secret_name" --project="$PROJECT_ID" > "$tmp_secret" 2>/dev/null
        local version_exists=$?
        set -e

        if [ $version_exists -eq 0 ] && cmp -s "$file_path" "$tmp_secret"; then
            echo "Secret '$secret_name' is unchanged. Skipping new version."
            rm -f "$tmp_secret"
            return 0
        fi
        echo "Updating existing Secret Manager secret '$secret_name'..."
        gcloud secrets versions add "$secret_name" --data-file="$file_path" --project="$PROJECT_ID" >/dev/null
    else
        echo "Creating Secret Manager secret '$secret_name'..."
        gcloud secrets create "$secret_name" --data-file="$file_path" --project="$PROJECT_ID" >/dev/null
    fi
    rm -f "$tmp_secret"
}

upsert_secret_from_value() {
    local secret_name="$1"
    local secret_val="$2"
    local tmp_file
    tmp_file=$(mktemp)
    printf "%s" "$secret_val" > "$tmp_file"
    upsert_secret_from_file "$secret_name" "$tmp_file"
    rm -f "$tmp_file"
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
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-conn" "$EBS_DB_CONNECTION_STRING"
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-user" "${EBS_DB_USER:-apps_ai}"
    upsert_secret_from_value "${MCP_TOOLBOX_SERVICE_NAME}-db-pass" "${EBS_DB_PASSWORD:-apps_ai}"
    SECRET_ENV_BINDINGS=",EBS_DB_CONNECTION_STRING=${MCP_TOOLBOX_SERVICE_NAME}-db-conn:latest,EBS_DB_USER=${MCP_TOOLBOX_SERVICE_NAME}-db-user:latest,EBS_DB_PASSWORD=${MCP_TOOLBOX_SERVICE_NAME}-db-pass:latest"
fi

# Upload tools.yaml to Secret Manager so tool definitions can also be updated without rebuilding
upsert_secret_from_file "$MCP_TOOLBOX_SECRET_NAME" "tools.yaml"

# Ensure the Cloud Run service account has Secret Manager Secret Accessor permission
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/secretmanager.secretAccessor" \
    --quiet >/dev/null 2>&1 || true

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
    echo "Building and publishing pre-configured EBS MCP image to Artifact Registry:"
    echo "  $MCP_TOOLBOX_IMAGE"
    gcloud builds submit . \
        --tag "$MCP_TOOLBOX_IMAGE" \
        --project "$PROJECT_ID" \
        --quiet
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
    --allow-unauthenticated

SERVICE_URL=$(gcloud run services describe "$MCP_TOOLBOX_SERVICE_NAME" --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
echo "========================================================================"
echo "Deployment complete!"
echo "  Cloud Run Service URL: $SERVICE_URL"
echo "  MCP Endpoint URL:      ${SERVICE_URL}/mcp"
echo "========================================================================"