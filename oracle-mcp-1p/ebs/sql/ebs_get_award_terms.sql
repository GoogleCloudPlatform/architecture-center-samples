-- Tool: ebs_get_award_terms
-- Skill: expense_auditor
-- Oracle Bind Variables:
--   :org_id (string): Operating unit ID (ORG_ID). Empty string = all operating units.
--   :award_number (string): Full or partial award number or name. Empty string = all awards.
--   :as_of_date (string): Date to test the award period against, YYYY-MM-DD. Empty string = today.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :org_id AS org_id,
        :award_number AS award_number,
        :as_of_date AS as_of_date
    FROM dual
)
SELECT
    ga.award_id,
    ga.award_number,
    ga.award_short_name,
    ga.award_full_name,
    ga.status AS award_status,
    ga.type AS award_type,
    ga.award_purpose_code,
    ga.funding_source_id,
    ga.funding_source_award_number AS sponsor_award_number,
    TO_CHAR(ga.preaward_date, 'YYYY-MM-DD') AS preaward_date,
    TO_CHAR(ga.start_date_active, 'YYYY-MM-DD') AS start_date,
    TO_CHAR(ga.end_date_active, 'YYYY-MM-DD') AS end_date,
    TO_CHAR(ga.close_date, 'YYYY-MM-DD') AS close_date,
    CASE
        WHEN ga.start_date_active IS NOT NULL
         AND NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)) < ga.start_date_active THEN 'NOT_STARTED'
        WHEN ga.end_date_active IS NOT NULL
         AND NVL(TO_DATE(p.as_of_date, 'YYYY-MM-DD'), TRUNC(SYSDATE)) > ga.end_date_active THEN 'PAST_END_DATE'
        ELSE 'WITHIN_PERIOD'
    END AS period_status,
    ga.award_manager_id,
    (SELECT MAX(papf.full_name) KEEP (DENSE_RANK LAST ORDER BY papf.effective_start_date)
       FROM apps.per_all_people_f papf
      WHERE papf.person_id = ga.award_manager_id) AS award_manager_name,
    ga.award_organization_id,
    ga.org_id,
    ga.hard_limit_flag,
    ga.fund_control_level_award,
    ga.allowable_schedule_id,
    ga.idc_schedule_id,
    (SELECT COUNT(*)
       FROM apps.gms_installments gi
      WHERE gi.award_id = ga.award_id) AS installment_count,
    (SELECT SUM(gi.direct_cost)
       FROM apps.gms_installments gi
      WHERE gi.award_id = ga.award_id
        AND NVL(gi.active_flag, 'Y') = 'Y') AS funded_direct_cost,
    (SELECT SUM(gi.indirect_cost)
       FROM apps.gms_installments gi
      WHERE gi.award_id = ga.award_id
        AND NVL(gi.active_flag, 'Y') = 'Y') AS funded_indirect_cost,
    (SELECT MAX(gbv.raw_cost) KEEP (DENSE_RANK LAST ORDER BY gbv.version_number)
       FROM apps.gms_budget_versions gbv
      WHERE gbv.award_id = ga.award_id
        AND gbv.current_flag = 'Y') AS budget_raw_cost,
    (SELECT MAX(gbv.burdened_cost) KEEP (DENSE_RANK LAST ORDER BY gbv.version_number)
       FROM apps.gms_budget_versions gbv
      WHERE gbv.award_id = ga.award_id
        AND gbv.current_flag = 'Y') AS budget_burdened_cost,
    (SELECT MAX(gbv.budget_status_code) KEEP (DENSE_RANK LAST ORDER BY gbv.version_number)
       FROM apps.gms_budget_versions gbv
      WHERE gbv.award_id = ga.award_id
        AND gbv.current_flag = 'Y') AS budget_status
FROM params p
JOIN apps.gms_awards_all ga
    ON (p.org_id IS NULL OR ga.org_id = TO_NUMBER(p.org_id))
   AND (p.award_number IS NULL
        OR UPPER(ga.award_number) LIKE UPPER('%' || p.award_number || '%')
        OR UPPER(ga.award_full_name) LIKE UPPER('%' || p.award_number || '%'))
WHERE NVL(ga.award_template_flag, 'N') <> 'Y'
ORDER BY ga.award_number
FETCH FIRST 50 ROWS ONLY;
