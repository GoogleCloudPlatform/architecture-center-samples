#!/bin/bash
set -e # CRITICAL: Force the script to fail and halt if any command crashes

# Ensure we're running from the script's directory
cd "$(dirname "$0")" || exit 1

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found."
    echo "Please ensure Terraform generated the .env file."
    exit 1
fi

# Source environment variables
source .env

# MCP_TOOLBOX specific configuration
MCP_TOOLBOX_SERVICE_NAME="mcp-toolbox-ebs"
# FIX: Google hosts this public image strictly in us-central1, regardless of where Cloud Run is deployed!
MCP_TOOLBOX_IMAGE="us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest"
MCP_TOOLBOX_SECRET_NAME="${MCP_TOOLBOX_SERVICE_NAME}-secret"

# Make sure required variables are set
REQUIRED_VARS=(PROJECT_ID REGION SERVICE_ACCOUNT_EMAIL VPC_NAME SUBNET_NAME)
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "Error: $VAR is not set in .env."
        exit 1
    fi
done

echo "Deploying MCP Toolkit EBS to Google Cloud Run..."
echo "Project ID: $PROJECT_ID"
echo "Service Name: $MCP_TOOLBOX_SERVICE_NAME"
echo "Region: $REGION"

# 1. Check tools.yaml and setup secret
if [ ! -f tools.yaml ]; then
    echo "Warning: tools.yaml not found in current directory."
    echo "You must configure tools.yaml before deploying."
    exit 1
else
    # Temporarily disable exit-on-error so a missing secret doesn't crash the script
    set +e
    gcloud secrets versions access latest --secret="$MCP_TOOLBOX_SECRET_NAME" --project="$PROJECT_ID" > /tmp/current_tools.yaml 2>/dev/null
    SECRET_EXISTS=$?
    set -e

    if [ $SECRET_EXISTS -eq 0 ]; then
        if cmp -s tools.yaml /tmp/current_tools.yaml; then
            echo "tools.yaml has not changed since the last deployment. Skipping secret update."
            SKIP_SECRET_UPDATE=true
        else
            echo "tools.yaml has changed since the last deployment. Updating secret..."
            SKIP_SECRET_UPDATE=false
        fi
    else
        echo "Secret $MCP_TOOLBOX_SECRET_NAME does not exist or cannot be accessed. It will be created."
        SKIP_SECRET_UPDATE=false
    fi
    rm -f /tmp/current_tools.yaml
    
    # Attempt to create the secret. If it exists, add a new version instead.
    if [ "$SKIP_SECRET_UPDATE" = false ]; then
        echo "Creating/Updating Secret Manager for tools.yaml..."
        set +e
        gcloud secrets create "$MCP_TOOLBOX_SECRET_NAME" --data-file=tools.yaml --project="$PROJECT_ID" 2>/dev/null
        CREATE_STATUS=$?
        set -e
        
        if [ $CREATE_STATUS -ne 0 ]; then
            echo "Secret already exists. Adding new version..."
            gcloud secrets versions add "$MCP_TOOLBOX_SECRET_NAME" --data-file=tools.yaml --project="$PROJECT_ID"
        fi
    fi
fi

# 2. Deploy to Cloud Run
echo "Deploying Cloud Run service..."
gcloud run deploy "$MCP_TOOLBOX_SERVICE_NAME" \
    --project "$PROJECT_ID" \
    --image "$MCP_TOOLBOX_IMAGE" \
    --service-account "$SERVICE_ACCOUNT_EMAIL" \
    --region "$REGION" \
    --set-secrets "/app/tools.yaml=$MCP_TOOLBOX_SECRET_NAME:latest" \
    --args="--config=/app/tools.yaml","--address=0.0.0.0","--port=8080","--log-level=DEBUG" \
    --network "$VPC_NAME" \
    --subnet "$SUBNET_NAME" \
    --allow-unauthenticated

echo "Deployment complete."
echo "To get the service URL run:"
echo "gcloud run services describe $MCP_TOOLBOX_SERVICE_NAME --project $PROJECT_ID --region $REGION --format 'value(status.url)'"