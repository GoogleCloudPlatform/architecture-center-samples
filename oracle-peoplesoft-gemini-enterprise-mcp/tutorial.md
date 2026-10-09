# Deploy Oracle PeopleSoft 9.2 MCP Server for Gemini Enterprise to Google Cloud

Welcome to the interactive **Oracle PeopleSoft FSCM 9.2 Gemini Enterprise MCP Server** deployment walkthrough. This guide walks you through deploying the 20-tool Oracle PeopleSoft MCP server (`mcp-toolbox-peoplesoft`) to **Google Artifact Registry** and **Google Cloud Run** (with credentials secured in **Google Cloud Secret Manager**) so it can power the **6 Gemini Enterprise Public Sector Skills**.

---

## Step 1: Select Your Google Cloud Project & Region

Set your target Google Cloud Project ID, region, and VPC network connected to your Oracle PeopleSoft 9.2 database tier:

```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
gcloud config set project "$PROJECT_ID"
```

Verify your active project:

```bash
echo "Deploying into Project: $PROJECT_ID (Region: $REGION)"
```

---

## Step 2: Enable Required Google Cloud APIs

Enable Cloud Run, Artifact Registry, Cloud Build, Secret Manager, Compute Engine, and Vertex AI APIs:

```bash
gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    compute.googleapis.com \
    aiplatform.googleapis.com \
    --project="$PROJECT_ID"
```

---

## Step 3: Install Oracle PeopleSoft 9.2 Database Objects (DBA Step)

Before starting the Cloud Run service, run the SQL and PL/SQL installation scripts in `PSFTScripts/` on your Oracle PeopleSoft FSCM 9.2 database tier (`EP92U055`):

1. **Create Least-Privilege `PSFT_AI` Schema, Grants & Logon Trigger** (as `SYS` / `DBA`):
   - `PSFTScripts/create_psft_ai.sql`
2. **Compile PL/SQL Wrapper Package & Audit Table** (as `SYSADM`):
   - `PSFTScripts/ge_psft_mcp_tools.sql`
3. **Install Public Sector Read-Only Views & Seed Data** (as `SYSADM`, optional for Public Sector skills):
   - `PSFTScripts/install_gov_psft_mcp_and_seed.sql`
   - `PSFTScripts/install_gov_public_sector_views.sql`

---

## Step 4: Configure & Deploy the Oracle PeopleSoft MCP Server to Artifact Registry & Cloud Run

Configure your environment variables in `MCPServers/mcp-toolbox-peoplesoft/.env`:

```bash
cd MCPServers/mcp-toolbox-peoplesoft
cp .env.example .env
```

Edit `MCPServers/mcp-toolbox-peoplesoft/.env` (or export the variables below) with your VPC, Subnet, Service Account, and Oracle PeopleSoft connection string:

```bash
export SERVICE_ACCOUNT_EMAIL="project-service-account@${PROJECT_ID}.iam.gserviceaccount.com"
export VPC_NAME="your-vpc-network"
export SUBNET_NAME="your-subnet"
export PSFT_DB_CONNECTION_STRING="10.117.0.20:1521/EP92U055"
export PSFT_DB_USER="PSFT_AI"
export PSFT_DB_PASSWORD="your-psft-ai-password"
```

Run the automated deployment script to:
1. Create the `peoplesoft-mcp-repo` Docker repository in your project's **Artifact Registry**
2. Build and push the pre-configured `mcp-toolbox-peoplesoft` container image (`Dockerfile` + 20 parameterized `tools.yaml` tools)
3. Store your Oracle PeopleSoft credentials in **Secret Manager**
4. Deploy `mcp-toolbox-peoplesoft` to **Cloud Run** with Direct VPC Egress

```bash
./deploy.sh
```

---

## Step 5: Connect Your Cloud Run MCP Endpoint to Gemini Enterprise

Once `./deploy.sh` finishes, it prints your **MCP Endpoint URL**:

```text
https://mcp-toolbox-peoplesoft-<hash>-uc.a.run.app/mcp
```

1. **Register the BYO-MCP Endpoint in Gemini Enterprise:** Register the `/mcp` endpoint directly in your Gemini Enterprise / Vertex AI Agent Builder console.
2. **Invoke the 6 Gemini Enterprise Public Sector Skills:** In the Gemini Enterprise web app, open the **Skills** gallery or type `/` in chat (`/plain-language-notice-generator`, `/redaction-and-foia-compliance`, `/policy-and-statute-assistant`, `/document-intake-cleanup-and-validation`, `/rfp-vendor-evaluation-scorer`, `/expense-auditor`) to ground your workflows in live Oracle PeopleSoft FSCM 9.2 data.

Congratulations! Your Oracle PeopleSoft 9.2 Gemini Enterprise MCP Server is now live.
