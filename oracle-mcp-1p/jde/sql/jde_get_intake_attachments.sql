-- Tool: jde_get_intake_attachments
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :applicant_an8 (string): Address number of the applicant or constituent who submitted the proof documents (F0101.ABAN8).
--   :object_name (string): Optional media object name of the intake record (F00165.GDOBNM), e.g. the address book media object. Use jde_list_media_object_types to discover it.
--   :document_type (string): Optional document category (F00166.GTMODOCTP), e.g. 'PAYSTB', 'W2' or 'UTIL' as configured by the agency (up to 6 characters).
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :applicant_an8 AS applicant_an8,
        :object_name AS object_name,
        :document_type AS document_type
    FROM dual
)
-- An attachment belongs to the applicant when its category record carries the
-- applicant's address number (F00166.GTAN8), or, when object_name is given, when the
-- applicant's address number is one of the parent record's key parts.
SELECT
    TO_NUMBER(p.applicant_an8) AS applicant_an8,
    TRIM(ab.abalph) AS applicant_name,
    TRIM(mo.gdobnm) AS object_name,
    mo.gdtxky AS intake_record_key,
    mo.gdmoseqn AS sequence,
    TRIM(cat.gtmodoctp) AS document_category,
    TRIM(cat.gtmodl01) AS document_description,
    TRIM(cat.gtmostatus) AS verification_status,
    CASE WHEN mo.gdgtmotype = 0 THEN 'TEXT' ELSE 'FILE_OR_LINK' END AS content_kind,
    TRIM(mo.gdgtitnm) AS item_name,
    TRIM(mo.gdgtfilenm) AS file_name_or_url,
    TRIM(mo.gdqunam) AS media_object_queue,
    CASE WHEN mo.gdupmj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(mo.gdupmj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS uploaded_date,
    mo.gdtxft AS content_blob
FROM params p
JOIN proddta.f00165 mo
    ON (p.object_name IS NULL OR mo.gdobnm = RPAD(UPPER(p.object_name), 10))
LEFT JOIN proddta.f00166 cat
    ON cat.gtobnm = mo.gdobnm
   AND cat.gttxky = mo.gdtxky
   AND cat.gtmoseqn = mo.gdmoseqn
LEFT JOIN proddta.f0101 ab
    ON ab.aban8 = TO_NUMBER(p.applicant_an8)
WHERE (cat.gtan8 = TO_NUMBER(p.applicant_an8)
    OR (p.object_name IS NOT NULL AND '|' || mo.gdtxky || '|' LIKE '%|' || p.applicant_an8 || '|%'))
  AND (p.document_type IS NULL OR TRIM(cat.gtmodoctp) = UPPER(p.document_type))
ORDER BY mo.gdupmj DESC, mo.gdmoseqn
FETCH FIRST 50 ROWS ONLY;
