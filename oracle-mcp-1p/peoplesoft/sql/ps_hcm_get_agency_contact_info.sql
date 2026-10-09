-- Tool: ps_hcm_get_agency_contact_info
-- Skill: ps_hcm_plain_language_notice_generator
-- Oracle Bind Variables:
--   :setid (string): Location SetID. Empty = any.
--   :location (string): Location code. Empty = any.
--   :company (string): Company code. Empty = any.
--   :keyword (string): Text to find in the description or city (case-insensitive). Empty = no text filter.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :setid AS setid,
        :location AS location,
        :company AS company,
        :keyword AS keyword
    FROM dual
)
SELECT * FROM (
    SELECT
        'LOCATION' AS entity_type,
        l.setid,
        l.location AS code,
        l.descr AS name,
        l.address1,
        l.address2,
        l.city,
        l.state,
        l.postal,
        l.country,
        l.phone,
        l.extension,
        l.fax,
        l.eff_status
    FROM params p
    JOIN sysadm.ps_location_tbl l
        ON (p.company IS NULL)
       AND (p.setid IS NULL OR l.setid = p.setid)
       AND (p.location IS NULL OR l.location = p.location)
       AND (p.keyword IS NULL OR UPPER(l.descr) LIKE '%' || UPPER(p.keyword) || '%'
            OR UPPER(l.city) LIKE '%' || UPPER(p.keyword) || '%')
       AND l.effdt = (SELECT MAX(l2.effdt) FROM sysadm.ps_location_tbl l2
                       WHERE l2.setid = l.setid AND l2.location = l.location AND l2.effdt <= TRUNC(SYSDATE))
    UNION ALL
    SELECT
        'COMPANY' AS entity_type,
        CAST(NULL AS VARCHAR2(5)) AS setid,
        c.company AS code,
        c.descr AS name,
        c.address1,
        c.address2,
        c.city,
        c.state,
        c.postal,
        c.country,
        CAST(NULL AS VARCHAR2(24)) AS phone,
        CAST(NULL AS VARCHAR2(6)) AS extension,
        CAST(NULL AS VARCHAR2(24)) AS fax,
        c.eff_status
    FROM params p
    JOIN sysadm.ps_company_tbl c
        ON (p.setid IS NULL AND p.location IS NULL)
       AND (p.company IS NULL OR c.company = p.company)
       AND (p.keyword IS NULL OR UPPER(c.descr) LIKE '%' || UPPER(p.keyword) || '%'
            OR UPPER(c.city) LIKE '%' || UPPER(p.keyword) || '%')
       AND c.effdt = (SELECT MAX(c2.effdt) FROM sysadm.ps_company_tbl c2
                       WHERE c2.company = c.company AND c2.effdt <= TRUNC(SYSDATE))
    ORDER BY 1, 3
)
WHERE ROWNUM <= 100;
