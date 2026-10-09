-- Tool: ebs_list_attachment_entities
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :keyword (string): Keyword to filter entity code or user entity name (e.g. '%PO%' or '%INVOICE%').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :keyword AS keyword FROM dual
)
SELECT
    fde.data_object_code AS entity_name,
    fde.user_entity_name,
    fde.table_name
FROM apps.fnd_document_entities_vl fde, params p
WHERE (p.keyword IS NULL OR UPPER(fde.data_object_code) LIKE UPPER(p.keyword) OR UPPER(fde.user_entity_name) LIKE UPPER(p.keyword))
ORDER BY fde.data_object_code
FETCH FIRST 50 ROWS ONLY;
