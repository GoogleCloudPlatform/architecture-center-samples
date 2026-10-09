-- Tool: ebs_get_award_expenditures
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :award_number (string): Exact award number (see ebs_get_award_terms). Empty string = all awards.
--   :start_date (string): Expenditure item date window start in YYYY-MM-DD format. Empty string = no lower bound.
--   :end_date (string): Expenditure item date window end in YYYY-MM-DD format. Empty string = no upper bound.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :award_number AS award_number,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
),
aw AS (
    SELECT
        ga.award_id,
        ga.award_number,
        ga.start_date_active,
        ga.end_date_active
    FROM params p
    JOIN apps.gms_awards_all ga
        ON (p.award_number IS NULL OR ga.award_number = p.award_number)
),
act AS (
    SELECT
        aw.award_id,
        pei.expenditure_type,
        pei.system_linkage_function,
        COUNT(*) AS item_count,
        SUM(gad.raw_cost) AS actual_raw_cost,
        TO_CHAR(MIN(pei.expenditure_item_date), 'YYYY-MM-DD') AS first_item_date,
        TO_CHAR(MAX(pei.expenditure_item_date), 'YYYY-MM-DD') AS last_item_date,
        SUM(CASE WHEN pei.expenditure_item_date < aw.start_date_active
                   OR pei.expenditure_item_date > aw.end_date_active
                 THEN gad.raw_cost ELSE 0 END) AS cost_outside_award_period
    FROM aw
    JOIN apps.gms_award_distributions gad
        ON gad.award_id = aw.award_id
       AND gad.document_type = 'EXP'
       AND gad.line_type = 'R'
       AND NVL(gad.reversed_flag, 'N') <> 'Y'
    JOIN apps.pa_expenditure_items_all pei
        ON pei.expenditure_item_id = gad.expenditure_item_id
    CROSS JOIN params p
    WHERE (p.start_date IS NULL OR pei.expenditure_item_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
      AND (p.end_date IS NULL OR pei.expenditure_item_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    GROUP BY aw.award_id, pei.expenditure_type, pei.system_linkage_function
)
SELECT
    aw.award_number,
    act.expenditure_type,
    act.system_linkage_function,
    act.item_count,
    act.actual_raw_cost,
    act.cost_outside_award_period,
    TO_CHAR(aw.start_date_active, 'YYYY-MM-DD') AS award_start_date,
    TO_CHAR(aw.end_date_active, 'YYYY-MM-DD') AS award_end_date,
    act.first_item_date,
    act.last_item_date
FROM aw
JOIN act
    ON act.award_id = aw.award_id
ORDER BY aw.award_number, act.expenditure_type
FETCH FIRST 200 ROWS ONLY;
