-- Tool: ps_hcm_get_leave_policy_rules
-- Skill: ps_hcm_policy_and_statute_assistant
-- Oracle Bind Variables:
--   :as_of_date (string): Date the rules must be in force on (YYYY-MM-DD). Empty = today.
--   :plan_type (string): Leave plan type code (for example 50, 51, 52). Empty = any.
--   :benefit_plan (string): Leave benefit plan code. Empty = any.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :as_of_date AS as_of_date,
        :plan_type AS plan_type,
        :benefit_plan AS benefit_plan
    FROM dual
)
SELECT * FROM (
    SELECT
        lp.plan_type,
        lp.benefit_plan,
        TO_CHAR(lp.effdt, 'YYYY-MM-DD') AS effective_date,
        NVL(p.as_of_date, TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD')) AS as_of_date,
        lp.accrual_frequency,
        lp.service_interval,
        lp.year_begin_calc,
        lp.maximum_leave_bal AS maximum_leave_balance,
        lp.maximum_carryover,
        lp.pay_at_termination,
        lp.pay_term_pct AS pay_at_termination_pct,
        lp.pay_vs_leave,
        lp.hrs_go_negative AS may_go_negative,
        lp.max_neg_hrs AS maximum_negative_hours,
        lp.balance_visible
    FROM params p
    JOIN sysadm.ps_leave_plan_tbl lp
        ON (p.plan_type IS NULL OR lp.plan_type = p.plan_type)
       AND (p.benefit_plan IS NULL OR lp.benefit_plan = p.benefit_plan)
       AND lp.effdt = (SELECT MAX(lp2.effdt) FROM sysadm.ps_leave_plan_tbl lp2
                        WHERE lp2.plan_type = lp.plan_type AND lp2.benefit_plan = lp.benefit_plan
                          AND lp2.effdt <= NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)))
    ORDER BY lp.plan_type, lp.benefit_plan
)
WHERE ROWNUM <= 100;
