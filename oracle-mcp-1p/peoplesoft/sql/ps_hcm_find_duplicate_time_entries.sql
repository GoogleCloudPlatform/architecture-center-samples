-- Tool: ps_hcm_find_duplicate_time_entries
-- Skill: ps_hcm_expense_auditor
-- Oracle Bind Variables:
--   :project_id (string): Project ID to check. Empty = all projects.
--   :start_date (string): First work date (YYYY-MM-DD). Empty = no lower bound.
--   :end_date (string): Last work date (YYYY-MM-DD). Empty = no upper bound.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :project_id AS project_id,
        :start_date AS start_date,
        :end_date AS end_date
    FROM dual
)
SELECT * FROM (
    SELECT
        t.emplid,
        TO_CHAR(t.dur, 'YYYY-MM-DD') AS work_date,
        t.trc AS time_reporting_code,
        t.tl_quantity AS hours_or_quantity,
        TRIM(t.project_id) AS project_id,
        TRIM(t.fund_code) AS fund_code,
        COUNT(*) AS entry_count,
        COUNT(DISTINCT t.seq_nbr) AS distinct_sequences,
        MIN(t.seq_nbr) AS first_seq_nbr,
        MAX(t.seq_nbr) AS last_seq_nbr,
        SUM(t.est_gross) AS total_estimated_gross,
        LISTAGG(DISTINCT t.payable_status, ',') WITHIN GROUP (ORDER BY t.payable_status) AS payable_statuses
    FROM params p
    JOIN sysadm.ps_tl_payable_time t
        ON TRIM(t.project_id) IS NOT NULL
       AND t.payable_status IN ('AP', 'CL', 'SP', 'TP', 'PD')
       AND (p.project_id IS NULL OR t.project_id = p.project_id)
       AND (p.start_date IS NULL OR t.dur >= TO_DATE(p.start_date, 'YYYY-MM-DD'))
       AND (p.end_date IS NULL OR t.dur <= TO_DATE(p.end_date, 'YYYY-MM-DD'))
    GROUP BY t.emplid, t.dur, t.trc, t.tl_quantity, TRIM(t.project_id), TRIM(t.fund_code)
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC, SUM(t.est_gross) DESC
)
WHERE ROWNUM <= 200;
