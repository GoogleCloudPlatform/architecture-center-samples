-- Tool: jde_list_business_units
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :name_pattern (string): Optional search pattern for business unit code, business unit name or company name (e.g. '%HEALTH%' or '%Grant%').
--   :company (string): Optional company code filter (e.g. '00001').
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :name_pattern AS name_pattern,
        :company AS company
    FROM dual
)
SELECT
    TRIM(bu.mcco) AS company,
    TRIM(co.ccname) AS company_name,
    TRIM(bu.mcmcu) AS business_unit,
    TRIM(bu.mcdl01) AS business_unit_name,
    TRIM(bu.mcstyl) AS business_unit_type,
    bu.mcpecc AS posting_edit_code
FROM proddta.f0006 bu
LEFT JOIN proddta.f0010 co
    ON co.ccco = bu.mcco
CROSS JOIN params p
WHERE (p.company IS NULL OR bu.mcco = LPAD(p.company, 5, '0'))
  AND (p.name_pattern IS NULL
    OR UPPER(TRIM(bu.mcmcu)) LIKE UPPER(p.name_pattern)
    OR UPPER(bu.mcdl01) LIKE UPPER(p.name_pattern)
    OR UPPER(co.ccname) LIKE UPPER(p.name_pattern))
ORDER BY bu.mcco, TRIM(bu.mcmcu)
FETCH FIRST 50 ROWS ONLY;
