# PSFT Master Agent (`Agents/PSFT_Master/`)

The **PSFT Master Agent (`PSFT_Master`)** is the top-level Agent Development Kit (ADK) orchestrator for the Oracle PeopleSoft FSCM 9.2 (`EP92U055`) multi-agent system. It receives natural language prompts from Gemini Enterprise, resolves user identity, routes database queries and transactional operations to `PSFT_SQL_Agent`, and delegates high-resolution chart generation to `PSFT_Graphs_Agent`.

## 1. Multi-Agent Architecture

```text
Gemini Enterprise User / Caller
       │
PSFT_Master (Root ADK Orchestrator — gemini-2.5-flash)
       ├── PSFT_SQL_Agent      — Executes 20 Oracle PeopleSoft MCP tools using Domain Semantic Maps
       ├── PSFT_Graphs_Agent   — Renders 180 DPI Charts (Donut, Bar, Line, Table)
       └── MrGoogle            — Google Search grounding for external regulatory & market context
```

Sub-agents are loaded dynamically via `AgentTool` according to the `enabled_agents` list in `agent_config.py`.

## 2. Routing Logic & Supported Workflows

| Workflow Category | Target Sub-Agents | Underlying MCP Tools |
| :--- | :--- | :--- |
| **Session Initialization & RBAC Discovery** | `PSFT_SQL_Agent` | `list_ps_roles`, `ps_init`, `list_ps_current_context` |
| **Core ERP Queries (AP, AR, GL, HR, INV, OM, PO)** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `execute_sql` (backed by domain semantic maps) |
| **Transactional ERP Actions (Inventory & Payables Voucher Build)** | `PSFT_SQL_Agent` | `create_onhand`, `reserve_item`, `delete_reserve_item`, `create_ap_voucher` |
| **Customer Notices & Document Attachments** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_case_determination`, `ps_get_attachment_content` + `render_bar_chart` |
| **Procurement Contracts & Workforce Records** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_search_foia_records`, `ps_get_employee_record_documents` + `render_pie_chart` |
| **Purchasing Approval Rules & Policy Attachments** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_policy_catalog_rules`, `ps_search_policy_documents` + `render_bar_chart` |
| **Customer Identity Verification & Intake Documents** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_constituent_documents`, `ps_verify_constituent_data` + `render_line_chart` |
| **Strategic Sourcing RFPs & Vendor Bids** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_strategic_sourcing_event`, `ps_get_vendor_responses` + `render_bar_chart` |
| **Travel & Expenses & PO/Voucher/Grant Matching** | `PSFT_SQL_Agent` + `PSFT_Graphs_Agent` | `ps_get_expense_sheets`, `ps_get_voucher_details` + `render_pie_chart` |

## 3. Upgraded Charting Engine (`sub_agents/PSFT_Graphs_Agent/`)

`PSFT_Graphs_Agent` renders publication-grade **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG business visualizations saved directly as ADK session artifacts (`inline_data` `image/png`) so they render inline inside the Gemini Enterprise web UI:
* **`render_bar_chart`**: Renders business bar charts with automatic USD currency formatting, share-of-total (`%`) callouts, KPI summary badges, and structured legends.
* **`render_pie_chart`**: Renders an executive donut chart with a bold center KPI total callout and a right-hand breakdown legend showing exact dollar/numeric amounts and percentage shares.
* **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, node value callouts, and structured peak summaries.

## 4. Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID | required |
| `GOOGLE_CLOUD_LOCATION` | Google Cloud region | `us-central1` |
| `GOOGLE_CLOUD_BUCKET_NAME` | Staging GCS bucket for Agent Engine deployment | required |
| `MCP_SERVER_SQL_URL` | Cloud Run MCP Toolbox `/mcp` endpoint URL | required |
| `ENV` | Deployment environment (`development` or `production`) | `development` |
| `DEFAULT_PSFT_USER_EMAIL` | Fallback Oracle PeopleSoft `PSOPRDEFN` email for non-production (`ENV != 'production'`) CLI testing | optional |
| `DEBUG` | Enable verbose debug logging | `false` |
