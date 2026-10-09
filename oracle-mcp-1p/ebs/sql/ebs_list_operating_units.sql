-- Tool: ebs_list_operating_units
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :name_pattern (string): Optional search pattern to filter operating units by name (e.g. '%Vision%' or '%Government%'). Defaults to '%' if empty.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :name_pattern AS name_pattern FROM dual
)
SELECT
    hou.organization_id,
    hou.name AS operating_unit_name,
    hou.short_code,
    hou.business_group_id
FROM apps.hr_operating_units hou, params p
WHERE (p.name_pattern IS NULL OR UPPER(hou.name) LIKE UPPER(p.name_pattern) OR p.name_pattern = '%')
ORDER BY hou.name
FETCH FIRST 50 ROWS ONLY;
