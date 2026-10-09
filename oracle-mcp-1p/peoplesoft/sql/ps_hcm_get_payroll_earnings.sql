-- Tool: ps_hcm_get_payroll_earnings
-- Skill: ps_hcm_expense_auditor
-- Oracle Bind Variables:
--   :emplid (string): Employee ID. Empty = any.
--   :company (string): Company code. Empty = any.
--   :start_date (string): Earliest pay period end date (YYYY-MM-DD). Empty = no lower bound.
--   :end_date (string): Latest pay period end date (YYYY-MM-DD). Empty = no upper bound.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :company AS company,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
),
ern AS (
    SELECT
        e.company, e.paygroup, e.pay_end_dt, e.off_cycle, e.page_num, e.line_num, e.sepchk,
        COUNT(*) AS earnings_lines,
        SUM(e.reg_hrs) AS regular_hours,
        SUM(e.ot_hrs) AS overtime_hours,
        SUM(NVL(e.reg_earns, 0) + NVL(e.reg_pay, 0) + NVL(e.reg_hrly_earns, 0)) AS regular_earnings,
        SUM(e.ot_hrly_earns) AS overtime_earnings,
        COUNT(DISTINCT e.deptid) AS department_count,
        COUNT(DISTINCT TRIM(e.acct_cd)) AS account_code_count
    FROM params p
    JOIN sysadm.ps_pay_earnings e
        ON (p.emplid IS NULL OR e.emplid = p.emplid)
       AND (p.company IS NULL OR e.company = p.company)
       AND (p.start_date IS NULL OR e.pay_end_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR e.pay_end_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    GROUP BY e.company, e.paygroup, e.pay_end_dt, e.off_cycle, e.page_num, e.line_num, e.sepchk
),
oth AS (
    SELECT
        o.company, o.paygroup, o.pay_end_dt, o.off_cycle, o.page_num, o.line_num, o.sepchk,
        SUM(o.oth_earns) AS other_earnings,
        SUM(o.oth_hrs) AS other_hours,
        LISTAGG(DISTINCT o.erncd, ',') WITHIN GROUP (ORDER BY o.erncd) AS other_earnings_codes
    FROM params p
    JOIN sysadm.ps_pay_oth_earns o
        ON (p.company IS NULL OR o.company = p.company)
       AND (p.start_date IS NULL OR o.pay_end_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR o.pay_end_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    GROUP BY o.company, o.paygroup, o.pay_end_dt, o.off_cycle, o.page_num, o.line_num, o.sepchk
)
SELECT * FROM (
    SELECT
        c.emplid,
        c.company,
        c.paygroup,
        TO_CHAR(c.pay_end_dt, 'YYYY-MM-DD') AS pay_period_end,
        TO_CHAR(c.check_dt, 'YYYY-MM-DD') AS check_date,
        c.paycheck_nbr,
        c.off_cycle,
        c.paycheck_status,
        c.deptid,
        c.total_gross,
        c.total_taxes,
        c.total_deductions,
        c.net_pay,
        e.earnings_lines,
        e.regular_hours,
        e.overtime_hours,
        e.regular_earnings,
        e.overtime_earnings,
        o.other_earnings,
        o.other_earnings_codes,
        e.department_count,
        e.account_code_count,
        c.total_gross - (NVL(e.regular_earnings, 0) + NVL(e.overtime_earnings, 0) + NVL(o.other_earnings, 0)) AS gross_minus_earnings
    FROM params p
    JOIN sysadm.ps_pay_check c
        ON (p.emplid IS NULL OR c.emplid = p.emplid)
       AND (p.company IS NULL OR c.company = p.company)
       AND (p.start_date IS NULL OR c.pay_end_dt >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR c.pay_end_dt <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    LEFT JOIN ern e
        ON e.company = c.company AND e.paygroup = c.paygroup AND e.pay_end_dt = c.pay_end_dt
       AND e.off_cycle = c.off_cycle AND e.page_num = c.page_num AND e.line_num = c.line_num AND e.sepchk = c.sepchk
    LEFT JOIN oth o
        ON o.company = c.company AND o.paygroup = c.paygroup AND o.pay_end_dt = c.pay_end_dt
       AND o.off_cycle = c.off_cycle AND o.page_num = c.page_num AND o.line_num = c.line_num AND o.sepchk = c.sepchk
    ORDER BY c.check_dt DESC, c.emplid
)
WHERE ROWNUM <= 200;
