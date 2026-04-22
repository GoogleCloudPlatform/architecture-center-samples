# EBS Master Agent

The EBS Master Agent is the top-level orchestrator for the Oracle EBS multi-agent system. It receives user requests, determines which specialist sub-agent should handle them, and returns the consolidated result. No EBS work is done directly by this agent — all execution is delegated.

## Architecture

```
User / Caller
      │
EBS Master Agent (orchestrator)
      ├── EBS_API_Agent      — REST/SOAP operations (invoices, vendors, users, …)
      ├── EBS_SQL_Agent      — Read-only SQL queries via SQLcl
      ├── EBS_Graphs_Agent   — Chart and table rendering (matplotlib)
      ├── MrGoogle           — Google-powered web research and summarisation
      ├── MrGoogleMaps       — Google Maps-based location visualisation
      ├── Gemini_User_Agent  — General EBS questions, user guidance
      └── EBS_Docs_Agent     — Document analysis (invoices, POs, …)
```

Sub-agents are loaded into the master agent as `AgentTool` instances. The `enabled_agents` constant in `agent_config.py` controls which sub-agents are active.

## Routing Logic

| User Intent | Sub-agent |
|---|---|
| Create, update, or void an invoice | EBS_API_Agent |
| Approve, cancel, or modify a purchase order | EBS_API_Agent |
| Query any EBS table or report | EBS_SQL_Agent |
| Render a chart or tabular report | EBS_Graphs_Agent → EBS_SQL_Agent data first |
| Plot sites, warehouses, vendors, or customers on a map | MrGoogleMaps → EBS_SQL_Agent data first |
| Current web research, release notes, external docs | MrGoogle |
| EBS concepts, navigation, general how-to | Gemini_User_Agent |
| Analyse an uploaded document | EBS_Docs_Agent |

The master agent checks conversation history for an existing EBS session before routing API calls. If a session has been established in a prior turn, that context is forwarded to the API sub-agent automatically.

## Built-in Tooling

| Tool | Purpose |
|---|---|
| `get_sub_agent_health()` | Checks whether any sub-agent failed to load at startup. Only used for diagnosing startup failures, not for routine health checks. |

## Configuration

### `enabled_agents`

Edit `agent_config.py` to enable or disable sub-agents:

```python
enabled_agents = [
    "EBS_API_Agent",
    "EBS_SQL_Agent",
    "EBS_Graphs_Agent",
    "MrGoogle",
    "MrGoogleMaps",
    "Gemini_User_Agent",
    "EBS_Docs_Agent",
]
```

Removing a name from the list prevents that agent from being loaded at startup.

### Environment Variables

| Variable | Description | Default |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | GCP project ID | required |
| `GOOGLE_CLOUD_PROJECT_NUMBER` | GCP project number | required |
| `GOOGLE_CLOUD_LOCATION` | GCP region | required |
| `GOOGLE_CLOUD_BUCKET_NAME` | Artifact Storage bucket | required |
| `MCP_SERVER_EBS_URL` | MCP Oracle EBS server URL | auto-derived from project number |
| `MCP_SERVER_SQL_URL` | MCP Oracle SQL server URL | auto-derived from project number |
| `DEBUG` | Enable verbose logging | `false` |

Copy `env.example` to `.env` and populate before running locally.

## Deployment

The master agent is deployed together with all sub-agents using the `deploy_gcloud.sh` script at the `Agents/` level. See [Agents/README.md](../../README.md) for full deployment instructions.

To deploy only the master agent directly:

```bash
cd Agents/EBS_Master
python deploy.py
```

This registers the agent on GCP Agent Engine. The returned resource ID (`projects/.../agents/...`) should be saved — it is needed to connect a front-end or test harness to the deployed agent.

## Local Development

```bash
cd Agents/EBS_Master
cp env.example .env
# edit .env

python agent.py          # start the ADK dev server
```

The ADK developer UI is available at `http://localhost:8000`.

## Key Files

| File | Purpose |
|---|---|
| `agent.py` | Agent definition, sub-agent loading, tool registration |
| `agent_config.py` | Instruction text, routing rules, enabled_agents list |
| `deploy.py` | GCP Agent Engine deployment script |
| `requirements.txt` | Python dependencies |
| `env.example` | Environment variable template |
| `logging_config.py` | Cloud Logging JSON formatter (structured logs) |
