# Oracle EBS MCP Server (`mcp-toolbox-ebs`) — Artifact Registry & Cloud Run Deployment Guide

This directory contains the containerized **Oracle E-Business Suite (EBS) Model Context Protocol (MCP) Server** built on Google's **GenAI Toolbox for Databases (`genai-toolbox`)** and pre-configured with **21 Oracle EBS ERP and Public Sector MCP tools** (`tools.yaml`).

## Key Capabilities

- **Pre-Configured Artifact Registry Image (`Dockerfile`):** Packages the official `genai-toolbox` runtime (`us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest`) together with the 21 parameterized Oracle EBS tool definitions (`/app/tools.yaml`) into your project's own **Google Artifact Registry** repository (`ebs-mcp-repo`).
- **Zero Plaintext Credentials in `tools.yaml`:** `tools.yaml` uses native `genai-toolbox` environment variable substitution (`${EBS_DB_CONNECTION_STRING}`, `${EBS_DB_USER}`, `${EBS_DB_PASSWORD}`), backed by **Google Cloud Secret Manager**.
- **Direct VPC Egress to Oracle EBS (`1521/tcp`):** Connects privately to your Oracle EBS database tier over your VPC network and subnet without exposing database ports to the public internet.

## Quick Start (1-Command Automated Deployment)

1. Copy `.env.example` to `.env` and populate your project, VPC, and Oracle EBS connection settings:
   ```bash
   cp .env.example .env
   ```
2. Run `deploy.sh` to automatically create the Artifact Registry repository (`ebs-mcp-repo`), build and push the container image via Cloud Build, store credentials in Secret Manager, and deploy `mcp-toolbox-ebs` to Cloud Run:
   ```bash
   ./deploy.sh
   ```

## Manual Step-by-Step Commands

If you prefer to run each `gcloud` step manually instead of executing `./deploy.sh`:

### 1. Set Environment Variables

```bash
export PROJECT_ID="your-project-id"
export REGION="us-central1"
export SERVICE_ACCOUNT_EMAIL="project-service-account@${PROJECT_ID}.iam.gserviceaccount.com"
export AR_REPO_NAME="ebs-mcp-repo"
export SERVICE_NAME="mcp-toolbox-ebs"
export VPC_NAME="your-vpc-network"
export SUBNET_NAME="your-subnet"
export EBS_DB_CONNECTION_STRING="10.0.0.10:1521/EBSDB"
export EBS_DB_USER="apps_ai"
export EBS_DB_PASSWORD="your-apps-ai-password"
```

### 2. Create Artifact Registry Repository & Build Image

```bash
gcloud artifacts repositories create "${AR_REPO_NAME}" \
    --repository-format=docker \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --description="Oracle EBS Gemini Enterprise MCP Server Container Repository"

export IMAGE_URL="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO_NAME}/${SERVICE_NAME}:latest"

gcloud builds submit . \
    --tag "${IMAGE_URL}" \
    --project "${PROJECT_ID}"
```

### 3. Store Oracle EBS Credentials & Tool Definitions in Secret Manager

```bash
printf "%s" "${EBS_DB_CONNECTION_STRING}" | gcloud secrets create "${SERVICE_NAME}-db-conn" --data-file=- --project="${PROJECT_ID}"
printf "%s" "${EBS_DB_USER}"              | gcloud secrets create "${SERVICE_NAME}-db-user" --data-file=- --project="${PROJECT_ID}"
printf "%s" "${EBS_DB_PASSWORD}"          | gcloud secrets create "${SERVICE_NAME}-db-pass" --data-file=- --project="${PROJECT_ID}"
gcloud secrets create "${SERVICE_NAME}-secret" --data-file=tools.yaml --project="${PROJECT_ID}"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/secretmanager.secretAccessor"
```

### 4. Deploy to Cloud Run

```bash
gcloud run deploy "${SERVICE_NAME}" \
    --project "${PROJECT_ID}" \
    --image "${IMAGE_URL}" \
    --service-account "${SERVICE_ACCOUNT_EMAIL}" \
    --region "${REGION}" \
    --set-secrets "/app/tools.yaml=${SERVICE_NAME}-secret:latest,EBS_DB_CONNECTION_STRING=${SERVICE_NAME}-db-conn:latest,EBS_DB_USER=${SERVICE_NAME}-db-user:latest,EBS_DB_PASSWORD=${SERVICE_NAME}-db-pass:latest" \
    --args="--config=/app/tools.yaml","--address=0.0.0.0","--port=8080","--log-level=DEBUG" \
    --network "${VPC_NAME}" \
    --subnet "${SUBNET_NAME}" \
    --allow-unauthenticated
```

### 5. Retrieve the MCP Server URL

```bash
echo "$(gcloud run services describe ${SERVICE_NAME} --project ${PROJECT_ID} --region ${REGION} --format 'value(status.url)')/mcp"
```
