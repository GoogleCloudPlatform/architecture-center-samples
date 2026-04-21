# oracle-ebs-agents

This repository contains agents and MCP servers for interacting with Oracle EBS.

## Components

### [Agents](Agents/)
This directory contains the code to deploy the master orchestration agent and its specialist sub-agents to Google Cloud Platform (GCP) using the Agent Development Kit (ADK).
- **Purpose**: Deploys the main agent orchestration logic to GCP Agent Engine.
- **Key Features**:
    - Uses ADK to deploy.
    - Configurable via `agent_config.py` and JSON configuration.
    - Manages dependencies via Conda and pip.

#### Sub-Agents

The master agent (`EBS_Master`) routes user requests to the appropriate specialist sub-agent via `AgentTool` wrappers. Each sub-agent operates independently and returns structured JSON responses.

Which sub-agents are active is controlled by the `enabled_agents` list in `EBS_Master/agent_config.py`. Sub-agents not in that list are skipped at startup without raising an error.

| Sub-Agent | Path | Purpose |
|---|---|---|
| `EBS_SQL_Agent` | `EBS_Master/agents/EBS_SQL_Agent/` | Translates natural-language requests into SQL queries and executes them directly against the Oracle EBS (`APPS_EBS`) schema. Covers AP/AR/GL data, vendor details, invoice history, and custom queries. |
| `EBS_API_Agent` | `EBS_Master/agents/EBS_API_Agent/` | Interacts with Oracle EBS REST/SOAP web services. Handles authentication, session context, and API-layer operations such as invoice creation and supplier management. |
| `EBS_Graphs_Agent` | `EBS_Master/agents/EBS_Graphs_Agent/` | Accepts tabular data (JSON array or CSV) from other sub-agents and renders bar charts, line charts, pie charts, or formatted Markdown tables. |

## Deployment Steps
All Makefile commands should be run from the project root for all the deployments.

### 1. Setup the environment

```bash
# Install required tools
make setup

# Verify Google Cloud account and project
gcloud config list

# Verify Google Cloud access and IAM roles
make verify-gcp-access
```

---

### 2. Authenticate with Google Cloud and configure Application Default Credentials:

Terraform uses Application Default Credentials (ADC) to interact with Google Cloud. Run the following command before initializing Terraform:

```bash
gcloud auth application-default login
```

---
### Prerequisites
To use the Gemini - EBS framework, ensure you have a functioning EBS environment. The framework can be executed from `architecture-center-samples/oracle-ebs-framework`.

You will need the connection strings, VPC network name, and subnet name.

### 3. Deploy MCP Servers

Run the commands below to deploy MCP Servers.

```bash
# Initialize Terraform backend and modules
make init

# Set the EBS URL, credentials and network details
make set_config_mcp_servers

# Plan the changes
make plan_mcp_server

# Deploy the changes
make deploy_mcp_server
```
### 4. Deploy Agents

Run the commands to deploy the Agents

```bash
# Plan the changes
make plan_ebs_agents

# Deploy the changes
make deploy_ebs_agents
```

---

### [MCPOracleEBS](MCPServers/mcp-oracle-ebs/)
An MCP server designed to call Oracle EBS APIs.
- **Purpose**: Interface with Oracle EBS via API calls.
- **Key Features**:
    - Dockerized setup.
    - Deployment scripts for Google Cloud Run.
    - Specialized WADL/XSD handling for EBS services.
    - Uses Google Cloud IAM (OIDC Identity Tokens) for backend authentication between Agent Engine and the Cloud Run hosted MCP server.

### [MCPOracleSQL](MCPServers/mcp-oracle-sql/)
A Python MCP wrapper around Oracle SQLcl.
- **Purpose**: Execute SQL commands against Oracle databases via MCP.
- **Key Features**:
    - Python wrapper for SQLcl.
    - Deployment configuration for Google Cloud Run.
    - Uses Google Cloud IAM (OIDC Identity Tokens) for backend authentication between Agent Engine and the Cloud Run hosted MCP server.

## Development

### Linting and Formatting


The project uses [Ruff](https://docs.astral.sh/ruff/) for fast Python linting and formatting to ensure coding style consistency across all components.

To check for issues, first ensure `ruff` is installed in your active Python environment:

```bash
pip install ruff
```

Then, run the linter:

```bash
ruff check .
```

To automatically fix any style and formatting issues:

```bash
ruff check . --fix
```

### Testing
This is still work in progress

Automated testing is maintained via `pytest` for the local MCP Servers. Tests have been designed heavily around mocking external network/database connections to ensure tests are fast, secure, and isolated from production data.

For comprehensive instructions on running test suites after making code changes, refer to the [TEST.md](TEST.md) guide.

