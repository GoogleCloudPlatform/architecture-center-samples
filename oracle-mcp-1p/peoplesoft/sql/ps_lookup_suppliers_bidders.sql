-- Tool: ps_lookup_suppliers_bidders
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :vendor_name (string): Partial supplier or bidder company name.
--   :setid (string): Optional SetID filter.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :vendor_name AS vendor_name,
        :setid AS setid
    FROM dual
)
SELECT * FROM (
    SELECT
        'SUPPLIER' AS entity_type,
        v.setid,
        v.vendor_id AS id,
        v.name1 AS entity_name
    FROM sysadm.ps_vendor v, params p
    WHERE (p.setid IS NULL OR v.setid = p.setid)
      AND UPPER(v.name1) LIKE UPPER('%' || p.vendor_name || '%')
    UNION ALL
    SELECT
        'BIDDER' AS entity_type,
        'BIDDER' AS setid,
        b.bidder_id AS id,
        b.name1 AS entity_name
    FROM sysadm.ps_bidder_hdr b, params p
    WHERE UPPER(b.name1) LIKE UPPER('%' || p.vendor_name || '%')
)
ORDER BY entity_name
FETCH FIRST 25 ROWS ONLY;
