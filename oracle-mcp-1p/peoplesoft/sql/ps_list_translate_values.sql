-- Tool: ps_list_translate_values
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :fieldname (string): Field name in PeopleSoft data dictionary (e.g. 'CATEGORY', 'ACTION', 'STATUS', 'POLICY_CODE').
--   :search_keyword (string): Optional keyword to filter display name or description.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :fieldname AS fieldname,
        :search_keyword AS search_keyword
    FROM dual
)
SELECT
    x.fieldname,
    x.fieldvalue,
    x.xlatlongname,
    x.xlatshortname,
    x.eff_status
FROM sysadm.psxlatitem x, params p
WHERE x.fieldname = UPPER(p.fieldname)
  AND x.eff_status = 'A'
  AND (p.search_keyword IS NULL OR UPPER(x.xlatlongname) LIKE UPPER('%' || p.search_keyword || '%'))
ORDER BY x.fieldvalue
FETCH FIRST 50 ROWS ONLY;
