# Oracle PeopleSoft FSCM 9.2 Gemini Enterprise MCP Server

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-peoplesoft-gemini-enterprise-mcp`  
> **Release:** Customer-Managed Cloud Run BYO-MCP Architecture (20 MCP Tools, Domain Semantic Maps & High-Resolution Charting)  
> **Target Audience:** Software Engineers, Database Administrators (DBAs), and Cloud Architects  

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-peoplesoft-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

## 1. MCP Overview

This repository provides a production-ready reference architecture connecting **Google Cloud Gemini Enterprise** directly to **Oracle PeopleSoft Financials and Supply Chain Management (FSCM) 9.2 (PeopleTools 8.62)** via a customer-managed Model Context Protocol (`genai-toolbox`) server deployed on Google Cloud Run.

It supports end-to-end read and write operations across core PeopleSoft FSCM 9.2 modules—including Procure-to-Pay (P2P), Accounts Payable (`PS_VOUCHER`, `PS_VCHR_HDR_STG`, `PS_VCHR_LINE_STG`, `PS_VCHR_DIST_STG`), Accounts Receivable & Customer Management (`PS_CUSTOMER`, `PS_ITEM`), Inventory (`PS_PHYSICAL_INV`, `PS_BU_ITEMS_INV`), General Ledger (`PS_JRNL_HEADER`), Purchasing (`PS_PO_HDR`), Strategic Sourcing (`PS_AUC_HDR`), Travel & Expenses (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`), Grants Management (`PS_GM_AWARD`), and PeopleTools Security (`PSOPRDEFN`, `PSROLEUSER`).

### Key Capabilities Included in This Release
1. **Containerized MCP Toolbox Server (`MCPServers/mcp-toolbox-peoplesoft/`):** A Go-based Model Context Protocol (`genai-toolbox`) service packaged into your project's **Google Artifact Registry** (`peoplesoft-mcp-repo`) and deployed on **Google Cloud Run** over Direct VPC Egress (`oracle-peoplesoft-toolkit-network`) to the Oracle PeopleSoft 9.2 database tier (`EP92U055`).
2. **20 Production-Ready MCP Tools (`tools.yaml`):** A unified catalog of 20 read and write tools covering session context initialization (`ps_init` via `SYSADM.GE_PSFT_MCP_TOOLS.ps_initialize_context`), role discovery (`list_ps_roles` across `PSOPRDEFN` and `PSROLEUSER`), active session inspection (`list_ps_current_context`), read-only analytical SQL execution (`execute_sql`), inventory receipt creation (`create_onhand`), stock reservation (`reserve_item`, `delete_reserve_item`), 3-table Accounts Payable Voucher Build staging (`create_ap_voucher`), and 12 parameterized SQL query tools spanning Customer Notices, Purchasing, Strategic Sourcing, Workforce/HR, Customer Master (`PS_CUSTOMER`), Travel & Expenses, Grants, Payables, and Document Attachments.
3. **Database Tier Integration & Read-Only Analytical Views (`PSFTScripts/`):**
   - Custom PL/SQL wrapper package (`SYSADM.GE_PSFT_MCP_TOOLS` in `ge_psft_mcp_tools.sql`) encapsulating PeopleSoft transactional staging tables (`PS_VCHR_HDR_STG`, `PS_VCHR_LINE_STG`, `PS_VCHR_DIST_STG`, `PS_PHYSICAL_INV`) and autonomous audit logging (`SYSADM.GGLTOOLBOX$MCP_LOG`).
   - Least-privilege database user provisioning (`PSFT_AI` via `create_psft_ai.sql` with `SYSADM.PSFT_AI_AFTER_LOGON_TRG` logon trigger).
   - 7 read-only analytical views (`SYSADM.VW_GOV_*`) across delivered PeopleSoft FSCM 9.2 tables (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_EX_SHEET_DIST`, `PS_VOUCHER`, `PS_PO_HDR`, `PS_AUC_HDR`, `PS_GM_AWARD`, `PS_CUSTOMER`) and `SYSADM.PS_GOV_*` staging tables (created via `install_gov_public_sector_views.sql`) with an isolated synthetic dataset (seeded via `install_gov_psft_mcp_and_seed.sql` using `IDs 990001–990999` and `-V2` records) that preserves 100% of baseline PUM demo data.
4. **Multi-Agent ADK Orchestration, Semantic Maps & 180 DPI Charting (`Agents/`):**
   - Curated JSON schema definitions (`semantic_maps/`) covering Accounts Payable, Accounts Receivable, General Ledger, PeopleTools Security & Workforce, Inventory, Travel/Expenses & Grants, and Purchasing & Strategic Sourcing, paired with `180 DPI` (`12.0" x 6.6"` widescreen) chart generation (`PSFT_Graphs_Agent`).

## 2. End-to-End Architecture Overview

```text
+----------------------------------------------------------------------------------------------------------+
|                      ORACLE PEOPLESOFT 9.2 GEMINI ENTERPRISE MCP ARCHITECTURE                            |
|                                                                                                          |
|  [ Gemini Enterprise ]                                                                                   |
|       |  * Natural Language ERP Queries, Document Analysis & Transactional Actions                       |
|       |  * Grounded Tool Execution & Inline Visual Analytics                                             |
|       |                                                                                                  |
|       | 1. Streamable HTTP MCP Protocol (/mcp) + OIDC Bearer Token + User Identity Context               |
|       v                                                                                                  |
|  [ Cloud Run: mcp-toolbox-peoplesoft ] (GenAI Toolbox for Databases)                                     |
|       |  * Pre-Configured Image in Customer Artifact Registry (peoplesoft-mcp-repo)                      |
|       |  * Zero Plaintext Credentials in tools.yaml (Secret Manager Env Var Injection)                   |
|       |  * Isolated via Direct VPC Egress (oracle-peoplesoft-toolkit-network)                            |
|       |                                                                                                  |
|       | 2. Oracle Net8 / SQL*Net Connection (TCP Port 1521 -> PDB EP92U055)                              |
|       v                                                                                                  |
|  [ Oracle PeopleSoft FSCM 9.2 Update Image 55 Database Tier (EP92U055) ]                                 |
|       |  * Schema: SYSADM / PSFT_AI (Least-Privilege Role & Logon Trigger)                               |
|       |  * PL/SQL Wrapper: SYSADM.GE_PSFT_MCP_TOOLS + Audit Table SYSADM.GGLTOOLBOX$MCP_LOG              |
|       |  * Core Tables: PS_EX_SHEET_HDR, PS_VOUCHER, PS_PO_HDR, PS_AUC_HDR, PS_GM_AWARD, PS_CUSTOMER     |
|       |  * Read-Only Analytical Views across Core PeopleSoft FSCM 9.2 Modules                            |
+----------------------------------------------------------------------------------------------------------+
```

## 3. Complete Inventory of 20 MCP Tools (`MCPServers/mcp-toolbox-peoplesoft/tools.yaml`)

| # | Tool Name | Tool Kind | Target PeopleSoft Package / View / Tables | Description |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **`ps_init`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.ps_initialize_context` | **Session Initialization:** Resolves user email in `PSOPRDEFN` (`VP1`), validates active role in `PSROLEUSER`, and sets active Business Unit (`US001` / `EGV05`) and TableSet ID (`SHARE`) in `PS_MCP_SESSION_CTX`. |
| **2** | **`list_ps_roles`** | `oracle-sql` | `PSOPRDEFN`, `PSROLEUSER`, `PSROLEDEFN` | **Role Discovery:** Lists valid PeopleTools security roles, operator descriptions, and default Business Unit / SetID assigned to a user email or OPRID. |
| **3** | **`list_ps_current_context`** | `oracle-sql` | `PS_MCP_SESSION_CTX` session state inspection | **Context Verification:** Returns active `OPRID`, `OPERATOR_NAME`, `EMAILID`, `EMPLID`, `BUSINESS_UNIT`, `SETID`, and `ROLENAME` for the current session. |
| **4** | **`execute_sql`** | `oracle-execute-sql` | Read-only SQL execution engine (`readOnly: true`) | **Analytical Discovery:** Executes read-only `SELECT` queries against Oracle PeopleSoft 9.2 tables and views under the active session security context. |
| **5** | **`create_onhand`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.create_onhand` | **Inventory Receipt:** Increments on-hand inventory quantity in PeopleSoft Inventory (`PS_PHYSICAL_INV` / `PS_BU_ITEMS_INV`). |
| **6** | **`reserve_item`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.reserve_item` | **Inventory Reservation:** Creates an item reservation against available on-hand warehouse stock in `PS_MCP_INV_RESERVATIONS`. |
| **7** | **`delete_reserve_item`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.delete_reservation` | **Reservation Release:** Cancels and releases an existing inventory reservation by `reservation_id`. |
| **8** | **`create_ap_voucher`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.create_ap_voucher` | **Payables Voucher Build Staging:** Programmatically stages a complete 3-table Accounts Payable voucher (`PS_VCHR_HDR_STG`, `PS_VCHR_LINE_STG`, `PS_VCHR_DIST_STG`) for the PeopleSoft Voucher Build (`AP_VCHRBLD`) Application Engine process. |
| **9** | **`ps_get_case_determination`** | `oracle-sql` | `SYSADM.VW_GOV_CONSTITUENT_NOTICES` | **Customer & Account Notices:** Retrieves customer account notices, determination headers, effective dates, and full notice text. |
| **10** | **`ps_get_attachment_content`** | `oracle-sql` | `PS_GOV_FND_DOCUMENTS`, `PS_GOV_FND_DOCS_LONG_TEXT` | **Document Attachments:** Fetches full text and attachment metadata for documents linked to PeopleSoft transactions and records. |
| **11** | **`ps_search_foia_records`** | `oracle-sql` | `SYSADM.VW_GOV_FOIA_RECORDS` (`PS_PO_HDR`) | **Contract & Compliance Record Search:** Searches procurement contracts, audit exhibits, and attached compliance records by document reference or keyword. |
| **12** | **`ps_get_employee_record_documents`** | `oracle-sql` | `SYSADM.VW_GOV_FOIA_RECORDS` (`PSOPRDEFN`) | **Workforce & Personnel Records:** Retrieves personnel attributes and attached file exhibits linked to PeopleSoft operator and employee records. |
| **13** | **`ps_get_policy_catalog_rules`** | `oracle-sql` | `SYSADM.VW_GOV_AGENCY_POLICY_RULES` | **Purchasing Approval Rules:** Queries structured procurement approval tiers, control groups, and authorization dollar limits in PeopleSoft Purchasing. |
| **14** | **`ps_search_policy_documents`** | `oracle-sql` | `SYSADM.VW_GOV_AGENCY_POLICY_RULES` | **Policy Document Search:** Searches policy manuals, compliance guidelines, and procurement rule attachments. |
| **15** | **`ps_get_constituent_documents`** | `oracle-sql` | `SYSADM.VW_GOV_INTAKE_DOCUMENTS` (`PS_CUSTOMER`) | **Customer Intake Document Inspection:** Retrieves staged application packets, optical quality telemetry, OCR confidence scores, and extracted financial/income fields. |
| **16** | **`ps_verify_constituent_data`** | `oracle-sql` | `SYSADM.VW_GOV_INTAKE_DOCUMENTS` (`PS_CUSTOMER`) | **Customer Identity Verification:** Cross-checks legal name, pre-masked tax/SSN identifier (`***-**-XXXX`), and verified address against PeopleSoft Customer (`PS_CUSTOMER`) master records. |
| **17** | **`ps_get_strategic_sourcing_event`** | `oracle-sql` | `SYSADM.VW_GOV_SOURCING_RFPS` (`PS_AUC_HDR`) | **Strategic Sourcing RFPs:** Retrieves PeopleSoft Strategic Sourcing RFP event headers (`AUC_ID`), addenda, mandatory qualification requirements, and evaluation criteria. |
| **18** | **`ps_get_vendor_responses`** | `oracle-sql` | `SYSADM.VW_GOV_SOURCING_RFPS` (`PS_AUC_HDR`) | **Strategic Sourcing Vendor Bids:** Retrieves competing vendor bid responses, pricing schedules, qualification evidence, and proposal sections for bid comparison. |
| **19** | **`ps_get_expense_sheets`** | `oracle-sql` | `SYSADM.VW_GOV_EXPENSE_REPORTS` (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`) | **Travel & Expense Sheets:** Retrieves PeopleSoft Travel & Expenses sheet headers (`SHEET_ID`), itemized expense lines, policy notes, and attached receipt OCR folios. |
| **20** | **`ps_get_voucher_details`** | `oracle-sql` | `SYSADM.VW_GOV_PO_INVOICE_MATCH` (`PS_VOUCHER`, `PS_PO_HDR`, `PS_GM_AWARD`) | **PO, Voucher & Grant Matching:** Retrieves PeopleSoft Accounts Payable vendor vouchers (`VOUCHER_ID`), matched Purchase Orders (`PO_ID`), quote notes, and PeopleSoft Grants (`PS_GM_AWARD`) award metadata. |

## 4. Security, Identity & Governance Architecture

1. **End-to-End Identity Propagation:** User identity from Gemini Enterprise (`session.user_email`) is passed to `ps_init`, which validates `PSOPRDEFN.EMAILID` (`VP1`), verifies active role assignments in `PSROLEUSER`, and sets the active Business Unit (`US001` / `EGV05`) and TableSet ID (`SHARE`) in `SYSADM.PS_MCP_SESSION_CTX`.
2. **Least-Privilege Database Schema (`PSFT_AI`):** Database connections use the dedicated `PSFT_AI` account (`PSFTScripts/create_psft_ai.sql` with `SYSADM.PSFT_AI_AFTER_LOGON_TRG` automatic schema context trigger) rather than administrative credentials.
3. **Read-Only SQL & Parameterized Tool Guardrails:** `execute_sql` enforces `readOnly: true` at the MCP server layer, and all 12 parameterized analytical query tools execute strictly read-only `SELECT` statements against curated `SYSADM.VW_GOV_*` views and `SYSADM.PS_GOV_FND_*` attachment tables.
4. **Autonomous Database Audit Trail:** Every session initialization and PL/SQL package invocation writes an immutable audit record via `PRAGMA AUTONOMOUS_TRANSACTION` (`SYSADM.MCP_TOOLBOX_LOG`) into `SYSADM.GGLTOOLBOX$MCP_LOG`.
5. **Network & Secret Isolation:** `tools.yaml` contains zero plaintext credentials (`${PSFT_DB_CONNECTION_STRING}`, `${PSFT_DB_USER}`, `${PSFT_DB_PASSWORD}`). Database credentials are stored in Google Cloud Secret Manager and injected at runtime into Cloud Run, which communicates with Oracle PeopleSoft (`1521/tcp`) exclusively over Direct VPC Egress.

## 5. Deployment Guidance & Step-by-Step Customer Setup

This section provides step-by-step instructions for deploying the customer-managed Oracle PeopleSoft 9.2 MCP Server into your own Google Cloud project and connecting it to Gemini Enterprise.

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
| **1. Deploying Engineer / CI Pipeline** | `roles/run.admin` *(or `roles/run.developer` + `roles/iam.securityAdmin`)*<br>`roles/artifactregistry.admin`<br>`roles/cloudbuild.builds.editor`<br>`roles/secretmanager.admin`<br>`roles/iam.serviceAccountUser`<br>`roles/compute.networkViewer` | Creates the Artifact Registry repo (`peoplesoft-mcp-repo`), builds the pre-configured MCP container image, provisions Secret Manager secrets, and deploys the Cloud Run MCP Server. |
| **2. Cloud Run Runtime Service Account** (`project-service-account@<PROJECT_ID>.iam.gserviceaccount.com`) | `roles/secretmanager.secretAccessor`<br>`roles/logging.logWriter`<br>`roles/monitoring.metricWriter` | Reads `tools.yaml` and Oracle PeopleSoft DB credentials (`PSFT_DB_CONNECTION_STRING`, `PSFT_DB_USER`, `PSFT_DB_PASSWORD`) from Secret Manager at container startup and writes audit/operational logs. |
| **3. Cloud Run Service Agent** (`service-<PROJECT_NUMBER>@serverless-robot-prod.iam.gserviceaccount.com`) | `roles/compute.networkUser` *(on the target VPC/Subnet)*<br>`roles/artifactregistry.reader` | Attaches the Cloud Run revision to your VPC subnet via Direct VPC Egress to reach Oracle PeopleSoft (`1521/tcp`) and pulls the container image from Artifact Registry. |
| **4. Cloud Build Service Account** (`<PROJECT_NUMBER>-compute@developer.gserviceaccount.com` or custom `CLOUD_BUILD_SERVICE_ACCOUNT`) | `roles/cloudbuild.builds.builder`<br>`roles/artifactregistry.writer`<br>`roles/logging.logWriter` | Required when executing regional Cloud Build (`gcloud builds submit --region=$REGION`) inside Assured Workloads projects (`constraints/gcp.resourceLocations`). |
| **5. Gemini Enterprise Discovery Engine Service Agent** (`service-<PROJECT_NUMBER>@gcp-sa-discoveryengine.iam.gserviceaccount.com`) | `roles/run.invoker` *(on the `mcp-toolbox-peoplesoft` Cloud Run service or at the project level)* | Invokes the authenticated Cloud Run MCP Server (`/mcp`) with OIDC authentication from Gemini Enterprise. |

#### C. Network & Firewall Prerequisites
- **VPC Connectivity:** Your Google Cloud VPC (`VPC_NAME` / `SUBNET_NAME`) must have private IP routing (via Cloud Interconnect, HA VPN, or VPC Peering) to your Oracle PeopleSoft 9.2 database host.
- **Private Google Access (Required for Assured Workloads Zero-External-IP Environments):** When `constraints/compute.vmExternalIpAccess` is enforced, enable Private Google Access on the target subnet so zero-external-IP Oracle PeopleSoft Compute Engine VMs and Cloud Run Direct VPC Egress can reach Google APIs over internal routes:
  ```bash
  gcloud compute networks subnets update "$SUBNET_NAME" \
      --region="$REGION" \
      --enable-private-ip-google-access \
      --project="$PROJECT_ID"
  ```
- **Firewall Rule:** Allow TCP egress from your Cloud Run Direct VPC Egress subnet CIDR to your Oracle PeopleSoft Database Listener port (default `1521/tcp`).

### 5.2 Step 1: Prepare the Oracle PeopleSoft FSCM 9.2 Database Tier (`PSFTScripts/`)

Connect to your Oracle PeopleSoft FSCM 9.2 database (`EP92U055`) and execute the SQL/PLSQL scripts in `PSFTScripts/`:

```bash
cd PSFTScripts

# 1. Create the least-privilege PSFT_AI database user, role, and logon trigger (run as SYS / DBA; SQL*Plus prompts for the PSFT_AI password)
sqlplus sys/<SYS_PASSWORD>@<PSFT_HOST>:1521/EP92U055 as sysdba @create_psft_ai.sql

# 2. Compile the SYSADM.GE_PSFT_MCP_TOOLS PL/SQL wrapper package and audit table (run as SYSADM)
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @ge_psft_mcp_tools.sql

# 3. Install read-only analytical views and (optional) seed synthetic test records across delivered PS_* and PS_GOV_* tables (run as SYSADM)
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @install_gov_psft_mcp_and_seed.sql
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @install_gov_public_sector_views.sql
```

### 5.3 Step 2: Choose Your Deployment Path

We support three streamlined deployment paths depending on your architecture:

#### Option A: 1-Command Artifact Registry + Cloud Run Deployment (Recommended for BYO-MCP in Gemini Enterprise)

Use this path when you want to deploy the **20-tool Oracle PeopleSoft MCP Server** into your GCP project and connect it directly to Gemini Enterprise.

1. **Create or verify your Cloud Run Runtime Service Account:**
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   export REGION="us-central1"
   export SA_NAME="project-service-account"
   export SERVICE_ACCOUNT_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

   gcloud iam service-accounts create "$SA_NAME" \
       --display-name="Oracle PeopleSoft MCP Service Account" \
       --project="$PROJECT_ID" || true

   gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
       --role="roles/secretmanager.secretAccessor"
   ```

2. **Configure `MCPServers/mcp-toolbox-peoplesoft/.env`:**
   ```bash
   cd MCPServers/mcp-toolbox-peoplesoft
   cp .env.example .env
   ```
   Update `.env` with your environment settings:
   ```dotenv
   PROJECT_ID=your-gcp-project-id
   REGION=us-central1
   SERVICE_ACCOUNT_EMAIL=project-service-account@your-gcp-project-id.iam.gserviceaccount.com
   SERVICE_ACCOUNT_NAME=project-service-account
   SERVICE_NAME=mcp-toolbox-peoplesoft
   BUILD_AR_IMAGE=true
   AR_REPO_NAME=peoplesoft-mcp-repo
   VPC_NAME=your-vpc-network
   SUBNET_NAME=your-subnet-us-central1
   PSFT_DB_CONNECTION_STRING=10.117.0.20:1521/EP92U055
   PSFT_DB_USER=PSFT_AI
   PSFT_DB_PASSWORD=your-psft-ai-password
   SECRET_NAME=mcp-toolbox-peoplesoft-secret
   ```

3. **Execute `./deploy.sh`:**
   ```bash
   ./deploy.sh
   ```
   **What `./deploy.sh` automates:**
   - Creates the Docker repository `peoplesoft-mcp-repo` in **Google Artifact Registry** (`${REGION}-docker.pkg.dev/${PROJECT_ID}/peoplesoft-mcp-repo`) if it does not exist.
   - Builds `MCPServers/mcp-toolbox-peoplesoft/Dockerfile` (packaging `genai-toolbox` + the 20 parameterized tools in `tools.yaml` with zero plaintext credentials) via **Cloud Build** and pushes `mcp-toolbox-peoplesoft:latest` to your Artifact Registry.
   - Creates/updates **Secret Manager** secrets for `PSFT_DB_CONNECTION_STRING`, `PSFT_DB_USER`, `PSFT_DB_PASSWORD`, and `tools.yaml`.
   - Deploys `mcp-toolbox-peoplesoft` to **Cloud Run** with Direct VPC Egress (`--network` / `--subnet`) and outputs the live MCP endpoint (`https://mcp-toolbox-peoplesoft-<hash>-uc.a.run.app/mcp`).

#### Option B: 1-Click Guided Deployment in Google Cloud Shell

Click the button below to clone this repository directly into **Google Cloud Shell** and launch an interactive step-by-step tutorial (`tutorial.md`):

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/architecture-center-samples&cloudshell_git_branch=main&cloudshell_workspace=oracle-peoplesoft-gemini-enterprise-mcp&cloudshell_tutorial=tutorial.md)

#### Option C: Automated Terraform & Makefile Deployment

Use this path when you want to provision the Artifact Registry repository, Secret Manager secrets, and Cloud Run PeopleSoft MCP Server using Terraform and `Makefile` automation:

```bash
# 1. Verify GCP access and initialize the GCS Terraform state backend
make verify-gcp-access PROJECT_ID=your-gcp-project-id REGION=us-central1
make init PROJECT_ID=your-gcp-project-id REGION=us-central1

# 2. Prompt for Oracle PeopleSoft DB credentials, VPC, and Subnet (saved to infra.auto.tfvars)
make set_config_mcp_servers

# 3. Build & deploy the Oracle PeopleSoft MCP Server to Artifact Registry & Cloud Run
make plan_mcp_server PROJECT_ID=your-gcp-project-id REGION=us-central1
make deploy_mcp_server PROJECT_ID=your-gcp-project-id REGION=us-central1
```

### 5.4 Step 3: Verify Deployment & Register with Gemini Enterprise

1. **Verify the Cloud Run MCP Server is healthy:**
   ```bash
   SERVICE_URL=$(gcloud run services describe mcp-toolbox-peoplesoft --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
   MCP_URL="${SERVICE_URL}/mcp"
   echo "MCP Server Endpoint: ${MCP_URL}"
   ```
2. **Test MCP Tool Discovery (`tools/list`):**
   ```bash
   curl -s -X POST "${MCP_URL}" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-identity-token --audiences="${SERVICE_URL}")" \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | jq '.result.tools[].name'
   ```
   You should see all **20 Oracle PeopleSoft MCP tools** returned.
3. **Connect to Gemini Enterprise:**
   - Grant `roles/run.invoker` to your Gemini Enterprise Discovery Engine Service Agent (`service-<PROJECT_NUMBER>@gcp-sa-discoveryengine.iam.gserviceaccount.com`) on the Cloud Run service (or at the project level via `gcloud projects add-iam-policy-binding`).
   - Register `${MCP_URL}` as your customer-managed MCP Server endpoint in Gemini Enterprise to enable live PeopleSoft FSCM 9.2 data access and transactional workflows.
