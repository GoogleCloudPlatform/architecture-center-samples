# EBS Master Agent (`Agents/EBS_Master/`)

The **EBS Master Agent (`EBS_Master`)** is the top-level Vertex AI ADK orchestrator for the Oracle E-Business Suite (EBS) multi-agent system. It receives natural language prompts from Gemini Enterprise, resolves user identity, routes database queries and transactional operations to `EBS_SQL_Agent`, delegates executive chart generation to `EBS_Graphs_Agent`, and enforces compliance rubrics across both core ERP workflows and the 6 **Gemini for government services** Public Sector skills.

## 1. Multi-Agent Architecture

```text
Gemini Enterprise User / Caller
       │
EBS_Master (Root ADK Orchestrator — gemini-2.5-pro)
       ├── EBS_SQL_Agent      — Executes 21 MCP tools (8 Baseline ERP + 13 Public Sector & Multimodal OIE) using 8 Semantic Maps
       ├── EBS_Graphs_Agent   — Renders 180 DPI Executive Charts (Donut, Horizontal/Grouped/Stacked Bar, Line)
       └── MrGoogle           — Google Search grounding for external regulatory & market context
```

Sub-agents are loaded dynamically via `AgentTool` according to the `enabled_agents` list in `agent_config.py`.

## 2. Routing Logic & Supported Workflows

| Workflow / Skill Category | Target Sub-Agents | Underlying MCP Tools |
| :--- | :--- | :--- |
| **Session Initialization & RBAC Discovery** | `EBS_SQL_Agent` | `list_ebs_responsibilities`, `ebs_init`, `list_ebs_current_context` |
| **Core ERP Queries (AP, AR, GL, HR, INV, OM, PO)** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `execute_sql` (backed by 7 core ERP semantic maps) |
| **Transactional ERP Actions (Inventory, Payables & OIE Expenses)** | `EBS_SQL_Agent` | `create_onhand`, `reserve_item`, `delete_reserve_item`, `create_ap_invoice`, `ebs_create_expense_report` |
| **Skill 3.1: Plain Language Notice Generator** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_constituent_notice_details`, `ebs_get_document_attachment` + `render_bar_chart` |
| **Skill 3.2: Redaction & FOIA Compliance** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_search_foia_records`, `ebs_get_employee_personnel_file` + `render_pie_chart` |
| **Skill 3.3: Policy & Statute Assistant** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_agency_policy_rules`, `ebs_search_policy_attachments` + `render_bar_chart` |
| **Skill 3.4: Document Intake Cleanup & Validation** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_intake_attachments`, `ebs_verify_party_identity` + `render_line_chart` |
| **Skill 3.5: RFP Vendor Evaluation Scorer** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_sourcing_rfp_details`, `ebs_get_vendor_bids` + `render_bar_chart` |
| **Skill 3.6: Expense Auditor & Multimodal Expense Creation (2 CFR Part 200)** | `EBS_SQL_Agent` + `EBS_Graphs_Agent` | `ebs_get_expense_reports`, `ebs_get_po_invoice_match`, `ebs_create_expense_report` + `render_pie_chart` |

## 3. Upgraded Executive Charting Engine (`sub-agents/EBS_Graphs_Agent/`)

`EBS_Graphs_Agent` renders publication-grade **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG business visualizations saved directly as ADK session artifacts (`inline_data` `image/png`) so they render inline inside the Gemini Enterprise web UI:
* **`render_bar_chart`**: Supports horizontal (`horizontal=True`), vertical, grouped, and stacked bar charts with automatic USD currency formatting, share-of-total (`%`) callouts, KPI summary badges, and optional dashed reference lines (`reference_value`, `reference_label`).
* **`render_pie_chart`**: Renders an executive donut chart (`width=0.44`) with a bold center KPI total callout and a right-hand breakdown legend showing exact dollar/numeric amounts and percentage shares.
* **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, Min/Max/Latest milestone badges, and optional statutory threshold rules.

## 4. Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID | required |
| `GOOGLE_CLOUD_LOCATION` | Vertex AI region | `us-central1` |
| `GOOGLE_CLOUD_BUCKET_NAME` | Staging GCS bucket for Agent Engine deployment | required |
| `MCP_SERVER_SQL_URL` | Cloud Run MCP Toolbox `/mcp` endpoint URL | `http://localhost:8082/mcp/` |
| `DEFAULT_EBS_USER_EMAIL` | Fallback Oracle EBS `FND_USER` email when running outside OAuth2 UI | `operations@example.com` |
| `DEBUG` | Enable verbose debug logging | `false` |
