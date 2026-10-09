# Oracle JD Edwards EnterpriseOne (JDE) 9.2 Gemini Enterprise MCP Server & Discrete Manufacturing AI Agent

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-jde-gemini-enterprise-mcp`  
> **Release:** Customer-Managed Hybrid JDE Orchestrator v3 + Oracle 19c SQL MCP Architecture (18 MCP Tools, JDE One View Watchlists `F980051`, DMAAI `F4095` Auto-Remediation, Google A2UI `v0.9` Governance & `JDE_Master` Multi-Agent Framework)  
> **Target Audience:** Manufacturing Engineering, Enterprise Architects, JDE Administrators, and Solutions Architecture  

## 1. Executive Summary

This repository provides a production-ready enterprise reference architecture connecting Google Cloud **Gemini Enterprise** and the **Discrete Manufacturing AI Agent (`JDE_Master`)** directly to **Oracle JD Edwards EnterpriseOne (JDE) 9.2 (`JPD920` / `PRODDTA`, Tools Release 9.2.x)**.

Designed specifically for **Discrete Manufacturing operations (`Branch/Plant M30 — Central Discrete Mfg Plant`)**, this solution combines **direct Oracle 19c SQL analytics** over normalized read-only manufacturing views (`PRODDTA.VW_JDE_*`) with **transactional JDE Orchestrator Studio v3 REST automations (`/jderest/v3/orchestrator/*`)** so that every shop-floor action strictly enforces JDE Master Business Functions (MBFs), Next Numbers (`F0002`), Inventory Commitments (`F41021`), Item Ledger Cardex (`F4111`), and Application Security (`PRODCTL.F00950`).

### Key Capabilities Included in This Release
1. **Hybrid JDE Orchestrator v3 + Oracle 19c SQL MCP Server (`MCPServers/mcp-jde-orchestrator/`):** A containerized Python `FastMCP` server deployed on **Google Cloud Run** (`mcp-jde-orchestrator`) via **Google Artifact Registry** (`jde-mcp-repo`) with Direct VPC Egress (`oracle-jde-toolkit-network`) to both the JDE AIS/Orchestrator v3 Server (`:7077`) and the Oracle 19c Database (`:1521/jdeorcl`).
2. **18 Production-Ready Hybrid MCP Tools (`server.py`):**
   - **3 JDE EnterpriseOne Identity & Security Context Tools:** `jde_init`, `list_jde_current_context`, and `list_jde_roles` mapping the signed-in Gemini Enterprise user email (`PRODDTA.F01151`) to their JDE User ID (`SY920.F0092` `NGONZAL`), Address Book Number (`PRODDTA.F0101` `AN8=80001`), Role (`SY920.F95921` `MFG_MGR`), and Application Security permissions (`PRODCTL.F00950`).
   - **7 Read-Only SQL, Watchlist, DMAAI & AIS Discovery Tools:** `jde_discover_orchestrations`, `jde_query_work_order_control_tower`, `jde_check_work_order_material_shortages`, `jde_analyze_work_center_capacity_and_bottlenecks`, `jde_analyze_production_cost_variances`, `jde_query_watchlist_alerts`, and `jde_diagnose_dmaai_exceptions_and_precedent` with automatic 6-digit JDE Julian date (`CYYDDD` $\leftrightarrow$ `YYYY-MM-DD`) and 4-decimal implied scaling conversion.
   - **7 JDE Orchestrator Studio v3 Transactional Tools:** `jde_create_discrete_work_order` (`P48013` + `R31410`), `jde_issue_material_to_work_order` (`P31113`), `jde_record_routing_hours` (`P311221`), `jde_complete_discrete_work_order` (`P31114`), `jde_expedite_shortage_po` (`P4310`), `jde_resolve_dmaai_accounting_exception` (`P4095` + `R31802A`), and `jde_execute_custom_orchestration`.
   - **1 Google A2UI `v0.9` Interactive Governance Surface Tool:** `jde_generate_a2ui_exception_approval_card` rendering interactive GM3 Material Catalog `<a2ui-json>` approval cards in Gemini Enterprise for human-in-the-loop sign-off on high-value (`>= $5,000`) accounting and supply-chain exceptions.
3. **JDE One View Watchlist (`F980051`), DMAAI (`F4095`) Auto-Remediation & Operational Precedent Ledger (`F48019`):**
   - **Watchlist Notification & 14-Day Proactive Horizon:** Monitors active JDE One View Watchlists (`WL-MFG-01` Critical Late Work Orders, `WL-MFG-02` Unresolved DMAAI Accounting Exceptions, `WL-MFG-03` Stalled Shortage Work Orders, `WL-MFG-04` Overloaded Work Centers `>100%`) plus a 14-day proactive lookahead horizon.
   - **DMAAI (`P4095`) Policy-Gated Auto-Remediation:** Diagnoses missing GL account mappings in `PRODDTA.F4095` that block `R31802A` Manufacturing Accounting (`DMAAI 3120` Work-in-Process `< $5,000` auto-remediated immediately via `ORCH_ResolveDMAAIException`; `DMAAI 3240` Manufacturing Variance `>= $5,000` gated via an interactive Google A2UI `v0.9` card).
   - **Operational Precedent Ledger (`PRODDTA.F48019`):** Matches live shop-floor bottlenecks and accounting exceptions against historical resolution precedents (`PREC-DMAAI-3120`, `PREC-DMAAI-3240`, `PREC-SHORT-ENC`, `PREC-SHORT-PCBA`, `PREC-CAP-200101`).
4. **`JDE_Master` Multi-Agent Framework & 180 DPI Executive Charting (`Agents/JDE_Master/`):**
   - Deploys `JDE_Master` (`JDE_Mfg_Agent` + `JDE_Graphs_Agent` + `MrGoogle`) to **Vertex AI Reasoning Engine** with publication-grade `180 DPI` (`12.0" x 6.6"` widescreen) charts rendered inline in Gemini Enterprise.

## 2. End-to-End 4-Tier Architecture Overview

```text
+----------------------------------------------------------------------------------------------------------+
|            ORACLE JD EDWARDS ENTERPRISEONE 9.2 DISCRETE MANUFACTURING AI AGENT ARCHITECTURE              |
|                                                                                                          |
|  [ Tier 1: Gemini Enterprise UI (Oracle JD Edwards Discrete Mfg Assistant) ]                             |
|       |  * Conversational Shop-Floor Control Tower, Watchlist Triage & Cost Variance Analysis            |
|       |  * Interactive Google A2UI v0.9 Approval Cards (<a2ui-json>) & 180 DPI Executive Charts          |
|       |                                                                                                  |
|       | 1. OAuth 2.0 / Signed-In User Identity (session.user_email)                                      |
|       v                                                                                                  |
|  [ Tier 2: Vertex AI Reasoning Engine — JDE_Master Multi-Agent System ]                                  |
|       |  * JDE_Mfg_Agent (18 MCP Tools + jde_discrete_mfg_semantic_map.json)                             |
|       |  * JDE_Graphs_Agent (180 DPI Widescreen Bar, Stacked Bar, Donut & Line Charts)                   |
|       |  * MrGoogle (External Supplier & Market Intelligence)                                            |
|       |                                                                                                  |
|       | 2. Streamable HTTP MCP Protocol (/mcp) + OIDC Bearer Token + X-User-Email Header                 |
|       v                                                                                                  |
|  [ Tier 3: Cloud Run — mcp-jde-orchestrator ] (18-Tool Hybrid FastMCP Server)                            |
|       |  * Pre-Configured Image in Customer Artifact Registry (jde-mcp-repo)                             |
|       |  * Secret Manager Credential Injection + Direct VPC Egress (oracle-jde-toolkit-network)          |
|       +-----------------------------------------------+--------------------------------------------------+
|                                                       |                                                  |
|       3A. REST /jderest/v3/orchestrator/* (:7077)     | 3B. Oracle Net8 / SQL*Net (:1521/jdeorcl)        |
|           (Enforces F00950 Security & MBF Rules)      |     (DBMS_SESSION.SET_IDENTIFIER + Read Views)   |
|       v                                               v                                                  |
|  [ Tier 4A: JDE AIS v2 & Orchestrator v3 Server ]    [ Tier 4B: Oracle 19c Database (PDB JDEORCL) ]      |
|    * 7 Orchestrations (P48013, P31113, P311221,        * Schemas: PRODDTA, PRODCTL, SY920, JDE_AI        |
|      P31114, P4310, P980051, P4095/R31802A)            * Identity: F0101, F01151, F0092, F95921, F00950  |
|    * Blocks raw AIS bsfnservice privilege escalation   * Core Mfg: F4801, F3111, F3112, F3102, F4111     |
|    * Stamps resolved JDE User into WHO columns         * Governance: F980051, F4095, F48019, 7 Views     |
+----------------------------------------------------------------------------------------------------------+
```

## 3. Complete Inventory of 18 Hybrid MCP Tools (`MCPServers/mcp-jde-orchestrator/server.py`)

### 3.1 JDE EnterpriseOne Identity, Role & Security Context Tools (3 Tools)

| Tool Name | Execution Path | Target JDE Objects | Description |
| :--- | :--- | :--- | :--- |
| **`jde_init`** | Oracle PL/SQL + Session State | `PRODDTA.GE_JDE_MCP_TOOLS.jde_initialize_context`, `F01151`, `F0092`, `F00950` | **Session Initialization:** Maps the signed-in Gemini Enterprise email (`admin@negonzal.altostrat.com`) to JDE User `NGONZAL` (`AN8=80001`), validates role `MFG_MGR` (`SY920.F95921`) and Branch/Plant `M30` security (`PRODCTL.F00950`), sets `DBMS_SESSION.SET_IDENTIFIER`, and logs to `PRODDTA.GGLTOOLBOX$MCP_LOG`. |
| **`list_jde_current_context`** | Oracle SQL | `PRODDTA.JDE_MCP_SESSION_CTX`, `PRODCTL.F00950` | **Context Verification:** Returns the active JDE User ID, Address Book Number (`AN8`), Role, Environment (`JPD920`), Branch/Plant (`M30`), Oracle `CLIENT_IDENTIFIER`, and authorized JDE applications. |
| **`list_jde_roles`** | Oracle SQL | `SY920.F0092`, `PRODDTA.F0101`, `PRODDTA.F01151`, `SY920.F95921` | **Role Discovery:** Lists JDE User Profiles, Address Book records, Electronic Address emails, and granted roles (`MFG_MGR`, `SHOP_SUPV`, `BUYER_M30`, `COST_ACCT`). |

### 3.2 Read-Only SQL Analytics, Watchlist, DMAAI & AIS Discovery Tools (7 Tools)

| Tool Name | Execution Path | Target JDE View / Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **`jde_discover_orchestrations`** | AIS REST v2 | `GET /jderest/v2/open-api-catalog` | **Orchestration Discovery:** Queries the JDE AIS Server OpenAPI 3.0.1 catalog to discover deployed JDE Orchestrations and their input/output schemas. |
| **`jde_query_work_order_control_tower`** | Oracle SQL | `PRODDTA.VW_JDE_MFG_WORK_ORDERS` (`F4801`, `F4101`, `F0005`) | **Shop-Floor Control Tower:** Returns active Discrete Manufacturing Work Orders (`480010`–`480025`) with ISO-8601 dates, completion percentages, shortage counts, and schedule health (`LATE`, `AT_RISK_SHORTAGE`, `ON_TRACK`, `COMPLETED`). |
| **`jde_check_work_order_material_shortages`** | Oracle SQL | `PRODDTA.VW_JDE_MFG_PARTS_SHORTAGES` (`F3111`, `F41021`, `F4311`) | **Component Shortage & PO Tracing:** Cross-references Work Order Parts List requirements against on-hand/committed inventory balances and open Purchase Orders (`PO 430101`, `430102`, `430103`). |
| **`jde_analyze_work_center_capacity_and_bottlenecks`** | Oracle SQL | `PRODDTA.VW_JDE_MFG_ROUTING_LOAD` (`F3112`, `F0006`) | **Capacity & Bottleneck Analysis:** Calculates scheduled setup, machine, and labor hours vs. weekly capacity across Work Centers `200-101` (`CNC Machining`, `115.8% OVERLOADED`) through `200-401`. |
| **`jde_analyze_production_cost_variances`** | Oracle SQL | `PRODDTA.VW_JDE_MFG_COST_VARIANCES` (`F3102`) | **Manufacturing Cost Accounting:** Compares Standard, Planned, Actual, Completed, and Scrap costs across Cost Types `A1` (Material), `B1` (Direct Labor), `B2` (Machine), `B3` (Setup), and `C1` (Overhead). |
| **`jde_query_watchlist_alerts`** | Hybrid SQL + Orchestrator v3 | `PRODDTA.VW_JDE_WATCHLIST_ALERTS` (`SY920.F980051`) + `ORCH_EvaluateWatchlistAndPrecedent` | **JDE One View Watchlists & 14-Day Horizon:** Evaluates active Watchlists (`WL-MFG-01`..`WL-MFG-04`) alongside a 14-day proactive horizon to flag upcoming component shortages and capacity overloads before they stall production. |
| **`jde_diagnose_dmaai_exceptions_and_precedent`** | Oracle SQL | `PRODDTA.VW_JDE_DMAAI_EXCEPTIONS` (`F4095`, `F0901`) + `VW_JDE_OPERATIONAL_PRECEDENTS` (`F48019`) | **DMAAI & Precedent Triage:** Diagnoses unposted `R31802A` Manufacturing Accounting work orders blocked by missing `F4095` DMAAI GL mappings (`3120`, `3240`) and retrieves matching historical precedents from `F48019`. |

### 3.3 JDE Orchestrator Studio v3 Transactional Tools & Google A2UI Governance (8 Tools)

| Tool Name | Execution Path | JDE Orchestration / Application | Description |
| :--- | :--- | :--- | :--- |
| **`jde_create_discrete_work_order`** | Orchestrator v3 | `ORCH_CreateDiscreteWorkOrder` (`P48013` + `R31410`) | **Work Order Creation:** Allocates a Next Number from `F0002`, creates the Work Order header in `F4801`, explodes the `F3002` BOM into `F3111`, attaches the `F3003` routing into `F3112`, and seeds `F3102` standard cost buckets. |
| **`jde_issue_material_to_work_order`** | Orchestrator v3 | `ORCH_IssueMaterialToWorkOrder` (`P31113`) | **Inventory Issue (`IM`):** Issues component stock to a Work Order, updates `F3111.WMTRQT`, decrements `F41021` on-hand inventory, writes an `IM` Cardex transaction to `F4111`, and rolls actual material cost (`A1`) into `F3102`. |
| **`jde_record_routing_hours`** | Orchestrator v3 | `ORCH_RecordRoutingHours` (`P311221`) | **Routing Time Entry:** Records actual labor, machine, and setup hours against a routing operation in `F3112` and updates actual `B1`/`B2`/`B3` costs and variances in `F3102`. |
| **`jde_complete_discrete_work_order`** | Orchestrator v3 | `ORCH_CompleteWorkOrder` (`P31114`) | **Work Order Completion (`IC`):** Completes finished assembly units into inventory (`F4801.WASOQS`), increments finished-goods on-hand balance in `F41021`, writes an `IC` Cardex receipt to `F4111`, and updates `F3102` completed valuation. |
| **`jde_expedite_shortage_po`** | Orchestrator v3 | `ORCH_ExpediteShortagePO` (`P4310`) | **Purchase Order Expedite:** Updates the Promised Delivery Date (`PDDJ`) and status on an open Purchase Order in `F4311` (`PO 430101` / `430102`) and records the expedited resolution in `F48019` and `GGLTOOLBOX$MCP_LOG`. |
| **`jde_resolve_dmaai_accounting_exception`** | Orchestrator v3 | `ORCH_ResolveDMAAIException` (`P4095` + `R31802A`) | **Policy-Gated DMAAI Auto-Remediation:** Configures missing GL accounts (`MCO`/`MMCU`/`MOBJ`/`MSUB`) in `PRODDTA.F4095` and runs `R31802A` Manufacturing Accounting. Automatically executes when unposted variance impact is `< $5,000` (`DMAAI 3120` on `WO 480015`, `$1,840.00`), and enforces a human approval gate (`REQUIRES_HUMAN_APPROVAL`) when `>= $5,000` (`DMAAI 3240` on `WO 480018`, `$18,450.00`). |
| **`jde_execute_custom_orchestration`** | Orchestrator v3 | `POST /jderest/v3/orchestrator/{name}` | **Custom Orchestration Dispatcher:** Invokes any custom JDE Orchestrator v3 endpoint with arbitrary JSON payload and automatic `SY920.F0092` / `PRODCTL.F00950` security enforcement. |
| **`jde_generate_a2ui_exception_approval_card`** | Google A2UI `v0.9` | GM3 Material Catalog `<a2ui-json>` Surface | **Interactive Human-in-the-Loop Governance Card:** Generates a valid Google A2UI `v0.9` JSON payload (`createSurface` + `updateComponents` + `updateDataModel`) with KPI chips, Operational Precedent citation, and **Approve & Execute in JDE** / **Hold for Review** action buttons. |

## 4. Security, Email-to-JDE Identity Propagation & AIS Hardening

1. **End-to-End Email-to-JDE Identity Propagation:** The signed-in Gemini Enterprise user email (`session.user_email`) is resolved via `PRODDTA.F01151` (Electronic Address) and `SY920.F0092` (User Display Preferences) to their JDE User ID (`NGONZAL`, `AN8=80001`) and verified against `PRODCTL.F00950` (Security Workbench) before any SQL query or Orchestrator v3 transaction executes.
2. **JDE `WHO` Column & Autonomous Audit Stamping:** Every database query sets `DBMS_SESSION.SET_IDENTIFIER('NGONZAL:admin@negonzal.altostrat.com')`, every Orchestrator v3 mutation stamps the resolved JDE User ID into JDE `WHO` audit columns (`WAUSER`, `WMUSER`, `WLUSER`, `ILUSER`, `MLUSER`, `UPMJ`, `TDAY`), and every action is logged via `PRAGMA AUTONOMOUS_TRANSACTION` in `PRODDTA.GGLTOOLBOX$MCP_LOG`.
3. **Orchestrator-First Boundary (Blocking Raw AIS `bsfnservice` Escalation):** Rather than exposing the raw AIS Business Function Service (`/jderest/v2/bsfnservice`), all mutations are strictly channeled through named JDE Orchestrator v3 endpoints (`/jderest/v3/orchestrator/*`) with `PRODCTL.F00950` application/branch-plant authorization checks.

## 5. Deployment Guidance & Step-by-Step Customer Setup

### 5.1 Prerequisites & Required Google Cloud APIs

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    compute.googleapis.com \
    aiplatform.googleapis.com \
    iam.googleapis.com \
    --project="$PROJECT_ID"
```

### 5.2 Step 1: Prepare the Oracle JD Edwards 9.2 Database & AIS/Orchestrator Tier (`JDEScripts/`)

```bash
cd JDEScripts

# Install JDE 9.2 Discrete Mfg schema, Email-to-JDE Identity (F0092/F00950),
# Read-Only Analytical Views (VW_JDE_*), Watchlists (F980051), DMAAI (F4095), and Precedents (F48019)
sqlplus sys/<SYS_PASSWORD>@<JDE_DB_HOST>:1521/jdeorcl as sysdba @install_all_mcp_db.sql
```

### 5.3 Step 2: Deploy the Hybrid JDE MCP Server to Artifact Registry & Cloud Run

#### Option A: 1-Command Artifact Registry + Cloud Run Deployment (`deploy.sh`)

```bash
cd MCPServers/mcp-jde-orchestrator
cp .env.example .env
# Edit .env with your PROJECT_ID, VPC_NAME, SUBNET_NAME, JDE_AIS_BASE_URL, and JDE_DB_DSN
./deploy.sh
```

#### Option B: 1-Click Guided Deployment in Google Cloud Shell

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-jde-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

#### Option C: Automated Terraform & Makefile Deployment (MCP Server + `JDE_Master` Agent)

```bash
# 1. Verify GCP access and initialize the GCS Terraform state backend
make verify-gcp-access PROJECT_ID=your-gcp-project-id REGION=us-central1
make init PROJECT_ID=your-gcp-project-id REGION=us-central1

# 2. Configure Oracle JDE DB DSN, AIS URL, VPC, and Subnet (saved to infra.auto.tfvars)
make set_config_mcp_servers

# 3. Deploy the Hybrid JDE MCP Server to Artifact Registry & Cloud Run
make deploy_mcp_server PROJECT_ID=your-gcp-project-id REGION=us-central1

# 4. Deploy the JDE_Master Discrete Manufacturing AI Agent to Vertex AI Reasoning Engine
make deploy_jde_agents PROJECT_ID=your-gcp-project-id REGION=us-central1
```
