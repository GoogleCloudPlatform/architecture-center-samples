# **Gemini for Government: Oracle E-Business Suite & PeopleSoft MCPs**

## Product Requirements Document (PRD)

**Document Status:** Draft   
**Authors:** negonzal@, \<pls add\>  
**Contributors**: \<pls add\>  
**Created**: September 28, 2026  
**Last update**: September 29, 2026  
Target Launch: MVP (Gemini for Government Oct '26) | V2 (Next '27)

### Executive Summary & Product Vision

The Oracle E-Business Suite (EBS) and PeopleSoft Model Context Protocol (MCP) Connectors for Gemini Enterprise enable AI agents running on Gemini Enterprise to leverage data and business logic within these Oracle applications to accomplish their goal. These MCPs will be offered to our customers through a BYO-MCP (bring-your-own MCP) model.

This PRD provides requirements to enhance these **EBS and PeopleSoft MCPs for the launch of the Gemini for Government Plugin** slated for launch in October 2026\. By enabling deterministic, zero-trust AI interactions with financials, human resources, procurement, and asset management across both cloud-hosted and on-premises environments, Google Cloud empowers government agencies to modernize operations, accelerate citizen services, and reduce administrative overhead without requiring risky, multi-year core platform migrations.

### Strategic Rationale & Market Opportunity

* **Market Opportunity (TAM/SAM):** The public sector represents a large and rapidly accelerating total addressable market for Agentic AI, growing from US\$ 2.3B in 2025 to US\$ 14.4B by 2030 (43.8% CAGR). Oracle EBS and PeopleSoft represent one of the deepest entrenched ERP footprints in the public sector, with over 6,800+ enterprise EBS deployments and thousands of state, municipal, and federal installations running PeopleSoft Financials and Campus Solutions.  
* **Differentiation:** Google Cloud through the Gemini for Government Plugin, and other industry plugins, delivers out-of-the-box, secure, performant MCP connectivity to their valuable data and business logic. This provides immediate AI value to agencies on their existing systems of record, establishing a major competitive differentiation for Gemini Enterprise vs. other front end AI harnesses from Labs and hyperscalers.  
* **Benefit for Government Agencies:** By bringing Agentic AI directly to their existing Oracle EBS and PeopleSoft data, government agencies that use Google Cloud (such as federal civilian agencies like USDA, VA, HHS, and state/local bodies like State Comptrollers and Transportation Departments) can adopt Gemini Enterprise to modernize operations, automate regulatory compliance, and provide intelligent citizen interaction systems without requiring a risky, multi-year lift-and-shift to a new ERP platform. It frees up civil servants to focus on mission-critical requirements rather than administrative data entry.

### Target Personas & Customer User Journeys (CUJs)

The EBS and PeopleSoft MCPs serve four distinct Personas spanning administrative provisioning, interactive user workflows, and autonomous agent execution:

#### Persona A: Gemini Enterprise Administrator (Prerequisite Enabler)

* **Profile example:** Agency IT / Cloud Security Administrator responsible for GCP infrastructure, hybrid network interconnects, and AI governance.  
* **Customer User Journey A (CUJ A — Discovery, Cloud Run Deployment & BYO-MCP Registration):**  
  1. **Discovery:** The administrator accesses the open-source Oracle EBS & PeopleSoft MCP Server repository (GCP [Architecture Center](https://github.com/GoogleCloudPlatform/architecture-center-samples)).  
  2. **Deployment:** Using the Google pre-validated Terraform modules, the administrator deploys the MCP server container to Cloud Run within the agency's GCP project, attaching it to a Serverless VPC Access connector.  
  3. **Hybrid Networking & Auth Setup:** The administrator establishes private routing to EBS and PeopleSoft database endpoints, either hosted on GCP via internal VPC routes or residing in private on-premises datacenters reached via Cloud VPN / Dedicated Interconnect or BeyondCorp Enterprise, configuring database connection pools and service credentials in Secret Manager.  
  4. **Activation:** In the Gemini Enterprise Admin Console, the administrator activates the new tool under the [BYO-MCP](https://docs.cloud.google.com/gemini/enterprise/docs/connectors/custom-mcp-server/set-up-custom-mcp-server) model, granting access to designated agency staff.

#### Persona B: Civil Servant / Knowledge Worker (Interactive User)

* **Profile example:** Agency Case Worker, Claims Adjudicator, or Benefits Specialist.  
* **Target Gemini for Government Launch Skill:** **Skill 3.1 — Plain Language Notice Generator (`plain_language_notice_generator`)**  
  * *Skill Objective:* Ingests dense, statutory administrative determinations, denial codes, or overpayment recalculations from the ERP and drafts clear, empathetic, 6th-grade reading level citizen notices complying with the Federal Plain Writing Act of 2010 and Title VI language access standards.  
* **Customer User Journey B (CUJ B — Interactive Plain-Language Notice Generation):**  
  1. **Interaction:** The case worker accesses the Gemini Enterprise chat interface to resolve an administrative benefit dispute and communicate an overpayment recalculation to a citizen.  
  2. **Skill & MCP Execution:** The user enters the command: *"Use `/plain_language_notice_generator` to pull the case determination and recalculation details for Claim \#84920 from Oracle, explain why the overpayment occurred in simple terms, and draft an empathetic citizen notice with clear appeal instructions."*  
     Gemini Enterprise invokes the Cloud Run MCP Server using the worker's authenticated identity (`ebs_get_constituent_notice_details` and `ebs_get_document_attachment` for EBS, or `ps_get_case_determination` and `ps_get_attachment_content` for PeopleSoft).  
  3. **Resolution:** The agent ingests the dense statutory denial codes, recalculation schedules, and attached decision letters, translates bureaucratic legalese into an empathetic 6th-grade level notice, and presents the draft in chat for one-click approval and citizen dispatch.

#### Persona C1: Autonomous Agent (Delegated User Identity)

* **Profile:** Autonomous workflow agent acting on behalf of an authorized civil servant (e.g., Agency FOIA Officer, Legal Compliance Analyst, or Senior Buyer).  
* **Target Gemini for Government Launch Skill:** **Skill 3.2 — Redaction & FOIA Compliance (`Redaction_and_foia_compliance`)**  
  * *Skill Objective:* High-throughput automated redaction and public records audit engine that ingests case records, contracts, and internal correspondence for FOIA, state Sunshine Law, or appeals discovery, detecting and redacting sensitive PII, FTI (IRS Pub 1075), CJIS, and HIPAA data while generating an automated statutory exemption log.  
* **Customer User Journey C1 (CUJ C1 — Automated Public Records Redaction & Exemption Logging):**  
  1. **Trigger:** A FOIA Officer receives a complex public records request for historical contract awards, employee hearing transcripts, and internal correspondence. The officer commands Gemini Enterprise: *"Run `/Redaction_and_foia_compliance` across Oracle records for RFP-2024-HEALTH, detect and redact all protected PII, tax identifiers, and banking records, and stage a statutory Exemption 6 audit log."*  
  2. **Skill & MCP Execution:** The agent runs asynchronously under the officer's delegated OAuth identity, invoking `ebs_search_foia_records` and `ebs_get_employee_personnel_file` (or `ps_search_foia_records` and `ps_get_employee_record_documents`). It retrieves responsive files, applies high-throughput zero-leak redaction to mask SSNs, dates of birth, minor names, and financial account numbers, verifies document formatting integrity, and generates an automated statutory exemption log citing legal justifications (e.g., Exemption 6 for personal privacy).  
  3. **Resolution:** The agent stages the redacted document package in the officer's review queue with a complete audit trail explaining each redaction, ready for final human sign-off. *(Note: Delegated agents similarly empower Skill 3.5 `rfp_vendor_evaluation_scorer` to autonomously audit vendor proposals against minimum RFP mandatory criteria).*

#### Persona C2: Autonomous Agent (Service Identity / Background Batch)

* **Profile:** Unattended system-level compliance agent operating under a secure GCP Service Account identity.  
* **Target Gemini for Government Launch Skill:** **Skill 3.6 — Expense Auditor (`expense_auditor`)**  
  * *Skill Objective:* Analyzes travel expense reports, invoices, and purchasing documentation for compliance with federal 2 CFR 200 Uniform Guidance cost principles and grant agreements, generating line-by-line audit determinations and flagging improper expenditures.  
* **Customer User Journey C2 (CUJ C2 — Nightly Automated 2 CFR 200 Grant & Travel Expense Audit):**  
  1. **Trigger:** Scheduled cron execution every night at 02:00 UTC under the agency service account identity.  
  2. **Skill & MCP Execution:** The agent autonomously invokes `/expense_auditor` via the Cloud Run MCP Server (`ebs_get_expense_reports` and `ebs_get_po_invoice_match` for EBS, or `ps_get_expense_sheets` and `ps_get_voucher_details` for PeopleSoft) to audit all expense claims and disbursements submitted in the preceding 24 hours.  
  3. **Resolution:** The agent reconciles line items and receipt image attachments against federal **2 CFR 200 Uniform Guidance** cost principles and specific grant budget rules. It automatically flags unallowable per-diem claims, missing itemized receipts, and potential duplicate billing, generating an executive audit report with specific regulatory citations and staging exception tasks for agency auditors at the start of business. *(Note: Unattended batch agents also power Skill 3.4 `Document_intake_cleanup_and_validation` for scheduled intake queue verification).*

### Product Features

The product features focus on providing robust support for core enterprise tasks across Oracle EBS and PeopleSoft to empower the Gemini for Government launch, organized into clear priority tiers.

#### Priority 0 (P0) — MVP Launch Requirements (Gemini for Government Skills)

##### Platform & Connectivity Foundation (P0)

* **Customer-Managed Cloud Run MCP Servers (BYO-MCP):** Open-source, production-ready Go/Python containerized MCP servers deployed in the agency's GCP project, supporting private connectivity to EBS and PeopleSoft environments.  
* **Dual Deployment Topologies:** Full native support for (1) applications hosted on Google Cloud (Compute Engine / GCE) and (2) hybrid deployments where applications remain on-premises and connect over Cloud VPN / Dedicated Interconnect / BeyondCorp Enterprise.  
* **Zero-Trust Identity Bridge (Santiago Bastidas's Recommendation):** Pre-validated integration with Oracle Identity Cloud Service (IDCS) and the EBS Asserter for Oracle EBS, and IDCS / OpenID Connect (OIDC) Sign-on PeopleCode for PeopleSoft, asserting authenticated user context down to the database and application tiers (`fnd_global.apps_initialize` for EBS; `OPRID` row-level security for PeopleSoft).  
* **Gemini Enterprise BYO-MCP Registration:** Streamlined catalog discovery and activation in the Gemini Enterprise Admin Console.

##### Gemini for Government Plugin Skill Enablement & Proposed MCP Tools (P0)

To power the 6 core skills targeted for the Gemini for Government Plugin launch, the MCP servers introduce dedicated, high-performance tools:

###### *1\. Plain Language Notice Generator (`plain_language_notice_generator`)*

* **Role of Oracle MCP:** Provides access to dense administrative determinations, statutory denial codes, overpayment recalculations, and attached determination notices stored within the ERP.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_get_constituent_notice_details`: Queries case determination, denial reason codes, overpayment balances, and billing adjustments from EBS AR and Grants Accounting.  
  * `ebs_get_document_attachment`: Retrieves attached determination letters and decision PDFs from EBS Document Management (`FND_ATTACHED_DOCUMENTS`).  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_get_case_determination`: Retrieves constituent account recalculations, financial determinations, or dispute records from PeopleSoft Student/Constituent Accounts and FSCM.  
  * `ps_get_attachment_content`: Retrieves attached case documents and decision files from the PeopleSoft Attachment Repository (`PS_ATTACHMENT_TBL`).  
* **Plugin Linkage:** Supplies raw statutory text and determination metadata to the agent to draft empathetic notices at a 6th-grade reading level, pre-formatted for certified multi-lingual translation.

###### *2\. Redaction and FOIA Compliance (`Redaction_and_foia_compliance`)*

* **Role of Oracle MCP:** Discovers and extracts personnel records, hearing files, and case correspondence stored across ERP repositories for automated PII audit and redaction.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_search_foia_records`: Searches discoverable case records, HR employee files, vendor agreements, and correspondence across EBS modules by date, party, or keyword.  
  * `ebs_get_employee_personnel_file`: Retrieves employee personnel files, disciplinary records, and attached documentation from EBS HRMS.  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_search_foia_records`: Searches public records, employee archives, and contract documents across PeopleSoft HCM and FSCM.  
  * `ps_get_employee_record_documents`: Retrieves personnel files, payroll stubs, and HR attachment records from PeopleSoft HCM Document Management.  
* **Plugin Linkage:** Extracts document streams and metadata for zero-leak redaction of sensitive PII (SSNs, DOBs, minor names, financial accounts), FTI (IRS Pub 1075), CJIS, and HIPAA data while generating a statutory exemption log.

###### *3\. Policy and Statute Assistant (`Policy_and_statute_assistant`)*

* **Role of Oracle MCP:** Provides internal agency operational rules, financial delegation limits, travel regulations, and standard operating procedures (SOPs) stored in Oracle ERP setups and attachment repositories to complement external statutes.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_get_agency_policy_rules`: Queries agency-configured procurement approval thresholds, financial authority limits, and travel regulations from EBS setups.  
  * `ebs_search_policy_attachments`: Retrieves operational policy bulletins, administrative guidelines, and SOP PDFs from the EBS FND Document Repository.  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_get_policy_catalog_rules`: Queries expense per-diem tables, delegation of authority rules, and regulatory compliance setups in PeopleSoft FSCM.  
  * `ps_search_policy_documents`: Retrieves agency policy guidelines and procedural documentation attachments from PeopleSoft.  
* **Plugin Linkage:** Grounds the agent's semantic reasoning in agency-specific operational policies alongside federal (CFR, USC) and state administrative statutes.

###### *4\. Document Intake Cleanup and Validation (`Document_intake_cleanup_and_validation`)*

* **Role of Oracle MCP:** Retrieves citizen-submitted proof documents (paystubs, W-2s, utility bills) staged in Oracle intake queues and cross-references extracted data against the system of record.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_get_intake_attachments`: Retrieves unverified applicant proof document attachments staged in EBS AR, Grants, or CRM.  
  * `ebs_verify_party_identity`: Validates extracted citizen identity data (legal name, address, tax ID/SSN hash) against EBS Trading Community Architecture (TCA) registries.  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_get_constituent_documents`: Retrieves applicant verification files and pending attachments from PeopleSoft Constituent / Student Case records.  
  * `ps_verify_constituent_data`: Cross-checks extracted income and demographic fields against PeopleSoft Person/Constituent master tables.  
* **Plugin Linkage:** Delivers raw intake files to the agent for document cleanup, mathematical verification, and anomaly detection, followed by programmatic validation against master records.

###### *5\. RFP Vendor Evaluation Scorer (`rfp_vendor_evaluation_scorer`)*

* **Role of Oracle MCP:** Retrieves solicitation criteria, evaluation rubrics, and vendor bid submissions directly from Oracle Sourcing/Procurement.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_get_sourcing_rfp_details`: Queries RFP posting packages, minimum mandatory qualifications, technical specifications, and scoring rubrics from Oracle Sourcing (EBS).  
  * `ebs_get_vendor_bids`: Retrieves vendor proposal submissions, attached technical bids, and pricing schedules from Oracle Sourcing.  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_get_strategic_sourcing_event`: Retrieves sourcing event specifications, minimum criteria, and scoring rubrics from PeopleSoft Strategic Sourcing (eProcurement).  
  * `ps_get_vendor_responses`: Retrieves vendor bid packages, proposal attachments, and compliance disclosures from PeopleSoft Strategic Sourcing.  
* **Plugin Linkage:** Empowers the agent to perform objective gap analysis against RFP criteria, evaluate mandatory versus scored qualitative requirements, and generate auditable scoring justifications.

###### *6\. Expense Auditor (`expense_auditor`)*

* **Role of Oracle MCP:** Accesses digital expense reports, receipts, matched POs, invoices, and federal grant project lines for automated regulatory audit.  
* **Proposed Oracle EBS MCP Tools:**  
  * `ebs_get_expense_reports`: Retrieves employee travel and operational expense reports, itemized expense lines, and receipt image attachments from Oracle Internet Expenses (OIE) / AP.  
  * `ebs_get_po_invoice_match`: Retrieves purchase order distributions, matched invoice lines, receiving receipts, and 2 CFR 200 grant project codes from EBS Payables and Purchasing.  
* **Proposed PeopleSoft MCP Tools:**  
  * `ps_get_expense_sheets`: Retrieves expense reports, itemized receipts, and accounting chartfields from PeopleSoft Expenses.  
  * `ps_get_voucher_details`: Retrieves AP vouchers, matched PO lines, receiving records, and federal grant budget charts from PeopleSoft Payables and Purchasing.  
* **Plugin Linkage:** Supplies transactional records, ledger distributions, and receipt artifacts for automated line-by-line compliance checks against 2 CFR 200 Uniform Guidance and grant agreements.

#### Priority 1 (P1) — Post-MVP Immediate Follow-Ons

* **FedRAMP High & DoD IL4/IL5 Support:** Hardened deployment profiles for federal civilian and defense environments within Assured Workloads.  
* **Safe Transactional Staging:** Human-in-the-Loop (HITL) approval workflows for staging journal entries and purchase requisitions.

#### Post-MVP Features (Next '27 Launch)

##### Gemini Enterprise Managed Connector

* **First-Party Managed Service:** Transition from customer-managed Cloud Run containers to a fully managed Gemini Enterprise Connector jointly maintained by Google Cloud and Oracle.  
* **Zero-Infrastructure Overhead:** Eliminate customer container lifecycle management.

##### Core Skill Enablement (Wave 2 Government Skills)

* **Automated Budget Encumbrance & Fund Control:** Deep integration with EBS Public Sector Budgeting and PeopleSoft Commitment Control.  
* **Cross-System Batch Migration Assistant:** Automated data extraction and validation pipelines to assist agencies in modernizing legacy EBS/PeopleSoft schemas toward Cloud ERP.

### Product Roadmap

* **Phase 1: MVP Launch (Gemini for Government — October 20, 2026\)**  
  * September 28, 2026: PRD Final Review and Technical Architecture Sign-off.  
  * October 2, 2026: Core MCP Container Build & Hybrid Connector Testing.  
  * October 9, 2026: Code Freeze & Security Review.  
  * October 20–22, 2026: Public Launch at Public Sector Summit.  
* **Phase 2: Post-MVP Expansion (Google Cloud Next '27 — Q2 2027\)**  
  * Q1 2027: Development of Native Managed Connector.  
  * Q2 2027: General Availability (GA) of Managed Connector and Wave 2 Skills at Next '27.

### Key Dependencies & Risks

* **Dependency: Oracle Identity Cloud Service (IDCS) & Identity Bridge Access:** Access to an Oracle Identity Cloud Service (IDCS) / OCI IAM environment configured with the **EBS Asserter** (recommended by Santiago Bastidas) for EBS identity mapping, and access to **PeopleSoft OpenID Connect (OIDC) / Sign-on PeopleCode** integration components to validate Google Cloud Identity OAuth 2.0 / OIDC tokens and assert PeopleSoft `OPRID` context.  
  * *Mitigation:* Partner with Oracle Partner Engineering (Santiago Bastidas) to obtain pre-configured IDCS tenant access and reference EBS Asserter deployment configurations.  
* **Dependency: Oracle EBS & PeopleSoft Test Lab Access:** Access to dedicated EBS R12.2 and PeopleSoft 9.2 test environments (with network-peered databases) to validate stored procedures, Integration Broker endpoints, and connection pooling.  
* **Risk: Network Latency over Hybrid Links:** Hybrid network egress (Cloud VPN / Interconnect) could impact conversational latency.  
  * *Mitigation:* Implement intelligent query caching and connection pooling in the Cloud Run MCP container.

### Appendix

#### MCP Tools & Underlying Enterprise Source Data Mapping Matrix

To enable engineering teams to implement production-grade MCP servers, the matrix below details the exact underlying database tables, views, stored procedures, Component Interfaces, and security contexts required in **Oracle E-Business Suite (EBS) R12.2** and **PeopleSoft 9.2** for each proposed MCP tool supporting the 6 Gemini for Government launch skills:

| Launch Skill | Platform | Proposed MCP Tool | Underlying Tables & Views | Stored Procedures / APIs / CIs | Data Attributes & Scope | Security & Session Context |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| **3.1 Plain Language Notice Generator** | **Oracle EBS** | `ebs_get_constituent_notice_details` | `RA_CUSTOMER_TRX_ALL`, `RA_CUSTOMER_TRX_LINES_ALL`, `AR_PAYMENT_SCHEDULES_ALL`, `HZ_PARTIES`, `HZ_CUST_ACCOUNTS`, `GMS_AWARDS_ALL` | `AR_INVOICE_API_PUB`, `HZ_CUSTOMER_INFO_PUB`, `APPS_AI.GET_NOTICE_DETAILS_PKG` | Transaction ID, notice date, bill/overpayment amount, outstanding balance, statutory line descriptions, reason codes | `fnd_global.apps_initialize`, `mo_global.set_policy_context('S', org_id)` |
| **3.1 Plain Language Notice Generator** | **Oracle EBS** | `ebs_get_document_attachment` | `FND_ATTACHED_DOCUMENTS`, `FND_DOCUMENTS`, `FND_DOCUMENTS_TL`, `FND_LOBS` | `FND_ATTACHED_DOCUMENTS_PKG.READ_ROW`, `APPS_AI.GET_BLOB_CONTENT` | Attached PDF letters, scanned determinations, file MIME type, byte stream (Base64) | APPS schema execution context; grants restricted to entity attachment categories |
| **3.1 Plain Language Notice Generator** | **PeopleSoft** | `ps_get_case_determination` | `PS_ITEM_SF`, `PS_ITEM_LINE_SF`, `PS_ACCOUNT_SF`, `PS_PERSONAL_DATA`, `PS_NAMES` | Component Interface: `SF_ACCOUNT_SUMMARY_CI`, IB Service: `SFA_GET_STUDENT_ACCOUNT.v1` | Account ID, constituent EMPLID, determination item code, amount due, recalculation history, billing dispute status | PeopleSoft `OPRID` session context; row-level security and SetID filtering |
| **3.1 Plain Language Notice Generator** | **PeopleSoft** | `ps_get_attachment_content` | `PS_ATTACHMENT_TBL`, `PSFILE_ATTDET`, `PS_SFA_DOC_ATTACH`, `PS_FILE_STORAGE` | PeopleCode: `GetAttachment()`, REST Service: `SCC_GET_ATTACHMENT.v1` | File name, attachment classification, binary byte stream (Base64), MIME type | OPRID authorization check on target parent record |
| **3.2 Redaction & FOIA Compliance** | **Oracle EBS** | `ebs_search_foia_records` | `PER_ALL_PEOPLE_F`, `PO_HEADERS_ALL`, `PO_LINES_ALL`, `AP_INVOICES_ALL`, `FND_ATTACHED_DOCUMENTS` | Custom query package: `APPS_AI.EBS_FOIA_SEARCH_PKG.SEARCH_DOCUMENTS` | Record ID, source module, creation date, creator username, document title, discovery classification | Cross-module discovery context; filtered by agency tenant Org ID |
| **3.2 Redaction & FOIA Compliance** | **Oracle EBS** | `ebs_get_employee_personnel_file` | `PER_ALL_PEOPLE_F`, `PER_ALL_ASSIGNMENTS_F`, `PER_DISCIPLINARY_ACTIONS`, `PER_ABSENCE_ATTENDANCES`, `FND_LOBS` | `HR_PERSON_API.GET_PERSON_DETAILS`, View: `APPS_AI.VW_FOIA_PERSONNEL_FILE` | Employee legal name, SSN/tax ID, DOB, job assignment, disciplinary notices, attached performance evals | Security profile context (`fnd_profile.value('PER_SECURITY_PROFILE_ID')`) |
| **3.2 Redaction & FOIA Compliance** | **PeopleSoft** | `ps_search_foia_records` | `PS_PERSONAL_DATA`, `PS_JOB`, `PS_PO_HDR`, `PS_PO_LINE`, `PS_VOUCHER`, `PS_ATTACHMENT_TBL` | Component Interfaces: `CI_PERSONAL_DATA`, `PO_PURCHASE_ORDER_CI`; QAS Services | Record category, reference ID, submission timestamp, party name, attachment count | PeopleSoft Permission List data permission security |
| **3.2 Redaction & FOIA Compliance** | **PeopleSoft** | `ps_get_employee_record_documents` | `PS_NAMES`, `PS_PERS_NID`, `PS_DISCIPLINARY`, `PS_GRIEVANCE`, `PS_PAY_CHECK`, `PS_HR_ATT_DATA` | Component Interface: `CI_JOB_DATA`, App Package: `HR_DOC_MGMT:DocumentHandler` | EMPLID, National ID (SSN), grievance filings, salary/payroll stubs, attached HR case documents | Row-level department security tree filtering |
| **3.3 Policy & Statute Assistant** | **Oracle EBS** | `ebs_get_agency_policy_rules` | `PO_CONTROL_RULES`, `PO_CONTROL_GROUPS`, `AP_EXPENSE_REPORT_PARAMS_ALL`, `FND_LOOKUP_VALUES`, `FND_PROFILE_OPTION_VALUES` | `PO_APPROVAL_LIST_PKG`, `AP_EXPENSE_PARAMS_PKG` | Policy parameter name, procurement signing thresholds, per-diem caps, travel rules, effective dates | Standard APPS schema access; Global profile options context |
| **3.3 Policy & Statute Assistant** | **Oracle EBS** | `ebs_search_policy_attachments` | `FND_ATTACHED_DOCUMENTS`, `FND_DOCUMENTS_TL`, `FND_LOBS` (linked to `FND_COMMON_OBJECTS` / Policy Entities) | `APPS_AI.EBS_POLICY_PKG.GET_POLICY_BLOB` | Policy title, transmittal number, effective date, full-text policy manual PDF byte streams | Public agency policy category filter |
| **3.3 Policy & Statute Assistant** | **PeopleSoft** | `ps_get_policy_catalog_rules` | `PS_EX_POLICY_TBL`, `PS_EX_LOC_DTL`, `PS_EX_PER_DIEM_TBL`, `PS_PO_APPR_RULE`, `PS_APPROVAL_RULE` | Integration Broker Service: `EX_GET_POLICY_RULES.v1`, CI: `EX_POLICY_TBL_CI` | Policy code, expense category, maximum daily lodging/meal rate, receipt required threshold, approval path | SetID business unit security context |
| **3.3 Policy & Statute Assistant** | **PeopleSoft** | `ps_search_policy_documents` | `PS_PORTAL_CONTENT`, `PS_EP_PUB_DOC`, `PS_ATTACHMENT_TBL` | Query Access Services (QAS) executing portal repository query handler | Document title, policy revision number, effective date, binary attachment byte stream | Portal folder permission security |
| **3.4 Document Intake Cleanup & Validation** | **Oracle EBS** | `ebs_get_intake_attachments` | `FND_ATTACHED_DOCUMENTS`, `FND_DOCUMENTS`, `FND_LOBS` (attached to intake staging tables) | `APPS_AI.GET_INTAKE_DOCS_PKG.FETCH_PENDING_ATTACHMENTS` | Intake queue ID, applicant ID, document category label (paystub, W-2, utility bill), image/PDF byte stream | APPS schema intake proxy execution |
| **3.4 Document Intake Cleanup & Validation** | **Oracle EBS** | `ebs_verify_party_identity` | `HZ_PARTIES`, `HZ_PERSON_PROFILES`, `HZ_LOCATIONS`, `HZ_PARTY_SITES`, `HZ_CONTACT_POINTS` | `HZ_PARTY_V2PUB.GET_PERSON`, `HZ_LOCATION_V2PUB.GET_LOCATION` | Party ID, legal name match score, tax ID/SSN hash match boolean, verified address, phone/email status | Multi-Org Access Control context |
| **3.4 Document Intake Cleanup & Validation** | **PeopleSoft** | `ps_get_constituent_documents` | `PS_SCC_ATT_DOC`, `PS_PROSPECT_DOC`, `PS_CHECKLIST_ITEM`, `PS_ATTACHMENT_TBL` | Component Interface: `SCC_INTAKE_DOC_CI`, REST Service: `SCC_GET_INTAKE_ATTACHMENT.v1` | Intake transaction ID, EMPLID, document category, binary byte stream | OPRID user context; checklist item status check |
| **3.5 RFP Vendor Evaluation Scorer** | **Oracle EBS** | `ebs_get_sourcing_rfp_details` | `PON_AUCTION_HEADERS_ALL`, `PON_AUCTION_ITEM_PRICES_ALL`, `PON_SCORING_CRITERIA`, `PON_AUCTION_TEAM_MEMBERS` | `PON_AUCTION_PKG`, `PON_EVALUATION_PVT` | Negotiation header ID, solicitation title, mandatory qualification criteria list, scoring rubric JSON | Sourcing Buyer / Evaluator security context |
| **3.5 RFP Vendor Evaluation Scorer** | **Oracle EBS** | `ebs_get_vendor_bids` | `PON_BID_HEADERS`, `PON_BID_ITEM_PRICES`, `FND_ATTACHED_DOCUMENTS`, `FND_LOBS` | `PON_BID_PKG.GET_BID_DETAILS`, `APPS_AI.GET_BID_ATTACHMENTS` | Bid number, vendor name, CAGE/DUNS code, technical response text, proposal attachment byte stream | Commercial-in-confidence isolation; sealed bid status validation |
| **3.5 RFP Vendor Evaluation Scorer** | **PeopleSoft** | `ps_get_strategic_sourcing_event` | `PS_AUC_EVENT_HDR`, `PS_AUC_EVNT_LINE`, `PS_AUC_RQD_DOC`, `PS_AUC_CRITERIA` | Component Interface: `AUC_EVENT_HDR_CI`, REST Service: `PS_GET_SOURCING_EVENT.v1` | Sourcing Event ID, event description, qualification checklist, rubric weightings, close date | Sourcing event business unit security |
| **3.5 RFP Vendor Evaluation Scorer** | **PeopleSoft** | `ps_get_vendor_responses` | `PS_AUC_BID_HDR`, `PS_AUC_BID_RESP`, `PS_AUC_ATTACHMENT`, `PS_ATTACHMENT_TBL` | Component Interface: `AUC_BID_ENTRY_CI` | Bid ID, vendor supplier ID, mandatory question responses, attached technical proposals and pricing exhibits | Sealed bid access control; Evaluator role authorization |
| **3.6 Expense Auditor** | **Oracle EBS** | `ebs_get_expense_reports` | `AP_EXPENSE_REPORT_HEADERS_ALL`, `AP_EXPENSE_REPORT_LINES_ALL`, `FND_ATTACHED_DOCUMENTS`, `FND_LOBS` | `AP_WEB_EXPENSE_WF.GET_REPORT_DETAILS`, View: `APPS_AI.VW_OIE_EXPENSE_AUDIT` | Expense report ID, employee name, report status, itemized expense breakdown (merchant, date, amount), receipt byte streams | Financial auditor responsibility context (`fnd_global.apps_initialize`) |
| **3.6 Expense Auditor** | **Oracle EBS** | `ebs_get_po_invoice_match` | `AP_INVOICES_ALL`, `AP_INVOICE_LINES_ALL`, `AP_INVOICE_DISTRIBUTIONS_ALL`, `PO_HEADERS_ALL`, `PO_LINES_ALL`, `RCV_TRANSACTIONS`, `GMS_AWARD_DISTRIBUTIONS` | `AP_MATCHING_PKG`, `PO_DOCUMENT_CHECKS_PVT` | Invoice ID, PO number, 3-way match status (Billed vs. Received vs. Ordered), 2 CFR 200 grant project/task, line variance amount | Org ID security context; AP auditor role |
| **3.6 Expense Auditor** | **PeopleSoft** | `ps_get_expense_sheets` | `PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_EX_SHEET_DIST`, `PS_EX_ATT_TBL`, `PS_ATTACHMENT_TBL` | Component Interface: `EX_EXP_SHEET.CI`, IB Service: `EX_GET_EXPENSE_REPORT.v1` | Expense sheet ID, employee EMPLID, itemized receipt breakdown, GL chartfields (Fund, Dept, Project/Grant), receipt image byte stream | Expenses auditor permission list; SetID security |
| **3.6 Expense Auditor** | **PeopleSoft** | `ps_get_voucher_details` | `PS_VOUCHER`, `PS_VOUCHER_LINE`, `PS_VCHR_LINE_WTHD`, `PS_PO_HDR`, `PS_PO_LINE_DISTRIB`, `PS_RECV_LN_SHIP`, `PS_PROJECT_RESOURCE` | Component Interface: `VOUCHER.CI`, IB Service: `VOUCHER_BUILD.v1` | Voucher ID, invoice number, matched PO line, receiving record confirmation, grant project chartfield, 3-way match status | Accounts Payable business unit security |

#### Technical Architecture & Security Topology

#### Oracle EBS R12.2 on Google Cloud (Compute Engine) Architecture

##### Architecture Narrative

Oracle EBS R12.2 application and database tiers run on Compute Engine (GCE) VMs within the agency's secure Google Cloud VPC. The Cloud Run EBS MCP Server interfaces directly with EBS over private VPC networking:

3. **Protocol Transport:** Gemini Enterprise communicates with the Customer-Managed Cloud Run EBS MCP Server via the standard MCP protocol (JSON-RPC over HTTPS / SSE).  
4. **Zero-Trust Identity Bridge (Santiago Bastidas's Recommendation):** Legacy Oracle EBS does not natively parse modern OAuth 2.0 / OIDC tokens. Following Santiago's identity bridge recommendation, the deployment utilizes **Oracle Identity Cloud Service (IDCS) with the EBS Asserter**. Gemini Enterprise passes the civil servant's Google Cloud Identity OAuth 2.0 / OIDC bearer token to Cloud Run. The MCP server queries the EBS Asserter / IDCS bridge to validate the token and assert the authenticated EBS user principal.  
5. **Database Session Context Initialization:** The Cloud Run server connects to the Oracle Database on GCE through a connection pool authenticated as a secure proxy user (`APPS_AI`). Prior to executing any business query, it initializes the EBS application context by invoking `fnd_global.apps_initialize(user_id, resp_id, resp_appl_id)` to enforce native EBS Function and Data Security (Multi-Org Access Control / MOAC).  
6. **Integration Interfaces:** Transactions and data queries are routed via Oracle Integrated SOA Gateway (ISG) REST/SOAP services and high-performance, validated PL/SQL APIs in the `APPS` schema.  
7. **Secret Management:** Database passwords, connection descriptors, and IDCS client secrets are retrieved dynamically from Google Cloud Secret Manager.

##### Architecture Topology: Oracle EBS R12.2 on GCE

```
+-----------------------------------------------------------------------------------+
|                        GOOGLE CLOUD PLATFORM (AGENCY TENANT)                      |
|                                                                                   |
|   +------------------------------------+                                          |
|   |         Gemini Enterprise          |                                          |
|   |  - Chat UI & Agentic AI Harness    |                                          |
|   |  - Personas: Admin, User, Agents   |                                          |
|   +-----------------+------------------+                                          |
|                     |                                                             |
|                     | MCP Protocol (JSON-RPC over HTTPS / SSE)                    |
|                     v                                                             |
|   +-----------------+------------------+                                          |
|   |    Customer-Managed Cloud Run      | <------+ Google Cloud Secret Manager     |
|   |  - Oracle EBS MCP Server (OSS)     |        | (DB Credentials & IDCS Secrets) |
|   |  - Serverless VPC Access Connector |        +---------------------------------+
|   +-----------------+------------------+                                          |
+---------------------|-------------------------------------------------------------+
                      |
                      | Private Egress (Serverless VPC Access)
                      v
+-----------------------------------------------------------------------------------+
|              IDENTITY & AUTH BRIDGE (SANTIAGO'S RECOMMENDATION)                   |
|                                                                                   |
|   Google Cloud Identity OIDC Token  -->  Oracle IDCS with EBS Asserter            |
|                                          - Validates Token & Asserts EBS User     |
|                                          - Sets fnd_global.apps_initialize Context|
+-----------------------------------------------------+-----------------------------+
                                                      |
                                                      | Private VPC Network
                                                      v
+-----------------------------------------------------------------------------------+
|             ORACLE EBS R12.2 HOSTED ON GOOGLE CLOUD (COMPUTE ENGINE)              |
|                                                                                   |
|   +------------------------------------+  +-----------------------------------+   |
|   |      EBS Application Tier (GCE)    |  |       EBS Database Tier (GCE)     |   |
|   |  - Integrated SOA Gateway (ISG)    |  |  - Oracle Database 19c on GCE     |   |
|   |  - REST / WebLogic Services        |  |  - APPS Schema PL/SQL API Packages|   |
|   |  - Concurrent Processing & Forms   |  |  - MOAC & EBS Security Context    |   |
|   +------------------------------------+  +-----------------------------------+   |
+-----------------------------------------------------------------------------------+
```

#### PeopleSoft 9.2 on Google Cloud (Compute Engine) Architecture

##### Architecture Narrative

PeopleSoft 9.2 is hosted on Compute Engine (GCE) VMs within the agency's Google Cloud VPC. The Customer-Managed Cloud Run PeopleSoft MCP Server establishes low-latency, private connectivity to PeopleSoft services:

1. **Protocol Transport:** Gemini Enterprise communicates with the Customer-Managed Cloud Run PeopleSoft MCP Server via MCP JSON-RPC over HTTPS.  
2. **Identity Bridge & Token Mapping (Santiago's Recommendation & OIDC Component):** Following Santiago's identity bridge framework, PeopleSoft leverages **Oracle Identity Cloud Service (IDCS) federation** in tandem with PeopleSoft's native **OpenID Connect (OIDC) / Sign-on PeopleCode** integration. The civil servant's Google Cloud Identity token is verified against IDCS, and PeopleSoft Sign-on PeopleCode maps the token identity to the corresponding PeopleSoft Operator ID (`OPRID`), ensuring strict enforcement of PeopleSoft Permission Lists, Roles, and Row-Level Security.  
3. **Integration Interfaces:** The Cloud Run MCP server communicates with the PeopleSoft Pure Internet Architecture (PIA) and Tuxedo Application Server on GCE via **PeopleSoft Integration Broker (REST/JSON)** endpoints and Component Interfaces (CI) to execute synchronous validations and business logic.  
4. **Data Access & Session Context:** Internal relational queries execute against the PeopleSoft Database on GCE with session-level security filtering based on the asserted `OPRID`.  
5. **Secret Management:** PeopleSoft node passwords, keystores, and IDCS integration credentials reside in Google Cloud Secret Manager.

##### Architecture Topology: PeopleSoft 9.2 on GCE

```
+-----------------------------------------------------------------------------------+
|                        GOOGLE CLOUD PLATFORM (AGENCY TENANT)                      |
|                                                                                   |
|   +------------------------------------+                                          |
|   |         Gemini Enterprise          |                                          |
|   |  - Chat UI & Agentic AI Harness    |                                          |
|   |  - Personas: Admin, User, Agents   |                                          |
|   +-----------------+------------------+                                          |
|                     |                                                             |
|                     | MCP Protocol (JSON-RPC over HTTPS / SSE)                    |
|                     v                                                             |
|   +-----------------+------------------+                                          |
|   |    Customer-Managed Cloud Run      | <------+ Google Cloud Secret Manager     |
|   |  - PeopleSoft MCP Server (OSS)     |        | (Node Credentials & API Keys)   |
|   |  - Serverless VPC Access Connector |        +---------------------------------+
|   +-----------------+------------------+                                          |
+---------------------|-------------------------------------------------------------+
                      |
                      | Private Egress (Serverless VPC Access)
                      v
+-----------------------------------------------------------------------------------+
|              IDENTITY & AUTH BRIDGE (SANTIAGO'S RECOMMENDATION)                   |
|                                                                                   |
|   Google Cloud Identity OIDC Token  -->  Oracle IDCS / OIDC IdP Federation        |
|                                          - PeopleSoft Sign-on PeopleCode / OIDC   |
|                                          - Validates Token & Asserts PS OPRID     |
|                                          - Applies Permission Lists & Row Security|
+-----------------------------------------------------+-----------------------------+
                                                      |
                                                      | Private VPC Network
                                                      v
+-----------------------------------------------------------------------------------+
|              PEOPLESOFT 9.2 HOSTED ON GOOGLE CLOUD (COMPUTE ENGINE)               |
|                                                                                   |
|   +------------------------------------+  +-----------------------------------+   |
|   |  PeopleSoft Application Tier (GCE) |  |   PeopleSoft Database Tier (GCE)  |   |
|   |  - PIA / WebLogic Web Server       |  |  - Oracle Database 19c on GCE     |   |
|   |  - Tuxedo Application Server       |  |  - PS Schema with OPRID Filtering |   |
|   |  - Integration Broker (REST/JSON)  |  |  - FSCM & HCM Enterprise Tables   |   |
|   |  - Component Interfaces (CI)       |  |  - Campus Solutions Schemas       |   |
|   +------------------------------------+  +-----------------------------------+   |
+-----------------------------------------------------------------------------------+
```

### 