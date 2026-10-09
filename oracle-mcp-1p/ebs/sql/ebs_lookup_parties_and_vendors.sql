-- Tool: ebs_lookup_parties_and_vendors
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :search_name (string): Partial supplier name or supplier number (e.g. 'Vision', 'Office' or '1003'). Empty string = any.
--   :org_id (string): Operating unit ID; returns only suppliers with a site in that operating unit. Empty string = any.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :search_name AS search_name,
        :org_id AS org_id
    FROM dual
)
SELECT
    vend.vendor_id,
    vend.segment1 AS vendor_number,
    vend.vendor_name,
    vend.party_id,
    hp.party_name,
    hp.party_number,
    hp.party_type
FROM apps.ap_suppliers vend
JOIN apps.hz_parties hp ON vend.party_id = hp.party_id, params p
WHERE (p.search_name IS NULL
    OR UPPER(vend.vendor_name) LIKE UPPER('%' || p.search_name || '%')
    OR UPPER(hp.party_name) LIKE UPPER('%' || p.search_name || '%')
    OR vend.segment1 = p.search_name)
  AND (p.org_id IS NULL OR EXISTS (
        SELECT 1 FROM apps.ap_supplier_sites_all ss
        WHERE ss.vendor_id = vend.vendor_id AND ss.org_id = TO_NUMBER(p.org_id)))
ORDER BY vend.vendor_name
FETCH FIRST 25 ROWS ONLY;
