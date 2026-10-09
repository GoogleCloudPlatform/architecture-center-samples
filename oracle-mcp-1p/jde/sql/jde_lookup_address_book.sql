-- Tool: jde_lookup_address_book
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :search_name (string): Full or partial name of a supplier, customer, constituent or other party (e.g. 'Acme' or 'Smith').
--   :search_type (string): Optional address book search type (F0101.ABAT1): 'V' supplier, 'C' customer, 'E' employee, or another agency-defined code.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_name AS search_name,
        :search_type AS search_type
    FROM dual
)
SELECT
    ab.aban8 AS an8,
    TRIM(ab.abalph) AS party_name,
    TRIM(ab.abat1) AS search_type,
    TRIM(ab.abalky) AS long_address_number,
    TRIM(ab.abduns) AS duns_number,
    TRIM(al.alcty1) AS city,
    TRIM(al.aladds) AS state,
    TRIM(al.aladdz) AS postal_code
FROM proddta.f0101 ab
LEFT JOIN proddta.f0116 al
    ON al.alan8 = ab.aban8
   AND al.aleftb = (SELECT MAX(x.aleftb) FROM proddta.f0116 x WHERE x.alan8 = ab.aban8)
CROSS JOIN params p
WHERE UPPER(ab.abalph) LIKE UPPER('%' || p.search_name || '%')
  AND (p.search_type IS NULL OR ab.abat1 = RPAD(UPPER(p.search_type), 3))
ORDER BY ab.abalph
FETCH FIRST 25 ROWS ONLY;
