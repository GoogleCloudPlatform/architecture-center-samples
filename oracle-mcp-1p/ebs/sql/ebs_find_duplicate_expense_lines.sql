-- Tool: ebs_find_duplicate_expense_lines
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :org_id (string): Operating unit ID (ORG_ID). Empty string = all operating units.
--   :start_date (string): Submission (week end) date window start in YYYY-MM-DD format. Empty string = no lower bound.
--   :end_date (string): Submission (week end) date window end in YYYY-MM-DD format. Empty string = no upper bound.
--   :min_amount (string): Ignore lines below this amount, e.g. '100'. Empty string = include all amounts.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :org_id AS org_id,
        :start_date AS start_date,
        :end_date AS end_date,
        :min_amount AS min_amount
    FROM dual
),
base AS (
    SELECT
        aerh.report_header_id,
        aerh.invoice_num,
        aerh.employee_id,
        aerh.week_end_date,
        aerl.report_line_id,
        aerl.amount,
        aerl.start_expense_date,
        aerl.justification,
        NVL(er_param.prompt, aerl.category_code) AS expense_type
    FROM params p
    JOIN apps.ap_expense_report_headers_all aerh
        ON (p.org_id IS NULL OR aerh.org_id = TO_NUMBER(p.org_id))
       AND (p.start_date IS NULL OR aerh.week_end_date >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR aerh.week_end_date <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    JOIN apps.ap_expense_report_lines_all aerl
        ON aerl.report_header_id = aerh.report_header_id
       AND (p.min_amount IS NULL OR aerl.amount >= TO_NUMBER(p.min_amount))
    LEFT JOIN apps.ap_expense_report_params_all er_param
        ON aerl.web_parameter_id = er_param.parameter_id
)
SELECT * FROM (
    SELECT
        d.match_type,
        d.employee_id,
        (SELECT MAX(papf.full_name) KEEP (DENSE_RANK LAST ORDER BY papf.effective_start_date)
           FROM apps.per_all_people_f papf
          WHERE papf.person_id = d.employee_id) AS employee_name,
        d.expense_type,
        d.line_amount,
        d.justification,
        d.expense_date,
        d.report_count,
        d.line_count,
        d.total_amount,
        d.first_submitted,
        d.last_submitted,
        d.reports
    FROM (
        SELECT
            'SAME_LINE_ACROSS_REPORTS' AS match_type,
            b.employee_id,
            b.expense_type,
            b.amount AS line_amount,
            b.justification,
            CAST(NULL AS VARCHAR2(10)) AS expense_date,
            COUNT(DISTINCT b.report_header_id) AS report_count,
            COUNT(*) AS line_count,
            SUM(b.amount) AS total_amount,
            TO_CHAR(MIN(b.week_end_date), 'YYYY-MM-DD') AS first_submitted,
            TO_CHAR(MAX(b.week_end_date), 'YYYY-MM-DD') AS last_submitted,
            LISTAGG(b.invoice_num, ', ' ON OVERFLOW TRUNCATE '...') WITHIN GROUP (ORDER BY b.week_end_date) AS reports
        FROM base b
        GROUP BY b.employee_id, b.expense_type, b.amount, b.justification
        HAVING COUNT(DISTINCT b.report_header_id) >= 2
        UNION ALL
        SELECT
            'SAME_DAY_SAME_AMOUNT' AS match_type,
            b.employee_id,
            b.expense_type,
            b.amount AS line_amount,
            MAX(b.justification) AS justification,
            TO_CHAR(b.start_expense_date, 'YYYY-MM-DD') AS expense_date,
            COUNT(DISTINCT b.report_header_id) AS report_count,
            COUNT(*) AS line_count,
            SUM(b.amount) AS total_amount,
            TO_CHAR(MIN(b.week_end_date), 'YYYY-MM-DD') AS first_submitted,
            TO_CHAR(MAX(b.week_end_date), 'YYYY-MM-DD') AS last_submitted,
            LISTAGG(b.invoice_num, ', ' ON OVERFLOW TRUNCATE '...') WITHIN GROUP (ORDER BY b.week_end_date) AS reports
        FROM base b
        GROUP BY b.employee_id, b.expense_type, b.amount, b.start_expense_date
        HAVING COUNT(*) >= 2
    ) d
    ORDER BY d.total_amount DESC, d.employee_id
)
FETCH FIRST 100 ROWS ONLY;
