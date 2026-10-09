-- Tool: jde_list_media_object_types
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :keyword (string): Optional keyword to filter media object names (e.g. '03B' for A/R, '0411' for vouchers, '43' for procurement).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :keyword AS keyword FROM dual
)
SELECT
    TRIM(mo.gdobnm) AS object_name,
    COUNT(*) AS attachment_count,
    SUM(CASE WHEN mo.gdgtmotype = 0 THEN 1 ELSE 0 END) AS text_attachment_count,
    MIN(mo.gdtxky) AS sample_text_key,
    CASE WHEN MAX(mo.gdupmj) > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(MAX(mo.gdupmj) + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS last_updated
FROM proddta.f00165 mo
CROSS JOIN params p
WHERE (p.keyword IS NULL OR UPPER(mo.gdobnm) LIKE UPPER('%' || p.keyword || '%'))
GROUP BY mo.gdobnm
ORDER BY COUNT(*) DESC
FETCH FIRST 50 ROWS ONLY;
