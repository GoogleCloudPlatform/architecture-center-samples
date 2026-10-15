# Oracle PeopleSoft MCP Server (`mcp-toolbox-peoplesoft`) — Artifact Registry & Cloud Run Deployment Guide

This directory contains the containerized **Oracle PeopleSoft FSCM 9.2 Model Context Protocol (MCP) Server** built on Google's **GenAI Toolbox for Databases (`genai-toolbox`)** and pre-configured with **20 Oracle PeopleSoft FSCM 9.2 MCP tools** (`tools.yaml`).

## Key Capabilities

- **Pre-Configured Artifact Registry Image (`Dockerfile`):** Packages the official `genai-toolbox` runtime (`us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest`) together with the 20 parameterized Oracle PeopleSoft 9.2 tool definitions (`/app/tools.yaml`) into your project's own **Google Artifact Registry** repository (`peoplesoft-mcp-repo`).
- **Zero Plaintext Credentials in `tools.yaml`:** `tools.yaml` uses native `genai-toolbox` environment variable substitution (`${PSFT_DB_CONNECTION_STRING}`, `${PSFT_DB_USER}`, `${PSFT_DB_PASSWORD}`), backed by **Google Cloud Secret Manager**.
- **Direct VPC Egress to Oracle PeopleSoft 9.2 (`1521/tcp`):** Connects privately to your Oracle PeopleSoft 9.2 database tier (`EP92U055`) over your VPC network and subnet without exposing database ports to the public internet.

## Quick Start (1-Command Automated Deployment)

1. Copy `.env.example` to `.env` and populate your project, VPC, and Oracle PeopleSoft connection settings:
   ```bash
   cp .env.example .env
   ```
2. Run `deploy.sh` to automatically create the Artifact Registry repository (`peoplesoft-mcp-repo`), build and push the container image via Cloud Build, store credentials in Secret Manager, and deploy `mcp-toolbox-peoplesoft` to Cloud Run:
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
export AR_REPO_NAME="peoplesoft-mcp-repo"
export SERVICE_NAME="mcp-toolbox-peoplesoft"
export VPC_NAME="your-vpc-network"
export SUBNET_NAME="your-subnet"
export PSFT_DB_CONNECTION_STRING="10.117.0.20:1521/EP92U055"
export PSFT_DB_USER="PSFT_AI"
export PSFT_DB_PASSWORD="your-psft-ai-password"
```

### 2. Create Artifact Registry Repository & Build Image

> **Assured Workloads Prerequisites:**
> 1. **Build-time:** When building regionally (`--region "${REGION}"`) inside an Assured Workloads folder (`constraints/gcp.resourceLocations`), ensure your Cloud Build service account (`<PROJECT_NUMBER>-compute@developer.gserviceaccount.com` or custom `CLOUD_BUILD_SERVICE_ACCOUNT`) holds `roles/cloudbuild.builds.builder`.
> 2. **Runtime:** Enable Private Google Access on your target subnet so that the zero-external-IP environment can reach Google APIs:
>    ```bash
>    gcloud compute networks subnets update "${SUBNET_NAME}" --region="${REGION}" --enable-private-ip-google-access --project="${PROJECT_ID}"
>    ```

```bash
gcloud artifacts repositories create "${AR_REPO_NAME}" \
    --repository-format=docker \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --description="Oracle PeopleSoft Gemini Enterprise MCP Server Container Repository"

export IMAGE_URL="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO_NAME}/${SERVICE_NAME}:latest"

gcloud builds submit . \
    --tag "${IMAGE_URL}" \
    --project "${PROJECT_ID}" \
    --region "${REGION}" \
    --default-buckets-behavior=regional-user-owned-bucket
```

### 3. Store Oracle PeopleSoft Credentials & Tool Definitions in Secret Manager

```bash
printf "%s" "${PSFT_DB_CONNECTION_STRING}" | gcloud secrets create "${SERVICE_NAME}-db-conn" \
    --replication-policy="user-managed" \
    --locations="${REGION}" \
    --data-file=- \
    --project="${PROJECT_ID}"
printf "%s" "${PSFT_DB_USER}"              | gcloud secrets create "${SERVICE_NAME}-db-user" \
    --replication-policy="user-managed" \
    --locations="${REGION}" \
    --data-file=- \
    --project="${PROJECT_ID}"
printf "%s" "${PSFT_DB_PASSWORD}"          | gcloud secrets create "${SERVICE_NAME}-db-pass" \
    --replication-policy="user-managed" \
    --locations="${REGION}" \
    --data-file=- \
    --project="${PROJECT_ID}"
gcloud secrets create "${SERVICE_NAME}-secret" \
    --replication-policy="user-managed" \
    --locations="${REGION}" \
    --data-file=tools.yaml \
    --project="${PROJECT_ID}"

for SECRET_ID in "${SERVICE_NAME}-db-conn" "${SERVICE_NAME}-db-user" "${SERVICE_NAME}-db-pass" "${SERVICE_NAME}-secret"; do
    gcloud secrets add-iam-policy-binding "${SECRET_ID}" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/secretmanager.secretAccessor" \
        --project="${PROJECT_ID}"
done
```

### 4. Deploy to Cloud Run

```bash
gcloud run deploy "${SERVICE_NAME}" \
    --project "${PROJECT_ID}" \
    --image "${IMAGE_URL}" \
    --service-account "${SERVICE_ACCOUNT_EMAIL}" \
    --region "${REGION}" \
    --set-secrets "/app/tools.yaml=${SERVICE_NAME}-secret:latest,PSFT_DB_CONNECTION_STRING=${SERVICE_NAME}-db-conn:latest,PSFT_DB_USER=${SERVICE_NAME}-db-user:latest,PSFT_DB_PASSWORD=${SERVICE_NAME}-db-pass:latest" \
    --args="--config=/app/tools.yaml","--address=0.0.0.0","--port=8080","--log-level=DEBUG" \
    --network "${VPC_NAME}" \
    --subnet "${SUBNET_NAME}" \
    --vpc-egress "${VPC_EGRESS:-private-ranges-only}" \
    --ingress "${INGRESS:-all}" \
    --no-allow-unauthenticated
```

### 5. Retrieve & Verify the Authenticated MCP Server URL

Since the service is deployed with `--no-allow-unauthenticated`, include an OIDC ID token scoped to the Cloud Run service URL (`--audiences="${SERVICE_URL}"`) in the `Authorization` header when making requests:

```bash
export SERVICE_URL="$(gcloud run services describe ${SERVICE_NAME} --project ${PROJECT_ID} --region ${REGION} --format 'value(status.url)')"
export MCP_URL="${SERVICE_URL}/mcp"
echo "${MCP_URL}"
curl -s -X POST "${MCP_URL}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-identity-token --audiences="${SERVICE_URL}")" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
```
