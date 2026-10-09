-- Tool: ebs_get_agency_policy_rules
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :policy_category (string): Policy category: 'PROCUREMENT', 'TRAVEL', 'EXPENSE', or 'ALL'.
--   :rule_name (string): Specific rule name or control group parameter identifier.
--   :org_id (string): Operating unit ID to restrict the rules to. Empty string = all operating units.
--   :as_of_date (string): YYYY-MM-DD; returns only rules that existed and had not ended on that date. Empty string = all rules, active or not.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :policy_category AS policy_category,
        :rule_name AS rule_name,
        :org_id AS org_id,
        :as_of_date AS as_of_date
    FROM dual
)
-- These setup tables have no start date, only an end (inactive) date, so created_date
-- stands in for the start: a rule counts as in force on as_of_date if it was created
-- by then and had not ended.
SELECT * FROM (
    SELECT
        'PROCUREMENT' AS policy_category,
        pcg.control_group_name AS rule_group,
        pcr.rule_type_code AS rule_type,
        pcr.object_code AS policy_object,
        pcr.amount_limit AS threshold_amount,
        'Approval amount limit' AS threshold_meaning,
        TO_CHAR(pcr.creation_date, 'YYYY-MM-DD') AS created_date,
        TO_CHAR(pcr.inactive_date, 'YYYY-MM-DD') AS effective_end_date,
        'Org: ' || TO_CHAR(pcg.org_id) AS rule_scope
    FROM apps.po_control_rules pcr
    JOIN apps.po_control_groups_all pcg
        ON pcr.control_group_id = pcg.control_group_id
    CROSS JOIN params p
    WHERE (p.policy_category IS NULL OR UPPER(p.policy_category) IN ('PROCUREMENT', 'ALL'))
      AND (p.rule_name IS NULL OR UPPER(pcg.control_group_name) LIKE UPPER('%' || p.rule_name || '%'))
      AND (p.org_id IS NULL OR pcg.org_id = TO_NUMBER(p.org_id))
      AND (p.as_of_date IS NULL OR (TRUNC(pcr.creation_date) <= TO_DATE(p.as_of_date, 'YYYY-MM-DD')
           AND (pcr.inactive_date IS NULL OR pcr.inactive_date > TO_DATE(p.as_of_date, 'YYYY-MM-DD'))))

    UNION ALL

    SELECT
        'EXPENSE' AS policy_category,
        aerp.prompt AS rule_group,
        aerp.category_code AS rule_type,
        aerp.receipt_required_flag AS policy_object,
        aerp.require_receipt_amount AS threshold_amount,
        'Amount above which a receipt is required (0 = any amount); applies when policy_object is A' AS threshold_meaning,
        TO_CHAR(aerp.creation_date, 'YYYY-MM-DD') AS created_date,
        TO_CHAR(aerp.end_date, 'YYYY-MM-DD') AS effective_end_date,
        'Org: ' || TO_CHAR(aerp.org_id) AS rule_scope
    FROM apps.ap_expense_report_params_all aerp
    CROSS JOIN params p
    WHERE (p.policy_category IS NULL OR UPPER(p.policy_category) IN ('TRAVEL', 'EXPENSE', 'ALL'))
      AND (p.rule_name IS NULL OR UPPER(aerp.prompt) LIKE UPPER('%' || p.rule_name || '%'))
      AND (p.org_id IS NULL OR aerp.org_id = TO_NUMBER(p.org_id))
      AND (p.as_of_date IS NULL OR (TRUNC(aerp.creation_date) <= TO_DATE(p.as_of_date, 'YYYY-MM-DD')
           AND (aerp.end_date IS NULL OR aerp.end_date > TO_DATE(p.as_of_date, 'YYYY-MM-DD'))))
)
ORDER BY policy_category, rule_group
FETCH FIRST 200 ROWS ONLY;
