-- Tool: ps_lookup_constituents
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :search_name (string): Full or partial constituent or employee name (e.g. 'Smith' or 'Jane').
--   :postal_code (string): Optional 5-digit postal code or ZIP code.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_name AS search_name,
        :postal_code AS postal_code
    FROM dual
)
SELECT
    nm.emplid,
    nm.name_display,
    TO_CHAR(pd.birthdate, 'YYYY-MM-DD') AS birthdate,
    addr.city,
    addr.state,
    addr.postal
FROM sysadm.ps_names nm
JOIN sysadm.ps_personal_data pd ON nm.emplid = pd.emplid
LEFT JOIN sysadm.ps_addresses addr ON nm.emplid = addr.emplid AND addr.address_type = 'HOME',
params p
WHERE nm.name_type = 'PRI'
  AND (UPPER(nm.name_display) LIKE UPPER('%' || p.search_name || '%'))
  AND (p.postal_code IS NULL OR addr.postal LIKE p.postal_code || '%')
ORDER BY nm.name_display
FETCH FIRST 25 ROWS ONLY;
