-- Tool: jde_lookup_employees
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :name_keyword (string): Full or partial employee name (e.g. 'Smith').
--   :employee_number (string): Optional additional employee or badge number (F060116.YAOEMP).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :name_keyword AS name_keyword,
        :employee_number AS employee_number
    FROM dual
)
SELECT
    ya.yaan8 AS employee_an8,
    TRIM(ya.yaoemp) AS employee_number,
    TRIM(ya.yaalph) AS full_name,
    CASE WHEN TRIM(ya.yassn) IS NOT NULL THEN 'XXX-XX-' || SUBSTR(TRIM(ya.yassn), -4) END AS ssn_masked,
    TRIM(ya.yahmco) AS home_company,
    TRIM(ya.yahmcu) AS home_business_unit,
    TRIM(ya.yajbcd) AS job_type,
    ya.yapast AS pay_status,
    CASE WHEN ya.yadst > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadst + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS start_date,
    CASE WHEN ya.yadt > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadt + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS termination_date
FROM proddta.f060116 ya
CROSS JOIN params p
WHERE (p.name_keyword IS NULL OR UPPER(ya.yaalph) LIKE UPPER('%' || p.name_keyword || '%'))
  AND (p.employee_number IS NULL OR TRIM(ya.yaoemp) = TRIM(p.employee_number))
ORDER BY ya.yaalph
FETCH FIRST 25 ROWS ONLY;
