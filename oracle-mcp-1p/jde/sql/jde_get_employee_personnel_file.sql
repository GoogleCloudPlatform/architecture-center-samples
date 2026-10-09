-- Tool: jde_get_employee_personnel_file
-- Skill: redaction_and_foia_compliance
-- Oracle Bind Variables:
--   :employee_an8 (string): Employee address number (F060116.YAAN8).
--   :employee_number (string): Additional employee number or badge number (F060116.YAOEMP), used when the address number is unknown.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :employee_an8 AS employee_an8,
        :employee_number AS employee_number
    FROM dual
)
-- HR history (F08042) and pay history (F06156) are returned as one text column each
-- (newest first) so an employee stays one row instead of multiplying rows.
SELECT
    ya.yaan8 AS employee_an8,
    TRIM(ya.yaoemp) AS employee_number,
    TRIM(ya.yaalph) AS full_name,
    TRIM(ww.wwgnnm) AS first_name,
    TRIM(ww.wwsrnm) AS last_name,
    TRIM(ya.yassn) AS ssn_tax_id,
    CASE WHEN ya.yadob > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadob + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS date_of_birth,
    TRIM(ya.yasex) AS gender,
    TRIM(al.aladd1) AS home_address,
    TRIM(al.alcty1) AS home_city,
    TRIM(al.aladds) AS home_state,
    TRIM(al.aladdz) AS home_postal_code,
    TRIM(ya.yahmco) AS home_company,
    TRIM(ya.yahmcu) AS home_business_unit,
    TRIM(bu.mcdl01) AS home_business_unit_name,
    TRIM(ya.yajbcd) AS job_type,
    TRIM(ya.yajbst) AS job_step,
    ya.yaest AS employment_status,
    ya.yapast AS pay_status,
    ya.yaanpa AS supervisor_an8,
    ya.yasal / 100 AS annual_salary,
    ya.yaphrt / 1000 AS hourly_rate,
    CASE WHEN ya.yadsi > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadsi + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS original_hire_date,
    CASE WHEN ya.yadst > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadst + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS start_date,
    CASE WHEN ya.yadt > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(ya.yadt + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS termination_date,
    TRIM(ya.yatrs) AS last_change_reason,
    (SELECT LISTAGG(
                CASE WHEN h.jwefto > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(h.jwefto + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END
                || ' ' || TRIM(h.jwdtai) || '=' || TRIM(h.jwhstd)
                || CASE WHEN TRIM(h.jwtrs) IS NOT NULL THEN ' (reason ' || TRIM(h.jwtrs) || ')' END,
                '; ' ON OVERFLOW TRUNCATE '...' WITH COUNT)
            WITHIN GROUP (ORDER BY h.jwefto DESC)
       FROM proddta.f08042 h
      WHERE h.jwan8 = ya.yaan8) AS hr_history,
    (SELECT LISTAGG(
                CASE WHEN pc.yuckd > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(pc.yuckd + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END
                || ' check ' || TO_CHAR(pc.yudocm)
                || ' gross ' || TO_CHAR(pc.yugpay / 100, 'FM999999990.00')
                || ' net ' || TO_CHAR(pc.yunpay / 100, 'FM999999990.00'),
                '; ' ON OVERFLOW TRUNCATE '...' WITH COUNT)
            WITHIN GROUP (ORDER BY pc.yuckd DESC)
       FROM proddta.f06156 pc
      WHERE pc.yuan8 = ya.yaan8) AS pay_history
FROM params p
JOIN proddta.f060116 ya
    ON (p.employee_an8 IS NOT NULL AND ya.yaan8 = TO_NUMBER(p.employee_an8))
    OR (p.employee_number IS NOT NULL AND TRIM(ya.yaoemp) = TRIM(p.employee_number))
LEFT JOIN proddta.f0111 ww
    ON ww.wwan8 = ya.yaan8
   AND ww.wwidln = 0
LEFT JOIN (
    SELECT a.*
    FROM proddta.f0116 a
    WHERE a.aleftb = (SELECT MAX(x.aleftb) FROM proddta.f0116 x WHERE x.alan8 = a.alan8)
) al
    ON al.alan8 = ya.yaan8
LEFT JOIN proddta.f0006 bu
    ON bu.mcmcu = ya.yahmcu;
