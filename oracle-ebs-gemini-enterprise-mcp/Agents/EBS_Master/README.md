# EBS Master Agent (`Agents/EBS_Master/`)

The **EBS Master Agent (`EBS_Master`)** is the top-level Agent Development Kit (ADK) orchestrator for the Oracle E-Business Suite (EBS) multi-agent system. It receives natural language prompts from Gemini Enterprise, resolves user identity, routes database queries and transactional operations to `EBS_SQL_Agent`, and delegates high-resolution chart generation to `EBS_Graphs_Agent`.

## 1. Multi-Agent Architecture

```text
Gemini Enterprise User / Caller
       │
EBS_Master (Root ADK Orchestrator — gemini-2.5-pro)
       ├── EBS_SQL_Agent      — Executes 21 Oracle EBS MCP tools using Domain Semantic Maps
       ├── EBS_Graphs_Agent   — Renders 180 DPI Charts (Donut, Horizontal/Grouped/Stacked Bar, Line)
       └── MrGoogle           — Google Search grounding for external regulatory & market context
```

Sub-agents are loaded dynamically via `AgentTool` according to the `enabled_agents` list in `agent_config.py`.

## 2. Routing Logic & Supported Workflows

| Workflow Category | Target Sub-Agents | Underlying MCP Tools |
| :--- | :--- | :--- |
| **Session Initialization & RBAC Discovery** | `EBS_SQL_Agent` | `list_ebs_responsibilities`, `ebs_init`, `list_ebs_current_context` |
| **Core ERP Queries (AP, AR, GL, HR, INV, OM, PO)** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `execute_sql` (backed by domain semantic maps) |
| **Transactional ERP Actions (Inventory, Payables & OIE Expenses)** | `EBS_SQL_Agent` | `create_onhand`, `reserve_item`, `delete_reserve_item`, `create_ap_invoice`, `ebs_create_expense_report` |
| **Receivables Notices & FND Attachments** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_constituent_notice_details`, `ebs_get_document_attachment` + `render_bar_chart` |
| **Procurement Contracts & HRMS Personnel Records** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_search_foia_records`, `ebs_get_employee_personnel_file` + `render_pie_chart` |
| **Purchasing Approval Rules & Policy Attachments** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_agency_policy_rules`, `ebs_search_policy_attachments` + `render_bar_chart` |
| **TCA Party Verification & Intake Documents** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_intake_attachments`, `ebs_verify_party_identity` + `render_line_chart` |
| **Oracle Sourcing RFPs & Vendor Bids** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_sourcing_rfp_details`, `ebs_get_vendor_bids` + `render_bar_chart` |
| **Oracle Internet Expenses & PO/Invoice/Grant Matching** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_expense_reports`, `ebs_get_po_invoice_match`, `ebs_create_expense_report` + `render_pie_chart` |

## 3. Upgraded Charting Engine (`sub-agents/EBS_Graphs_Agent/`)

`EBS_Graphs_Agent` renders publication-grade **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG business visualizations saved directly as ADK session artifacts (`inline_data` `image/png`) so they render inline inside the Gemini Enterprise web UI:
* **`render_bar_chart`**: Supports horizontal (`horizontal=True`), vertical, grouped, and stacked bar charts with automatic USD currency formatting, share-of-total (`%`) callouts, KPI summary badges, and optional dashed reference lines (`reference_value`, `reference_label`).
* **`render_pie_chart`**: Renders an executive donut chart (`width=0.44`) with a bold center KPI total callout and a right-hand breakdown legend showing exact dollar/numeric amounts and percentage shares.
* **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, Min/Max/Latest milestone badges, and optional threshold rules.

## 4. Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID | required |
| `GOOGLE_CLOUD_LOCATION` | Google Cloud region | `us-central1` |
| `GOOGLE_CLOUD_BUCKET_NAME` | Staging GCS bucket for Agent Engine deployment | required |
| `MCP_SERVER_SQL_URL` | Cloud Run MCP Toolbox `/mcp` endpoint URL | `http://localhost:8082/mcp/` |
| `DEFAULT_EBS_USER_EMAIL` | Fallback Oracle EBS `FND_USER` email when running outside OAuth2 UI | `operations@example.com` |
| `DEBUG` | Enable verbose debug logging | `false` |
