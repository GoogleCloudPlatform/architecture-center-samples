# Deploy Oracle JD Edwards 9.2 Hybrid MCP Server & Discrete Manufacturing AI Agent to Google Cloud

Welcome to the interactive **Oracle JD Edwards EnterpriseOne (JDE) 9.2 Gemini Enterprise MCP Server & Discrete Manufacturing AI Agent** deployment walkthrough. This guide walks you through deploying the 18-tool Hybrid JDE Orchestrator v3 + Oracle 19c SQL MCP server (`mcp-jde-orchestrator`) to **Google Artifact Registry** and **Google Cloud Run**, and deploying the **`JDE_Master`** Discrete Manufacturing AI Agent to **Vertex AI Reasoning Engine**.

## Step 1: Select Your Google Cloud Project & Region

```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
gcloud config set project "$PROJECT_ID"
echo "Deploying into Project: $PROJECT_ID (Region: $REGION)"
```

## Step 2: Enable Required Google Cloud APIs

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

## Step 3: Install Oracle JD Edwards 9.2 Database Objects (`JDEScripts/`)

Connect to your Oracle 19c JDE database (`JDEORCL`) and run the consolidated installer in `JDEScripts/`:

```bash
cd JDEScripts
sqlplus sys/<SYS_PASSWORD>@<JDE_DB_HOST>:1521/jdeorcl as sysdba @install_all_mcp_db.sql
cd ..
```

## Step 4: Configure & Deploy the Hybrid JDE MCP Server (`mcp-jde-orchestrator`)

```bash
cd MCPServers/mcp-jde-orchestrator
cp .env.example .env
```

Update `.env` with your VPC, Subnet, Service Account, JDE AIS/Orchestrator URL (`:7077`), and Oracle JDE 19c Database DSN (`:1521/jdeorcl`), then run:

```bash
./deploy.sh
cd ../..
```

## Step 5: Deploy the `JDE_Master` Discrete Manufacturing AI Agent to Vertex AI Reasoning Engine

```bash
make deploy_jde_agents PROJECT_ID="$PROJECT_ID" REGION="$REGION"
```

Congratulations! Your Oracle JD Edwards 9.2 Hybrid MCP Server and Discrete Manufacturing AI Agent are now live and ready for Gemini Enterprise.
