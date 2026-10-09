-- Tool: jde_get_media_object_attachment
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :object_name (string): Media object name (F00165.GDOBNM), e.g. 'GT03B11'. Use jde_list_media_object_types to discover valid names and key formats.
--   :text_key (string): Parent record key (F00165.GDTXKY) or one or more consecutive key parts, e.g. a document number such as '12345'.
--   :sequence (string): Optional media object sequence number (F00165.GDMOSEQN); leave empty to return every attachment on the record.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :object_name AS object_name,
        :text_key AS text_key,
        :sequence AS sequence
    FROM dual
)
-- GDTXKY holds the parent record's key values separated by '|'. The key match below
-- accepts the full key or any run of whole key parts, so '12345' matches '00001|RI|12345|001'.
SELECT
    TRIM(mo.gdobnm) AS object_name,
    mo.gdtxky AS text_key,
    mo.gdmoseqn AS sequence,
    mo.gdgtmotype AS media_object_type,
    CASE WHEN mo.gdgtmotype = 0 THEN 'TEXT' ELSE 'FILE_OR_LINK' END AS content_kind,
    TRIM(mo.gdgtitnm) AS item_name,
    TRIM(mo.gdgtfilenm) AS file_name_or_url,
    TRIM(mo.gdqunam) AS media_object_queue,
    TRIM(cat.gtmodoctp) AS document_type,
    TRIM(cat.gtmodl01) AS document_description,
    TRIM(cat.gtmostatus) AS document_status,
    TRIM(mo.gduser) AS updated_by,
    CASE WHEN mo.gdupmj > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(mo.gdupmj + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END AS updated_date,
    mo.gdtxft AS content_blob
FROM params p
JOIN proddta.f00165 mo
    ON mo.gdobnm = RPAD(UPPER(p.object_name), 10)
   AND (mo.gdtxky = p.text_key OR '|' || mo.gdtxky || '|' LIKE '%|' || p.text_key || '|%')
   AND (p.sequence IS NULL OR mo.gdmoseqn = TO_NUMBER(p.sequence))
LEFT JOIN proddta.f00166 cat
    ON cat.gtobnm = mo.gdobnm
   AND cat.gttxky = mo.gdtxky
   AND cat.gtmoseqn = mo.gdmoseqn
ORDER BY mo.gdtxky, mo.gdmoseqn
FETCH FIRST 20 ROWS ONLY;
