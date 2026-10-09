-- Tool: ebs_list_lookup_values
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :lookup_type (string): The FND lookup type (e.g. 'PO_CONTROL_RULES', 'YES_NO', 'FOB_VALUES', 'DOCUMENT_TYPE').
--   :keyword (string): Optional keyword to filter lookup codes or descriptions.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :lookup_type AS lookup_type,
        :keyword AS keyword
    FROM dual
)
SELECT
    flv.lookup_type,
    flv.lookup_code,
    flv.meaning,
    flv.description
FROM apps.fnd_lookup_values flv, params p
WHERE flv.lookup_type = UPPER(p.lookup_type)
  AND flv.language = USERENV('LANG')
  AND flv.enabled_flag = 'Y'
  AND (p.keyword IS NULL OR UPPER(flv.lookup_code) LIKE UPPER(p.keyword) OR UPPER(flv.meaning) LIKE UPPER(p.keyword))
ORDER BY flv.lookup_code
FETCH FIRST 50 ROWS ONLY;
