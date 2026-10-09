-- Tool: ebs_lookup_employees
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :name_keyword (string): Full or partial employee name (e.g. 'Smith').
--   :employee_number (string): Exact or partial employee badge / worker number.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :name_keyword AS name_keyword,
        :employee_number AS employee_number
    FROM dual
)
SELECT
    papf.person_id,
    papf.employee_number,
    papf.full_name,
    papf.email_address,
    CASE WHEN papf.national_identifier IS NULL THEN NULL
         ELSE 'XXXXX' || SUBSTR(REGEXP_REPLACE(papf.national_identifier, '[^0-9A-Za-z]', ''), -4)
    END AS ssn_masked,
    TO_CHAR(papf.effective_start_date, 'YYYY-MM-DD') AS effective_start_date
FROM apps.per_all_people_f papf, params p
WHERE TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
  AND (p.name_keyword IS NULL OR UPPER(papf.full_name) LIKE UPPER('%' || p.name_keyword || '%'))
  AND (p.employee_number IS NULL OR papf.employee_number = p.employee_number)
ORDER BY papf.full_name
FETCH FIRST 25 ROWS ONLY;
