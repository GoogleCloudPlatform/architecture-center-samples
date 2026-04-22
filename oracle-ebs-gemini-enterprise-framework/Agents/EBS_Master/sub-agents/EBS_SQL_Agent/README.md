# EBS SQL Agent

The EBS SQL Agent is a read-only specialist sub-agent for querying Oracle E-Business Suite using SQL. It connects to the database via the **MCP Oracle SQL** server (`mcp-oracle-sql`), which manages a SQLcl subprocess. All queries are executed as the APPS schema user and results are returned as structured data for the caller or for the EBS_Graphs_Agent to render.

## Responsibilities

- Answer data questions about EBS financial and procurement records
- Execute ad-hoc SQL queries against the APPS schema
- Use semantic maps to identify the correct tables and columns for a given domain
- Feed raw result data to EBS_Graphs_Agent for visualisation

## MCP Tool Workflow

```
connect(connection_name="APPS_EBS")
        │
        └──▶  run-sql("SELECT …")
                    │
                    ├──▶  run-sql("SELECT …")   ← additional queries in the same session
                    │
                    └──▶  (session ends automatically when sub-agent turn completes)
```

The `connect` tool must be called once per session before any `run-sql` calls. After a successful connection, multiple `run-sql` calls can be made without reconnecting.

### Tool Reference

| Tool | Description |
|---|---|
| `connect` | Opens a SQLcl connection to a named database connection (e.g., `APPS_EBS`). |
| `run-sql` | Executes a SQL statement against the current connection. Returns rows as JSON. |

Connection parameters for `connect`:

| Parameter | Description |
|---|---|
| `connection_name` | Name of the pre-configured SQLcl connection (always `APPS_EBS` for EBS queries). |

## Oracle SQL Rules

The following rules are enforced on all generated SQL:

| Rule | Correct | Incorrect |
|---|---|---|
| Row limiting | `FETCH FIRST 100 ROWS ONLY` or `WHERE ROWNUM <= 100` | `LIMIT 100` (not valid in Oracle) |
| Default row limit | Always apply a 100-row ceiling unless the user explicitly asks for more | Unbounded queries |
| Multi-org tables | Add `AND org_id = :org_id` to all `_ALL` tables (`AP_INVOICES_ALL`, `AP_SUPPLIERS`, …) | Querying `_ALL` tables without an org filter |
| Case-insensitive search | `WHERE UPPER(vendor_name) = UPPER('Acme')` | `WHERE vendor_name = 'acme'` |
| Date literals | `TO_DATE('2024-01-31', 'YYYY-MM-DD')` | `'2024-01-31'` uncast |
| Aliases | Always alias columns for clarity | Anonymous expressions |

## Semantic Maps

Semantic maps are JSON files that describe the EBS data model for a specific module. The agent uses them to select the correct tables and columns when translating a user question into SQL.

| Map file | Module | Key tables covered |
|---|---|---|
| `ap_semantic_map.json` | Accounts Payable | `AP_INVOICES_ALL`, `AP_INVOICE_LINES_ALL`, `AP_SUPPLIERS`, `AP_SUPPLIER_SITES_ALL`, `AP_CHECKS_ALL` |
| `ar_semantic_map.json` | Accounts Receivable | `AR_CUSTOMERS`, `RA_CUSTOMER_TRX_ALL`, `AR_PAYMENT_SCHEDULES_ALL` |
| `gl_semantic_map.json` | General Ledger | `GL_JE_HEADERS`, `GL_JE_LINES`, `GL_CODE_COMBINATIONS`, `GL_PERIODS` |
| `security_semantic_map.json` | Security & Users | `FND_USER`, `FND_RESPONSIBILITY`, `FND_USER_RESP_GROUPS_ALL` |

The semantic map for the relevant module is loaded automatically based on the topic of the user's question.

## Error and Retry Behaviour

| Situation | Action |
|---|---|
| `connect` fails (wrong credentials, network) | Return an error immediately — do not retry repeatedly |
| `run-sql` returns an ORA- error | Fix the SQL and retry once; if still failing, report the error |
| Query returns 0 rows | Report "no records found" — do not retry with a looser query unless the user asks |
| Query times out | Simplify the query (fewer joins, tighter date range) and retry once |

## Output Format

Results are returned as a JSON array of row objects. Column names are the SQL aliases used in the query. The calling agent (or EBS_Graphs_Agent) is responsible for presenting the data.

Example:

```json
[
  { "invoice_num": "INV-2024-001", "vendor_name": "Acme Corp", "invoice_amount": 1500.00 },
  { "invoice_num": "INV-2024-002", "vendor_name": "Beta Ltd",  "invoice_amount": 3200.00 }
]
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | GCP project ID | required |
| `GOOGLE_CLOUD_PROJECT_NUMBER` | GCP project number | required |
| `GOOGLE_CLOUD_LOCATION` | GCP region | required |
| `GOOGLE_CLOUD_BUCKET_NAME` | Artifact storage bucket | required |
| `MCP_SERVER_SQL_URL` | MCP Oracle SQL server endpoint | `https://mcp-oracle-sql-{PROJECT_NUMBER}.{LOCATION}.run.app/mcp` |
| `DEBUG` | Enable verbose logging | `false` |

Copy `env.example` to `.env` and populate before running locally.

## Deployment

```bash
cd Agents/EBS_Master/agents/EBS_SQL_Agent
python deploy.py
```

In production this agent is loaded as a sub-agent by EBS_Master. Independent deployment is only needed for isolated testing.

## Key Files

| File | Purpose |
|---|---|
| `agent.py` | Agent definition and MCP toolset configuration |
| `agent_config.py` | Instruction text, SQL rules, semantic map guidance |
| `instructions.md` | Short supplemental instructions (connection name override) |
| `descriptions.md` | Agent description used by the master agent for routing |
| `semantic_maps/` | JSON domain maps: ap, ar, gl, security |
| `deploy.py` | GCP Agent Engine deployment script |
| `requirements.txt` | Python dependencies |
| `env.example` | Environment variable template |
