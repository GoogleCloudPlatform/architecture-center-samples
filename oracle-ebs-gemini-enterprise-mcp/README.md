# Oracle E-Business Suite (EBS) Gemini Enterprise MCP Server & Public Sector Skills

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-ebs-gemini-enterprise-mcp`  
> **Release:** Customer-Managed Cloud Run BYO-MCP Architecture (21 MCP Tools, 8 Domain Semantic Maps, 6 Public Sector Skills & 180 DPI Executive Charting)  
> **Target Audience:** Engineering, Solutions Architecture, and Product Management  

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-ebs-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

## 1. Executive Summary

This repository provides a production-ready enterprise reference architecture connecting Google Cloud **Gemini Enterprise** and the **6 Gemini for government services Public Sector Skills** directly to **Oracle E-Business Suite (EBS R12.2.x)**.

It combines core Procure-to-Pay (P2P), Order-to-Cash (O2C), Inventory (`MTL_ONHAND_QUANTITIES_DETAIL`, `MTL_RESERVATIONS`), General Ledger (`GL_JE_HEADERS`), Human Resources (`PER_ALL_PEOPLE_F`), Purchasing (`PO_HEADERS_ALL`), Sourcing (`PON_AUCTION_HEADERS_ALL`), Grants (`GMS_AWARDS_ALL`), and Oracle Internet Expenses (OIE `AP_EXPENSE_REPORT_HEADERS_ALL`) capabilities with 6 specialized **Gemini for government services** Public Sector compliance and casework skills, backed by a customer-managed 21-tool Cloud Run Model Context Protocol (`genai-toolbox`) server and publication-grade 180 DPI executive charting.

### Key Capabilities Included in This Release
1. **Containerized MCP Toolbox Server (`MCPServers/mcp-toolbox-ebs/`):** A Go-based Model Context Protocol (`genai-toolbox`) service packaged into your GCP project's **Google Artifact Registry** (`ebs-mcp-repo`) and deployed on **Google Cloud Run** over Direct VPC Egress to the Oracle EBS database tier (`EBSDB`).
2. **21 Production-Ready MCP Tools (`tools.yaml`):**
   - **8 Baseline ERP & Transactional Tools:** Session context initialization (`ebs_init` via `FND_GLOBAL.APPS_INITIALIZE` and `MO_GLOBAL`), responsibility discovery (`list_ebs_responsibilities`), active session inspection (`list_ebs_current_context`), read-only analytical discovery (`execute_sql`), inventory receipt creation (`create_onhand`), stock reservation (`reserve_item`, `delete_reserve_item`), and Accounts Payable invoice creation (`create_ap_invoice`).
   - **13 Public Sector, Regulatory Compliance & Multimodal OIE Tools:** Purpose-built parameterized SQL and PL/SQL API tools supporting all 6 **Gemini for government services** skills across constituent notices, FOIA/privacy compliance, statutory hierarchy analysis, document intake validation, RFP vendor evaluation, 2 CFR Part 200 grant/expense auditing, and **multimodal/conversational OIE Expense Report creation (`ebs_create_expense_report`)** from uploaded expense form screenshots or chat text.
3. **Database Tier Integration & Read-Only Governance Views (`EBSScripts/`):**
   - Custom PL/SQL wrapper package (`APPS.GE_EBS_MCP_TOOLS` in `ge_ebs_mcp_tools.pls` / `.plb`) encapsulating Oracle EBS public APIs (including `create_expense_report` across 7 official Oracle Internet Expenses, AOL Attachment, Workflow, and Audit PL/SQL APIs) and autonomous audit logging (`APPS.GGLTOOLBOX$MCP_LOG`).
   - Least-privilege database user provisioning (`APPS_AI` via `create_apps_ai.sql`, `GrantToApps_AI.sql`, and `GrantToApps_AIRESTRICTED.sql`).
   - 7 read-only Public Sector views (`APPS.VW_GOV_*`) across 15 core Oracle EBS tables (`install_gov_public_sector_views.sql` (read-only views) and `create_v2_reports_via_oracle_apis.sql` (official Oracle PL/SQL APIs & Open Interfaces)) with an isolated synthetic evaluation dataset (`IDs 990001–990999`) covering 163 test scenarios with zero mutation of baseline Vision data.
4. **6 Gemini Enterprise Public Sector Skills & 180 DPI Executive Charting:**
   - **Direct Skill-to-MCP Execution:** Gemini Enterprise executes the 6 Public Sector Skills (`/plain-language-notice-generator`, `/redaction-and-foia-compliance`, `/policy-and-statute-assistant`, `/document-intake-cleanup-and-validation`, `/rfp-vendor-evaluation-scorer`, and `/expense-auditor`) directly against the Cloud Run Oracle EBS MCP Server (`/mcp`).
   - **8 Domain Semantic Maps:** Curated schema definitions covering Accounts Payable (`ap`), Accounts Receivable (`ar`), General Ledger (`gl`), Human Resources (`hr`), Oracle Inventory (`inventory`), Order Management (`om`), Purchasing (`po`), and Public Sector Views (`gov_public_sector_semantic_map.json`).
   - **180 DPI Executive Charting:** Generates publication-grade `180 DPI` (`12.0" x 6.6"` widescreen) horizontal bar, vertical bar, grouped/stacked bar, executive donut, and multi-series line charts with automatic currency formatting, KPI summary callouts, reference threshold rules, and source provenance footers rendered inline in Gemini Enterprise (including click-to-enlarge full-resolution inspection).

## 2. End-to-End Architecture Overview

```text
+----------------------------------------------------------------------------------------------------------+
|                         ORACLE EBS GEMINI ENTERPRISE MCP ARCHITECTURE                                    |
|                                                                                                          |
|  [ Gemini Enterprise UI & 6 Public Sector Skills ]                                                       |
|       |  * /plain-language-notice-generator    * /document-intake-cleanup-and-validation                 |
|       |  * /redaction-and-foia-compliance      * /rfp-vendor-evaluation-scorer                           |
|       |  * /policy-and-statute-assistant       * /expense-auditor                                        |
|       |                                                                                                  |
|       | 1. Streamable HTTP MCP Protocol (/mcp) + OIDC Bearer Token + User Identity Context               |
|       v                                                                                                  |
|  [ Cloud Run: mcp-toolbox-ebs ] (GenAI Toolbox for Databases)                                            |
|       |  * Pre-Configured Image in Customer Artifact Registry (ebs-mcp-repo)                             |
|       |  * Zero Plaintext Credentials in tools.yaml (Secret Manager Env Var Injection)                   |
|       |  * Isolated via Direct VPC Egress (--network / --subnet)                                         |
|       |                                                                                                  |
|       | 2. Oracle Net8 / SQL*Net Connection (TCP Port 1521 -> EBSDB)                                     |
|       v                                                                                                  |
|  [ Oracle E-Business Suite 12.2.x Database Tier (EBSDB) ]                                                |
|       |  * Schema: APPS / APPS_AI (Least-Privilege Role & Grants)                                        |
|       |  * PL/SQL Wrapper: APPS.GE_EBS_MCP_TOOLS + Audit Table APPS.GGLTOOLBOX$MCP_LOG                   |
|       |  * Core Public APIs: FND_GLOBAL.APPS_INITIALIZE, MO_GLOBAL, INV_TXN_MANAGER_PUB, AP_WEB_*        |
|       |  * Public Sector Read-Only Views: 7 APPS.VW_GOV_* Views across 15 Core EBS Tables                |
+----------------------------------------------------------------------------------------------------------+
```

## 3. Complete Inventory of 21 MCP Tools (`MCPServers/mcp-toolbox-ebs/tools.yaml`)

### 3.1 Baseline ERP, Session Security & Transactional Tools (8 Tools)

| Tool Name | Tool Kind | Underlying Oracle Mechanism | Description |
| :--- | :--- | :--- | :--- |
| **`ebs_init`** | `oracle-sql` | `ge_ebs_mcp_tools.ebs_initialize_context` | **Session Initialization:** Resolves user email in `FND_USER`, validates active responsibility in `FND_USER_RESP_GROUPS_DIRECT`, invokes `FND_GLOBAL.APPS_INITIALIZE`, initializes Multi-Org (`MO_GLOBAL.INIT`), and sets policy context (`MO_GLOBAL.SET_POLICY_CONTEXT('S', l_ou_id)`). |
| **`list_ebs_responsibilities`** | `oracle-sql` | `FND_USER`, `FND_RESPONSIBILITY_VL`, `HR_OPERATING_UNITS` | **Role Discovery:** Lists valid responsibilities, application short names, and operating units assigned to an EBS user email prior to session initialization. |
| **`list_ebs_current_context`** | `oracle-sql` | `FND_GLOBAL` session state inspection | **Context Verification:** Returns active `user_id`, `responsibility_name`, `security_group_name`, `application_short_name`, and `operating_unit_id`. |
| **`execute_sql`** | `oracle-execute-sql` | Read-only SQL execution engine (`readOnly: true`) | **Analytical Discovery:** Executes read-only `SELECT` queries against Oracle EBS tables and views under the active session security context. |
| **`create_onhand`** | `oracle-sql` | `ge_ebs_mcp_tools.create_onhand` &rarr; `INV_TXN_MANAGER_PUB` | **Inventory Receipt:** Creates an Oracle Inventory Miscellaneous Receipt via `MTL_TRANSACTIONS_INTERFACE` and `INV_TXN_MANAGER_PUB.process_Transactions`. |
| **`reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.reserve_item` &rarr; `INV_RESERVATION_PUB` | **Inventory Reservation:** Creates an item reservation against available on-hand warehouse stock. |
| **`delete_reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.delete_reservation` &rarr; `INV_RESERVATION_PUB` | **Reservation Release:** Deletes and releases an existing inventory reservation by `reservation_id`. |
| **`create_ap_invoice`** | `oracle-sql` | `ge_ebs_mcp_tools.create_ap_invoice` &rarr; `AP_INVOICES_INTERFACE` | **Payables Invoicing:** Programmatically validates and creates an Accounts Payable vendor invoice record. |

### 3.2 Public Sector, Regulatory Compliance & Multimodal OIE Tools (13 Tools Supporting 6 Skills)

| Skill | Tool Name | Target EBS View / Tables | Description |
| :--- | :--- | :--- | :--- |
| **3.1 Plain Language Notice Generator** | **`ebs_get_constituent_notice_details`** | `APPS.VW_GOV_CONSTITUENT_NOTICES` (`RA_CUSTOMER_TRX_ALL`, `FND_DOCUMENTS_LONG_TEXT`) | Retrieves population-level public benefit notices or individual determinations, statutory citations, effective dates, and full notice text for translation into Plain English language. |
| **3.1 Plain Language Notice Generator** | **`ebs_get_document_attachment`** | `FND_DOCUMENTS`, `FND_DOCUMENTS_TL`, `FND_DOCUMENTS_LONG_TEXT`, `FND_ATTACHED_DOCUMENTS` | Fetches full text and attachment metadata for statutory directives, agency transmittals, and determinations. |
| **3.2 Redaction & FOIA Compliance** | **`ebs_search_foia_records`** | `APPS.VW_GOV_FOIA_RECORDS` (`PO_HEADERS_ALL`, `PER_ALL_PEOPLE_F`, `FND_DOCUMENTS_LONG_TEXT`) | Searches responsive public procurement contracts, audit exhibits, and oversight records for a FOIA request or solicitation reference. |
| **3.2 Redaction & FOIA Compliance** | **`ebs_get_employee_personnel_file`** | `APPS.VW_GOV_FOIA_RECORDS` (`PER_ALL_PEOPLE_F`, `FND_DOCUMENTS_LONG_TEXT`) | Retrieves HR personnel attributes and attached tax/medical/security exhibits to segregate releasable official roles from protected PII, PHI, FTI, and Exemption 7(E)/4 secrets. |
| **3.3 Policy & Statute Assistant** | **`ebs_get_agency_policy_rules`** | `APPS.VW_GOV_AGENCY_POLICY_RULES` (`PO_CONTROL_GROUPS_ALL`, `PO_CONTROL_RULES`) | Queries structured procurement approval tiers, control groups, and statutory dollar limits in Oracle Purchasing. |
| **3.3 Policy & Statute Assistant** | **`ebs_search_policy_attachments`** | `APPS.VW_GOV_AGENCY_POLICY_RULES` (`FND_DOCUMENTS_LONG_TEXT`) | Searches official federal/state statutory and regulatory policy transmittals (SNAP, Medicaid, statutory preemption, procurement code, 2 CFR Part 200). |
| **3.4 Document Intake Cleanup & Validation** | **`ebs_get_intake_attachments`** | `APPS.VW_GOV_INTAKE_DOCUMENTS` (`HZ_PARTIES`, `FND_DOCUMENTS_LONG_TEXT`) | Retrieves staged constituent intake packets, Gate A optical telemetry (focus variance, skew, 4-corner framing), OCR confidence scores, and Gate C paystub/ledger math. |
| **3.4 Document Intake Cleanup & Validation** | **`ebs_verify_party_identity`** | `APPS.VW_GOV_INTAKE_DOCUMENTS` (`HZ_PARTIES`) | Cross-checks applicant legal name, pre-masked SSN hash (`***-**-XXXX`), and verified address against Oracle Trading Community Architecture (TCA) master records. |
| **3.5 RFP Vendor Evaluation Scorer** | **`ebs_get_sourcing_rfp_details`** | `APPS.VW_GOV_SOURCING_RFPS` (`PON_AUCTION_HEADERS_ALL`, `FND_DOCUMENTS_LONG_TEXT`) | Retrieves Oracle Sourcing RFP solicitation headers, addenda, Section M.1 Minimum Mandatory Qualifications, and Section M.2 evaluation criteria. |
| **3.5 RFP Vendor Evaluation Scorer** | **`ebs_get_vendor_bids`** | `APPS.VW_GOV_SOURCING_RFPS` (`PON_BID_HEADERS`, `FND_DOCUMENTS_LONG_TEXT`) | Retrieves competing vendor bid headers, pricing, mandatory qualification evidence, and cross-document proposal sections for compliance matrix compilation. |
| **3.6 Expense Auditor** | **`ebs_get_expense_reports`** | `APPS.VW_GOV_EXPENSE_REPORTS` (`AP_EXPENSE_REPORT_HEADERS_ALL`, `AP_EXPENSE_REPORT_LINES_ALL`) | Retrieves Oracle Internet Expenses travel headers, itemized expense lines, GSA Per Diem notes, and attached hotel/flight receipt OCR folios. |
| **3.6 Expense Auditor** | **`ebs_get_po_invoice_match`** | `APPS.VW_GOV_PO_INVOICE_MATCH` (`AP_INVOICES_ALL`, `PO_HEADERS_ALL`, `GMS_AWARDS_ALL`) | Retrieves Accounts Payable vendor invoices, matched Purchase Orders, competitive quote notes, and Oracle Grants Accounting Period of Performance / NICRA metadata. |
| **3.6 Expense Submission & Auditor** | **`ebs_create_expense_report`** | `ge_ebs_mcp_tools.create_expense_report` &rarr; `AP_WEB_DB_EXPRPT_PKG`, `AP_EXPENSE_REPORT_HEADERS_PKG`, `AP_WEB_DB_EXPLINE_PKG`, `AP_WEB_DB_EXPDIST_PKG`, `FND_WEBATTCH`, `AP_WEB_EXPENSE_WF`, `AP_WEB_AUDIT_PROCESS`, `AP_WEB_AUDIT_QUEUE_UTILS` | **Multimodal & Conversational Expense Creation:** Creates, submits, evaluates, and enqueues an Oracle Internet Expenses (OIE) travel report from user chat text or an uploaded expense form/receipt screenshot strictly via official Oracle PL/SQL APIs. |

## 4. Gemini Enterprise Public Sector Skills & Semantic Schema Mapping

### 4.1 6 Validated Public Sector Skills
1. **Plain Language Notice Generator (`/plain-language-notice-generator`):** Rewrites complex statutory directives (`ebs_get_constituent_notice_details`, `ebs_get_document_attachment`) into clear Plain English public notices while locking mandatory federal nondiscrimination statements verbatim and blocking individual adverse-action claims containing PII.
2. **Redaction & FOIA Compliance (`/redaction-and-foia-compliance`):** Segregates public procurement and official salary records from exempt PII, IRS Section 6103 FTI, HIPAA PHI, and Exemption 7(E)/4 secrets (`ebs_search_foia_records`, `ebs_get_employee_personnel_file`), producing an inline redacted release and statutory Vaughn Index.
3. **Policy & Statute Assistant (`/policy-and-statute-assistant`):** Enforces a 3-tier statutory hierarchy (Statute > Regulation > Agency Manual) and temporal rule verification over Oracle EBS Purchasing control rules and transmittals (`ebs_get_agency_policy_rules`, `ebs_search_policy_attachments`).
4. **Document Intake Cleanup & Validation (`/document-intake-cleanup-and-validation`):** Executes a 3-Gate intake audit (Gate A optical telemetry, Gate B identity completeness against Oracle TCA `HZ_PARTIES`, and Gate C bi-weekly/semi-monthly income math) with pre-masked SSNs (`ebs_get_intake_attachments`, `ebs_verify_party_identity`).
5. **RFP Vendor Evaluation Scorer (`/rfp-vendor-evaluation-scorer`):** Compiles page-cited Mandatory Qualification matrices, Consensus Evaluation Worksheets (leaving the Evaluator Score column 100% blank for human evaluators), and Cross-Document Contradiction Logs (`ebs_get_sourcing_rfp_details`, `ebs_get_vendor_bids`).
6. **Expense Auditor (`/expense-auditor`):** Audits Oracle Internet Expenses (OIE) reports and Grant Payables invoices against 2 CFR Part 200 (Uniform Guidance) and GSA Per Diem caps (`ebs_get_expense_reports`, `ebs_get_po_invoice_match`, `ebs_create_expense_report`).

### 4.2 8 Domain Semantic Maps
* Grounds SQL discovery and tool invocation across **8 domain semantic maps**:
  1. `ap_semantic_map.json` (Accounts Payable — `AP_INVOICES_ALL`, `AP_INVOICE_LINES_ALL`, `AP_SUPPLIERS`)
  2. `ar_semantic_map.json` (Accounts Receivable — `RA_CUSTOMER_TRX_ALL`, `HZ_PARTIES`, `HZ_CUST_ACCOUNTS`)
  3. `gl_semantic_map.json` (General Ledger — `GL_JE_HEADERS`, `GL_JE_LINES`, `GL_CODE_COMBINATIONS`)
  4. `hr_semantic_map.json` (Human Resources / HRMS — `PER_ALL_PEOPLE_F`, `PER_ALL_ASSIGNMENTS_F`)
  5. `inventory_semantic_map.json` (Oracle Inventory — `MTL_SYSTEM_ITEMS_B`, `MTL_ONHAND_QUANTITIES_DETAIL`, `MTL_RESERVATIONS`)
  6. `om_semantic_map.json` (Order Management — `OE_ORDER_HEADERS_ALL`, `OE_ORDER_LINES_ALL`)
  7. `po_semantic_map.json` (Purchasing — `PO_HEADERS_ALL`, `PO_LINES_ALL`, `PO_CONTROL_RULES`)
  8. `gov_public_sector_semantic_map.json` (Public Sector Views `APPS.VW_GOV_*`, Grants `GMS_AWARDS_ALL`, Sourcing `PON_AUCTION_HEADERS_ALL`, Internet Expenses `AP_EXPENSE_REPORT_HEADERS_ALL`, and FND Attachments)

### 4.3 180 DPI Executive Charting Utilities
* Renders high-resolution **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG charts for inline display inside Gemini Enterprise (including click-to-enlarge full-resolution inspection):
  - **`render_bar_chart`**: Supports horizontal (`horizontal=True`), vertical, grouped multi-series, and stacked (`stacked=True`) bar charts with direct value and share-of-total (`%`) callouts, KPI summary badges, and optional dashed target/ceiling reference lines (`reference_value`, `reference_label`).
  - **`render_pie_chart`**: Renders an executive donut chart (`width=0.44`) with a bold center KPI total callout and a structured right-hand breakdown legend showing exact dollar/numeric values and percentages.
  - **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, Direct Min/Max/Latest milestone callout badges, and optional statutory threshold rules.
  - **`render_table`**: Produces styled executive tables and Markdown summaries.

## 5. Security, Identity & Governance Architecture

1. **End-to-End Identity Propagation:** User identity from Gemini Enterprise (`session.user_email`) is passed to `ebs_init`, which validates `FND_USER.EMAIL_ADDRESS` and invokes `FND_GLOBAL.APPS_INITIALIZE(user_id, resp_id, resp_appl_id)` and `MO_GLOBAL.SET_POLICY_CONTEXT('S', org_id)` to enforce Oracle EBS Row-Level Security (RLS) and Multi-Org Access Control (MOAC).
2. **Least-Privilege Database Schema (`APPS_AI`):** Database connections use the dedicated `APPS_AI` account (`EBSScripts/create_apps_ai.sql` and `GrantToApps_AIRESTRICTED.sql`) rather than administrative credentials.
3. **Read-Only SQL & Parameterized Tool Guardrails:** `execute_sql` enforces `readOnly: true` at the MCP server layer, and all 12 Public Sector analytical tools execute strictly parameterized `SELECT` queries against curated `APPS.VW_GOV_*` read-only views.
4. **Autonomous Database Audit Trail:** Every session initialization and PL/SQL package invocation writes an immutable audit record via `PRAGMA AUTONOMOUS_TRANSACTION` (`APPS.MCP_TOOLBOX_LOG`) into `APPS.GGLTOOLBOX$MCP_LOG`.
5. **Network & Secret Isolation:** `tools.yaml` contains zero plaintext credentials (`${EBS_DB_CONNECTION_STRING}`, `${EBS_DB_USER}`, `${EBS_DB_PASSWORD}`). Database credentials are stored in Google Cloud Secret Manager and injected at runtime into Cloud Run, which communicates with Oracle EBS (`1521/tcp`) exclusively over Direct VPC Egress.

## 6. Deployment Guidance & Step-by-Step Customer Setup

This section provides complete step-by-step instructions for deploying the customer-managed Oracle EBS MCP Server into your own Google Cloud project and connecting it to Gemini Enterprise.

### 6.1 Prerequisites & Required Permissions

#### A. Required Google Cloud APIs
Run the following command to enable all required Google Cloud APIs in your target project:

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    compute.googleapis.com \
    iam.googleapis.com \
    --project="$PROJECT_ID"
```

#### B. Required IAM Roles by Persona / Identity

| Identity / Principal | Required GCP IAM Roles | Purpose |
| :--- | :--- | :--- |
| **1. Deploying Engineer / CI Pipeline** | `roles/run.admin`<br>`roles/artifactregistry.admin`<br>`roles/cloudbuild.builds.editor`<br>`roles/secretmanager.admin`<br>`roles/iam.serviceAccountUser`<br>`roles/compute.networkViewer` | Creates the Artifact Registry repo (`ebs-mcp-repo`), builds the pre-configured MCP container image, provisions Secret Manager secrets, and deploys the Cloud Run MCP Server. |
| **2. Cloud Run Runtime Service Account** (`project-service-account@<PROJECT_ID>.iam.gserviceaccount.com`) | `roles/secretmanager.secretAccessor`<br>`roles/logging.logWriter`<br>`roles/monitoring.metricWriter` | Reads `tools.yaml` and Oracle EBS DB credentials (`EBS_DB_CONNECTION_STRING`, `EBS_DB_USER`, `EBS_DB_PASSWORD`) from Secret Manager at container startup and writes audit/operational logs. |
| **3. Cloud Run Service Agent** (`service-<PROJECT_NUMBER>@serverless-robot-prod.iam.gserviceaccount.com`) | `roles/compute.networkUser` *(on the target VPC/Subnet)*<br>`roles/artifactregistry.reader` | Attaches the Cloud Run revision to your VPC subnet via Direct VPC Egress to reach Oracle EBS (`1521/tcp`) and pulls the container image from Artifact Registry. |
| **4. Gemini Enterprise Service Account** | `roles/run.invoker` *(on the `mcp-toolbox-ebs` Cloud Run service)* | Invokes the Cloud Run MCP Server (`/mcp`) with OIDC authentication from Gemini Enterprise. |

#### C. Network & Firewall Prerequisites
- **VPC Connectivity:** Your Google Cloud VPC (`VPC_NAME` / `SUBNET_NAME`) must have private IP routing (via Cloud Interconnect, HA VPN, or VPC Peering) to your Oracle E-Business Suite database host.
- **Firewall Rule:** Allow TCP egress from your Cloud Run Direct VPC Egress subnet CIDR to your Oracle EBS Database Listener port (default `1521/tcp`).

### 6.2 Step 1: Prepare the Oracle E-Business Suite Database Tier (`EBSScripts/`)

Connect to your Oracle EBS R12.2.x database (`EBSDB`) and execute the SQL/PLSQL scripts in `EBSScripts/`:

```bash
cd EBSScripts

# 1. Create the least-privilege APPS_AI database user and role (run as SYSTEM / DBA)
sqlplus system/<SYSTEM_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @create_apps_ai.sql

# 2. Grant restricted SELECT and EXECUTE privileges to APPS_AI (run as APPS)
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @GrantToApps_AIRESTRICTED.sql

# 3. Compile the APPS.GE_EBS_MCP_TOOLS PL/SQL wrapper package and audit table (run as APPS)
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @ge_ebs_mcp_tools.pls
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @ge_ebs_mcp_tools.plb

# 4. (Optional — Public Sector Skills & Synthetic Showcase Data) Install read-only VW_GOV_* views
#    and seed v2 records via official Oracle PL/SQL APIs (run as APPS)
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @install_gov_public_sector_views.sql
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @create_v2_reports_via_oracle_apis.sql
```

### 6.3 Step 2: Choose Your Deployment Path

We support three streamlined deployment paths depending on your architecture:

#### Option A: 1-Command Artifact Registry + Cloud Run Deployment (Recommended for BYO-MCP in Gemini Enterprise)

Use this path when you want to deploy the **21-tool Oracle EBS MCP Server** into your GCP project and connect it directly to Gemini Enterprise.

1. **Create or verify your Cloud Run Runtime Service Account:**
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   export REGION="us-central1"
   export SA_NAME="project-service-account"
   export SERVICE_ACCOUNT_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

   gcloud iam service-accounts create "$SA_NAME" \
       --display-name="Oracle EBS MCP Service Account" \
       --project="$PROJECT_ID" || true

   gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
       --role="roles/secretmanager.secretAccessor"
   ```

2. **Configure `MCPServers/mcp-toolbox-ebs/.env`:**
   ```bash
   cd MCPServers/mcp-toolbox-ebs
   cp .env.example .env
   ```
   Update `.env` with your environment settings:
   ```dotenv
   PROJECT_ID=your-gcp-project-id
   REGION=us-central1
   SERVICE_ACCOUNT_EMAIL=project-service-account@your-gcp-project-id.iam.gserviceaccount.com
   SERVICE_ACCOUNT_NAME=project-service-account
   SERVICE_NAME=mcp-toolbox-ebs
   BUILD_AR_IMAGE=true
   AR_REPO_NAME=ebs-mcp-repo
   VPC_NAME=your-vpc-network
   SUBNET_NAME=your-subnet-us-central1
   EBS_DB_CONNECTION_STRING=10.0.0.10:1521/EBSDB
   EBS_DB_USER=apps_ai
   EBS_DB_PASSWORD=your-apps-ai-password
   SECRET_NAME=mcp-toolbox-ebs-secret
   ```

3. **Execute `./deploy.sh`:**
   ```bash
   ./deploy.sh
   ```
   **What `./deploy.sh` automates:**
   - Creates the Docker repository `ebs-mcp-repo` in **Google Artifact Registry** (`${REGION}-docker.pkg.dev/${PROJECT_ID}/ebs-mcp-repo`) if it does not exist.
   - Builds `MCPServers/mcp-toolbox-ebs/Dockerfile` (packaging `genai-toolbox` + the 21 parameterized tools in `tools.yaml` with zero plaintext credentials) via **Cloud Build** and pushes `mcp-toolbox-ebs:latest` to your Artifact Registry.
   - Creates/updates **Secret Manager** secrets for `EBS_DB_CONNECTION_STRING`, `EBS_DB_USER`, `EBS_DB_PASSWORD`, and `tools.yaml`.
   - Deploys `mcp-toolbox-ebs` to **Cloud Run** with Direct VPC Egress (`--network` / `--subnet`) and outputs the live MCP endpoint (`https://mcp-toolbox-ebs-<hash>-uc.a.run.app/mcp`).

#### Option B: 1-Click Guided Deployment in Google Cloud Shell

Click the button below to clone this repository directly into **Google Cloud Shell** and launch an interactive step-by-step tutorial (`tutorial.md`):

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-ebs-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

#### Option C: Automated Terraform & Makefile Deployment

Use this path when you want to provision the Artifact Registry repository, Secret Manager secrets, and Cloud Run Oracle EBS MCP Server using Terraform and `Makefile` automation:

```bash
# 1. Verify GCP access and initialize the GCS Terraform state backend
make verify-gcp-access PROJECT_ID=your-gcp-project-id REGION=us-central1
make init PROJECT_ID=your-gcp-project-id REGION=us-central1

# 2. Prompt for Oracle EBS DB credentials, VPC, and Subnet (saved to infra.auto.tfvars)
make set_config_mcp_servers

# 3. Build & deploy the Oracle EBS MCP Server to Artifact Registry & Cloud Run
make plan_mcp_server PROJECT_ID=your-gcp-project-id REGION=us-central1
make deploy_mcp_server PROJECT_ID=your-gcp-project-id REGION=us-central1
```

### 6.4 Step 3: Verify Deployment & Register with Gemini Enterprise

1. **Verify the Cloud Run MCP Server is healthy:**
   ```bash
   MCP_URL=$(gcloud run services describe mcp-toolbox-ebs --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
   echo "MCP Server Endpoint: ${MCP_URL}/mcp"
   ```
2. **Test MCP Tool Discovery (`tools/list`):**
   ```bash
   curl -s -X POST "${MCP_URL}/mcp" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | jq '.result.tools[].name'
   ```
   You should see all **21 Oracle EBS MCP tools** returned.
3. **Connect to Gemini Enterprise:**
   - Register `${MCP_URL}/mcp` as your customer-managed MCP Server endpoint in Gemini Enterprise to enable live Oracle EBS R12.2 data access across the 6 Public Sector Skills.
