# Gap analysis: `expense-auditor` skill vs the EBS MCP tools

Prepared 2026-10-05. The skill (`google_oracle_skills/expense_auditor/`) was read, not changed. Only the tools (`ebs/sql/`, `ebs/tools.yaml`) are candidates for change.

**Evidence base:** the skill's `SKILL.md` and three reference files; the SQL of the six EBS tools that touch its data; and the live audit of 50 reports in org 204 (305 lines), where each gap below that says "seen live" actually blocked or weakened a finding.

**Confidence labels:** *Confirmed* = the column or table is already used by a tool in this repo or was returned live. *Verify* = from my knowledge of Oracle EBS R12; must be checked against this instance's data dictionary before building (a wrong column raises ORA-00904 on the first live call, which the hot-reloading Toolbox makes cheap to find).

## 1. Coverage matrix

Status: **Covered**, **Partial**, **Gap**.

| # | Skill requirement (phase) | What the tools give today | Status | Seen live |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Award terms: NOA, period of performance, budget categories, capitalization threshold (Phase 1.1) | Only `award_number` and `award_full_name`, and only on AR notices (`ebs_get_constituent_notice_details`). Nothing for expense reports. | **Gap** | Period of performance and budgets reported as "not tested". |
| 2 | Funding stream classification: federal, pass-through, state, local (Phase 1.2, Principle 1) | Nothing. | **Gap** | Funding stayed "unspecified"; fell back to the baseline protocol. |
| 3 | Ledger integrity: lines sum to the voucher total (Phase 1.3) | `ebs_get_expense_reports` returns every line plus `report_total`. | Covered | Verified on all 50 reports. |
| 4 | Currency, exchange rate, receipt amount vs reimbursable amount | Not returned. | **Gap** (*Verify* columns) | Cannot tell whether amounts are in one currency. |
| 5 | Attachment mapping: every line to its receipt (Phase 1.4) | Attachment level, file name, MIME type, and the raw blob. | Partial | Showed that no line has a receipt. No attachment title/description. |
| 6 | Receipt requirement per expense type (Pillar 4, 200.403(g)) | Only in a separate tool (`ebs_get_agency_policy_rules`), under the ambiguous name `threshold_amount` (it is `require_receipt_amount`). Not on the line. | Partial | Had to cross-reference by hand. Initially misread as a spending cap, which put an error in the first dossier. |
| 7 | Period of performance: incurred vs liquidation (Phase 2.1) | No award link on expense lines; no payment date. | **Gap** | Not testable. |
| 8 | Budget ceiling per category (Phase 2.2) | Nothing. | **Gap** | Not testable. |
| 9 | Allocability and consistent treatment (Pillars 2 and 3): which project, task, award, GL account | Expense accounting distributions are not exposed. Invoice distributions carry award/project/task only on `ebs_get_po_invoice_match`. | **Gap** (*Verify* `AP_EXP_REPORT_DISTS_ALL`) | Not testable. |
| 10 | Reasonableness (Pillar 1) | Amounts per line only; no peer or history comparison. Workable by joining lists. | Partial | I had to do it offline by script. |
| 11 | Travel: GSA per diem and lodging by locality (Phase 4) | No location, no end date or number of days on lines; no policy schedules. GSA rates themselves are not in EBS. | **Gap** | Hotel nights and meals could not be tested. |
| 12 | Airfare class, Fly America (Phase 4) | Nothing beyond the `Airfare` amount and a justification string. | **Gap** | Not testable. |
| 13 | Alcohol and entertainment isolation (Principle 4) | Itemized sub-lines are not returned. Receipt images come back as a raw blob that the model cannot read. | **Gap** | Meals could not be split; alcohol never isolated. |
| 14 | Capital equipment of $5,000 or more and prior approval (Principle 5) | `ebs_get_po_invoice_match` gives unit price and quantity, but no item description, supplier name, PO approval date or asset flag. | Partial | Not exercised in this audit (expense reports only). |
| 15 | Procurement thresholds and competition (Phase 4) | RFP tools exist but are not linked to POs. Approval limits in `ebs_get_agency_policy_rules` are authority limits, not 2 CFR 200.320 thresholds. | Partial | Not exercised. |
| 16 | Compensation and effort certification (200.430) | Nothing. | **Gap** | Not exercised. |
| 17 | Duplicate billing (skill description) | Nothing. `ebs_lookup_recent_transactions` matches on document number only. | **Gap** | I found 45 of 50 reports cloned month to month by script outside the tools. |
| 18 | Approval trail and segregation of duties; paid date | Status only (`PAID`). | **Gap** (*Verify*) | Could not tell who approved or when paid. |
| 19 | Policy violations flagged by EBS | `policy_status` per line from `AP_POL_VIOLATIONS_ALL`. | Covered | Returned `OK` on every line, including sightseeing tours. |
| 20 | Read-only operation (Guardrail 3) | All tools are read-only. | Covered | |
| 21 | Questioned cost arithmetic and Single Audit test (Phase 5) | Done by the model from line amounts. | Covered | |

## 2. Defects in the existing tools (seen live)

| Tool | Problem | Impact |
| :--- | :--- | :--- |
| `ebs_lookup_employees` | Returns `national_identifier` under the name `ssn_masked`, but values come back unmasked (for example `543-44-3000`). `ebs_get_employee_personnel_file` also returns it as `ssn_tax_id`. | Full tax identifiers reach the model and the transcript from a directory search. Highest priority, independent of the skill. |
| `ebs_get_agency_policy_rules` | Returned 393 rows (about 109 KB) with no org filter; the result overflowed the client limit. `threshold_amount` hides what the number means. | Unusable without post-processing. Mislabelled amount caused a wrong statement in the first dossier. |
| `ebs_list_expense_reports` (new) | Hard cap of 50 with no offset and no "more rows exist" signal. | A population larger than 50 cannot be audited; I reported the cap in the dossier but the tool should signal truncation. |
| `ebs_lookup_recent_transactions` | `org_id` is an integer, so "any org" cannot be expressed; passing `0` silently returns nothing. | Same trap that affected the expense tools. Other integer-typed optional parameters have the same issue (`ebs_get_po_invoice_match`, `ebs_get_sourcing_rfp_details` and others). |
| `ebs_get_expense_reports` | Returns the whole receipt blob inline when requested; JSON blob is not readable by the model. | Receipts are present but unreadable (see gap 13). |
| `ebs_blob_utils_pkg` (draft) | Fails the sync: header name has a `.sql` suffix, trailing comma in the params CTE, a `DECLARE` block after a `WITH`. It blocks regeneration of `ebs/tools.yaml` for everyone. | Not a tool yet, but it breaks the pipeline. It is aimed at gap 13. |

## 3. Proposed tool backlog

Ordered by value to the skill against effort. "Skill ref" points at where `SKILL.md` needs the data.

### P1: quick wins on existing tools (no new tables)

| # | Change | Fills gaps | Confidence |
| :--- | :--- | :--- | :--- |
| 1 | `ebs_get_expense_reports`: add `receipt_required_flag`, `require_receipt_amount`, a computed `receipt_required` (Y/N) and `receipt_missing` (Y/N) per line. Add attachment title and description. | 5, 6 | *Confirmed* (columns already used by `ebs_get_agency_policy_rules`). Attachment titles use `FND_DOCUMENTS_TL`, as in `ebs_get_document_attachment`. |
| 2 | `ebs_get_agency_policy_rules`: add an `org_id` filter, a row cap and a column `threshold_meaning`. | 6, defect | *Confirmed* |
| 3 | `ebs_list_expense_reports`: add `offset`, a `truncated` flag and total match count; add `has_violation` and `receipt_missing_count` per report. | defect, 17 | *Confirmed* |
| 4 | `ebs_lookup_employees` and `ebs_get_employee_personnel_file`: stop returning the national identifier (or return only the last four digits). | defect | *Confirmed* |
| 5 | Make optional integer parameters strings ("empty = any") across the remaining tools, as already done for the expense tools. | defect | *Confirmed* |

### P2: new tools

| # | Tool | Purpose and skill ref | Likely tables | Confidence |
| :--- | :--- | :--- | :--- | :--- |
| 6 | `ebs_find_duplicate_expense_lines` | Same employee, date, type and amount across reports, plus near-identical report totals. Skill description ("detecting duplicate billing"). | `AP_EXPENSE_REPORT_HEADERS_ALL`, `AP_EXPENSE_REPORT_LINES_ALL` | *Confirmed* tables and columns |
| 7 | `ebs_get_expense_report_distributions` | Project, task, award, expenditure type and GL account per line. Pillars 2 and 3; Phase 2. | `AP_EXP_REPORT_DISTS_ALL`, `GMS_AWARD_DISTRIBUTIONS` | *Verify* |
| 8 | `ebs_get_expense_report_approval_and_payment` | Approver, approval date, payment date, check or EFT number, payment status. Phase 2.1 (incurred vs paid); segregation of duties. | Report header approver columns, `AP_INVOICES_ALL`, `AP_INVOICE_PAYMENTS_ALL`, `AP_CHECKS_ALL` | *Verify* |
| 9 | `ebs_get_award_terms` | Sponsor, funding type, start and end dates, budget, indirect-cost basis. Phase 1.1, 1.2, 2; Principle 1; Single Audit test. | `GMS_AWARDS_ALL` (award number and name *confirmed*), `GMS_SPONSORS` and award dates | *Verify* |
| 10 | `ebs_get_award_budget_vs_actual` | Approved budget by category against actual expenditure. Phase 2.2 and ledger reconciliation. | `GMS_BUDGET_VERSIONS`, `PA_BUDGET_LINES`, `PA_EXPENDITURE_ITEMS_ALL` | *Verify* |
| 11 | `ebs_get_expense_policy_schedules` | Per diem, lodging and mileage schedules by location and role. Phase 4 travel. | `AP_POL_HEADERS` (*confirmed*), `AP_POL_LINES`, `AP_POL_LOCATIONS_B` | *Verify* |
| 12 | `ebs_list_invoices` and a richer `ebs_get_po_invoice_match` | Search invoices by supplier, amount, date, status and payment; add supplier name, item description, PO approval date, asset flag, expenditure type. Principle 5; Phase 4 procurement. | `AP_INVOICES_ALL`, `AP_SUPPLIERS`, `PO_LINES_ALL`, `PO_HEADERS_ALL` | *Confirmed* tables, *Verify* some columns |
| 13 | `ebs_get_po_sourcing_link` | PO to solicitation, number of bids, sole-source indicator. Phase 4 procurement. | `PO_LINES_ALL`, `PON_AUCTION_HEADERS_ALL`, `PON_BID_HEADERS` | *Verify* |

### P3: later or harder

| # | Item | Note |
| :--- | :--- | :--- |
| 14 | Receipt content as text or base64 in chunks (finish `ebs_blob_utils_pkg`) | Lets the model read receipts and isolate alcohol. Needs an analyst-owned fix to the draft first. |
| 15 | Itemized sub-lines of expense lines | Likely `AP_EXPENSE_REPORT_LINES_ALL` itemization columns (*Verify*). |
| 16 | Effort certification (200.430) | Labor expenditure items by employee and award; large scope. |
| 17 | Expense line detail columns: location, end date, number of days, currency, merchant name, distance | Directly feeds the per diem test. All *Verify* against the line table. |

## 4. Gaps no EBS tool can fill

- **GSA per diem and lodging rates.** They are published by GSA, not stored in EBS. The skill says to compare against them; this needs another source (a loaded reference table or an HTTP-backed tool, if the Toolbox version supports it; check the v1.13.1 documentation).
- **Receipt reading and OCR.** Even with a base64 tool, reading text out of images needs a vision-capable step outside the database.
- **Fly America carrier status.** Needs a carrier reference list.

## 5. Same gaps elsewhere

PeopleSoft and JD Edwards each have their own `get_expense_reports` and policy tools. I have not examined them. Anything built for EBS above would need a counterpart there if the plugin treats the three systems alike.

## 6. How a tool would be built and checked

For each tool: write `ebs/sql/<tool>.sql` and `.txt` under the repo rules (single bind per CTE, positional order, no leading comment), regenerate with the sync, validate, add a sample payload to `scripts/test_live_toolbox.py`, then call it live through the hot-reloading Toolbox. A *Verify* column that is wrong shows up at that call as an Oracle error and is fixed in place. Nothing in `google_oracle_skills/` changes.

## 7. Status after the build (2026-10-05)

All four groups chosen for the first round were built, run live against the instance through the Toolbox, and kept only where the result was usable. Nothing under `google_oracle_skills/` changed. Details are in DECISIONS.md section 11b.

| Gap (section 1) | Resolved by | Result |
| :--- | :--- | :--- |
| 4 currency | `ebs_get_expense_reports` (extended) | All 305 sampled lines are USD. |
| 5, 6 receipts | `ebs_get_expense_reports` and `ebs_list_expense_reports` | Line flags (`receipt_required`, `receipt_missing`, `receipt_verified`), type setup and attachment counts are now returned. They disagree with the header receipts status, which the first dossier had missed. |
| 1, 2, 7 award terms, funding stream, period | `ebs_get_award_terms`, `ebs_get_award_expenditures` | Award type shows federal, state, matching or private funding. No sampled expense line carries an award, so no period test was possible for them. Budget by expenditure type is empty in this instance, so only award-level budget is returned. |
| 9 allocation | `ebs_get_expense_reports` (project, task, award, expenditure type on lines) | Not populated on the sampled lines. The accounting distribution table `AP_EXP_REPORT_DISTS_ALL` exists and is readable, but no tool reads it yet. |
| 11 travel (location, dates) | `ebs_get_expense_reports` (end date, location, nights) | Hotel nights and location now appear. Per diem and lodging limit schedules exist (`AP_POL_LINES`: `MAX_LODGING_AMT`, `MAX_PER_DIEM_AMT`, `MEAL_LIMIT`) but no tool reads them yet. |
| 12 airfare class | `ebs_get_expense_reports` (`ticket_class_code`, `travel_type`) | 45 of 47 sampled airfares are domestic business class: a new finding. |
| 13 alcohol and entertainment | Partly: attendees and attendee count | Itemization is empty on every sampled line. Receipt content is still unreadable. |
| 17 duplicates | `ebs_find_duplicate_expense_lines` | 56 recurring-line groups found in org 204, including reports outside the audit sample. |
| 18 approval and payment | `ebs_get_expense_report_approval_and_payment` | All 50 sampled reports were paid in full 1 to 11 days after submission; no approver is recorded on any; 48 still show paper receipts REQUIRED. |
| Defects (section 2) | Tool fixes | SSN masked in the employee lookup; org filter, cap and clearer meaning on the policy rules; paging and truncation signal on the list tool; string-typed optional IDs on the two audit-flow tools; a PO filter bug fixed in `ebs_get_po_invoice_match`. |

New facts the build surfaced:
- The population in org 204 is **1,841** reports; the audit sample is 50 (2.7%).
- `THRESHOLD_AMOUNT` in the policy rules is the receipt-required amount, not a spending cap.

Still open:
- A tool that reads the expense policy schedules (`AP_POL_LINES`, `AP_POL_SCHEDULE_PERIODS`, `AP_POL_LOCATIONS_TL`) for lodging and per diem limits.
- A tool for expense accounting distributions (`AP_EXP_REPORT_DISTS_ALL`).
- Richer `ebs_get_po_invoice_match` (supplier name, item description, PO approval, asset flag) and `ebs_get_po_sourcing_link`.
- Receipt text, effort certification, and the GSA rates, none of which an EBS query can supply.
- The analyst draft `ebs_blob_utils_pkg.sql` (pushed by mistake; to be ignored) still fails the sync.
- The PeopleSoft and JD Edwards counterparts of everything above.
