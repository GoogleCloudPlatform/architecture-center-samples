# Oracle EBS Database Scripts, PL/SQL Wrapper & Public Sector Views (`EBSScripts/`)

This directory contains the SQL and PL/SQL scripts required to configure the Oracle E-Business Suite (EBS 12.2.x) database tier for the Gemini Enterprise MCP Server (`mcp-toolbox-ebs`).

## 1. Script Inventory

| Script File | Schema | Purpose |
| :--- | :--- | :--- |
| **`create_apps_ai.sql`** | `SYSDBA` / `SYSTEM` | Creates the dedicated least-privilege `APPS_AI` database user and logon trigger (`ALTER SESSION SET CURRENT_SCHEMA = APPS`). |
| **`GrantToApps_AI.sql`** | `APPS` | Option A (Analytical Sandbox): Grants broad read access and execute privileges on `APPS.GE_EBS_MCP_TOOLS` to `APPS_AI`. |
| **`GrantToApps_AIRESTRICTED.sql`** | `APPS` | Option B (Production Least-Privilege): Grants explicit `SELECT` privileges on ~3,000 curated Oracle EBS tables and views to `APPS_AI`. |
| **`ge_ebs_mcp_tools.pls`** | `APPS` | Package specification for `APPS.GE_EBS_MCP_TOOLS` (session context initialization, inventory receipts/reservations, supplier and AP invoice creation, and OIE expense report creation via `create_expense_report`). |
| **`ge_ebs_mcp_tools.plb`** | `APPS` | Package body for `APPS.GE_EBS_MCP_TOOLS` implementing `FND_GLOBAL.APPS_INITIALIZE`, `MO_GLOBAL.INIT`, `MO_GLOBAL.SET_POLICY_CONTEXT`, and public API wrappers (`INV_TXN_MANAGER_PUB`, `INV_RESERVATION_PUB`, `AP_INVOICES_INTERFACE`, and the 7 Oracle Internet Expenses PL/SQL packages for `create_expense_report`). |
| **`sql_logs.sql`** | `APPS` | Creates the `APPS.GGLTOOLBOX$MCP_LOG` table and `APPS.MCP_TOOLBOX_LOG` autonomous transaction logging procedure. |
| **`install_all_mcp_db.sql`** | `APPS` | Consolidated one-step installer that creates `APPS.GGLTOOLBOX$MCP_LOG`, `APPS.MCP_TOOLBOX_LOG`, and compiles `ge_ebs_mcp_tools.pls` and `ge_ebs_mcp_tools.plb`. |
| **`install_gov_public_sector_views.sql`** | `APPS` | **100% Oracle Support-Compliant Read-Only Views**: Creates the **7 read-only Public Sector views (`APPS.VW_GOV_*`)** with zero direct base-table DML (`INSERT`/`UPDATE`/`DELETE`). |
| **`create_v2_reports_via_oracle_apis.sql`** | `APPS` | **Official Oracle PL/SQL API & Open Interface Loader**: Creates synthetic `-V2` Expense Reports (`EXP-ATL-9921-V2`, `EXP-DEN-5521-V2`, `EXP-CHI-8812-V2`) and Grant AP Invoices (`HM-4409-V2`, `V-2026-301-V2`, `MS-1049-V2`) strictly via official Oracle Internet Expenses PL/SQL APIs (`AP_WEB_DB_EXPRPT_PKG`, `AP_EXPENSE_REPORT_HEADERS_PKG`, `AP_WEB_DB_EXPLINE_PKG`), Oracle AOL Attachment APIs (`FND_WEBATTCH.ADD_ATTACHMENT`), and the Payables Open Interface (`AP_INVOICES_INTERFACE` + `APXIIMPT`). |

## 2. Quick-Start Installation

### Step 1: Install Core PL/SQL Package and Audit Logging Table
Connect to the Oracle EBS database (`EBSDB`) as `APPS` and run `install_all_mcp_db.sql`:

```bash
sqlplus apps/<apps_password>@<ebs_db_host>:1521/EBSDB @install_all_mcp_db.sql
```

### Step 2: Install Read-Only Public Sector Views (100% Oracle Support-Compliant)
To create the 7 read-only `APPS.VW_GOV_*` views consumed by the 12 Public Sector MCP tools (pure `CREATE OR REPLACE VIEW` DDL with zero base-table DML):

```bash
sqlplus apps/<apps_password>@<ebs_db_host>:1521/EBSDB @install_gov_public_sector_views.sql
```

### Step 3 (Optional — Demo / Sandbox Environments): Load Synthetic `-V2` Expense Reports & Grant Invoices via Official Oracle APIs
To populate synthetic evaluation Expense Reports (`EXP-ATL-9921-V2`, `EXP-DEN-5521-V2`, `EXP-CHI-8812-V2`) and Grant Invoices (`HM-4409-V2`, `V-2026-301-V2`, `MS-1049-V2`) strictly using Oracle-approved PL/SQL packages and Open Interfaces:

```bash
sqlplus apps/<apps_password>@<ebs_db_host>:1521/EBSDB @create_v2_reports_via_oracle_apis.sql
```

This creates the 7 read-only views consumed by the MCP server:
1. `APPS.VW_GOV_CONSTITUENT_NOTICES` (Skill 3.1 — Plain Language Notice Generator)
2. `APPS.VW_GOV_FOIA_RECORDS` (Skill 3.2 — Redaction & FOIA Compliance)
3. `APPS.VW_GOV_AGENCY_POLICY_RULES` (Skill 3.3 — Policy & Statute Assistant)
4. `APPS.VW_GOV_INTAKE_DOCUMENTS` (Skill 3.4 — Document Intake Cleanup & Validation)
5. `APPS.VW_GOV_SOURCING_RFPS` (Skill 3.5 — RFP Vendor Evaluation Scorer)
6. `APPS.VW_GOV_EXPENSE_REPORTS` (Skill 3.6 — Expense Auditor: Travel & Per Diem)
7. `APPS.VW_GOV_PO_INVOICE_MATCH` (Skill 3.6 — Expense Auditor: PO, Invoice & Grant Matching)
