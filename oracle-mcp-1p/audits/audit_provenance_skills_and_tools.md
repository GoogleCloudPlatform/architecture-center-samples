# Audit provenance: skills and tools used

Companion to `expense_audit_org204_2026-10-05.md` (and its `.pdf`, `_lines.csv`). Written 2026-10-05 to help evaluate the imported `google_oracle_skills`.

## Skills

| Skill | How it was used |
| :--- | :--- |
| `expense-auditor` (`google_oracle_skills/expense_auditor/`) | Followed for the audit method, line classifications and 4-part dossier structure. Loaded by reading `SKILL.md` and its three reference files directly, not through the Skill tool, so it was never registered as a skill. |


Read earlier in the session but not used in the audit: `document_intake_cleanup_and_validation`, `plain_language_notice_generator`, `policy_and_statute_assistant`.

## MCP tools (server `ebs`, `http://ebs-mcp.com:8080/mcp`)

| Tool | Purpose |
| :--- | :--- |
| `ebs_lookup_employees` | First look at the directory (capped list). No part in the final audit. |
| `ebs_list_operating_units` | Found org 204 (Vision Operations). |
| `ebs_lookup_recent_transactions` (EXPENSE) | First set of candidate report numbers. |
| `ebs_get_agency_policy_rules` (EXPENSE) | iExpense policy setup; source of the $24.99 threshold amounts cited in CAP-03. Output was too large for the transcript and was summarized with `jq`. |
| `ebs_list_expense_reports` | New tool added during this session; listed the 50 reports and employee IDs. |
| `ebs_get_expense_reports` | Line items for all 50 reports (see workaround below). |

No other `ebs` tools were used. The ADK Docs and Google developer knowledge MCP servers were not involved.

### Workaround: line items did not go through the MCP tool binding

The MCP client had cached the old integer schema for `ebs_get_expense_reports`, so calls through the tool were rejected. Line items were fetched with a script (`mcpcall.py`, kept in the session scratchpad) that sends JSON-RPC `tools/call` requests to the same `/mcp` endpoint, authenticated with the token stored in `/tmp/ebs.json`. These ran the server's tool with its normal security wrapper. The Toolbox REST API (`/api/...`) is disabled on this server, and the first MCP calls failed on authentication before the registration was fixed.

### Changes made to the repo's tools during the session

- New `ebs/sql/ebs_list_expense_reports.sql` and `.txt`.
- `ebs_get_expense_reports`: optional string IDs, `include_receipts` switch, 500-line cap, rewritten description.
- Regenerated `ebs/tools.yaml` and patched the git-ignored `ebs/tools_secure.yaml` (kept its `apps.ge_ebs_mcp_tools` wrapper package). Not committed.

## Observations on the `expense-auditor` skill

What worked:
- The 4-part dossier structure (scorecard, line-item matrix, RFI checklist, CAP) and the four classifications (ALLOWABLE, QUESTIONED, UNALLOWABLE, INCOMPLETE) mapped cleanly onto the EBS data.
- The Federal Uniform Guidance baseline protocol let the audit proceed with no state rules or award data, with the required baseline notice.
- The unallowable categories (entertainment, 2 CFR 200.438; alcohol, 200.423) caught the clearest findings (sightseeing rentals, concert and baseball tickets).
- The skill's rule that undocumented lines cannot be ALLOWABLE (200.403(g)) produced the $0.00 allowable result.

Gaps and judgment calls:
- **Data it assumes but the tools did not provide:** Notice of Award, period of performance and budget categories (Phases 1 and 2), GSA locality (so no per diem or lodging test), receipts. The audit states these as not tested instead of guessing rates.
- **Date mismatch:** The data is from 2010, before 2 CFR 200 existed (effective December 2014). The skill applies 2 CFR 200 regardless; the dossier flags this in its baseline notice.
- **INCOMPLETE vs QUESTIONED:** The skill defines INCOMPLETE as supporting files missing, which would apply to every line here. Lines were split by judgment: INCOMPLETE for low-risk categories (phone, misc, mileage), QUESTIONED where a substantive concern exists (meals, hotel, airfare). This split is a choice, not something the skill specifies.
- **Prompt-injection sandwich:** The skill asks for `<untrusted_ledger_data>` delimiters when quoting data. Not used literally; justification text was treated as data and checked for instructions (none found).
- **Beyond the skill:** The month-to-month cloning analysis (15 of 17 employees) and the duplicate-claim CAP are additions the skill does not ask for.
- **Error in the skill's own example:** `references/worked_examples.md` Example 1 shows claimed $2,370.00 and questioned $396.00; the lines sum to $2,355.00 and $381.00, which is what `SKILL.md` shows.- **Line classification is rule-based** on expense type and justification text, applied uniformly. QUESTIONED and INCOMPLETE mean unsupported, not improper.
