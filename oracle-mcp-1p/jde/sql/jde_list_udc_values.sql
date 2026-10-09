-- Tool: jde_list_udc_values
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :product_code (string): UDC product code (F0005.DRSY), e.g. '00' for foundation, '03B' for A/R, '43' for procurement.
--   :udc_type (string): UDC type (F0005.DRRT), e.g. 'DT' (document types), 'PS' (pay status), 'DE' (deduction reasons).
--   :keyword (string): Optional keyword to filter codes or descriptions.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :product_code AS product_code,
        :udc_type AS udc_type,
        :keyword AS keyword
    FROM dual
)
SELECT
    TRIM(dr.drsy) AS product_code,
    TRIM(dr.drrt) AS udc_type,
    TRIM(dt.dtdl01) AS udc_type_description,
    TRIM(dr.drky) AS code,
    TRIM(dr.drdl01) AS description,
    TRIM(dr.drdl02) AS description_2,
    TRIM(dr.drsphd) AS special_handling_code
FROM prodctl.f0005 dr
LEFT JOIN prodctl.f0004 dt
    ON dt.dtsy = dr.drsy
   AND dt.dtrt = dr.drrt
CROSS JOIN params p
WHERE dr.drsy = RPAD(UPPER(p.product_code), 4)
  AND dr.drrt = RPAD(UPPER(p.udc_type), 2)
  AND (p.keyword IS NULL
    OR UPPER(TRIM(dr.drky)) LIKE UPPER('%' || p.keyword || '%')
    OR UPPER(dr.drdl01) LIKE UPPER('%' || p.keyword || '%'))
ORDER BY TRIM(dr.drky)
FETCH FIRST 50 ROWS ONLY;
