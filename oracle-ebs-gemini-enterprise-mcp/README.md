# Oracle E-Business Suite (EBS) Gemini Enterprise MCP Server

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-ebs-gemini-enterprise-mcp`  
> **Release:** Customer-Managed Cloud Run BYO-MCP Architecture (21 MCP Tools, Domain Semantic Maps & High-Resolution Charting)  
> **Target Audience:** Software Engineers, Database Administrators (DBAs), and Cloud Architects  

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-ebs-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

## 1. MCP Overview

This repository provides a production-ready reference architecture connecting **Google Cloud Gemini Enterprise** directly to **Oracle E-Business Suite (EBS R12.2.x)** via a customer-managed Model Context Protocol (`genai-toolbox`) server deployed on Google Cloud Run.

It supports end-to-end read and write operations across core Oracle E-Business Suite modules—including Procure-to-Pay (P2P), Order-to-Cash (O2C), Inventory (`MTL_ONHAND_QUANTITIES_DETAIL`, `MTL_RESERVATIONS`), General Ledger (`GL_JE_HEADERS`), Human Resources (`PER_ALL_PEOPLE_F`), Purchasing (`PO_HEADERS_ALL`, `PO_CONTROL_RULES`), Sourcing (`PON_AUCTION_HEADERS_ALL`, `PON_BID_HEADERS`), Grants Accounting (`GMS_AWARDS_ALL`), Trading Community Architecture (`HZ_PARTIES`), FND Document Attachments (`FND_DOCUMENTS_LONG_TEXT`), and Oracle Internet Expenses (OIE `AP_EXPENSE_REPORT_HEADERS_ALL`).

### Key Capabilities Included in This Release
1. **Containerized MCP Toolbox Server (`MCPServers/mcp-toolbox-ebs/`):** A Go-based Model Context Protocol (`genai-toolbox`) service packaged into your GCP project's **Google Artifact Registry** (`ebs-mcp-repo`) and deployed on **Google Cloud Run** over Direct VPC Egress to the Oracle EBS database tier (`EBSDB`).
2. **21 Production-Ready MCP Tools (`tools.yaml`):** A unified catalog of 21 read and write tools covering session context initialization (`ebs_init` via `FND_GLOBAL.APPS_INITIALIZE` and `MO_GLOBAL`), responsibility discovery (`list_ebs_responsibilities`), active session inspection (`list_ebs_current_context`), read-only analytical SQL execution (`execute_sql`), inventory receipt creation (`create_onhand`), stock reservation (`reserve_item`, `delete_reserve_item`), Accounts Payable invoice creation (`create_ap_invoice`), multimodal/conversational OIE expense report creation (`ebs_create_expense_report`), and 12 parameterized SQL query tools spanning Receivables, Purchasing, Sourcing, HRMS, TCA, Grants, Payables, and FND Document Attachments.
3. **Database Tier Integration & Read-Only Analytical Views (`EBSScripts/`):**
   - Custom PL/SQL wrapper package (`APPS.GE_EBS_MCP_TOOLS` in `ge_ebs_mcp_tools.pls` / `.plb`) encapsulating Oracle EBS public APIs (including `create_expense_report` across 7 official Oracle Internet Expenses, AOL Attachment, Workflow, and Audit PL/SQL APIs) and autonomous audit logging (`APPS.GGLTOOLBOX$MCP_LOG`).
   - Least-privilege database user provisioning (`APPS_AI` via `create_apps_ai.sql`, `GrantToApps_AI.sql`, and `GrantToApps_AIRESTRICTED.sql`).
   - 7 read-only analytical views across 15 core Oracle EBS tables (created via `install_gov_public_sector_views.sql`) with an isolated synthetic test dataset (seeded via `create_v2_reports_via_oracle_apis.sql` using `IDs 990001–990999`) that preserves 100% of baseline Vision data.
4. **Multi-Agent ADK Orchestration, Semantic Maps & 180 DPI Charting (`Agents/`):**
   - Curated JSON schema definitions (`semantic_maps/`) covering Accounts Payable, Accounts Receivable, General Ledger, Human Resources, Inventory, Order Management, Purchasing, Sourcing, Grants, and Security, paired with `180 DPI` (`12.0" x 6.6"` widescreen) chart generation (`EBS_Graphs_Agent`).

## 2. End-to-End Architecture Overview

```text
+----------------------------------------------------------------------------------------------------------+
|                         ORACLE EBS GEMINI ENTERPRISE MCP ARCHITECTURE                                    |
|                                                                                                          |
|  [ Gemini Enterprise ]                                                                                   |
|       |  * Natural Language ERP Queries, Document Analysis & Transactional Actions                       |
|       |  * Grounded Tool Execution & Inline Visual Analytics                                             |
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
|       |  * Read-Only Analytical Views across 15 Core EBS Tables (AR, AP, PO, PON, HR, TCA, GMS, FND)     |
+----------------------------------------------------------------------------------------------------------+
```

## 3. Complete Inventory of 21 MCP Tools (`MCPServers/mcp-toolbox-ebs/tools.yaml`)

| # | Tool Name | Tool Kind | Target Oracle EBS Package / View / Tables | Description |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **`ebs_init`** | `oracle-sql` | `ge_ebs_mcp_tools.ebs_initialize_context` | **Session Initialization:** Resolves user email in `FND_USER`, validates active responsibility in `FND_USER_RESP_GROUPS_DIRECT`, invokes `FND_GLOBAL.APPS_INITIALIZE`, initializes Multi-Org (`MO_GLOBAL.INIT`), and sets policy context (`MO_GLOBAL.SET_POLICY_CONTEXT('S', l_ou_id)`). |
| **2** | **`list_ebs_responsibilities`** | `oracle-sql` | `FND_USER`, `FND_RESPONSIBILITY_VL`, `HR_OPERATING_UNITS` | **Role Discovery:** Lists valid responsibilities, application short names, and operating units assigned to an EBS user email prior to session initialization. |
| **3** | **`list_ebs_current_context`** | `oracle-sql` | `FND_GLOBAL` session state inspection | **Context Verification:** Returns active `user_id`, `responsibility_name`, `security_group_name`, `application_short_name`, and `operating_unit_id`. |
| **4** | **`execute_sql`** | `oracle-execute-sql` | Read-only SQL execution engine (`readOnly: true`) | **Analytical Discovery:** Executes read-only `SELECT` queries against Oracle EBS tables and views under the active session security context. |
| **5** | **`create_onhand`** | `oracle-sql` | `ge_ebs_mcp_tools.create_onhand` &rarr; `INV_TXN_MANAGER_PUB` | **Inventory Receipt:** Creates an Oracle Inventory Miscellaneous Receipt via `MTL_TRANSACTIONS_INTERFACE` and `INV_TXN_MANAGER_PUB.process_Transactions`. |
| **6** | **`reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.reserve_item` &rarr; `INV_RESERVATION_PUB` | **Inventory Reservation:** Creates an item reservation against available on-hand warehouse stock. |
| **7** | **`delete_reserve_item`** | `oracle-sql` | `ge_ebs_mcp_tools.delete_reservation` &rarr; `INV_RESERVATION_PUB` | **Reservation Release:** Deletes and releases an existing inventory reservation by `reservation_id`. |
| **8** | **`create_ap_invoice`** | `oracle-sql` | `ge_ebs_mcp_tools.create_ap_invoice` &rarr; `AP_INVOICES_INTERFACE` | **Payables Invoicing:** Programmatically validates and creates an Accounts Payable vendor invoice record. |
| **9** | **`ebs_create_expense_report`** | `oracle-sql` | `ge_ebs_mcp_tools.create_expense_report` &rarr; `AP_WEB_DB_EXPRPT_PKG`, `AP_EXPENSE_REPORT_HEADERS_PKG`, `AP_WEB_DB_EXPLINE_PKG`, `AP_WEB_DB_EXPDIST_PKG`, `FND_WEBATTCH`, `AP_WEB_EXPENSE_WF`, `AP_WEB_AUDIT_PROCESS`, `AP_WEB_AUDIT_QUEUE_UTILS` | **Multimodal & Conversational Expense Creation:** Creates, submits, evaluates, and enqueues an Oracle Internet Expenses (OIE) travel report from user chat text or an uploaded expense form/receipt screenshot strictly via official Oracle PL/SQL APIs. |
| **10** | **`ebs_get_constituent_notice_details`** | `oracle-sql` | `APPS.VW_GOV_CONSTITUENT_NOTICES` (`RA_CUSTOMER_TRX_ALL`, `FND_DOCUMENTS_LONG_TEXT`) | **Receivables & Account Notices:** Retrieves Accounts Receivable transaction notices, effective dates, billing metadata, and full long-text notice bodies. |
| **11** | **`ebs_get_document_attachment`** | `oracle-sql` | `FND_DOCUMENTS`, `FND_DOCUMENTS_TL`, `FND_DOCUMENTS_LONG_TEXT`, `FND_ATTACHED_DOCUMENTS` | **FND Document Attachments:** Fetches full text and attachment metadata for documents linked to Oracle EBS transactions and entities. |
| **12** | **`ebs_search_foia_records`** | `oracle-sql` | `APPS.VW_GOV_FOIA_RECORDS` (`PO_HEADERS_ALL`, `PER_ALL_PEOPLE_F`, `FND_DOCUMENTS_LONG_TEXT`) | **Contract & Compliance Record Search:** Searches procurement contracts, audit exhibits, and attached compliance records by document reference or keyword. |
| **13** | **`ebs_get_employee_personnel_file`** | `oracle-sql` | `APPS.VW_GOV_FOIA_RECORDS` (`PER_ALL_PEOPLE_F`, `FND_DOCUMENTS_LONG_TEXT`) | **HRMS Personnel Records:** Retrieves employee HR assignment attributes and attached personnel file exhibits from Oracle Human Resources. |
| **14** | **`ebs_get_agency_policy_rules`** | `oracle-sql` | `APPS.VW_GOV_AGENCY_POLICY_RULES` (`PO_CONTROL_GROUPS_ALL`, `PO_CONTROL_RULES`) | **Purchasing Approval Rules:** Queries structured procurement approval tiers, control groups, and authorization dollar limits in Oracle Purchasing. |
| **15** | **`ebs_search_policy_attachments`** | `oracle-sql` | `APPS.VW_GOV_AGENCY_POLICY_RULES` (`FND_DOCUMENTS_LONG_TEXT`) | **Policy Document Search:** Searches policy manuals, compliance guidelines, and procurement rule attachments stored in `FND_DOCUMENTS_LONG_TEXT`. |
| **16** | **`ebs_get_intake_attachments`** | `oracle-sql` | `APPS.VW_GOV_INTAKE_DOCUMENTS` (`HZ_PARTIES`, `FND_DOCUMENTS_LONG_TEXT`) | **TCA Intake Document Inspection:** Retrieves staged application packets, optical quality telemetry, OCR confidence scores, and extracted financial/income fields. |
| **17** | **`ebs_verify_party_identity`** | `oracle-sql` | `APPS.VW_GOV_INTAKE_DOCUMENTS` (`HZ_PARTIES`) | **TCA Party Identity Verification:** Cross-checks party legal name, pre-masked tax/SSN identifier (`***-**-XXXX`), and verified address against Oracle Trading Community Architecture (`HZ_PARTIES`) master records. |
| **18** | **`ebs_get_sourcing_rfp_details`** | `oracle-sql` | `APPS.VW_GOV_SOURCING_RFPS` (`PON_AUCTION_HEADERS_ALL`, `FND_DOCUMENTS_LONG_TEXT`) | **Oracle Sourcing RFPs:** Retrieves Oracle Sourcing RFP solicitation headers, addenda, mandatory qualification requirements, and evaluation criteria. |
| **19** | **`ebs_get_vendor_bids`** | `oracle-sql` | `APPS.VW_GOV_SOURCING_RFPS` (`PON_BID_HEADERS`, `FND_DOCUMENTS_LONG_TEXT`) | **Oracle Sourcing Vendor Bids:** Retrieves competing vendor bid headers, pricing schedules, qualification evidence, and proposal sections for bid comparison. |
| **20** | **`ebs_get_expense_reports`** | `oracle-sql` | `APPS.VW_GOV_EXPENSE_REPORTS` (`AP_EXPENSE_REPORT_HEADERS_ALL`, `AP_EXPENSE_REPORT_LINES_ALL`) | **OIE Expense Reports:** Retrieves Oracle Internet Expenses travel headers, itemized expense lines, policy notes, and attached receipt OCR folios. |
| **21** | **`ebs_get_po_invoice_match`** | `oracle-sql` | `APPS.VW_GOV_PO_INVOICE_MATCH` (`AP_INVOICES_ALL`, `PO_HEADERS_ALL`, `GMS_AWARDS_ALL`) | **PO, Invoice & Grant Matching:** Retrieves Accounts Payable vendor invoices, matched Purchase Orders, quote notes, and Oracle Grants Accounting (`GMS_AWARDS_ALL`) award metadata. |

## 4. Security, Identity & Governance Architecture

1. **End-to-End Identity Propagation:** User identity from Gemini Enterprise (`session.user_email`) is passed to `ebs_init`, which validates `FND_USER.EMAIL_ADDRESS` and invokes `FND_GLOBAL.APPS_INITIALIZE(user_id, resp_id, resp_appl_id)` and `MO_GLOBAL.SET_POLICY_CONTEXT('S', org_id)` to enforce Oracle EBS Row-Level Security (RLS) and Multi-Org Access Control (MOAC).
2. **Least-Privilege Database Schema (`APPS_AI`):** Database connections use the dedicated `APPS_AI` account (`EBSScripts/create_apps_ai.sql` and `GrantToApps_AIRESTRICTED.sql`) rather than administrative credentials.
3. **Read-Only SQL & Parameterized Tool Guardrails:** `execute_sql` enforces `readOnly: true` at the MCP server layer, and all 12 parameterized analytical query tools execute strictly read-only `SELECT` statements against curated `APPS.VW_GOV_*` views and standard FND attachment tables (`FND_DOCUMENTS`, `FND_DOCUMENTS_TL`, `FND_DOCUMENTS_LONG_TEXT`, `FND_ATTACHED_DOCUMENTS`).
4. **Autonomous Database Audit Trail:** Every session initialization and PL/SQL package invocation writes an immutable audit record via `PRAGMA AUTONOMOUS_TRANSACTION` (`APPS.MCP_TOOLBOX_LOG`) into `APPS.GGLTOOLBOX$MCP_LOG`.
5. **Network & Secret Isolation:** `tools.yaml` contains zero plaintext credentials (`${EBS_DB_CONNECTION_STRING}`, `${EBS_DB_USER}`, `${EBS_DB_PASSWORD}`). Database credentials are stored in Google Cloud Secret Manager and injected at runtime into Cloud Run, which communicates with Oracle EBS (`1521/tcp`) exclusively over Direct VPC Egress.

## 5. Deployment Guidance & Step-by-Step Customer Setup

This section provides step-by-step instructions for deploying the customer-managed Oracle EBS MCP Server into your own Google Cloud project and connecting it to Gemini Enterprise.

### 5.1 Prerequisites & Required Permissions

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

### 5.2 Step 1: Prepare the Oracle E-Business Suite Database Tier (`EBSScripts/`)

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

# 4. Install read-only analytical views and (optional) seed synthetic test records via official Oracle PL/SQL APIs (run as APPS)
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @install_gov_public_sector_views.sql
sqlplus apps/<APPS_PASSWORD>@<EBS_HOST>:1521/<EBS_SID> @create_v2_reports_via_oracle_apis.sql
```

### 5.3 Step 2: Choose Your Deployment Path

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

### 5.4 Step 3: Verify Deployment & Register with Gemini Enterprise

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
   - Register `${MCP_URL}/mcp` as your customer-managed MCP Server endpoint in Gemini Enterprise to enable live Oracle E-Business Suite R12.2 data access and transactional workflows.
