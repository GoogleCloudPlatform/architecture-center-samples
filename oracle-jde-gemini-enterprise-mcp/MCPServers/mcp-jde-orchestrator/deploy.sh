#!/bin/bash
set -e

cd "$(dirname "$0")" || exit 1

if [ -f .env ]; then
    source .env
else
    echo "Notice: .env file not found in $(pwd); reading configuration from environment variables."
fi

MCP_SERVICE_NAME="${SERVICE_NAME:-mcp-jde-orchestrator}"
AR_REPO_NAME="${AR_REPO_NAME:-jde-mcp-repo}"
BUILD_AR_IMAGE="${BUILD_AR_IMAGE:-true}"
JDE_AIS_BASE_URL="${JDE_AIS_BASE_URL:-http://10.118.0.43:7077}"
JDE_ENVIRONMENT="${JDE_ENVIRONMENT:-JPD920}"
JDE_ROLE="${JDE_ROLE:-MFG_MGR}"

REQUIRED_VARS=(PROJECT_ID REGION SERVICE_ACCOUNT_EMAIL VPC_NAME SUBNET_NAME)
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "Error: $VAR is not set in .env or environment."
        exit 1
    fi
done

echo "========================================================================"
echo "Deploying Oracle JDE Hybrid Orchestrator + SQL MCP Server ($MCP_SERVICE_NAME)"
echo "  Project ID:            $PROJECT_ID"
echo "  Region:                $REGION"
echo "  Service Account:       $SERVICE_ACCOUNT_EMAIL"
echo "  VPC / Subnet:          $VPC_NAME / $SUBNET_NAME"
echo "  JDE AIS Base URL:      $JDE_AIS_BASE_URL"
echo "  Build AR Image:        $BUILD_AR_IMAGE ($AR_REPO_NAME)"
echo "========================================================================"

upsert_secret_from_value() {
    local secret_name="$1"
    local secret_val="$2"
    local current_val=""

    if gcloud secrets describe "$secret_name" --project="$PROJECT_ID" >/dev/null 2>&1; then
        if current_val=$(gcloud secrets versions access latest --secret="$secret_name" --project="$PROJECT_ID" 2>/dev/null); then
            if [ "$secret_val" != "$current_val" ]; then
                echo "Updating Secret Manager secret '$secret_name'..."
                printf "%s" "$secret_val" | gcloud secrets versions add "$secret_name" --data-file=- --project="$PROJECT_ID" >/dev/null
            fi
        else
            echo "Adding initial version to Secret Manager secret '$secret_name'..."
            printf "%s" "$secret_val" | gcloud secrets versions add "$secret_name" --data-file=- --project="$PROJECT_ID" >/dev/null
        fi
    else
        echo "Creating Secret Manager secret '$secret_name'..."
        gcloud secrets create "$secret_name" --project="$PROJECT_ID" >/dev/null
        printf "%s" "$secret_val" | gcloud secrets versions add "$secret_name" --data-file=- --project="$PROJECT_ID" >/dev/null
    fi
}

SECRET_ENV_ARGS=""
if [ -n "${JDE_DB_DSN:-}" ]; then
    upsert_secret_from_value "${MCP_SERVICE_NAME}-db-dsn" "$JDE_DB_DSN"
    upsert_secret_from_value "${MCP_SERVICE_NAME}-db-user" "${JDE_DB_USER:-JDE_AI}"
    upsert_secret_from_value "${MCP_SERVICE_NAME}-db-pass" "${JDE_DB_PASSWORD:-REPLACE_ME}"
    upsert_secret_from_value "${MCP_SERVICE_NAME}-ais-pass" "${JDE_PASSWORD:-REPLACE_ME}"
    SECRET_ENV_ARGS="--set-secrets=JDE_DB_DSN=${MCP_SERVICE_NAME}-db-dsn:latest,JDE_DB_USER=${MCP_SERVICE_NAME}-db-user:latest,JDE_DB_PASSWORD=${MCP_SERVICE_NAME}-db-pass:latest,JDE_PASSWORD=${MCP_SERVICE_NAME}-ais-pass:latest"
fi

if ! gcloud artifacts repositories describe "$AR_REPO_NAME" --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    echo "Creating Artifact Registry Docker repository '$AR_REPO_NAME' in $REGION..."
    gcloud artifacts repositories create "$AR_REPO_NAME" \
        --repository-format=docker \
        --location="$REGION" \
        --project="$PROJECT_ID" \
        --description="Oracle JD Edwards Hybrid Orchestrator + SQL MCP Server Repository"
fi

MCP_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO_NAME}/${MCP_SERVICE_NAME}:latest"
echo "Building and publishing JDE Hybrid MCP container image to Artifact Registry:"
echo "  $MCP_IMAGE"
gcloud builds submit . \
    --tag "$MCP_IMAGE" \
    --project "$PROJECT_ID" \
    --quiet

echo "Deploying Cloud Run service '$MCP_SERVICE_NAME'..."
gcloud run deploy "$MCP_SERVICE_NAME" \
    --project "$PROJECT_ID" \
    --image "$MCP_IMAGE" \
    --service-account "$SERVICE_ACCOUNT_EMAIL" \
    --region "$REGION" \
    --set-env-vars "JDE_AIS_BASE_URL=${JDE_AIS_BASE_URL},JDE_ENVIRONMENT=${JDE_ENVIRONMENT},JDE_ROLE=${JDE_ROLE},JDE_USERNAME=${JDE_USERNAME:-NGONZAL},JDE_SCHEMA=PRODDTA" \
    $SECRET_ENV_ARGS \
    --network "$VPC_NAME" \
    --subnet "$SUBNET_NAME" \
    --vpc-egress all-traffic \
    --no-allow-unauthenticated

SERVICE_URL=$(gcloud run services describe "$MCP_SERVICE_NAME" --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
echo "========================================================================"
echo "Deployment complete!"
echo "  Cloud Run Service URL: $SERVICE_URL"
echo "  MCP Endpoint URL:      ${SERVICE_URL}/mcp"
echo "========================================================================"
