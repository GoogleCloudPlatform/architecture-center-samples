-- Tool: ps_verify_constituent_data
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :first_name (string): First name of the constituent.
--   :last_name (string): Last name of the constituent.
--   :emplid (string): Constituent EMPLID if available.
--   :nid (string): National ID / SSN hash or last 4 digits for identity matching.
--   :postal (string): Residential postal/ZIP code.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :first_name AS first_name,
        :last_name AS last_name,
        :emplid AS emplid,
        :nid AS nid,
        :postal AS postal
    FROM dual
)
SELECT
    pers.emplid,
    nm.first_name,
    nm.last_name,
    nm.name_display,
    addr.address1,
    addr.city,
    addr.state,
    addr.postal,
    CASE
        WHEN UPPER(nm.first_name) = UPPER(p.first_name) AND UPPER(nm.last_name) = UPPER(p.last_name) THEN 100
        WHEN UPPER(nm.last_name) = UPPER(p.last_name) THEN 75
        ELSE 50
    END AS name_match_confidence,
    CASE
        WHEN p.nid IS NOT NULL AND nid.national_id LIKE '%' || p.nid THEN 'VERIFIED_MATCH'
        WHEN p.nid IS NOT NULL THEN 'NO_MATCH'
        ELSE 'NOT_CHECKED'
    END AS nid_match_status
FROM params p
JOIN sysadm.ps_personal_data pers
    ON (p.emplid IS NULL OR pers.emplid = p.emplid)
JOIN sysadm.ps_names nm
    ON pers.emplid = nm.emplid
   AND nm.name_type = 'PRI'
   AND (p.first_name IS NULL OR UPPER(nm.first_name) = UPPER(p.first_name))
   AND (p.last_name IS NULL OR UPPER(nm.last_name) = UPPER(p.last_name))
LEFT JOIN sysadm.ps_pers_nid nid
    ON pers.emplid = nid.emplid
   AND nid.primary_nid = 'Y'
LEFT JOIN sysadm.ps_addresses addr
    ON pers.emplid = addr.emplid
   AND addr.address_type = 'HOME'
   AND (p.postal IS NULL OR addr.postal = p.postal)
FETCH FIRST 10 ROWS ONLY;
