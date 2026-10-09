-- Tool: ps_list_business_units
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :bu_type (string): Optional business unit family filter: 'FS' for Financials/SCM, 'HR' for HCM, or 'ALL'.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :bu_type AS bu_type FROM dual
)
SELECT * FROM (
    SELECT
        fs.business_unit,
        fs.descr AS unit_description,
        'FSCM' AS bu_family
    FROM sysadm.ps_bus_unit_tbl_fs fs, params p
    WHERE (p.bu_type IS NULL OR UPPER(p.bu_type) IN ('FS', 'ALL'))
    UNION ALL
    SELECT
        hr.business_unit,
        hr.descr AS unit_description,
        'HCM' AS bu_family
    FROM sysadm.ps_bus_unit_tbl_hr hr, params p
    WHERE (p.bu_type IS NULL OR UPPER(p.bu_type) IN ('HR', 'ALL'))
)
ORDER BY business_unit
FETCH FIRST 50 ROWS ONLY;
