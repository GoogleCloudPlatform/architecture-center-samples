# PSFT Master Agent (`Agents/PSFT_Master/`)

The **PSFT Master Agent (`PSFT_Master`)** is the top-level Vertex AI ADK orchestrator for the Oracle PeopleSoft FSCM 9.2 (`EP92U055`) multi-agent system. It receives natural language prompts from Gemini Enterprise, resolves user identity, routes database queries and transactional operations to `PSFT_SQL_Agent`, delegates executive chart generation to `PSFT_Graphs_Agent`, and enforces compliance rubrics across both core ERP workflows and the 6 **Gemini for Government** Public Sector skills.

## 1. Multi-Agent Architecture

```text
Gemini Enterprise User / Caller
       │
PSFT_Master (Root ADK Orchestrator — gemini-2.5-flash)
       ├── PSFT_SQL_Agent      — Executes 20 MCP tools (8 Baseline ERP + 12 Public Sector) using 8 Semantic Maps
       ├── PSFT_Graphs_Agent   — Renders 180 DPI Executive Charts (Donut, Bar, Line, Table)
       └── MrGoogle            — Google Search grounding for external regulatory & market context
```

Sub-agents are loaded dynamically via `AgentTool` according to the `enabled_agents` list in `agent_config.py`.

## 2. Routing Logic & Supported Workflows

| Workflow / Skill Category | Target Sub-Agents | Underlying MCP Tools |
| :--- | :--- | :--- |
| **Session Initialization & RBAC Discovery** | `PSFT_SQL_Agent` | `list_psft_roles`, `psft_init`, `list_psft_current_context` |
| **Core ERP Queries (AP, AR, GL, HR, INV, OM, PO)** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `execute_sql` (backed by 8 semantic maps) |
| **Transactional ERP Actions (Inventory & Payables)** | `PSFT_SQL_Agent` | `create_putaway`, `reserve_inventory_item`, `delete_inventory_reservation`, `create_ap_voucher` |
| **Skill 3.1: Plain Language Notice Generator** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_case_determination`, `ps_get_attachment_content` + `render_bar_chart` |
| **Skill 3.2: Redaction & FOIA Compliance** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_search_foia_records`, `ps_get_employee_record_documents` + `render_pie_chart` |
| **Skill 3.3: Policy & Statute Assistant** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_policy_catalog_rules`, `ps_search_policy_documents` + `render_bar_chart` |
| **Skill 3.4: Document Intake Cleanup & Validation** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_constituent_documents`, `ps_verify_constituent_data` + `render_line_chart` |
| **Skill 3.5: RFP Vendor Evaluation Scorer** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_strategic_sourcing_event`, `ps_get_vendor_responses` + `render_bar_chart` |
| **Skill 3.6: Expense Auditor (2 CFR Part 200)** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_expense_sheets`, `ps_get_voucher_details` + `render_pie_chart` |

## 3. Upgraded Executive Charting Engine (`sub_agents/PSFT_Graphs_Agent/`)

`PSFT_Graphs_Agent` renders publication-grade **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG business visualizations saved directly as ADK session artifacts (`inline_data` `image/png`) so they render inline inside the Gemini Enterprise web UI:
* **`render_bar_chart`**: Renders executive business bar charts with automatic USD currency formatting, share-of-total (`%`) callouts, KPI summary badges, and structured legends.
* **`render_pie_chart`**: Renders an executive donut chart with a bold center KPI total callout and a right-hand breakdown legend showing exact dollar/numeric amounts and percentage shares.
* **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, node value callouts, and structured peak summaries.

## 4. Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID | required |
| `GOOGLE_CLOUD_LOCATION` | Vertex AI region | `us-central1` |
| `GOOGLE_CLOUD_BUCKET_NAME` | Staging GCS bucket for Agent Engine deployment | required |
| `MCP_SERVER_SQL_URL` | Cloud Run MCP Toolbox `/mcp` endpoint URL | required |
| `DEFAULT_PSFT_USER_EMAIL` | Fallback Oracle PeopleSoft `PSOPRDEFN` email when running outside OAuth2 UI | optional |
| `DEBUG` | Enable verbose debug logging | `false` |
