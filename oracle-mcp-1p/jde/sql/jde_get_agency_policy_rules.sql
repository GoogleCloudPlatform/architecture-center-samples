-- Tool: jde_get_agency_policy_rules
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :policy_category (string): Policy category: 'EXPENSE' (per diem and receipt rules), 'AUDIT' (expense audit sampling), 'PROCUREMENT' (approval limits) or 'ALL'.
--   :rule_name (string): Optional expense policy name or procurement approval route code (partial match).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :policy_category AS policy_category,
        :rule_name AS rule_name
    FROM dual
)
SELECT * FROM (
    -- Expense Management policy rules by expense category and location
    SELECT
        'EXPENSE' AS policy_category,
        TO_CHAR(TRIM(pr.prpolicy)) AS rule_group,
        TO_CHAR(TRIM(pr.prdl01)) AS rule_description,
        TO_CHAR(TRIM(pr.prexptype)) AS rule_type,
        TO_CHAR('Location ' || NVL(TRIM(pr.prlocatn), 'ANY') || ' | Report type ' || TRIM(pr.prexrpttyp)) AS rule_scope,
        pr.prdlyallow / 100 AS threshold_amount,
        TO_CHAR(pr.prrctrqd) AS receipt_required,
        pr.prdomrctam / 100 AS receipt_threshold_amount,
        pr.prrate1 / 1000 AS rate_or_percent,
        'Audit amount ' || TO_CHAR(pr.prauditamt / 100, 'FM999999990.00')
            || ' | Tolerance ' || TO_CHAR(pr.prtoler) || '%'
            || ' | Hard edit ' || TO_CHAR(pr.prhedit)
            || ' | Allowable/unallowable rule ' || TO_CHAR(pr.prgovtflag) AS rule_notes,
        TO_CHAR(TRIM(pr.prpolcrcy)) AS currency_code,
        CASE WHEN pr.preftj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(pr.preftj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS effective_start_date,
        CASE WHEN pr.prexdj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(pr.prexdj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS effective_end_date
    FROM proddta.f09e108 pr
    CROSS JOIN params p
    WHERE (p.policy_category IS NULL OR UPPER(p.policy_category) IN ('EXPENSE', 'TRAVEL', 'ALL'))
      AND (p.rule_name IS NULL OR UPPER(pr.prpolicy) LIKE UPPER('%' || p.rule_name || '%'))

    UNION ALL

    -- Expense audit selection (sampling) rules
    SELECT
        'AUDIT' AS policy_category,
        TO_CHAR(TRIM(au.aspolicy)) AS rule_group,
        TO_CHAR('Audit selection rule ' || TO_CHAR(au.asrulenum)) AS rule_description,
        'AUDIT_SAMPLING' AS rule_type,
        TO_CHAR('Report amount ' || TO_CHAR(au.asfromrng / 100, 'FM999999990.00') || ' to ' || TO_CHAR(au.asthrurng / 100, 'FM999999990.00')) AS rule_scope,
        au.asthrurng / 100 AS threshold_amount,
        NULL AS receipt_required,
        NULL AS receipt_threshold_amount,
        au.aspercsel AS rate_or_percent,
        'Percent of reports selected for audit' AS rule_notes,
        NULL AS currency_code,
        CASE WHEN au.aseftb > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(au.aseftb + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS effective_start_date,
        NULL AS effective_end_date
    FROM proddta.f09e110 au
    CROSS JOIN params p
    WHERE (p.policy_category IS NULL OR UPPER(p.policy_category) IN ('AUDIT', 'EXPENSE', 'ALL'))
      AND (p.rule_name IS NULL OR UPPER(au.aspolicy) LIKE UPPER('%' || p.rule_name || '%'))

    UNION ALL

    -- Procurement approval routes and delegation-of-authority limits
    SELECT
        'PROCUREMENT' AS policy_category,
        TO_CHAR(TRIM(ap.apartg)) AS rule_group,
        TO_CHAR(TRIM(ap.apdl01)) AS rule_description,
        'APPROVAL_LIMIT' AS rule_type,
        TO_CHAR('Order type ' || ap.apdcto || ' | Approver ' || TRIM(ab.abalph) || ' (' || TO_CHAR(ap.aprper) || ')') AS rule_scope,
        ap.apalim AS threshold_amount,
        NULL AS receipt_required,
        NULL AS receipt_threshold_amount,
        NULL AS rate_or_percent,
        'Approver type ' || TO_CHAR(ap.apaty) AS rule_notes,
        NULL AS currency_code,
        NULL AS effective_start_date,
        NULL AS effective_end_date
    FROM proddta.f43008 ap
    LEFT JOIN proddta.f0101 ab
        ON ab.aban8 = ap.aprper
    CROSS JOIN params p
    WHERE (p.policy_category IS NULL OR UPPER(p.policy_category) IN ('PROCUREMENT', 'ALL'))
      AND (p.rule_name IS NULL OR UPPER(ap.apartg) LIKE UPPER('%' || p.rule_name || '%'))
)
ORDER BY policy_category, rule_group, rule_type;
