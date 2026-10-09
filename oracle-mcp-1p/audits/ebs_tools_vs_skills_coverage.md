# EBS tools vs the `google_oracle_skills`: consolidated coverage

Prepared 2026-10-07. EBS only. Nothing under `google_oracle_skills/` was changed.

This document brings the earlier audits together and adds the one skill they did not cover:
- Round 1 (2026-10-05): [`expense_auditor_vs_ebs_tools_gap_analysis.md`](expense_auditor_vs_ebs_tools_gap_analysis.md). Built and run live; six tools were added or extended.
- Round 2 (2026-10-06): [`other_skills_vs_ebs_tools_gap_analysis.md`](other_skills_vs_ebs_tools_gap_analysis.md), covering the notice, intake and policy skills. Read from the SQL only, never run live.
- **New here:** `rfp_vendor_evaluation_scorer` (section 3), the skill inventory check (section 1), and a re-check of which earlier defects are still in the code (section 4).

**Not run live.** The `ebs` MCP server was unreachable on 2026-10-07 (connection refused). Items marked *Verify* are EBS columns to check with `ebs_describe_table` before building; items marked *Confirm live* are read from the SQL and need one query to confirm.

## 1. Skill inventory vs toolsets

The skills say what data they need; none of them names an MCP tool. `ebs/tools.yaml` has 7 toolsets with 24 tools. `google_oracle_skills/` has **5** skills.

| Toolset in `ebs/tools.yaml` | Skill in `google_oracle_skills/` | Tools | Fit |
| :--- | :--- | :--- | :--- |
| `expense_auditor` | `expense-auditor` | 7 | **Good** after round 1. Remaining gaps are listed in round 1, section 7. |
| `rfp_vendor_evaluation_scorer` | `rfp-vendor-evaluation-scorer` | 2 | **Weak.** The skill reads documents; the tools return structured rows with defects (section 3). |
| `policy_and_statute_assistant` | `policy-and-statute-assistant` | 2 | **Partial.** The law comes from external connectors. EBS supplies only the agency's own rules and documents (round 2, section 3). |
| `document_intake_cleanup_and_validation` | `document-intake-cleanup-and-validation` | 2 | **Thin.** EBS is not a benefits or case system (round 2, section 2). |
| `plain_language_notice_generator` | `plain-language-notice-generator` | 2 | **Conflict.** The main tool returns individual determinations with PII, which the skill must refuse (round 2, section 1). |
| `redaction_and_foia_compliance` | **None** | 2 | **No skill.** The PRD names this skill, but it is not in `google_oracle_skills/`. Two other skills explicitly exclude FOIA work (policy: "Don't use for ... PII redaction or FOIA logs"; intake: "Don't use for ... FOIA public records media response letters"). |
| `schema_discovery_and_lovs` | (shared helpers) | 7 | Serves every skill: operating units, lookups, parties, employees, recent transactions, attachment entities, table metadata. |

**F1, decided 2026-10-07:** the FOIA skill hasn't been delivered yet, so `redaction_and_foia_compliance` stays a placeholder and its two tools are left unchanged until it arrives. The original question was: `ebs_search_foia_records` and `ebs_get_employee_personnel_file` serve no skill, and the second returns the full national identifier (`ssn_tax_id`). The options are:
- keep them for a FOIA skill that is still to come;
- mask the identifier now, as already done in `ebs_lookup_employees`;
- move them out of the plugin's toolsets until a FOIA skill exists.

## 2. Tool-by-tool map

| Tool | Skill (toolset) | Skill actually uses it for | State |
| :--- | :--- | :--- | :--- |
| `ebs_list_expense_reports` | expense_auditor | Population and sample selection | Built round 1, run live |
| `ebs_get_expense_reports` | expense_auditor | Line items, receipts flags, travel detail | Extended round 1, run live |
| `ebs_find_duplicate_expense_lines` | expense_auditor | Duplicate billing | Built round 1, run live |
| `ebs_get_expense_report_approval_and_payment` | expense_auditor | Approval trail, incurred vs paid | Built round 1, run live |
| `ebs_get_award_terms` | expense_auditor | Notice of Award, funding stream, period | Built round 1, run live |
| `ebs_get_award_expenditures` | expense_auditor | Costs charged to an award, out-of-period costs | Built round 1, run live |
| `ebs_get_po_invoice_match` | expense_auditor | Three-way match, capital equipment | PO filter bug fixed round 1; enrichment still open (E3) |
| `ebs_get_sourcing_rfp_details` | rfp_vendor_evaluation_scorer | Solicitation, requirements, rubric | **Defects** (section 3.2) |
| `ebs_get_vendor_bids` | rfp_vendor_evaluation_scorer | Vendor responses and files | **Defects** (section 3.2) |
| `ebs_get_agency_policy_rules` | policy_and_statute_assistant | Agency approval limits and expense rules | Org filter and cap added round 1; no `as_of_date` |
| `ebs_search_policy_attachments` | policy_and_statute_assistant | Agency manuals and transmittals | **Defects** (round 2, 3.2) |
| `ebs_get_intake_attachments` | document_intake_cleanup_and_validation | Citizen-submitted documents | **Defects** (round 2, 2.2) |
| `ebs_verify_party_identity` | document_intake_cleanup_and_validation | Identity cross-check | **Defects** (round 2, 2.2) |
| `ebs_get_constituent_notice_details` | plain_language_notice_generator | (skill must refuse this data) | **Conflict and defect** (round 2, 1.2) |
| `ebs_get_document_attachment` | plain_language_notice_generator | Source document of a notice | Raw blob only; not readable |
| `ebs_search_foia_records` | redaction_and_foia_compliance | (no skill) | Decision F1 |
| `ebs_get_employee_personnel_file` | redaction_and_foia_compliance | (no skill) | Decision F1; unmasked SSN |
| 7 discovery tools | schema_discovery_and_lovs | Parameter grounding | `ebs_lookup_employees` SSN masked in round 1 |

## 3. `rfp_vendor_evaluation_scorer` (new)

### 3.1 What the skill needs

The skill is built around **documents**. It compares the solicitation, its addenda and rubric against each vendor's proposal files, cites section and page for every finding, checks the files for consistency with each other, and never proposes a score. EBS Sourcing holds the structured side of that: the negotiation, its amendments, requirements and scoring setup, and each bid's responses and attachments.

| # | Need (skill ref) | Tool coverage today | Status |
| :--- | :--- | :--- | :--- |
| 1 | Governing solicitation: identity, type (RFP, RFQ, RFI), title, due date (Header block, Phase 1) | `ebs_get_sourcing_rfp_details`: number, title, status, open and close dates. No document type. | Partial (*Verify* `DOCTYPE_ID` → `PON_AUC_DOCTYPES`) |
| 2 | **Addenda applied in order, latest governs** (Phase 2) | Nothing. Sourcing stores each amendment as a new negotiation version. | **Gap** (*Verify* `AMENDMENT_NUMBER`, `AUCTION_HEADER_ID_ORIG_AMEND`, `AUCTION_HEADER_ID_PREV_AMEND`) |
| 3 | Requirements register: mandatory vs scored, by section (Phase 3) | `attribute_name`, `mandatory_flag`, `weight`, `scoring_method`; no section, no requirement text, header and line attributes mixed. | Partial (*Verify* `SECTION_NAME`, `LINE_NUMBER = -1` for header requirements, `PON_AUCTION_SECTIONS`) |
| 4 | Rubric: weights and **rating definitions quoted verbatim** (Phase 6) | Weight only. | **Gap** (*Verify* `PON_ATTRIBUTE_SCORES`: value or range → score; `KNOCKOUT_SCORE`, maximum score) |
| 5 | Solicitation documents: base RFP, Section L/M, attachments (Phase 1) | Nothing. Attachments on the negotiation are not queried. | **Gap** (`FND_ATTACHED_DOCUMENTS` with entity `PON_AUCTION_HEADERS_ALL`; *Verify* entity name with `ebs_list_attachment_entities`) |
| 6 | Each vendor's **response to each requirement** (compliance matrix, Phase 4) | Nothing. Only one free-text note per line. | **Gap**, the largest one (*Verify* `PON_BID_ATTRIBUTE_VALUES`: value and score per requirement) |
| 7 | Vendor proposal files, complete and readable (Phase 1, "require full-document content") | File name and MIME type of bid header attachments, no content, no line-level attachments. | Partial. Content needs the shared text tool (round 2, N1). |
| 8 | **Multiple versions of one vendor's submission** (Missing-inputs table) | Bids with status `ARCHIVED` (superseded revisions) are returned alongside active ones, with no flag. | **Defect** (*Verify* status values and `OLD_BID_NUMBER`) |
| 9 | Timeliness: submitted before the due date | No submission date. | **Gap** (*Verify* `PON_BID_HEADERS.PUBLISH_DATE`) |
| 10 | Addenda acknowledged by each vendor (Phase 5) | Nothing. A bid on an earlier amendment is not distinguished. | **Gap** (bid's `AUCTION_HEADER_ID` vs latest amendment) |
| 11 | **Price separation**: technical evaluators must not see price unless allowed ("do not open or reference price files") | Prices always returned with the technical response in the same rows. | **Conflict** |
| 12 | Price tabulation for price criteria (Phase 6) | `buyer_bid_total`, line prices. | Covered (subject to need 11) |
| 13 | Vendor legal identity for consistency checks (Phase 5) | `trading_partner_name`, site code. No supplier ID. | Partial (*Verify* `PON_BID_HEADERS.VENDOR_ID` → `AP_SUPPLIERS`) |
| 14 | Debarment (SAM.gov), state debarment lists, CPARS, licensing | Not in EBS. The skill expects `Cannot Verify` without an external connector. | **Outside this server**: correct as is |
| 15 | Never score or rank | Read-only tools. EBS team scores, if they exist, must **not** be exposed to this skill. | Covered. Keep it that way: no tool for `PON_TEAM_SCORES` or similar. |

### 3.2 Defects in the two tools (read from the SQL)

| Tool | Defect | Confirm live |
| :--- | :--- | :--- |
| `ebs_get_sourcing_rfp_details` | Items and attributes are two independent `LEFT JOIN`s on the header only, so the result is **lines × criteria**: 20 lines and 30 criteria give 600 rows, with every criterion repeated on every line. Line-level attributes are not tied to their own line. | Yes: count rows for one negotiation. |
| `ebs_get_sourcing_rfp_details` | `:auction_header_id` is an integer, so a lookup by RFP number alone must pass a dummy ID (the round-1 "integer optional" trap). | |
| `ebs_get_vendor_bids` | Bid lines × attachments are joined together, so each line repeats once per attachment. | Yes |
| `ebs_get_vendor_bids` | Excludes only `DRAFT` and `DISQUALIFIED`, so superseded (`ARCHIVED`) revisions come back as if they were separate bids (need 8). | Yes: check status values in the instance. |
| `ebs_get_vendor_bids` | `:auction_header_id` and `:bid_number` are integers; the auction is required, so "all bids from vendor X" is impossible. | |
| `ebs_get_vendor_bids` | Price and technical content are inseparable (need 11). | |
| Both descriptions | Name APIs the SQL never calls (`PON_AUCTION_PKG`, `PON_EVALUATION_PVT`, `PON_BID_PKG.GET_BID_DETAILS`, `APPS_AI.GET_BID_ATTACHMENTS`), which misleads the agent. | |

### 3.3 Proposed tools and changes

| # | Proposal | Fills | Confidence |
| :--- | :--- | :--- | :--- |
| R1 | Split `ebs_get_sourcing_rfp_details` into a header-and-lines tool and a new **`ebs_get_solicitation_requirements`**: one row per requirement with section, text, mandatory flag, weight, knockout score and the scoring scale (values or ranges → score) aggregated per requirement. Accept the RFP number alone; make IDs strings. Add document type and amendment number. | 1, 3, 4; defect | *Verify* PON columns listed above |
| R2 | **`ebs_get_solicitation_amendments`**: the amendment chain for a negotiation (number, date, what changed if stored), so the agent can apply addenda in order. | 2 | *Verify* amendment columns |
| R3 | **`ebs_get_bid_requirement_responses`**: per vendor and requirement, the vendor's response value, with the requirement's mandatory flag. No scores (need 15). | 6 | *Verify* `PON_BID_ATTRIBUTE_VALUES` |
| R4 | Fix `ebs_get_vendor_bids`: one row per bid (lines and attachments aggregated or split into their own tools), latest revision only by default with the superseded ones flagged, submission date, amendment the bid was made on, supplier ID. Add an `include_prices` switch, off by default, so technical review does not see price. String IDs; auction optional when a vendor is given. | 7 to 11, 13; defects | *Verify* `PUBLISH_DATE`, `VENDOR_ID`, status values |
| R5 | **`ebs_list_solicitation_documents`**: attachments on the negotiation and on its bids (title, category, file name, size, date), with no content. Content comes from the shared text tool. | 5, 7 | *Verify* entity names |
| R6 | Correct both tool descriptions to describe what the SQL does. | defect | *Confirmed* |

Not buildable in SQL: reading and paging through PDF proposals with page citations, which needs the shared text or document-processing step (round 2, N1), and external registries (need 14).

## 4. Re-check of earlier defects (2026-10-07, read from the SQL)

Round 1 fixed the expense-side defects (SSN masked in `ebs_lookup_employees`, policy rules org filter and cap, list paging, string IDs on the audit tools, PO filter). None of the round-2 defects have been fixed:

| Defect (from) | Still present | Evidence |
| :--- | :--- | :--- |
| Notice tool joins every award in the operating unit (round 2, 1.2) | Yes | `ebs_get_constituent_notice_details.sql`: `ON trx.org_id = gms.org_id` |
| Intake attachments: no entity filter, no cap, blobs always (round 2, 2.2) | Yes | `ebs_get_intake_attachments.sql`: `ON fad.pk1_value = p.intake_queue_id`, no `FETCH FIRST` |
| Identity check: substring match, hash compared as RAW to text (round 2, 2.2) | Yes | `ebs_verify_party_identity.sql`: `LIKE '%' ...`, `STANDARD_HASH(...) = p.tax_id_hash` |
| Policy attachments: category matched against entity name; creation date shown as effective date (round 2, 3.2) | Yes | `ebs_search_policy_attachments.sql` |
| Policy rules: no `as_of_date` (round 2, 3.2) | Yes | `ebs_get_agency_policy_rules.sql` |
| Personnel file returns the full national identifier (round 1, section 2) | Yes | `ebs_get_employee_personnel_file.sql`: `papf.national_identifier AS ssn_tax_id` |
| Integer optional IDs on the remaining tools (round 1, section 2) | Yes | Notice, attachment, identity, both RFP tools |
| Descriptions naming APIs the SQL does not call (round 2) | Yes | Notice, attachment, intake, identity, both RFP tools |

### 4.1 Status after the fixes (2026-10-07)

All defects in the table above are fixed except those in the two FOIA tools (left as placeholders), together with RFP items R4 and R6. Every fix was confirmed live first, then run directly, through `toolbox invoke`, and wrapped with a token; `scripts/test_live_toolbox.py` passes 24 of 24. Details are in DECISIONS.md §11c. Findings made while fixing:
- `ebs_get_vendor_bids` had never returned an attachment: bid files are on entity `PON_BID_ITEM_PRICES`, not `PON_BID_HEADERS`.
- `ebs_lookup_parties_and_vendors` silently ignored its `org_id` filter.
- The identity hash check failed only for lowercase hex, which is what most tools produce.
- `ebs_search_policy_attachments` now finds real policy documents in this instance (Travel Policy, Vision Expense Reporting Policy) under category "Miscellaneous", so a category filter alone will miss them; the keyword search finds them.

Still open from section 4: the full national identifier in `ebs_get_employee_personnel_file` (FOIA placeholder).

### 4.2 Shared text tool (backlog item 3), 2026-10-07

`ebs_get_attachment_text` is built and run live (DECISIONS.md §11d). It returns text for short and long text attachments and for text, HTML, XML and JSON files, about 60% of the stored files. It cannot return text for **PDF, Word or Excel** (about 25%), because EBS's text index does not filter binary documents and extraction needs a database function created by a DBA (`CTX_DOC.POLICY_FILTER` with an `AUTO_FILTER` policy). That is decision **T1**: whether to ask the DBA for such a function (one function plus one Oracle Text policy, read-only), or to extract outside the database in the plugin.

**T1 decided 2026-10-07: DBA function.** `ebs/install/xx_ai_attachment_pkg.sql` (formerly `xx_ai_attachment_text_pkg.sql`) and the post-install tool version are written and tested on Oracle Database Free; they wait for a DBA to install the package in EBS (`ebs/install/README.md`).

## 5. Consolidated backlog (EBS)

Ordered by risk first, then value.

| Order | Items | Why first |
| :--- | :--- | :--- |
| 1 | **Decisions:** F1 (FOIA tools with no skill), N6 (notice tool returns PII the skill refuses), D4 (how much personal data intake may return) | They decide whether some tools stay at all; building fixes first could be wasted. |
| 2 | **Defect fixes** in section 4, plus RFP defects R4 and R6 | Small, read-only, and they stop wrong or excessive data reaching the agent. |
| 3 | **Shared text tool** (round 2, N1: `ebs_get_attachment_text`) | Needed by four skills: notice, policy, intake and RFP. Without it the document-centric skills cannot read anything EBS stores. |
| 4 | **RFP structure:** R1, R3, R2, R5 | Turns the RFP toolset from header rows into a requirements register with vendor responses. |
| 5 | **Round 1 leftovers:** E1 expense policy schedules, E2 expense distributions, E3 richer PO match, E4 PO-to-sourcing link | Columns largely confirmed in round 1. |
| 6 | **Discovery additions** from round 2: N2, N3, P4, P5, D3 | Depend on what the dictionary shows. |

Outside this server in every case: eCFR and state codes (policy skill), SAM.gov and debarment lists (RFP skill), GSA per diem rates (expense skill), and image quality checks and OCR (intake skill).

## 6. Before building

1. Bring the `ebs` MCP server back up (it refused connections on 2026-10-07) and refresh the token.
2. Run the *Confirm live* checks in section 3.2 and round 2, and check every *Verify* column with `ebs_describe_table`.
3. Build each item under the repo rules (bind once, positional order, no leading comment), sync, validate, add a sample to `scripts/test_live_toolbox.py`, and run it live before keeping it.
4. The analyst draft `ebs/sql/ebs_blob_utils_pkg.sql` still breaks `sync_sql_to_yaml.py --system ebs`. Sync on a scratch copy without it until it is removed or fixed.
