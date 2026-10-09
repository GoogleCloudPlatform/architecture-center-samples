# Oracle PeopleSoft FSCM 9.2 Database Scripts, PL/SQL Wrapper & Public Sector Views (`PSFTScripts/`)

This directory contains the SQL and PL/SQL scripts required to configure the Oracle PeopleSoft Financials and Supply Chain Management (FSCM) 9.2 (PeopleTools 8.62, PDB `EP92U055`) database tier for the Gemini Enterprise MCP Server (`mcp-toolbox-peoplesoft`).

## 1. Script Inventory

| Script File | Schema | Purpose |
| :--- | :--- | :--- |
| **`create_psft_ai.sql`** | `SYSDBA` / `SYSTEM` | Creates the dedicated least-privilege `PSFT_AI` database user, role (`PSFT_AI_ROLE`), and logon trigger (`SYSADM.PSFT_AI_AFTER_LOGON_TRG` setting `CURRENT_SCHEMA = SYSADM`). |
| **`GrantToPsft_AI.sql`** | `SYSADM` | Option A (Analytical Sandbox): Grants read access and execute privileges on `SYSADM.GE_PSFT_MCP_TOOLS` to `PSFT_AI`. |
| **`GrantToPsft_AIRESTRICTED.sql`** | `SYSADM` | Option B (Production Least-Privilege): Grants explicit `SELECT` privileges on curated Oracle PeopleSoft FSCM 9.2 tables and views to `PSFT_AI_ROLE`. |
| **`ge_psft_mcp_tools.sql`** | `SYSADM` | Compiles the `SYSADM.GE_PSFT_MCP_TOOLS` PL/SQL wrapper package (`ps_initialize_context`, `create_onhand`, `reserve_item`, `delete_reservation`, `create_ap_voucher`) and autonomous audit procedure `SYSADM.MCP_TOOLBOX_LOG`. |
| **`sql_logs.sql`** | `SYSADM` | Creates the `SYSADM.GGLTOOLBOX$MCP_LOG` autonomous audit table and `SYSADM.MCP_TOOLBOX_LOG` logging procedure. |
| **`install_all_mcp_db.sql`** | `SYSADM` | Consolidated one-step installer that creates `SYSADM.GGLTOOLBOX$MCP_LOG`, `SYSADM.MCP_TOOLBOX_LOG`, and compiles `ge_psft_mcp_tools.sql`. |
| **`install_gov_psft_mcp_and_seed.sql`** | `SYSADM` | Creates the PeopleSoft Public Sector staging tables (`SYSADM.PS_GOV_*`) and seeds synthetic evaluation scenarios (`IDs 990001–990999` and `-V2` records) across delivered PeopleSoft FSCM 9.2 tables (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_VOUCHER`, `PS_PO_HDR`, `PS_AUC_HDR`, `PS_GM_AWARD`, `PS_CUSTOMER`) with zero mutation of PUM baseline demo records. |
| **`install_gov_public_sector_views.sql`** | `SYSADM` | **100% Oracle Support-Compliant Read-Only Views**: Creates the **7 read-only Public Sector views (`SYSADM.VW_GOV_*`)** with zero direct base-table DML (`INSERT`/`UPDATE`/`DELETE`). |

## 2. Quick-Start Installation

### Step 1: Create Least-Privilege `PSFT_AI` User & Logon Trigger
Connect to the Oracle PeopleSoft database (`EP92U055`) as `SYSDBA` and run `create_psft_ai.sql`:

```bash
sqlplus sys/<sys_password>@<psft_db_host>:1521/EP92U055 as sysdba @create_psft_ai.sql
```

### Step 2: Install Core PL/SQL Package and Audit Logging Table
Connect as `SYSADM` and run `install_all_mcp_db.sql`:

```bash
sqlplus SYSADM/<sysadm_password>@<psft_db_host>:1521/EP92U055 @install_all_mcp_db.sql
```

### Step 3: Install Read-Only Public Sector Views & Synthetic Evaluation Dataset
To create the 7 read-only `SYSADM.VW_GOV_*` views consumed by the 12 Public Sector MCP tools:

```bash
sqlplus SYSADM/<sysadm_password>@<psft_db_host>:1521/EP92U055 @install_gov_psft_mcp_and_seed.sql
sqlplus SYSADM/<sysadm_password>@<psft_db_host>:1521/EP92U055 @install_gov_public_sector_views.sql
```

This creates the 7 read-only views consumed by the MCP server:
1. `SYSADM.VW_GOV_CONSTITUENT_NOTICES` (Skill 3.1 — Plain Language Notice Generator)
2. `SYSADM.VW_GOV_FOIA_RECORDS` (Skill 3.2 — Redaction & FOIA Compliance)
3. `SYSADM.VW_GOV_AGENCY_POLICY_RULES` (Skill 3.3 — Policy & Statute Assistant)
4. `SYSADM.VW_GOV_INTAKE_DOCUMENTS` (Skill 3.4 — Document Intake Cleanup & Validation)
5. `SYSADM.VW_GOV_SOURCING_RFPS` (Skill 3.5 — RFP Vendor Evaluation Scorer)
6. `SYSADM.VW_GOV_EXPENSE_REPORTS` (Skill 3.6 — Expense Auditor: Travel & Per Diem)
7. `SYSADM.VW_GOV_PO_INVOICE_MATCH` (Skill 3.6 — Expense Auditor: PO, Voucher & Grant Matching)
