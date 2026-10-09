-- Tool: ps_hcm_get_earnings_rules
-- Skill: ps_hcm_policy_and_statute_assistant
-- Oracle Bind Variables:
--   :as_of_date (string): Date the rules must be in force on (YYYY-MM-DD). Empty = today.
--   :erncd (string): Earnings code. Empty = any.
--   :keyword (string): Text to find in the earnings code description (case-insensitive). Empty = no text filter.
--   :active_only (string): Y = only active codes, N or empty = include inactive.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :as_of_date AS as_of_date,
        :erncd AS erncd,
        :keyword AS keyword,
        :active_only AS active_only
    FROM dual
)
SELECT * FROM (
    SELECT
        e.erncd AS earnings_code,
        e.descr AS description,
        e.eff_status,
        TO_CHAR(e.effdt, 'YYYY-MM-DD') AS effective_date,
        NVL(p.as_of_date, TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD')) AS as_of_date,
        e.payment_type,
        e.amt_or_hours,
        e.hrly_rt_maximum AS hourly_rate_maximum,
        e.earn_flat_amt AS flat_amount,
        e.earn_ytd_max AS year_to_date_maximum,
        e.factor_mult AS rate_multiplier,
        e.add_gross AS adds_to_gross,
        e.subject_fwt AS subject_to_federal_tax,
        e.subject_fica AS subject_to_fica,
        e.effect_on_flsa,
        e.flsa_category,
        e.shift_diff_elig AS shift_differential_eligible
    FROM params p
    JOIN sysadm.ps_earnings_tbl e
        ON (p.erncd IS NULL OR e.erncd = p.erncd)
       AND (p.keyword IS NULL OR UPPER(e.descr) LIKE '%' || UPPER(p.keyword) || '%')
       AND (p.active_only IS NULL OR UPPER(p.active_only) <> 'Y' OR e.eff_status = 'A')
       AND e.effdt = (SELECT MAX(e2.effdt) FROM sysadm.ps_earnings_tbl e2
                       WHERE e2.erncd = e.erncd
                         AND e2.effdt <= NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)))
    ORDER BY e.erncd
)
WHERE ROWNUM <= 100;
