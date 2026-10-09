-- Tool: jde_verify_address_book_identity
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :legal_name (string): Legal full name of the citizen or party to cross-reference against the JDE Address Book.
--   :tax_id_hash (string): Hex SHA-256 hash of the tax ID or SSN exactly as stored in JDE (F0101.ABTAX), for deterministic verification without sending the raw value.
--   :postal_code (string): Residential ZIP or postal code to verify against the current address.
--   :an8 (string): Existing JDE address number if already known.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :legal_name AS legal_name,
        :tax_id_hash AS tax_id_hash,
        :postal_code AS postal_code,
        :an8 AS an8
    FROM dual
)
SELECT
    ab.aban8 AS an8,
    TRIM(ab.abalph) AS party_name,
    TRIM(ab.abat1) AS search_type,
    TRIM(ww.wwgnnm) AS first_name,
    TRIM(ww.wwsrnm) AS last_name,
    CASE WHEN ww.wwdyr > 0 THEN TO_CHAR(ww.wwdyr) || '-' || LPAD(TO_CHAR(ww.wwdmon), 2, '0') || '-' || LPAD(TO_CHAR(ww.wwddate), 2, '0') END AS date_of_birth,
    TRIM(al.aladd1) AS address1,
    TRIM(al.alcty1) AS city,
    TRIM(al.aladds) AS state,
    TRIM(al.aladdz) AS postal_code,
    (SELECT MIN(TRIM(ea.eaemal)) FROM proddta.f01151 ea WHERE ea.eaan8 = ab.aban8 AND ea.eaidln = 0) AS email_address,
    (SELECT MIN(TRIM(ph.wpar1) || ' ' || TRIM(ph.wpph1)) FROM proddta.f0115 ph WHERE ph.wpan8 = ab.aban8 AND ph.wpidln = 0) AS phone_number,
    CASE
        WHEN UPPER(TRIM(ab.abalph)) = UPPER(TRIM(p.legal_name)) THEN 100
        WHEN UPPER(TRIM(ww.wwgnnm) || ' ' || TRIM(ww.wwsrnm)) = UPPER(TRIM(p.legal_name)) THEN 100
        WHEN UPPER(ab.abalph) LIKE UPPER('%' || p.legal_name || '%') THEN 75
        ELSE 50
    END AS name_match_confidence,
    CASE
        WHEN p.tax_id_hash IS NOT NULL AND RAWTOHEX(STANDARD_HASH(TO_CHAR(TRIM(ab.abtax)), 'SHA256')) = UPPER(p.tax_id_hash) THEN 'VERIFIED_MATCH'
        WHEN p.tax_id_hash IS NOT NULL THEN 'NO_MATCH'
        ELSE 'NOT_CHECKED'
    END AS tax_id_hash_verification,
    CASE
        WHEN p.postal_code IS NULL THEN 'NOT_CHECKED'
        WHEN TRIM(al.aladdz) LIKE p.postal_code || '%' THEN 'VERIFIED_MATCH'
        ELSE 'NO_MATCH'
    END AS postal_code_verification
FROM params p
JOIN proddta.f0101 ab
    ON (p.an8 IS NOT NULL AND ab.aban8 = TO_NUMBER(p.an8))
    OR (p.an8 IS NULL AND p.legal_name IS NOT NULL AND UPPER(ab.abalph) LIKE UPPER('%' || p.legal_name || '%'))
LEFT JOIN proddta.f0111 ww
    ON ww.wwan8 = ab.aban8
   AND ww.wwidln = 0
LEFT JOIN proddta.f0116 al
    ON al.alan8 = ab.aban8
   AND al.aleftb = (SELECT MAX(x.aleftb) FROM proddta.f0116 x WHERE x.alan8 = ab.aban8)
ORDER BY name_match_confidence DESC, ab.aban8
FETCH FIRST 10 ROWS ONLY;
