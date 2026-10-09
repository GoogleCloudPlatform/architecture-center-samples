# Gap analysis, round 2: the other three skills vs the EBS MCP tools

Prepared 2026-10-06. Nothing under `google_oracle_skills/` was changed; only the tools (`ebs/sql/`, `ebs/tools.yaml`) are candidates for change. Round 1 covered `expense-auditor` (see `expense_auditor_vs_ebs_tools_gap_analysis.md`).

**Evidence base:** the three `SKILL.md` files and their reference files (`domain_standards_and_examples.md`; `authority_hierarchy_and_citation_formats.md`; `corner_cases_and_edge_conditions.md`), and the SQL and descriptions of the five tools mapped to these skills. The Toolbox was down when this was written, so nothing here was run live. Items marked **Confirm live** are read from the SQL and need a query to confirm; items marked **Verify** are Oracle EBS columns or tables to check with `ebs_describe_table` first.

## 0. The big picture

| Skill | What it does | Tools mapped to it | Fit with EBS data |
| :--- | :--- | :--- | :--- |
| `plain_language_notice_generator` | Rewrites **population-level** public notices; refuses anything naming an individual (PII, appeal rights) | `ebs_get_constituent_notice_details`, `ebs_get_document_attachment` | **Conflict:** the main tool returns exactly what the skill must refuse. |
| `document_intake_cleanup_and_validation` | Validates citizen-submitted proof documents (paystubs, W-2s, bank statements, leases, IDs) and does the wage and ledger math | `ebs_get_intake_attachments`, `ebs_verify_party_identity` | **Thin:** EBS is an ERP, not a benefits system. It can hold attachments and a party registry. |
| `policy_and_statute_assistant` | Finds the controlling statute, regulation and state rule, with currency stamps | `ebs_get_agency_policy_rules`, `ebs_search_policy_attachments` | **Partial:** the law comes from external sources; EBS can supply the agency's own policies and limits. |

Two themes cut across all three:
1. **The tools mostly return raw blobs or database rows, but the skills need text, dates and categories.** A PDF in `FND_LOBS` is not readable by the model, and the skills rely on effective dates, revisions and categories that the tools don't expose.
2. **Several tool descriptions name APIs and packages the SQL never calls** (for example `APPS_AI.GET_INTAKE_DOCS_PKG.FETCH_PENDING_ATTACHMENTS`, `HZ_PARTY_V2PUB.GET_PERSON`, `APPS_AI.GET_BLOB_CONTENT`). Those descriptions are shown to the AI agent, so they mislead it about what the tool does.

## 1. `plain_language_notice_generator`

### 1.1 What the skill needs

| # | Need (skill ref) | Tool coverage today | Status |
| :--- | :--- | :--- | :--- |
| 1 | Source text of a **population-level** notice, mass announcement or form guide (Phase 1) | `ebs_get_document_attachment` returns one attachment as a raw blob. | **Gap:** text of a PDF or Word file is not readable. |
| 2 | **No PII, no individual determinations** (mandatory escalation rule) | `ebs_get_constituent_notice_details` returns a named customer, account number, overpayment balance, reason codes and award, for one transaction. | **Conflict:** the tool serves exactly the case the skill refuses. |
| 3 | Agency contact channels: voice phone, TTY or relay, URL, hours (required-element checklist; source gap audit) | Nothing. | **Gap** |
| 4 | Language-access notice of availability (45 CFR 92.11); verbatim protected blocks | Nothing; attachments may hold them but cannot be searched by category. | **Gap** |
| 5 | Effective dates and deadlines for the notice | Only what is inside the document. | Partial |
| 6 | Mass-change facts (counts, amounts) | Skill rule: never supply facts the source lacks. | Not a tool need |

### 1.2 Defects in the tools (read from the SQL)

| Tool | Defect | Confirm live |
| :--- | :--- | :--- |
| `ebs_get_constituent_notice_details` | `LEFT JOIN gms_awards_all gms ON trx.org_id = gms.org_id` joins **every award in the operating unit** to each notice line, so each line is multiplied by the number of awards and carries an unrelated award. | Yes: count rows for one transaction. |
| `ebs_get_constituent_notice_details` | `:org_id` is an integer, so it cannot be left empty. Reason codes and amounts come with no decoding; the skill treats reason codes as agency-specific and requires a source table. | |
| `ebs_get_document_attachment` | Integer `:document_id`; returns only the blob and file metadata; `FETCH FIRST 1 ROWS` hides which attachment of several was chosen. | |
| Both descriptions | Name packages and APIs the SQL does not call. | |

### 1.3 Proposed tools and changes

| # | Proposal | Fills | Confidence |
| :--- | :--- | :--- | :--- |
| N1 | `ebs_get_attachment_text`: for text-like attachments (plain text, HTML, XML) return the decoded text; for other types return metadata plus the length and a note that content needs extraction. | Need 1 | *Verify* LOB columns (`FND_LOBS`), character set handling |
| N2 | `ebs_list_documents` (population-level): search attachments by category, entity and date, returning title, category, dates and size **without** content and without entity keys that identify individuals. | Needs 1, 4 | *Verify* `FND_DOCUMENT_CATEGORIES_TL`, `FND_DOCUMENTS` dates |
| N3 | `ebs_get_agency_contact_info`: the operating unit's location, phone numbers, email and URL fields. TTY is not a standard field; report what exists and flag the rest as "not found". | Need 3 | *Verify* `HR_LOCATIONS_ALL`, `HR_ORGANIZATION_INFORMATION` |
| N4 | `ebs_get_notice_template`: text of AR dunning letters or workflow message templates, which are population-level boilerplate. | Needs 1, 4 | *Verify* `AR_DUNNING_LETTERS_B/TL` and `WF_MESSAGES_TL` (or `FND_NEW_MESSAGES`) |
| N5 | Fix the award join in `ebs_get_constituent_notice_details` (drop it or link it through the transaction); make `:org_id` a string. | Defect | *Confirm live*, then fix |
| N6 | **Decision for you:** keep, restrict or retire `ebs_get_constituent_notice_details`. It returns PII that the skill must refuse to process. Options: retire it from this skill's toolset, return a de-identified view (no names or account numbers), or keep it for a different skill. | Conflict | Product decision |

## 2. `document_intake_cleanup_and_validation`

### 2.1 What the skill needs

| # | Need (skill ref) | Tool coverage today | Status |
| :--- | :--- | :--- | :--- |
| 1 | Fetch the citizen's uploaded documents (Phase 1) | `ebs_get_intake_attachments(intake_queue_id, applicant_id)` returns attachments with blobs. | Partial |
| 2 | Image quality: blur, DPI, corners (Gate A) | Nothing. | **Outside SQL:** needs image analysis. |
| 3 | Pages and sequence (Gate B): missing intermediate page, blank trailing page | No page count or attachment sequence. | **Gap** |
| 4 | Document class and category | `document_category_label` is the document **title**, not a category. | **Gap** |
| 5 | Upload or document date for the lookback window (30 or 60 days) | `upload_date` from `FND_LOBS`. | Covered |
| 6 | Identity cross-check: name, address, tax ID hash (Connected mode) | `ebs_verify_party_identity` | Partial |
| 7 | Date of birth, gender, marital status, citizenship for application consistency | Not returned. | **Gap** (*Verify* `HZ_PERSON_PROFILES`) |
| 8 | **Service address** versus mailing or P.O. box (utility bills; shelter) | Address lines only, with no address use or type. | **Gap** (*Verify* `HZ_PARTY_SITE_USES`) |
| 9 | Employer verification for paystubs | Nothing. | **Gap** (*Verify* `HZ_EMPLOYMENT_HISTORY`, relationships) |
| 10 | Wage, YTD and ledger math (Gate C) | Done by the model. | Covered |
| 11 | Case record context (`case_id`, `case_record_context`) | EBS has no case or intake-queue object; the "queue id" is just an attachment key. | **Gap:** not an EBS concept. |

### 2.2 Defects in the tools (read from the SQL)

| Tool | Defect | Confirm live |
| :--- | :--- | :--- |
| `ebs_get_intake_attachments` | Joins on `fad.pk1_value = :intake_queue_id` with **no entity filter**, so any attachment on any entity whose key happens to equal the string comes back (for example a purchase order with the same number). No row cap, and every row returns its blob. | Yes: try a number that is also a PO or invoice ID. |
| `ebs_verify_party_identity` | Matches `UPPER(party_name) LIKE '%name%'`, so a short name returns up to 10 unrelated constituents with address, email and phone. The `name_match_confidence` branch `ELSE 50` can never be the "no match" it implies, because the join already required a substring match. | Yes |
| `ebs_verify_party_identity` | The tax ID check compares `STANDARD_HASH(...)` (a RAW value) with a string parameter, which may never match unless the caller passes a raw value. Persons only (`hz_person_profiles` is an inner join). | Yes, needs a test party with a known identifier. |
| `ebs_verify_party_identity` | `:party_id` is an integer. | |
| Descriptions | Name `APPS_AI.GET_INTAKE_DOCS_PKG.FETCH_PENDING_ATTACHMENTS` and `HZ_PARTY_V2PUB.GET_PERSON`, which the SQL does not call. | |

### 2.3 Proposed tools and changes

| # | Proposal | Fills | Confidence |
| :--- | :--- | :--- | :--- |
| D1 | `ebs_get_intake_attachments`: add an entity filter, a row cap, attachment sequence, document category, data type, byte length and the uploader; make blob return optional (as with `include_receipts`). | Needs 3, 4; defect | *Verify* `fad.seq_num`, `fad.category_id`, `fd.datatype_id`, `DBMS_LOB.GETLENGTH` |
| D2 | `ebs_verify_party_identity`: exact or ranked match with a minimum-name-length guard, and add DOB, gender, marital status, address use (service, billing, mailing) and site dates. Fix the hash comparison (`RAWTOHEX`). | Needs 6, 7, 8; defects | *Verify* `HZ_PERSON_PROFILES`, `HZ_PARTY_SITE_USES` |
| D3 | `ebs_get_party_employment`: employer name, dates and relationship type for a party. | Need 9 | *Verify* `HZ_EMPLOYMENT_HISTORY`, `HZ_RELATIONSHIPS` |
| D4 | **Decision for you:** these tools return personal data (DOB, contact details, tax identifier checks). The skill extracts identifiers on purpose, but a registry lookup is a wider exposure than reading a submitted document. Confirm what the plugin is allowed to return, and whether returns should be masked. | | Product decision |

Not buildable in SQL: image quality (Gate A), page counts from PDFs and OCR. These need a document-processing step in the plugin.

## 3. `policy_and_statute_assistant`

### 3.1 What the skill needs

| # | Need (skill ref) | Tool coverage today | Status |
| :--- | :--- | :--- | :--- |
| 1 | Federal statutes and regulations: eCFR, U.S. Code, Federal Register (Tiers 1 to 3) | Not in EBS. The skill requires **external connectors first** (eCFR renderer, OLRC, state code portals). | **Outside this server:** needs a separate MCP source. |
| 2 | State administrative code and manuals (Tiers 4 to 6) | Same: external. | **Outside this server** |
| 3 | The agency's **own** policy manuals and transmittals with effective dates and revisions (Tier 6) | `ebs_search_policy_attachments`: title, description, file name, MIME type, and a creation date labelled `effective_date`. | Partial |
| 4 | Point-in-time retrieval: `as_of_date` must drive the query (invariant 7) | `ebs_get_agency_policy_rules` has no date parameter; it returns active and inactive rules together. | **Gap** |
| 5 | Quantitative thresholds from the source, never from memory (date grounding rule 2) | Approval limits and expense receipt rules, per operating unit. Micro-purchase, simplified acquisition and sole-source thresholds are not EBS concepts. | Partial |
| 6 | Jurisdiction (state) as a hard pre-filter | No tool reports the agency's state. | **Gap:** small (*Verify* legal entity or location address) |
| 7 | Read a policy document's content | Only via `ebs_get_document_attachment` (raw blob). | **Gap** (same as N1) |
| 8 | Supersession and currency of a manual section | No revision, end date or "replaced by" fields. | **Gap** (*Verify* `FND_DOCUMENTS.START_DATE_ACTIVE` and `END_DATE_ACTIVE`) |
| 9 | Approval authority limits for procurement actions (skill scope: procurement thresholds, sole-source) | Only `po_control_rules` amounts. Approval groups and position limits are not exposed. | **Gap** (*Verify* `PO_APPROVAL_GROUP_HEADERS/ROWS`, `PO_POSITION_CONTROLS_ALL`) |

### 3.2 Defects in the tools (read from the SQL)

| Tool | Defect | Confirm live |
| :--- | :--- | :--- |
| `ebs_search_policy_attachments` | The `:policy_category` parameter is matched against `fad.entity_name` (the entity the file is attached to, such as `PO_HEADERS`), not against a document category. A policy category such as "travel" therefore matches nothing sensible. | Yes |
| `ebs_search_policy_attachments` | Returns attachments on **any** entity, including purchase orders and invoices, with only a title or keyword filter. The `effective_date` column is the document **creation** date, which the skill's currency stamp would treat as an effective date. | Yes |
| `ebs_search_policy_attachments` | No end date, revision or category returned; the blob is not returned either. | |
| `ebs_get_agency_policy_rules` | Round 1 added an org filter, a cap and a threshold meaning. Still missing: `as_of_date`. The description (corrected in round 1) previously listed tables it does not read. | |

### 3.3 Proposed tools and changes

| # | Proposal | Fills | Confidence |
| :--- | :--- | :--- | :--- |
| P1 | `ebs_get_agency_policy_rules`: add `:as_of_date` (rules in force on that date) and return start and end dates and the effective period explicitly. | Need 4 | *Confirmed* date columns exist (`end_date`, `inactive_date`) |
| P2 | `ebs_search_policy_attachments`: filter by document category, return category, start and end active dates, last update and size, and drop entities that are not policy documents (or take an entity filter). | Needs 3, 8; defects | *Verify* `FND_DOCUMENT_CATEGORIES_TL`, `FND_DOCUMENTS` dates |
| P3 | Text retrieval for policy documents: same tool as N1 (`ebs_get_attachment_text`). | Need 7 | *Verify* |
| P4 | `ebs_get_po_approval_limits`: approval groups and rows (object, amount limit), position controls, and document-type approval settings. | Need 9 | *Verify* PO approval tables |
| P5 | `ebs_get_agency_jurisdiction`: the operating unit's legal entity and location (state, country). | Need 6 | *Verify* `HR_OPERATING_UNITS`, `XLE_ENTITY_PROFILES`, `HR_LOCATIONS_ALL` |

External connectors for needs 1 and 2 (eCFR, state codes) are a plugin decision, not something to add to this EBS Toolbox.

## 4. Round 1 leftovers (expense-auditor), still to build

| # | Tool | Fills | Source tables |
| :--- | :--- | :--- | :--- |
| E1 | `ebs_get_expense_policy_schedules` | Lodging, per diem and meal limits by location and role | `AP_POL_HEADERS`, `AP_POL_SCHEDULE_PERIODS`, `AP_POL_LINES` (`MAX_LODGING_AMT`, `MAX_PER_DIEM_AMT`, `MEAL_LIMIT`), `AP_POL_LOCATIONS_B/TL`; all columns confirmed in round 1 |
| E2 | `ebs_get_expense_report_distributions` | Project, task, award and GL account per expense line | `AP_EXP_REPORT_DISTS_ALL` (columns confirmed in round 1) |
| E3 | Richer `ebs_get_po_invoice_match` | Supplier, item description, PO approval status and date, capital flag, invoice and payment status | `AP_SUPPLIERS`, `PO_LINES_ALL.CAPITAL_EXPENSE_FLAG`, `PO_HEADERS_ALL` approval columns |
| E4 | `ebs_get_po_sourcing_link` | PO to solicitation, bids received, sole-source indicator | `PO_LINES_ALL.AUCTION_HEADER_ID`, `PON_AUCTION_HEADERS_ALL`, `PON_BID_HEADERS` |

## 5. Suggested build order

1. **Fix the defects first** (small, safe, and they protect data): intake attachment entity filter and cap; award join in the notice tool; identity match guard; policy-attachment category filter; `as_of_date` on policy rules; string-typed optional IDs.
2. **Round 1 leftovers E1 to E4**, whose columns are largely confirmed already.
3. **Shared text tool N1**, which serves two skills.
4. **Discovery tools** N2, N3, P4, P5, D3, subject to what the dictionary shows.
5. **Product decisions N6 and D4** before touching PII behaviour.

## 6. What blocks progress right now

The Toolbox at `http://ebs-mcp.com:8080/mcp` is not running and the token in `/tmp/ebs.json` has expired, so no query could be run to confirm the "Confirm live" items or to check any "Verify" column. Building needs the server and a fresh token.
