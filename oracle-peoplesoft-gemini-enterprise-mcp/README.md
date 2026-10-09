# Oracle PeopleSoft FSCM 9.2 Gemini Enterprise MCP Server & Public Sector Skills

> **Repository:** `GoogleCloudPlatform/architecture-center-samples/oracle-peoplesoft-gemini-enterprise-mcp`  
> **Release:** Customer-Managed Cloud Run BYO-MCP Architecture (20 MCP Tools, 8 Domain Semantic Maps, 6 Public Sector Skills & 180 DPI Executive Charting)  
> **Target Audience:** Engineering, Solutions Architecture, and Product Management  

## 1. Executive Summary

This repository provides a production-ready enterprise reference architecture connecting Google Cloud **Gemini Enterprise** and the **6 Gemini for government services Public Sector Skills** directly to **Oracle PeopleSoft Financials and Supply Chain Management (FSCM) 9.2 (PeopleTools 8.62)**.

It combines core Procure-to-Pay (P2P), Accounts Payable (`PS_VOUCHER`), Accounts Receivable (`PS_CUSTOMER`, `PS_ITEM`), Inventory (`PS_PHYSICAL_INV`), General Ledger (`PS_JRNL_HEADER`), Strategic Sourcing (`PS_AUC_HDR`), Travel & Expenses (`PS_EX_SHEET_HDR`), Grants Management (`PS_GM_AWARD`), and PeopleTools Security (`PSOPRDEFN`, `PSROLEUSER`) capabilities with 6 specialized **Gemini for government services** Public Sector compliance and casework skills, backed by a customer-managed 20-tool Cloud Run Model Context Protocol (`genai-toolbox`) server and publication-grade 180 DPI executive charting.

### Key Capabilities Included in This Release
1. **Containerized MCP Toolbox Server (`MCPServers/mcp-toolbox-peoplesoft/`):** A Go-based Model Context Protocol (`genai-toolbox`) service packaged into your project's **Google Artifact Registry** (`peoplesoft-mcp-repo`) and deployed on Google Cloud Run with Direct VPC Egress (`oracle-peoplesoft-toolkit-network`) to the Oracle PeopleSoft 9.2 database tier (`EP92U055`).
2. **20 Production-Ready MCP Tools (`tools.yaml`):**
   - **8 Baseline ERP & Transactional Tools:** Session context initialization (`ps_init` via `SYSADM.GE_PSFT_MCP_TOOLS.ps_initialize_context`), role discovery (`list_ps_roles` across `PSOPRDEFN` and `PSROLEUSER`), active session inspection (`list_ps_current_context`), read-only analytical discovery (`execute_sql`), inventory receipt creation (`create_onhand`), stock reservation (`reserve_item`, `delete_reserve_item`), and Accounts Payable voucher creation (`create_ap_voucher`).
   - **12 Public Sector & Regulatory Compliance Tools:** Purpose-built parameterized SQL tools (2 per skill) supporting all 6 **Gemini for government services** skills across constituent notices, FOIA/privacy compliance, statutory hierarchy analysis, document intake validation, RFP vendor evaluation, and 2 CFR Part 200 grant/expense auditing.
3. **Database Tier Integration & Read-Only Governance Views (`PSFTScripts/`):**
   - Custom PL/SQL wrapper package (`SYSADM.GE_PSFT_MCP_TOOLS` in `ge_psft_mcp_tools.sql`) encapsulating PeopleSoft transactional tables and autonomous audit logging (`SYSADM.GGLTOOLBOX$MCP_LOG`).
   - Least-privilege database user provisioning (`PSFT_AI` via `create_psft_ai.sql` with `SYSADM.PSFT_AI_AFTER_LOGON_TRG` logon trigger).
   - 7 read-only Public Sector views (`SYSADM.VW_GOV_*`) across delivered PeopleSoft FSCM 9.2 tables (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_EX_SHEET_DIST`, `PS_VOUCHER`, `PS_PO_HDR`, `PS_AUC_HDR`, `PS_GM_AWARD`, `PS_CUSTOMER`) and `SYSADM.PS_GOV_*` tables (`install_gov_psft_mcp_and_seed.sql` and `install_gov_public_sector_views.sql`) with an isolated synthetic evaluation dataset (`IDs 990001–990999` and `-V2` records) covering 163 test scenarios with zero mutation of baseline PUM demo data.
4. **6 Gemini Enterprise Public Sector Skills & 180 DPI Executive Charting:**
   - **Direct Skill-to-MCP Execution:** Gemini Enterprise executes the 6 Public Sector Skills (`/plain-language-notice-generator`, `/redaction-and-foia-compliance`, `/policy-and-statute-assistant`, `/document-intake-cleanup-and-validation`, `/rfp-vendor-evaluation-scorer`, and `/expense-auditor`) directly against the Cloud Run PeopleSoft MCP Server (`/mcp`).
   - **8 Domain Semantic Maps:** Curated schema definitions covering Accounts Payable (`ap`), Accounts Receivable (`ar`), General Ledger (`gl`), PeopleTools Security & HR (`hr`), Inventory (`inventory`), Travel/Expenses & Grants (`om`), Purchasing & Strategic Sourcing (`po`), and Public Sector Views (`gov_public_sector_semantic_map.json`).
   - **180 DPI Executive Charting:** Generates publication-grade `180 DPI` (`12.0" x 6.6"` widescreen) horizontal bar, vertical bar, grouped/stacked bar, executive donut, and multi-series line charts with automatic currency formatting, KPI summary callouts, reference threshold rules, and source provenance footers rendered inline in Gemini Enterprise (including click-to-enlarge full-resolution inspection).

## 2. End-to-End Architecture Overview

```text
+----------------------------------------------------------------------------------------------------------+
|                      ORACLE PEOPLESOFT 9.2 GEMINI ENTERPRISE MCP ARCHITECTURE                            |
|                                                                                                          |
|  [ Gemini Enterprise UI & 6 Public Sector Skills ]                                                       |
|       |  * /plain-language-notice-generator    * /document-intake-cleanup-and-validation                 |
|       |  * /redaction-and-foia-compliance      * /rfp-vendor-evaluation-scorer                           |
|       |  * /policy-and-statute-assistant       * /expense-auditor                                        |
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
|       |  * Public Sector Read-Only Views: 7 SYSADM.VW_GOV_* Views                                        |
+----------------------------------------------------------------------------------------------------------+
```

## 3. Complete Inventory of 20 MCP Tools (`MCPServers/mcp-toolbox-peoplesoft/tools.yaml`)

### 3.1 Baseline PeopleSoft 9.2 ERP, Session Security & Transactional Tools (8 Tools)

| Tool Name | Tool Kind | Underlying Oracle Mechanism | Description |
| :--- | :--- | :--- | :--- |
| **`ps_init`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.ps_initialize_context` | **Session Initialization:** Resolves user email in `PSOPRDEFN` (`VP1`), validates active role in `PSROLEUSER`, and sets active Business Unit (`US001` / `EGV05`) and TableSet ID (`SHARE`) in `PS_GOV_MCP_SESSION_CTX`. |
| **`list_ps_roles`** | `oracle-sql` | `PSOPRDEFN`, `PSROLEUSER`, `PSROLEDEFN` | **Role Discovery:** Lists valid PeopleTools security roles, operator descriptions, and default Business Unit / SetID assigned to a user email or OPRID. |
| **`list_ps_current_context`** | `oracle-sql` | `PS_GOV_MCP_SESSION_CTX` session state inspection | **Context Verification:** Returns active `OPRID`, `OPERATOR_NAME`, `EMAILID`, `EMPLID`, `BUSINESS_UNIT`, `SETID`, and `ROLENAME`. |
| **`execute_sql`** | `oracle-execute-sql` | Read-only SQL execution engine (`readOnly: true`) | **Analytical Discovery:** Executes read-only `SELECT` queries against Oracle PeopleSoft 9.2 tables and views under the active session security context. |
| **`create_onhand`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.create_onhand` | **Inventory Receipt:** Increments on-hand inventory quantity in PeopleSoft Inventory (`PS_PHYSICAL_INV` / `PS_BU_ITEMS_INV`). |
| **`reserve_item`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.reserve_item` | **Inventory Reservation:** Creates an item reservation against available on-hand warehouse stock in `PS_GOV_INV_RESERVATIONS`. |
| **`delete_reserve_item`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.delete_reservation` | **Reservation Release:** Cancels and releases an existing inventory reservation by `reservation_id`. |
| **`create_ap_voucher`** | `oracle-sql` | `SYSADM.GE_PSFT_MCP_TOOLS.create_ap_voucher` | **Payables Voucher:** Programmatically validates and creates an Accounts Payable voucher record in `PS_VOUCHER` / `PS_GOV_AP_VOUCHERS`. |

### 3.2 Public Sector & Regulatory Compliance Tools (12 Tools Supporting 6 Skills)

| Skill | Tool Name | Target PeopleSoft View / Tables | Description |
| :--- | :--- | :--- | :--- |
| **3.1 Plain Language Notice Generator** | **`ps_get_case_determination`** | `SYSADM.VW_GOV_CONSTITUENT_NOTICES` | Retrieves population-level public benefit notices or individual determinations, statutory citations, effective dates, and full notice text. |
| **3.1 Plain Language Notice Generator** | **`ps_get_attachment_content`** | `PS_GOV_FND_DOCUMENTS`, `PS_GOV_FND_DOCS_LONG_TEXT` | Fetches full text and attachment metadata for statutory directives, agency transmittals, and determinations. |
| **3.2 Redaction & FOIA Compliance** | **`ps_search_foia_records`** | `SYSADM.VW_GOV_FOIA_RECORDS` (`PS_PO_HDR`) | Searches responsive public procurement contracts, audit exhibits, and oversight records for a FOIA request or solicitation reference. |
| **3.2 Redaction & FOIA Compliance** | **`ps_get_employee_record_documents`** | `SYSADM.VW_GOV_FOIA_RECORDS` (`PSOPRDEFN`) | Retrieves personnel attributes and attached tax/medical/security exhibits to segregate releasable official roles from protected PII, PHI, FTI, and Exemption 7(E)/4 secrets. |
| **3.3 Policy & Statute Assistant** | **`ps_get_policy_catalog_rules`** | `SYSADM.VW_GOV_AGENCY_POLICY_RULES` | Queries structured procurement approval tiers, control groups, and statutory dollar limits in PeopleSoft Purchasing. |
| **3.3 Policy & Statute Assistant** | **`ps_search_policy_documents`** | `SYSADM.VW_GOV_AGENCY_POLICY_RULES` | Searches official federal/state statutory and regulatory policy transmittals (SNAP, Medicaid, statutory preemption, procurement code, 2 CFR Part 200). |
| **3.4 Document Intake Cleanup & Validation** | **`ps_get_constituent_documents`** | `SYSADM.VW_GOV_INTAKE_DOCUMENTS` (`PS_CUSTOMER`) | Retrieves staged constituent intake packets, Gate A optical telemetry (focus variance, skew, 4-corner framing), OCR confidence scores, and Gate C paystub/ledger math. |
| **3.4 Document Intake Cleanup & Validation** | **`ps_verify_constituent_data`** | `SYSADM.VW_GOV_INTAKE_DOCUMENTS` (`PS_CUSTOMER`) | Cross-checks applicant legal name, pre-masked SSN hash (`***-**-XXXX`), and verified address against PeopleSoft Customer (`PS_CUSTOMER`) master records. |
| **3.5 RFP Vendor Evaluation Scorer** | **`ps_get_strategic_sourcing_event`** | `SYSADM.VW_GOV_SOURCING_RFPS` (`PS_AUC_HDR`) | Retrieves PeopleSoft Strategic Sourcing RFP event headers (`AUC_ID`), addenda, Section M.1 Minimum Mandatory Qualifications, and Section M.2 evaluation criteria. |
| **3.5 RFP Vendor Evaluation Scorer** | **`ps_get_vendor_responses`** | `SYSADM.VW_GOV_SOURCING_RFPS` (`PS_AUC_HDR`) | Retrieves competing vendor bid responses, pricing, mandatory qualification evidence, and cross-document proposal sections for compliance matrix compilation. |
| **3.6 Expense Auditor** | **`ps_get_expense_sheets`** | `SYSADM.VW_GOV_EXPENSE_REPORTS` (`PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`) | Retrieves PeopleSoft Travel & Expenses sheet headers (`SHEET_ID`), itemized expense lines, GSA Per Diem notes, and attached hotel/flight receipt OCR folios. |
| **3.6 Expense Auditor** | **`ps_get_voucher_details`** | `SYSADM.VW_GOV_PO_INVOICE_MATCH` (`PS_VOUCHER`, `PS_PO_HDR`, `PS_GM_AWARD`) | Retrieves PeopleSoft Accounts Payable vendor vouchers (`VOUCHER_ID`), matched Purchase Orders (`PO_ID`), competitive quote notes, and PeopleSoft Grants (`PS_GM_AWARD`) Period of Performance / NICRA metadata. |

## 4. Gemini Enterprise Public Sector Skills & Semantic Schema Mapping

### 4.1 6 Validated Public Sector Skills
1. **Plain Language Notice Generator (`/plain-language-notice-generator`):** Rewrites complex statutory directives (`ps_get_case_determination`, `ps_get_attachment_content`) into clear Plain English public notices while locking mandatory federal nondiscrimination statements verbatim and blocking individual adverse-action claims containing PII.
2. **Redaction & FOIA Compliance (`/redaction-and-foia-compliance`):** Segregates public procurement and official salary records from exempt PII, IRS Section 6103 FTI, HIPAA PHI, and Exemption 7(E)/4 secrets (`ps_search_foia_records`, `ps_get_employee_record_documents`), producing an inline redacted release and statutory Vaughn Index.
3. **Policy & Statute Assistant (`/policy-and-statute-assistant`):** Enforces a 3-tier statutory hierarchy (Statute > Regulation > Agency Manual) and temporal rule verification over PeopleSoft policy rules and transmittals (`ps_get_policy_catalog_rules`, `ps_search_policy_documents`).
4. **Document Intake Cleanup & Validation (`/document-intake-cleanup-and-validation`):** Executes a 3-Gate intake audit (Gate A optical telemetry, Gate B identity completeness against `PS_CUSTOMER`, and Gate C bi-weekly/semi-monthly income math) with pre-masked SSNs (`ps_get_constituent_documents`, `ps_verify_constituent_data`).
5. **RFP Vendor Evaluation Scorer (`/rfp-vendor-evaluation-scorer`):** Compiles page-cited Mandatory Qualification matrices, Consensus Evaluation Worksheets (leaving the Evaluator Score column 100% blank for human evaluators), and Cross-Document Contradiction Logs (`ps_get_strategic_sourcing_event`, `ps_get_vendor_responses`).
6. **Expense Auditor (`/expense-auditor`):** Audits PeopleSoft Travel & Expense sheets and Grant Payables vouchers against 2 CFR Part 200 (Uniform Guidance) and GSA Per Diem caps (`ps_get_expense_sheets`, `ps_get_voucher_details`).

### 4.2 8 Domain Semantic Maps
* Grounds SQL discovery and tool invocation across **8 domain semantic maps**:
  1. `ap_semantic_map.json` (Accounts Payable — `PS_VOUCHER`, `PS_DISTRIB_LINE`, `PS_PYMNT_VCHR_XREF`, `PS_VENDOR`)
  2. `ar_semantic_map.json` (Accounts Receivable — `PS_CUSTOMER`, `PS_ITEM`, `PS_ITEM_ACTIVITY`)
  3. `gl_semantic_map.json` (General Ledger — `PS_JRNL_HEADER`, `PS_JRNL_LN`, `PS_LEDGER`)
  4. `hr_semantic_map.json` (PeopleTools Security & Workforce — `PSOPRDEFN`, `PSROLEUSER`, `PSROLEDEFN`, `PS_PERSONAL_DATA`)
  5. `inventory_semantic_map.json` (Inventory — `PS_PHYSICAL_INV`, `PS_BU_ITEMS_INV`, `PS_MASTER_ITEM_TBL`)
  6. `om_semantic_map.json` (Travel & Expenses & Grants — `PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_GM_AWARD`)
  7. `po_semantic_map.json` (Purchasing & Strategic Sourcing — `PS_PO_HDR`, `PS_PO_LINE`, `PS_AUC_HDR`)
  8. `gov_public_sector_semantic_map.json` (Public Sector Views `SYSADM.VW_GOV_*`, Grants `PS_GM_AWARD`, Strategic Sourcing `PS_AUC_HDR`, Travel & Expenses `PS_EX_SHEET_HDR`, and Attachments `PS_GOV_FND_DOCUMENTS`)

### 4.3 180 DPI Executive Charting Utilities
* Renders high-resolution **`180 DPI` (`12.0" x 6.6"` widescreen)** PNG charts for inline display inside Gemini Enterprise (including click-to-enlarge full-resolution inspection):
  - **`render_bar_chart`**: Supports horizontal (`horizontal=True`), vertical, grouped multi-series, and stacked (`stacked=True`) bar charts with direct value and share-of-total (`%`) callouts, KPI summary badges, and optional dashed target/ceiling reference lines (`reference_value`, `reference_label`).
  - **`render_pie_chart`**: Renders an executive donut chart (`width=0.44`) with a bold center KPI total callout and a structured right-hand breakdown legend showing exact dollar/numeric values and percentages.
  - **`render_line_chart`**: Renders multi-series trend trajectories with subtle area fills, Direct Min/Max/Latest milestone callout badges, and optional statutory threshold rules.
  - **`render_table`**: Produces styled executive tables and Markdown summaries.

## 5. Security, Identity & Governance Architecture

1. **End-to-End Identity Propagation:** User identity from Gemini Enterprise (`session.user_email`) is passed to `ps_init`, which validates `PSOPRDEFN.EMAILID` (`VP1`), verifies active role assignments in `PSROLEUSER`, and sets the active Business Unit (`US001` / `EGV05`) and TableSet ID (`SHARE`) in `SYSADM.PS_GOV_MCP_SESSION_CTX`.
2. **Least-Privilege Database Schema (`PSFT_AI`):** Database connections use the dedicated `PSFT_AI` account (`PSFTScripts/create_psft_ai.sql` with `SYSADM.PSFT_AI_AFTER_LOGON_TRG` automatic schema context trigger) rather than administrative credentials.
3. **Read-Only SQL & Parameterized Tool Guardrails:** `execute_sql` enforces `readOnly: true` at the MCP server layer, and all 12 Public Sector analytical tools execute strictly parameterized `SELECT` queries against curated `SYSADM.VW_GOV_*` read-only views.
4. **Autonomous Database Audit Trail:** Every session initialization and PL/SQL package invocation writes an immutable audit record via `PRAGMA AUTONOMOUS_TRANSACTION` (`SYSADM.MCP_TOOLBOX_LOG`) into `SYSADM.GGLTOOLBOX$MCP_LOG`.
5. **Network & Secret Isolation:** `tools.yaml` contains zero plaintext credentials (`${PSFT_DB_CONNECTION_STRING}`, `${PSFT_DB_USER}`, `${PSFT_DB_PASSWORD}`). Database credentials are stored in Google Cloud Secret Manager and injected at runtime into Cloud Run, which communicates with Oracle PeopleSoft (`1521/tcp`) exclusively over Direct VPC Egress.

## 6. Deployment Guidance & Step-by-Step Customer Setup

This section provides complete step-by-step instructions for deploying the customer-managed Oracle PeopleSoft 9.2 MCP Server into your own Google Cloud project and connecting it to Gemini Enterprise.

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
| **1. Deploying Engineer / CI Pipeline** | `roles/run.admin`<br>`roles/artifactregistry.admin`<br>`roles/cloudbuild.builds.editor`<br>`roles/secretmanager.admin`<br>`roles/iam.serviceAccountUser`<br>`roles/compute.networkViewer` | Creates the Artifact Registry repo (`peoplesoft-mcp-repo`), builds the pre-configured MCP container image, provisions Secret Manager secrets, and deploys the Cloud Run MCP Server. |
| **2. Cloud Run Runtime Service Account** (`project-service-account@<PROJECT_ID>.iam.gserviceaccount.com`) | `roles/secretmanager.secretAccessor`<br>`roles/logging.logWriter`<br>`roles/monitoring.metricWriter` | Reads `tools.yaml` and Oracle PeopleSoft DB credentials (`PSFT_DB_CONNECTION_STRING`, `PSFT_DB_USER`, `PSFT_DB_PASSWORD`) from Secret Manager at container startup and writes audit/operational logs. |
| **3. Cloud Run Service Agent** (`service-<PROJECT_NUMBER>@serverless-robot-prod.iam.gserviceaccount.com`) | `roles/compute.networkUser` *(on the target VPC/Subnet)*<br>`roles/artifactregistry.reader` | Attaches the Cloud Run revision to your VPC subnet via Direct VPC Egress to reach Oracle PeopleSoft (`1521/tcp`) and pulls the container image from Artifact Registry. |
| **4. Gemini Enterprise Service Account** | `roles/run.invoker` *(on the `mcp-toolbox-peoplesoft` Cloud Run service)* | Invokes the Cloud Run MCP Server (`/mcp`) with OIDC authentication from Gemini Enterprise. |

#### C. Network & Firewall Prerequisites
- **VPC Connectivity:** Your Google Cloud VPC (`VPC_NAME` / `SUBNET_NAME`) must have private IP routing (via Cloud Interconnect, HA VPN, or VPC Peering) to your Oracle PeopleSoft 9.2 database host.
- **Firewall Rule:** Allow TCP egress from your Cloud Run Direct VPC Egress subnet CIDR to your Oracle PeopleSoft Database Listener port (default `1521/tcp`).

### 6.2 Step 1: Prepare the Oracle PeopleSoft FSCM 9.2 Database Tier (`PSFTScripts/`)

Connect to your Oracle PeopleSoft FSCM 9.2 database (`EP92U055`) and execute the SQL/PLSQL scripts in `PSFTScripts/`:

```bash
cd PSFTScripts

# 1. Create the least-privilege PSFT_AI database user, role, and logon trigger (run as SYS / DBA)
sqlplus sys/<SYS_PASSWORD>@<PSFT_HOST>:1521/EP92U055 as sysdba @create_psft_ai.sql

# 2. Compile the SYSADM.GE_PSFT_MCP_TOOLS PL/SQL wrapper package and audit table (run as SYSADM)
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @ge_psft_mcp_tools.sql

# 3. (Optional — Public Sector Skills & Synthetic Showcase Data) Install read-only VW_GOV_* views
#    and seed Public Sector records across delivered PS_* and PS_GOV_* tables (run as SYSADM)
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @install_gov_psft_mcp_and_seed.sql
sqlplus SYSADM/<SYSADM_PASSWORD>@<PSFT_HOST>:1521/EP92U055 @install_gov_public_sector_views.sql
```

### 6.3 Step 2: Choose Your Deployment Path

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

### 6.4 Step 3: Verify Deployment & Register with Gemini Enterprise

1. **Verify the Cloud Run MCP Server is healthy:**
   ```bash
   MCP_URL=$(gcloud run services describe mcp-toolbox-peoplesoft --project "$PROJECT_ID" --region "$REGION" --format 'value(status.url)')
   echo "MCP Server Endpoint: ${MCP_URL}/mcp"
   ```
2. **Test MCP Tool Discovery (`tools/list`):**
   ```bash
   curl -s -X POST "${MCP_URL}/mcp" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | jq '.result.tools[].name'
   ```
   You should see all **20 Oracle PeopleSoft MCP tools** returned.
3. **Connect to Gemini Enterprise:**
   - Register `${MCP_URL}/mcp` as your customer-managed MCP Server endpoint in Gemini Enterprise to enable live PeopleSoft data access across the 6 Public Sector Skills.
