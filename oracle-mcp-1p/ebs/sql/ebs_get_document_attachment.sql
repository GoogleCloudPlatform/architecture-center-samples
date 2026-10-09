-- Tool: ebs_get_document_attachment
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :document_id (string): Document identifier (FND_DOCUMENTS.DOCUMENT_ID).
--   :entity_name (string): Optional entity the document is attached to (e.g. RA_CUSTOMER_TRX_ALL). Empty string = any.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :document_id AS document_id,
        :entity_name AS entity_name
    FROM dual
)
-- A document can be attached to several records; the lowest attached_document_id is
-- returned and attachment_count says how many attachments share the document.
SELECT
    fad.attached_document_id,
    fd.document_id,
    fad.entity_name,
    fad.pk1_value AS entity_pk1,
    COUNT(*) OVER () AS attachment_count,
    cat.user_name AS document_category,
    dtype.user_name AS document_datatype,
    fdt.title AS document_name,
    fdt.description AS document_description,
    NVL(fl.file_name, fd.file_name) AS file_name,
    fd.url,
    fl.file_content_type AS mime_type,
    fl.file_format,
    DBMS_LOB.GETLENGTH(fl.file_data) AS file_size_bytes,
    fl.file_data
FROM params p
JOIN apps.fnd_documents fd
    ON fd.document_id = TO_NUMBER(p.document_id)
JOIN apps.fnd_attached_documents fad
    ON fad.document_id = fd.document_id
   AND (p.entity_name IS NULL OR fad.entity_name = p.entity_name)
LEFT JOIN apps.fnd_documents_tl fdt
    ON fd.document_id = fdt.document_id
   AND fdt.language = USERENV('LANG')
LEFT JOIN apps.fnd_document_categories_tl cat
    ON cat.category_id = fd.category_id
   AND cat.language = USERENV('LANG')
LEFT JOIN apps.fnd_document_datatypes dtype
    ON dtype.datatype_id = fd.datatype_id
   AND dtype.language = USERENV('LANG')
LEFT JOIN apps.fnd_lobs fl
    ON fd.datatype_id = 6
   AND fd.media_id = fl.file_id
ORDER BY fad.attached_document_id
FETCH FIRST 1 ROWS ONLY;
