# PeopleSoft tools vs the `google_oracle_skills`: coverage

Prepared 2026-10-08. PeopleSoft only. Nothing under `google_oracle_skills/` was changed (it is git-ignored and was only read).

This is the PeopleSoft counterpart of [`ebs_tools_vs_skills_coverage.md`](ebs_tools_vs_skills_coverage.md). It reuses that audit's skill-needs lists (the five `SKILL.md` files are dated 2026-09-24 to 2026-10-05, so they predate it and are unchanged) and checks each need against `peoplesoft/sql/*.sql`.

**Evidence level: SQL read, plus a live `EXPLAIN PLAN` of all 18 statements on 2026-10-08** (as `SYSADM_AI` on `HR92U054`, through the tunnel on port 1522; nothing was executed against data except row counts). Items marked *Verify* are still unconfirmed; *Certain* items are visible in the SQL or confirmed by the database.

## 0. Live result (2026-10-08): 13 of 18 tools cannot run on this database

`HR92U054` is a **PeopleSoft HCM database** (33,359 `PS_` tables, mostly Time and Labor, Global Payroll, Payroll and HR) with only the FSCM *setup* tables. The FSCM and Campus transaction tables the tools read are **not there**.

| Result | Tools |
| :--- | :--- |
| **Parse OK (5)** | `ps_list_business_units`, `ps_list_setids`, `ps_list_translate_values`, `ps_lookup_constituents`, `ps_verify_constituent_data` |
| **ORA-00942, table missing (13)** | all other tools |

30 of the 43 tables the SQL references do not exist:
- **Expenses:** `PS_EX_SHEET_HDR`, `PS_EX_SHEET_LINE`, `PS_EX_SHEET_DIST`, `PS_EX_ATT_TBL`, `PS_EX_POLICY_TBL`, `PS_EX_PER_DIEM_TBL`
- **Sourcing:** `PS_AUC_EVENT_HDR`, `PS_AUC_EVNT_LINE`, `PS_AUC_CRITERIA`, `PS_AUC_RQD_DOC`, `PS_AUC_BID_HDR`, `PS_AUC_BID_RESP`, `PS_AUC_ATTACHMENT`, `PS_BIDDER_HDR`
- **Purchasing and projects:** `PS_PO_HDR`, `PS_PO_LINE_DISTRIB`, `PS_RECV_LN_SHIP`, `PS_PROJECT_RESOURCE`
- **Student Financials and Campus:** `PS_ITEM_SF`, `PS_ITEM_LINE_SF`, `PS_ACCOUNT_SF`, `PS_SCC_ATT_DOC`
- **Attachments and portal:** `PS_ATTACHMENT_TBL`, `PS_FILE_STORAGE`, `PS_PORTAL_CONTENT`, `PS_EP_PUB_DOC`
- **HR:** `PS_DISCIPLINARY`, `PS_HR_ATT_DATA`

Further facts:
- **Present but empty:** `PS_VOUCHER` has 0 rows (shared table); `PS_GRIEVANCE` has 0. `PS_VENDOR` has 77 rows, `PS_CHECKLIST_ITEM` 318, `PS_PAY_CHECK` 122,576, `PS_NAMES` 19,814.
- **Attachments:** `PS_ATTACHMENT_TBL` and `PS_FILE_STORAGE` are not PeopleSoft records here. The attachment store that exists is `PSFILE_ATTDET` (2,813 rows; columns `ATTACHSYSFILENAME, FILE_SEQ, VERSION, FILE_SIZE, FILE_DATA`) and `PSFILEDATA` (chunked blobs). There is no file name or MIME type column in `PSFILE_ATTDET`; those live in the owning component's own attachment record (for HR, the `PS_HR_ATT_*` tables). So `ps_get_attachment_content`, which needs `PS_FILE_STORAGE`, cannot work as written.
- **Present and usable as setup data:** `PS_PROJECT`, `PS_PROJ_*` (project setup), `PS_GM_TEC_*` (grants time and effort), `PS_BUS_UNIT_TBL_*`, `PS_CHECKLIST_*`, `PS_DISCIPLIN_ACTN/LTR/STEP`, `PS_GRIEV_*`, `PS_HR_ATT_*`, `PS_PERS_NID`.

**Consequence:** for the expense, sourcing, voucher, student-financial, policy and portal tools, the column-level findings in section 3 are *design* findings: they are valid for the intended FSCM database but were never confirmed, and these tools need an FSCM database (or a redesign onto HCM tables) before any of them can be tested. Only the discovery and identity tools work on this instance. The README's listing of 18 working PeopleSoft tools is therefore not true for this target.

## 1. Skill inventory vs toolsets

| Toolset in `peoplesoft/tools.yaml` | Skill in `google_oracle_skills/` | Tools | Fit |
| :--- | :--- | :--- | :--- |
| `expense_auditor` | `expense_auditor` | 2 | **Weak.** EBS has 7 tools for this skill; PeopleSoft has the raw sheet and voucher reads only (section 2). |
| `rfp_vendor_evaluation_scorer` | `rfp_vendor_evaluation_scorer` | 2 | **Weak.** Same shape as the EBS tools before their fixes, with the same fan-out and price-separation problems. |
| `policy_and_statute_assistant` | `policy_and_statute_assistant` | 2 | **Partial.** No effective-date handling, so `as_of_date` cannot drive the query. |
| `document_intake_cleanup_and_validation` | `document_intake_cleanup_and_validation` | 2 | **Thin.** Campus-style intake (`PS_SCC_ATT_DOC`, checklists) is the right idea; the join logic is not sound. |
| `plain_language_notice_generator` | `plain_language_notice_generator` | 2 | **Conflict.** `ps_get_case_determination` returns a named individual's determination, which the skill must refuse. |
| `redaction_and_foia_compliance` | **None** | 2 | **No skill** (decision F1 in the EBS audit applies equally). `ps_get_employee_record_documents` returns the full national ID plus discipline and pay data. |
| `schema_discovery_and_lovs` | (shared helpers) | 6 | Serves every skill, but is missing the two most useful tools EBS has: table description and attachment text. |

PeopleSoft has **18 tools, EBS has 25.** The seven EBS tools PeopleSoft lacks are the ones added after live auditing: `list_expense_reports`, `find_duplicate_expense_lines`, `get_expense_report_approval_and_payment`, `get_award_terms`, `get_award_expenditures`, `describe_table`, `get_attachment_text`.

## 2. Tool-by-tool map

| Tool | Skill (toolset) | Skill actually uses it for | State |
| :--- | :--- | :--- | :--- |
| `ps_get_expense_sheets` | expense_auditor | Line items, receipts, chartfields | **Defects** (3.1) |
| `ps_get_voucher_details` | expense_auditor | Three-way match, grant project | **Defects, one likely wrong join** (3.1) |
| `ps_get_strategic_sourcing_event` | rfp_vendor_evaluation_scorer | Solicitation, requirements, rubric | **Defects** (3.2) |
| `ps_get_vendor_responses` | rfp_vendor_evaluation_scorer | Vendor responses and files | **Defects** (3.2) |
| `ps_get_policy_catalog_rules` | policy_and_statute_assistant | Expense limits, per diem | No effective-date logic (3.3) |
| `ps_search_policy_documents` | policy_and_statute_assistant | Agency manuals | **Defects** (3.3) |
| `ps_get_constituent_documents` | document_intake_cleanup_and_validation | Submitted proof documents | **Defects** (3.4) |
| `ps_verify_constituent_data` | document_intake_cleanup_and_validation | Identity cross-check | **Defects** (3.4) |
| `ps_get_case_determination` | plain_language_notice_generator | (skill must refuse this data) | **Conflict** (3.5) |
| `ps_get_attachment_content` | plain_language_notice_generator | Source document | Raw blob only; not readable |
| `ps_search_foia_records` | redaction_and_foia_compliance | (no skill) | Decision F1 |
| `ps_get_employee_record_documents` | redaction_and_foia_compliance | (no skill) | Decision F1; unmasked national ID |
| 6 discovery tools | schema_discovery_and_lovs | Parameter grounding | One inconsistency between tools (3.6) |

## 3. Findings per skill

### 3.1 `expense_auditor` (needs: EBS round 1, section 1)

| EBS-audit need | PeopleSoft coverage today | Status |
| :--- | :--- | :--- |
| Population and sample selection | None. `ps_get_expense_sheets` with every parameter empty returns **every line of every sheet** (no row cap). No list tool. | **Gap + defect** |
| Ledger integrity: lines sum to total | Lines and `total_amount` returned. | Covered, but see fan-out below |
| Currency, receipt-required rule, receipt present | Not returned. Attachment filename only; no per-line receipt flag, no required-amount rule. | **Gap** |
| Award terms, funding stream, period of performance, budget | Nothing. `PS_PROJECT_RESOURCE` is joined only to show a project ID. | **Gap** (*Verify*: Grants and Contracts records) |
| Allocation (project, fund, dept) | `fund_code`, `deptid`, `project_id` from `PS_EX_SHEET_DIST`. | Covered, if the table is right |
| Approval trail, segregation of duties, paid date | Status only. | **Gap** (*Verify*: Approval Framework records, voucher link) |
| Per diem and travel detail (location, days, airfare class) | Only `expense_type`, `merchant`, purpose. | **Gap** |
| Duplicate billing | Nothing. | **Gap** |
| Capital equipment, PO match, sourcing link | `ps_get_voucher_details` (below). | Partial |

**Defects, *Certain* from the SQL:**
- `ps_get_expense_sheets` joins distributions and attachments separately on the line, so a line with 2 distributions and 3 receipts returns **6 rows** and amounts repeat. The EBS tools needed exactly this fix.
- No `FETCH FIRST` and no required parameter: an unfiltered call is a full table read.
- `ps_get_voucher_details` joins the PO distribution on `vline.po_id = pdist.po_id AND vline.line_nbr = pdist.line_nbr`, which compares the **voucher** line number to the **PO** line number. PeopleSoft vouchers carry a separate PO line and schedule reference (*Verify* `PS_VOUCHER_LINE` and `PS_DISTRIB_LINE`/`PS_PO_LINE_DISTRIB` keys), so `match_variance` is probably computed against the wrong line. It also joins `PS_PO_HDR` on `po_id` alone (PO keys include the business unit) and `PS_PROJECT_RESOURCE` on project alone, which multiplies each voucher line by every resource row in the project.
- The column `grant_project_chartfield` is just a project ID; it says nothing about a grant.

### 3.2 `rfp_vendor_evaluation_scorer` (needs: EBS audit section 3.1)

| Need | PeopleSoft coverage | Status |
| :--- | :--- | :--- |
| Solicitation identity, type, dates | `ps_get_strategic_sourcing_event`: description, status, start and close. No event type. | Partial |
| Addenda applied in order | Nothing. | **Gap** (*Verify*: event versions or amendments in Strategic Sourcing) |
| Requirements register, mandatory vs scored | `criteria_description` and `weighting_pct` only; no section, no mandatory flag, no text. | Partial |
| Rubric with rating definitions | Nothing. | **Gap** |
| Solicitation documents | Nothing; `PS_AUC_RQD_DOC` returns the required document **type**, not files. | **Gap** |
| Vendor response per requirement | Only one `technical_response` text per **line**; none per criterion. | **Gap**, the largest |
| Vendor proposal files | Filename only. | Partial; needs the text tool |
| Versions of one bid, submission time, addenda acknowledged | `bid_status` excludes `SAVED` and `CANCELLED`; superseded revisions not flagged; no submission date. | **Gap + defect** |
| Price separation | Price and technical response in the same row. | **Conflict** (skill: do not open price files) |
| Vendor legal identity | `bidder_id` only. | Partial (`ps_lookup_suppliers_bidders` helps) |

**Defects, *Certain*:** `ps_get_strategic_sourcing_event` joins lines, criteria and required documents independently, so the result is **lines × criteria × documents** (the same fan-out the EBS tool had: 20 × 30 × 4 = 2,400 rows). `ps_get_vendor_responses` joins attachments on `bid_id` only, so every response line repeats once per attachment, and attachments are not tied to a line. Both tools require string IDs but accept no "find by event ID alone" (business unit is mandatory on the first).

### 3.3 `policy_and_statute_assistant` (needs: EBS round 2, section 3)

| Need | PeopleSoft coverage | Status |
| :--- | :--- | :--- |
| Federal and state law | Not in PeopleSoft. | **Outside this server** (external connectors) |
| Agency's own policies with effective dates | `ps_search_policy_documents`: title, folder, summary, status, effective date; attachment name. | Partial, see defects |
| `as_of_date` drives retrieval | None. `PS_EX_POLICY_TBL` and per-diem tables are effective-dated, but the query neither takes a date nor selects the latest `EFFDT` ≤ date, so it returns **every historical version, active and inactive**. | **Gap + defect** |
| Thresholds from source | Receipt threshold and per-diem rate, per SetID. No approval limits or procurement thresholds. | Partial |
| Jurisdiction | Nothing. | **Gap** |
| Read policy text | Only `ps_get_attachment_content` (blob). | **Gap** |

**Defects:** `ps_search_policy_documents` joins `PS_ATTACHMENT_TBL` on `cnt.portal_objname = att.attachsysfilename`, which equates a portal object name with a stored file name and will almost never match (*Verify*); `ORDER BY pub.effdt DESC FETCH FIRST 20` hides older versions, and `eff_status` is shown but not filtered. The per-diem join has no location, so one policy returns a row per location.

### 3.4 `document_intake_cleanup_and_validation` (needs: EBS round 2, section 2)

| Need | PeopleSoft coverage | Status |
| :--- | :--- | :--- |
| Fetch submitted documents | `ps_get_constituent_documents`: filename, MIME type, size, category, checklist status. No content. | Partial |
| Page count and sequence, document class | Category only. | **Gap** |
| Upload date for the lookback window | Not returned. | **Gap** |
| Identity cross-check | `ps_verify_constituent_data`: name match score, last-digits ID match, home address. | Partial |
| DOB, mailing or service address, employer | Not returned (address type fixed to `HOME`). | **Gap** |
| Case context | Intake transaction ID exists (`SCC_INTAKE_TRANS_ID`). | Better than EBS |

**Defects:** `ps_get_constituent_documents` joins the checklist on `emplid` alone, so every checklist item for the person is paired with every document (**documents × checklist items**) and the status shown is unrelated to the document; no cap. `ps_verify_constituent_data` has no required parameter: with all inputs empty it returns the first 10 people in the table. Names and addresses are effective-dated in PeopleSoft but read without an `EFFDT` filter, so a person who changed name or address appears more than once. The `name_match_confidence` value of 50 is unreachable when a name is supplied. The ID check compares a user-supplied suffix with `LIKE '%' || nid` against the full number, and the response also returns the full home address.

### 3.5 `plain_language_notice_generator`

The skill needs the text of population-level notices, agency contact details and language-access blocks, and refuses anything about an individual. `ps_get_case_determination` returns a named person, account, determination amount and balance for one `emplid`: same **conflict** as EBS decision N6 (retire it from this skill, de-identify it, or keep it for another skill). It also inner-joins `PS_ACCOUNT_SF` without using any column from it, and reads Student Financials (`PS_ITEM_SF`, a Campus Solutions record) from what the README calls an HCM/FSCM database, so it may not exist there (*Verify*). Nothing returns notice templates or agency contacts (*Gap*, same as N2 to N4); attachments come back as raw blobs with `FETCH FIRST 1 ROWS` and no way to see which of several matched.

### 3.6 Discovery tools and internal inconsistencies

- **Two tools disagree about the same record, so at least one fails with ORA-00904 (*Certain*):** `PS_EX_SHEET_HDR` is read as `posted_date` / `total_amount` by `ps_get_expense_sheets` but as `sheet_dttm` / `total_amt` by `ps_lookup_recent_transactions`; `PS_AUC_EVENT_HDR` is read as `start_dt` / `end_dt` by the sourcing tool but as `event_dttm` by the lookup. Also `PS_PROJECT_RESOURCE` looks like a misnamed `PS_PROJ_RESOURCE` (*Verify*).
- `ps_lookup_recent_transactions`: the `PO` branch returns a hard-coded `0` total; the `EXPENSE` branch ignores `business_unit` (it returns `p.business_unit` as if it were the sheet's); `LIKE '%...%'` on keys.
- `ps_lookup_constituents` returns birthdate and city for any name search, so it exposes more personal data than the intake tool's `HOME` address check; it also has no row cap on the person table beyond 25 and no effective-dating.
- `ps_list_business_units` is capped at 50 with no paging or search; `ps_list_setids` and `ps_list_translate_values` are fine as lookups.
- **Effective dating is not handled anywhere** except as a displayed column: 0 of 18 queries select the row in force on a date. This affects names, addresses, policy tables, translate values and the portal content. It is the PeopleSoft-specific version of the EBS `as_of_date` gap, and the biggest systematic risk.
- **No live validation:** no explain plan and no `scripts/test_live_*` coverage for PeopleSoft (the existing live scripts cover EBS only).
- Tool descriptions name Component Interfaces and IB services (`EX_EXP_SHEET.CI`, `VOUCHER_BUILD.v1`, `AUC_BID_ENTRY_CI`, ...) that the SQL never calls, and a "Security Context" the tool does not apply without the wrapper. These descriptions are shown to the agent and mislead it (same defect fixed for EBS in DECISIONS.md §11c).

## 4. Proposed work

Ordered like the EBS backlog: decisions, defects, then new tools.

| Order | Item | Why / fills |
| :--- | :--- | :--- |
| 0 | **Choose the target database** (section 0): an FSCM (and Campus, if the notice tool stays) instance, or redesign the tools onto the HCM tables that exist. Then run each query live and fix column names (3.6). | 13 of 18 tools cannot run on `HR92U054`. |
| 1 | **Decisions:** F1 (FOIA tools, no skill; mask `national_id`), N6 (case determination), D4 (identity data returned), whether the target database actually holds FSCM and Campus data. | They decide which tools stay. |
| 2 | **Defect fixes:** fan-out joins (3.1, 3.2, 3.4); row caps and required parameters on `ps_get_expense_sheets`, `ps_verify_constituent_data`; voucher-to-PO key; policy attachment join; correct descriptions. | Small, read-only, stop wrong data. |
| 3 | **Effective dating** across names, addresses, policy tables with an `as_of_date` parameter (`EFFDT <= date`, latest row). | Policy skill invariant; avoids duplicate people. |
| 4 | **PS-A1 `ps_describe_table`** (`PSRECDEFN`, `PSRECFIELD`, `ALL_TAB_COLUMNS`) and **PS-A2 `ps_get_attachment_text`** (the `PS_FILE_STORAGE` content as text, same limits as EBS: PDF/Word need a DBA function). | Unblocks every *Verify*, and four document-centric skills. |
| 5 | **Expense tools to match EBS:** `ps_list_expense_sheets` (population, receipt flags), `ps_find_duplicate_expense_lines`, `ps_get_expense_approval_and_payment`, `ps_get_award_terms` and `ps_get_award_expenditures` (Grants, Contracts, Project Costing), per-diem schedules by location. | Skill expense_auditor needs 1, 2, 7 to 9, 11, 17, 18. |
| 6 | **RFP structure:** separate requirements tool (section, text, mandatory, weight, rating scale), per-requirement vendor responses with an `include_prices` switch default off, event amendments, solicitation documents, bid revisions and submission time. | Needs 2 to 11 in section 3.2. |
| 7 | **Discovery additions** (agency contacts, jurisdiction, approval limits, employer) once the dictionary shows what exists. | Notice, policy and intake skills. |

Outside this server in every case, as for EBS: eCFR and state codes, SAM.gov debarment, GSA per diem rates, image quality and OCR.

## 5. What I need from you

1. **Is there a PeopleSoft FSCM database (and Campus Solutions, for student financials) we can reach?** Without it, the expense, sourcing, voucher, policy and notice tools cannot be tested. If not, say which HCM-side data the skills should be served from (for example `PS_PAY_CHECK`, `PS_GM_TEC_*` time and effort, `PS_PROJECT`, HR attachments) and I will redesign around those.
2. F1, N6 and D4 decisions above; the EBS answers (F1: keep as placeholders; N6 and D4 still open) are the likely defaults.

## 6. Follow-up (2026-10-08): HCM redesign built

The 13 failing tools were left in place (disabled) and 15 replacement tools, `ps_hcm_*`, were built on the HCM tables that exist (DECISIONS.md section 12; README "PeopleSoft 9.2 HCM Tools"). Coverage on this database now:

| Skill | HCM toolset | Tools | What is still not servable from HCM |
| :--- | :--- | :--- | :--- |
| `expense_auditor` | `ps_hcm_expense_auditor` | 4 (labor distribution, duplicate time, payroll earnings, project setup) | expense reports, receipts, vouchers and PO match, per diem, award terms and budgets |
| `rfp_vendor_evaluation_scorer` | `ps_hcm_rfp_vendor_evaluation_scorer` | 1 (vendor profile) | solicitations, requirements, rubric, bids, addenda |
| `policy_and_statute_assistant` | `ps_hcm_policy_and_statute_assistant` | 3 (leave rules, earnings rules, document search), all with `as_of_date` | law and regulations (external), portal policy library |
| `document_intake_cleanup_and_validation` | `ps_hcm_document_intake_cleanup_and_validation` | 1 (person documents), plus the enabled `ps_verify_constituent_data` | document content beyond text files, image checks |
| `plain_language_notice_generator` | `ps_hcm_plain_language_notice_generator` | 2 (agency contacts, attachment text) | notice templates, TTY and URLs |
| FOIA (no skill) | `ps_hcm_redaction_and_foia_compliance` | 2 | POs and vouchers |
| discovery | `ps_hcm_schema_discovery_and_lovs` | 2 (recent transactions, describe table) | |

Findings from the build: unused Time and Labor fields hold a blank, not NULL; `PS_CHECKLIST_ITEM` is a template table, not per-person status; payroll regular earnings are spread across three columns; payable status `DL` and `IG` entries (Diluted, Ignore) would otherwise look like duplicates; `PS_PAY_OTH_EARNS.EX_DOC_ID` exists for expense reimbursements paid through payroll but is empty in this database.
