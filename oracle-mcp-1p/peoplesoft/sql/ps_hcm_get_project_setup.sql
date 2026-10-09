-- Tool: ps_hcm_get_project_setup
-- Skill: ps_hcm_expense_auditor
-- Oracle Bind Variables:
--   :business_unit (string): Project Costing business unit. Empty = any.
--   :project_id (string): Project ID. Empty = any.
--   :keyword (string): Text to find in the project ID or description (case-insensitive). Empty = no text filter.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :business_unit AS business_unit,
        :project_id AS project_id,
        :keyword AS keyword
    FROM dual
),
team AS (
    SELECT
        tm.business_unit, tm.project_id,
        COUNT(*) AS team_member_count,
        LISTAGG(DISTINCT tm.proj_role, ',') WITHIN GROUP (ORDER BY tm.proj_role) AS team_roles
    FROM sysadm.ps_project_team tm
    GROUP BY tm.business_unit, tm.project_id
)
SELECT * FROM (
    SELECT
        pr.business_unit,
        pr.project_id,
        pr.descr AS project_description,
        pr.eff_status,
        pr.project_type,
        pr.project_function,
        pr.in_use_sw AS in_use,
        TO_CHAR(pr.start_dt, 'YYYY-MM-DD') AS start_date,
        TO_CHAR(pr.end_dt, 'YYYY-MM-DD') AS end_date,
        pr.currency_cd,
        pr.percent_complete,
        pr.docket_number,
        pr.system_source,
        pr.template_sw AS is_template,
        pr.summary_sw AS is_summary,
        NVL(tm.team_member_count, 0) AS team_member_count,
        tm.team_roles
    FROM params p
    JOIN sysadm.ps_project pr
        ON (p.business_unit IS NULL OR pr.business_unit = p.business_unit)
       AND (p.project_id IS NULL OR pr.project_id = p.project_id)
       AND (p.keyword IS NULL
            OR UPPER(pr.project_id) LIKE '%' || UPPER(p.keyword) || '%'
            OR UPPER(pr.descr) LIKE '%' || UPPER(p.keyword) || '%')
    LEFT JOIN team tm
        ON tm.business_unit = pr.business_unit
       AND tm.project_id = pr.project_id
    ORDER BY pr.business_unit, pr.project_id
)
WHERE ROWNUM <= 100;
