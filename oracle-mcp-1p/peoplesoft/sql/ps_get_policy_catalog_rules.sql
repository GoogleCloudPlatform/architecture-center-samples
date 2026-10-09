-- Tool: ps_get_policy_catalog_rules
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :setid (string): SetID business unit code (e.g., 'SHARE').
--   :policy_code (string): Specific expense policy code.
--   :expense_category (string): Expense category (e.g., 'MEALS', 'LODGING', 'AIRFARE').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :setid AS setid,
        :policy_code AS policy_code,
        :expense_category AS expense_category
    FROM dual
)
SELECT
    pol.setid,
    pol.expense_policy_id AS policy_code,
    pol.descr AS policy_title,
    pol.expense_type AS expense_category,
    pdiem.per_diem_amt AS daily_maximum_rate,
    pol.receipt_req_amt AS receipt_threshold_amount,
    TO_CHAR(pol.effdt, 'YYYY-MM-DD') AS effective_date,
    pol.eff_status AS status
FROM params p
JOIN sysadm.ps_ex_policy_tbl pol
    ON pol.setid = p.setid
   AND (p.policy_code IS NULL OR pol.expense_policy_id = p.policy_code)
   AND (p.expense_category IS NULL OR UPPER(pol.expense_type) = UPPER(p.expense_category))
LEFT JOIN sysadm.ps_ex_per_diem_tbl pdiem
    ON pol.setid = pdiem.setid
   AND pol.expense_policy_id = pdiem.expense_policy_id
ORDER BY pol.expense_policy_id;
