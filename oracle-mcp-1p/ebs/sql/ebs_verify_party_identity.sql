-- Tool: ebs_verify_party_identity
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :legal_name (string): Legal full name of the person to cross-reference (at least 3 characters when party_id is empty).
--   :tax_id_hash (string): SHA-256 hash (64 hex characters, either case) of the tax ID or SSN exactly as stored in EBS. Empty string = not checked.
--   :postal_code (string): ZIP or postal code to verify against the person's active addresses. Empty string = not checked.
--   :party_id (string): Existing TCA party ID, if known. Empty string = search by name.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :legal_name AS legal_name,
        :tax_id_hash AS tax_id_hash,
        :postal_code AS postal_code,
        :party_id AS party_id
    FROM dual
)
-- One row per person. The address shown is the one matching postal_code if any, else
-- the identifying address; email and phone are the primary active contact points.
SELECT
    hp.party_id,
    hp.party_number,
    hp.party_name,
    hpp.person_first_name,
    hpp.person_last_name,
    hl.address1,
    hl.city,
    hl.state,
    hl.postal_code,
    (SELECT LISTAGG(u.site_use_type, ',') WITHIN GROUP (ORDER BY u.site_use_type)
       FROM apps.hz_party_site_uses u
      WHERE u.party_site_id = hps.party_site_id AND u.status = 'A') AS address_uses,
    (SELECT MAX(cp.email_address) KEEP (DENSE_RANK FIRST ORDER BY cp.primary_flag DESC NULLS LAST)
       FROM apps.hz_contact_points cp
      WHERE cp.owner_table_name = 'HZ_PARTIES' AND cp.owner_table_id = hp.party_id
        AND cp.status = 'A' AND cp.contact_point_type = 'EMAIL') AS email_address,
    (SELECT MAX(TRIM(cp.phone_area_code || ' ' || cp.phone_number)) KEEP (DENSE_RANK FIRST ORDER BY cp.primary_flag DESC NULLS LAST)
       FROM apps.hz_contact_points cp
      WHERE cp.owner_table_name = 'HZ_PARTIES' AND cp.owner_table_id = hp.party_id
        AND cp.status = 'A' AND cp.contact_point_type = 'PHONE') AS phone_number,
    CASE
        WHEN p.legal_name IS NULL THEN NULL
        WHEN UPPER(TRIM(hp.party_name)) = UPPER(TRIM(p.legal_name))
          OR UPPER(hpp.person_first_name || ' ' || hpp.person_last_name) = UPPER(TRIM(p.legal_name))
          OR UPPER(hpp.person_last_name || ', ' || hpp.person_first_name) = UPPER(TRIM(p.legal_name)) THEN 100
        WHEN UPPER(hp.party_name) LIKE UPPER('%' || TRIM(p.legal_name) || '%') THEN 75
        ELSE 0
    END AS name_match_confidence,
    CASE
        WHEN p.tax_id_hash IS NULL THEN 'NOT_CHECKED'
        WHEN hpp.jgzz_fiscal_code IS NULL THEN 'NO_TAX_ID_ON_FILE'
        WHEN RAWTOHEX(STANDARD_HASH(hpp.jgzz_fiscal_code, 'SHA256')) = UPPER(TRIM(p.tax_id_hash)) THEN 'VERIFIED_MATCH'
        ELSE 'NO_MATCH'
    END AS tax_id_hash_verification,
    CASE
        WHEN p.postal_code IS NULL THEN 'NOT_CHECKED'
        WHEN hl.postal_code LIKE TRIM(p.postal_code) || '%' THEN 'VERIFIED_MATCH'
        ELSE 'NO_MATCH'
    END AS postal_code_verification
FROM params p
JOIN apps.hz_parties hp
    ON hp.party_type = 'PERSON'
   AND ((p.party_id IS NOT NULL AND hp.party_id = TO_NUMBER(p.party_id))
     OR (p.party_id IS NULL AND LENGTH(TRIM(p.legal_name)) >= 3
         AND UPPER(hp.party_name) LIKE UPPER('%' || TRIM(p.legal_name) || '%')))
JOIN apps.hz_person_profiles hpp
    ON hp.party_id = hpp.party_id
   AND SYSDATE BETWEEN hpp.effective_start_date AND NVL(hpp.effective_end_date, SYSDATE + 1)
OUTER APPLY (
    SELECT s.party_site_id, s.location_id
    FROM apps.hz_party_sites s
    JOIN apps.hz_locations l
        ON l.location_id = s.location_id
    WHERE s.party_id = hp.party_id
      AND s.status = 'A'
    ORDER BY CASE WHEN p.postal_code IS NOT NULL AND l.postal_code LIKE TRIM(p.postal_code) || '%' THEN 0 ELSE 1 END,
             CASE WHEN s.identifying_address_flag = 'Y' THEN 0 ELSE 1 END,
             s.party_site_id
    FETCH FIRST 1 ROWS ONLY
) hps
LEFT JOIN apps.hz_locations hl
    ON hl.location_id = hps.location_id
ORDER BY name_match_confidence DESC NULLS LAST, hp.party_id
FETCH FIRST 10 ROWS ONLY;
