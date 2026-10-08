# Deploy Oracle EBS MCP Server for Gemini Enterprise to Google Cloud

Welcome to the interactive **Oracle E-Business Suite (EBS) Gemini Enterprise MCP Server** deployment walkthrough. This guide walks you through deploying the 21-tool Oracle EBS MCP server (`mcp-toolbox-ebs`) to **Google Artifact Registry** and **Google Cloud Run** (with credentials secured in **Google Cloud Secret Manager**) so it can power the **6 Gemini Enterprise Public Sector Skills**.

---

## Step 1: Select Your Google Cloud Project & Region

Set your target Google Cloud Project ID, region, and VPC network connected to your Oracle EBS database tier:

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

## Step 3: Install Oracle EBS Database Objects (DBA Step)

Before starting the Cloud Run service, run the SQL and PL/SQL installation scripts in `EBSScripts/` on your Oracle EBS 12.2.x database tier (`EBSDB`):

1. **Create Least-Privilege `APPS_AI` Schema & Grants** (as `SYSTEM` / `APPS`):
   - `EBSScripts/create_apps_ai.sql`
   - `EBSScripts/GrantToApps_AIRESTRICTED.sql`
2. **Compile PL/SQL Wrapper Package & Audit Table** (as `APPS`):
   - `EBSScripts/ge_ebs_mcp_tools.pls`
   - `EBSScripts/ge_ebs_mcp_tools.plb`
3. **Install Public Sector Read-Only Views & Official API Seed Script** (as `APPS`, optional for Public Sector skills):
   - `EBSScripts/install_gov_public_sector_views.sql`
   - `EBSScripts/create_v2_reports_via_oracle_apis.sql`

---

## Step 4: Configure & Deploy the Oracle EBS MCP Server to Artifact Registry & Cloud Run

Configure your environment variables in `MCPServers/mcp-toolbox-ebs/.env`:

```bash
cd MCPServers/mcp-toolbox-ebs
cp .env.example .env
```

Edit `MCPServers/mcp-toolbox-ebs/.env` (or export the variables below) with your VPC, Subnet, Service Account, and Oracle EBS connection string:

```bash
export SERVICE_ACCOUNT_EMAIL="project-service-account@${PROJECT_ID}.iam.gserviceaccount.com"
export VPC_NAME="your-vpc-network"
export SUBNET_NAME="your-subnet"
export EBS_DB_CONNECTION_STRING="10.0.0.10:1521/EBSDB"
export EBS_DB_USER="apps_ai"
export EBS_DB_PASSWORD="your-apps-ai-password"
```

Run the automated deployment script to:
1. Create the `ebs-mcp-repo` Docker repository in your project's **Artifact Registry**
2. Build and push the pre-configured `mcp-toolbox-ebs` container image (`Dockerfile` + 21 parameterized `tools.yaml` tools)
3. Store your Oracle EBS credentials in **Secret Manager**
4. Deploy `mcp-toolbox-ebs` to **Cloud Run** with Direct VPC Egress

```bash
./deploy.sh
```

---

## Step 5: Connect Your Cloud Run MCP Endpoint to Gemini Enterprise

Once `./deploy.sh` finishes, it prints your **MCP Endpoint URL**:

```text
https://mcp-toolbox-ebs-<hash>-uc.a.run.app/mcp
```

1. **Register the BYO-MCP Endpoint in Gemini Enterprise:** Register the `/mcp` endpoint directly in your Gemini Enterprise / Vertex AI Agent Builder console.
2. **Invoke the 6 Gemini Enterprise Public Sector Skills:** In the Gemini Enterprise web app, open the **Skills** gallery or type `/` in chat (`/plain-language-notice-generator`, `/redaction-and-foia-compliance`, `/policy-and-statute-assistant`, `/document-intake-cleanup-and-validation`, `/rfp-vendor-evaluation-scorer`, `/expense-auditor`) to ground your workflows in live Oracle E-Business Suite R12.2 data.

Congratulations! Your Oracle EBS Gemini Enterprise MCP Server is now live.

