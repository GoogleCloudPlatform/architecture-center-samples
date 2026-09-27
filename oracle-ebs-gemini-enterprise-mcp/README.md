# Oracle EBS Gemini Enterprise MCP: Current Baseline Capabilities

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-ebs-gemini-enterprise-mcp`  
> **Status:** Current Baseline Audit  
> **Target Audience:** Engineering, Solutions Architecture, and Product Management  

---

## 1. Executive Summary

This repository provides an enterprise reference architecture connecting Google Cloud Gemini Enterprise agents to **Oracle E-Business Suite (EBS R12.2.x)**. 

Contrary to common assumptions that the repository only performs raw SQL queries, the current codebase provides an end-to-end integration stack:
1. **Containerized MCP Toolbox Server (`mcp-toolbox-ebs`):** A Go-based Model Context Protocol (`genai-toolbox`) service running on Google Cloud Run with VPC peering to the EBS database tier.
2. **8 Out-of-the-Box MCP Tools:** Exposing session initialization (`FND_GLOBAL`), analytical discovery, and transactional public PL/SQL APIs (`INV_TXN_MANAGER_PUB`, AP invoice creation).
3. **Database Tier Integration (`EBSScripts/`):** A custom PL/SQL package (`ge_ebs_mcp_tools.pls`) that encapsulates core Oracle EBS public APIs, paired with dedicated least-privilege security provisioning scripts (`APPS_AI`).
4. **Hierarchical Multi-Agent Framework (`Agents/EBS_Master/`):** An ADK-based master orchestrator with specialist sub-agents backed by 7 domain semantic maps.
5. **Integrated SOA Gateway (ISG) WADL Automation Framework:** An automated developer skill designed to parse Oracle EBS ISG REST WADL/XSD definitions and generate typed Python client services.

---

## 2. Component Architecture Overview

```text
+----------------------------------------------------------------------------------------------------+
|                                    CURRENT REPOSITORY ARCHITECTURE                                 |
|                                                                                                    |
|  [ Gemini Enterprise / ADK Master Agent ]                                                          |
|       |                                                                                            |
|       | 1. Evaluates Intent & Semantic Maps (AP, AR, GL, PO, OM, Inv, Security)                    |
|       v                                                                                            |
|  [ EBS_Master Orchestrator ] ---> Dispatches to: [ EBS_SQL_Agent ] | [ EBS_Graphs_Agent ]          |
|       |                                                                                            |
|       | 2. Standard MCP Protocol (/mcp JSON-RPC) + Google IAM Token                                |
|       v                                                                                            |
|  [ Cloud Run: mcp-toolbox-ebs ] (Go genai-toolbox)                                                 |
|       |  * Configured via Google Secret Manager (tools.yaml)                                       |
|       |  * Connected via Serverless VPC Access Connector                                           |
|       |                                                                                            |
|       | 3. Oracle Net8 / SQL Connection (Port 1521)                                                |
|       v                                                                                            |
|  [ Oracle Database Tier: EBSDB ]                                                                   |
|       |  * Schema: APPS / APPS_AI                                                                  |
|       |  * Custom Wrapper: ge_ebs_mcp_tools (.pls / .plb)                                          |
|       |  * Oracle Core Public APIs: INV_TXN_MANAGER_PUB, AP_INVOICES_PKG                           |
|       +--------------------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------------------------+
```

---

## 3. Detailed Inventory of Out-of-the-Box Tools (`tools.yaml`)

The MCP runtime is configured via `MCPServers/mcp-toolbox-ebs/tools.yaml`. It exposes **8 production-ready tools**:

| Tool Name | Tool Kind | Underlying Mechanism | Description |
| :--- | :--- | :--- | :--- |
| **`ebs_init`** | `oracle-sql` | `ge_ebs_mcp_tools.ebs_initialize_context` via `AppsInitialisefromemailid.sql` | **Session Initialization:** Looks up user email, retrieves responsibilities, and calls `FND_GLOBAL.APPS_INITIALIZE` to enforce Row-Level Security (RLS) and Multi-Org Access Control (MOAC). |
| **`list_ebs_responsibilities`** | `oracle-sql` | Queries `fnd_user`, `fnd_responsibility_vl`, `fnd_application` | **Role Discovery:** Identifies valid responsibilities and operating units for a user prior to session initialization. |
| **`list_ebs_current_context`** | `oracle-sql` | Diagnostic query on `fnd_global` variables | **Context Verification:** Returns current `user_id`, `resp_id`, `appl_id`, and `org_id` to troubleshoot security policies. |
| **`execute_sql`** | `oracle-execute-sql` | Read-only SQL execution engine | **Data Discovery:** Executes arbitrary read-only SQL queries against base tables and views. |
| **`create_onhand`** | `oracle-sql` | `ge_ebs_mcp_tools.create_onhand` &rarr; `INV_TXN_MANAGER_PUB.process_Transactions` | **Inventory Receipt:** Executes an Oracle Inventory Miscellaneous Receipt via public APIs to add stock to a warehouse location. |
| **`reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.reserve_item` | **Inventory Reservation:** Creates reservations against on-hand stock for specific inventory items. |
| **`delete_reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.delete_reserve_item` | **Reservation Cancellation:** Cancels and releases an existing inventory reservation. |
| **`create_ap_invoice`** | `oracle-sql` | `ge_ebs_mcp_tools.create_ap_invoice` | **Payables Invoicing:** Programmatically inserts, validates, and commits an AP invoice record using EBS Payables business rules. |

---

## 4. Multi-Agent Orchestration Layer (`Agents/EBS_Master/`)

The repository includes a multi-agent framework built with the Google Cloud Agent Development Kit (ADK):

### A. `EBS_Master` Orchestrator (`agent.py`, `agent_config.py`)
* Acts as the root supervisor for incoming prompts.
* Resolves user identity on turn 1 (`get_user_id`) and caches non-sensitive context in session state (`get_session_user_context`).
* Routes tasks across specialist sub-agents based on intent.

### B. `EBS_SQL_Agent` (`sub-agents/EBS_SQL_Agent/`)
Specialist agent for database querying and transactional tool execution:
* Connected to the MCP server via `McpToolset` using authenticated streaming HTTP connection parameters.
* Powered by **7 domain semantic maps** stored in `semantic_maps/`:
  1. `po_semantic_map.json`: Purchase orders, lines, shipments, distributions, and vendor master data.
  2. `ap_semantic_map.json`: Invoices, payments, check runs, holds, and accounting distributions.
  3. `ar_semantic_map.json`: Customer accounts, transactions, receipts, and aging balances.
  4. `gl_semantic_map.json`: Chart of accounts, journal entries, ledger sets, and budget balances.
  5. `inventory_semantic_map.json`: Items, sub-inventories, locators, reservations, and transaction history.
  6. `om_semantic_map.json`: Sales orders, line items, price lists, and shipping holds.
  7. `security_semantic_map.json`: Users, responsibilities, menus, and operating unit mappings.

### C. `EBS_Graphs_Agent` (`sub-agents/EBS_Graphs_Agent/`)
* Receives structured JSON arrays or CSV query outputs from `EBS_SQL_Agent`.
* Uses Gemini Code Execution / visualization engines to generate clean charts (bar, line, pie) and high-density markdown tables.

### D. `MrGoogle` (`sub-agents/MrGoogle/`)
* Grounding agent that executes web research to supplement EBS enterprise data with external market or regulatory context.

---

## 5. Integrated SOA Gateway (ISG) WADL Framework (`.github/skills/`)

The repository contains a dedicated engineering skill: `.github/skills/ebs-wadl-to-client/SKILL.md`:
* **Purpose:** Automates the creation of typed Python client classes from Oracle EBS Integrated SOA Gateway (ISG) REST services.
* **Mechanism:**
  1. Ingests raw WADL and XSD schema files from Oracle EBS ISG REST catalogs (e.g., `WADL/APINV/`, `WADL/vendor/`, `WADL/AccessControlService/`).
  2. Derives resource endpoints, request/response XML/JSON schemas, and header requirements.
  3. Generates strongly typed subclasses inheriting from `EBSBaseClient` with built-in retry and authentication handlers.

---

## 6. Database Artifacts & Security Posture (`EBSScripts/`)

* **`ge_ebs_mcp_tools.pls` / `.plb`:** Published in the `APPS` schema; wraps raw public APIs into clean SQL-callable scalar/JSON functions.
* **`create_apps_ai.sql`:** Creates a dedicated database user (`APPS_AI`) to isolate AI agent database activity from default administrative accounts.
* **`GrantToApps_AI.sql` & `GrantToApps_AIRESTRICTED.sql`:**
  * *Global Posture:* Grants `SELECT ANY TABLE` for broad analytical sandboxes.
  * *Restricted Posture:* Grants granular permissions on ~3,000 specific tables and views, enforcing the principle of least privilege.
