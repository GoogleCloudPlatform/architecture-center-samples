# EBS Agent — GCP Deployment

Deploys the EBS orchestration agent and its sub-agents to GCP Agent Engine using the Google ADK CLI.

## Prerequisites

### Python environment

From the repository root, create and activate a Conda environment:

```bash
conda create -n EBS python=3.14 -y
conda activate EBS
pip install -r requirements.txt
pip install -r Agents/requirements.txt
```

### GCP authentication

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Environment file

Each agent directory requires a `.env` file. Copy the example and fill in your values:

```bash
cp EBS_Master/env.example EBS_Master/.env
# Edit EBS_Master/.env with your project ID, region, and MCP server URLs
```

Key variables:

| Variable | Description |
|---|---|
| `GOOGLE_CLOUD_PROJECT` | GCP project ID |
| `GOOGLE_CLOUD_LOCATION` | GCP region (e.g. `us-central1`) |
| `MCP_SERVER_EBS_URL` | Cloud Run URL of `mcp-oracle-ebs` |
| `MCP_SERVER_SQL_URL` | Cloud Run URL of `mcp-oracle-sql` |

> **Important:** The `.env` file must not contain `localhost` references — the script will reject it and exit.

## Deploying with `deploy_gcloud.sh`

`deploy_gcloud.sh` wraps the `adk deploy agent_engine` command with validation, logging, and shared-utility sync. Run it from the `Agents/` directory:

```bash
cd Agents/
./deploy_gcloud.sh AGENT_NAME [AGENT_ENGINE_ID]
```

**Arguments:**

| Argument | Required | Description |
|---|---|---|
| `AGENT_NAME` | Yes | Name of the agent to deploy (e.g. `EBS_Master`, or a sub-agent under `agents/`) |
| `AGENT_ENGINE_ID` | No | Existing Agent Engine resource ID to update. Omit to create a new instance. |

**What the script does:**

1. Validates that `gcloud` and `adk` CLIs are installed and that you are authenticated.
2. Checks the agent's `.env` file for `localhost` references (invalid for GCP) and exits with an error if found.
3. Creates a default `.env` if one does not exist, then exits so you can fill it in.
4. Copies `utils/logging_config.py` (canonical shared utility) into the agent directory so it is bundled in the deployment package.
5. Runs `adk deploy agent_engine` with OpenTelemetry and Cloud Trace enabled, streaming output to both the terminal and `logs/<AGENT_NAME>_deploy.log`.
6. Exits with a non-zero code and a clear error message if deployment fails.

**Examples:**

Deploy the master orchestrator (creates a new Agent Engine instance):

```bash
./deploy_gcloud.sh EBS_Master
```

Update an existing deployment (no new instance created):

```bash
./deploy_gcloud.sh EBS_Master 1234567890123456789
```

Deploy a standalone sub-agent:

```bash
./deploy_gcloud.sh agents/EBS_SQL_Agent
```

**After a successful deployment**, the Agent Engine resource name is printed and saved to the log:

```text
Agent Engine updated. Resource name: projects/PROJECT_NUMBER/locations/LOCATION/reasoningEngines/RESOURCE_ID
```

Note the `RESOURCE_ID` — pass it as the second argument on future deployments to update the same instance rather than creating a new one.

## Notes

- The `staging_bucket` is set from `GOOGLE_CLOUD_BUCKET_NAME` in `.env` and will be created by ADK if it does not exist.
- The service account must be specified in `agent_engine_config.json` (ADK does not accept it on the command line).
- Cloud Trace (`--trace_to_cloud`, `--otel_to_cloud`) is always enabled by the deploy script.
- Deployment logs are written to `logs/<AGENT_NAME>_deploy.log`.