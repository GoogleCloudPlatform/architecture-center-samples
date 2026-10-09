-- Tool: ps_hcm_get_labor_distribution
-- Skill: ps_hcm_expense_auditor
-- Oracle Bind Variables:
--   :emplid (string): Employee ID. Empty = any.
--   :project_id (string): Project ID that the time is charged to. Empty = any project.
--   :business_unit_pc (string): Project Costing business unit of the project. Empty = any.
--   :start_date (string): First work date (YYYY-MM-DD). Empty = no lower bound.
--   :end_date (string): Last work date (YYYY-MM-DD). Empty = no upper bound.
--   :payable_status (string): Time and Labor payable status code (see ps_list_translate_values, field PAYABLE_STATUS). Empty = any.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :emplid AS emplid,
        :project_id AS project_id,
        :business_unit_pc AS business_unit_pc,
        :start_date AS start_date,
        :end_date AS end_date,
        :payable_status AS payable_status
    FROM dual
)
SELECT * FROM (
    SELECT
        t.emplid,
        t.empl_rcd,
        TO_CHAR(t.dur, 'YYYY-MM-DD') AS work_date,
        t.seq_nbr,
        t.trc AS time_reporting_code,
        t.tl_quantity AS hours_or_quantity,
        t.payable_status,
        t.est_gross AS estimated_gross,
        t.lbr_dist_amt AS labor_distribution_amount,
        TRIM(t.business_unit_pc) AS project_business_unit,
        TRIM(t.project_id) AS project_id,
        pr.descr AS project_description,
        TRIM(t.activity_id) AS activity_id,
        TRIM(t.fund_code) AS fund_code,
        TRIM(t.account) AS account,
        TRIM(t.acct_cd) AS account_code,
        TRIM(t.program_code) AS program_code,
        t.deptid,
        t.jobcode,
        t.company,
        t.billable_ind,
        t.oprid AS entered_by,
        TO_CHAR(t.lastupddttm, 'YYYY-MM-DD HH24:MI:SS') AS last_updated
    FROM params p
    JOIN sysadm.ps_tl_payable_time t
        ON TRIM(t.project_id) IS NOT NULL
       AND (p.emplid IS NULL OR t.emplid = p.emplid)
       AND (p.project_id IS NULL OR t.project_id = p.project_id)
       AND (p.business_unit_pc IS NULL OR t.business_unit_pc = p.business_unit_pc)
       AND (p.start_date IS NULL OR t.dur >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR t.dur <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
       AND (p.payable_status IS NULL OR t.payable_status = p.payable_status)
    LEFT JOIN sysadm.ps_project pr
        ON pr.business_unit = t.business_unit_pc
       AND pr.project_id = t.project_id
    ORDER BY t.dur DESC, t.emplid, t.seq_nbr
)
WHERE ROWNUM <= 200;
