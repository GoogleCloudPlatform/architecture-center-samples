# Oracle JD Edwards EnterpriseOne (JDE) 9.2 Database Scripts, Views & Orchestrator Server (`JDEScripts/`)

This directory contains the SQL/PLSQL installation scripts and JDE AIS v2 / Orchestrator v3 service required to configure the **Oracle JD Edwards EnterpriseOne 9.2 Discrete Manufacturing** tier (`JPD920` / `PRODDTA`, Branch/Plant `M30`, PDB `JDEORCL`) for the **Gemini Enterprise Hybrid JDE MCP Server (`mcp-jde-orchestrator`)** and **Discrete Manufacturing AI Agent (`JDE_Master`)**.

## 1. Script & Component Inventory

| File | Target Schema / Host | Purpose |
| :--- | :--- | :--- |
| **`install_all_mcp_db.sql`** | `SYSDBA` / `PRODDTA` | Consolidated one-step installer executing all 4 JDE 9.2 Discrete Manufacturing SQL scripts in sequence. |
| **`install_jde_920_discrete_mfg_schema.sql`** | `PRODDTA` / `PRODCTL` | Provisions `PRODDTA`, `PRODCTL`, `SY920`, `SVM920`, and least-privilege `JDE_AI` schemas; creates JDE Julian date converters (`PRODDTA.JDE_TO_DATE`, `PRODDTA.DATE_TO_JDE`); and seeds Branch/Plant `M30` (`Central Discrete Mfg Plant`) across `F0005`, `F0006`, `F0002`, `F4101`, `F4102`, `F41021`, `F4105`, `F4111`, `F3002`, `F3003`, `F4801`, `F3111`, `F3112`, `F3102`, and `F4311`. |
| **`install_jde_identity_and_context.sql`** | `PRODDTA` / `SY920` / `PRODCTL` | Creates Email-to-JDE Identity tables (`PRODDTA.F0101`, `PRODDTA.F01151`, `SY920.F0092`, `SY920.F95921`), Application Security Workbench (`PRODCTL.F00950` for `P48013`, `P4095`, `P980051`, `P31113`, `P311221`, `P31114`, `P4310`), session table `PRODDTA.JDE_MCP_SESSION_CTX`, and PL/SQL package `PRODDTA.GE_JDE_MCP_TOOLS` (`jde_initialize_context`, `get_active_jde_user`, `get_active_an8` + `DBMS_SESSION.SET_IDENTIFIER`). |
| **`install_jde_mfg_views_and_audit.sql`** | `PRODDTA` | Creates the autonomous audit table `PRODDTA.GGLTOOLBOX$MCP_LOG` (`PRAGMA AUTONOMOUS_TRANSACTION`) and 4 normalized read-only analytical views (`VW_JDE_MFG_WORK_ORDERS`, `VW_JDE_MFG_PARTS_SHORTAGES`, `VW_JDE_MFG_ROUTING_LOAD`, `VW_JDE_MFG_COST_VARIANCES`) with automatic CYYDDD-to-ISO date and implied decimal conversion. |
| **`install_jde_watchlist_dmaai_precedent.sql`** | `SY920` / `PRODDTA` | Creates JDE One View Watchlists (`SY920.F980051`: `WL-MFG-01`..`WL-MFG-04`), Account Master (`PRODDTA.F0901`), Distribution/Manufacturing Automatic Accounting Instructions (`PRODDTA.F4095` with `< $5,000` auto-execute and `>= $5,000` A2UI human approval policy gates), Operational Precedent Ledger (`PRODDTA.F48019`), and 3 read-only views (`VW_JDE_WATCHLIST_ALERTS`, `VW_JDE_DMAAI_EXCEPTIONS`, `VW_JDE_OPERATIONAL_PRECEDENTS`). |
| **`jde_ais_orchestrator_server.py`** | JDE Web/AIS Tier (`:7077`) | Reference JDE AIS v2 (`/jderest/v2/*`) and Orchestrator Studio v3 (`/jderest/v3/orchestrator/*`) endpoint enforcing `SY920.F0092` identity resolution and `PRODCTL.F00950` security across all 7 Discrete Manufacturing orchestrations. |

## 2. Quick-Start Database Installation

Connect to your Oracle 19c JDE database (`JDEORCL`) and run `install_all_mcp_db.sql`:

```bash
cd JDEScripts
sqlplus sys/<SYS_PASSWORD>@<JDE_DB_HOST>:1521/jdeorcl as sysdba @install_all_mcp_db.sql
```
