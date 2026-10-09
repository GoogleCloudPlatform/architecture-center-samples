-- Tool: ebs_get_intake_attachments
-- Skill: document_intake_cleanup_and_validation
-- Oracle Bind Variables:
--   :intake_queue_id (string): Primary key value of the intake record the documents are attached to (FND_ATTACHED_DOCUMENTS.PK1_VALUE).
--   :applicant_id (string): Optional second key value, e.g. the applicant or party ID (PK2_VALUE). Empty string = any.
--   :entity_name (string): Required. Attachment entity of the intake record (e.g. the agency's intake or party entity); use ebs_list_attachment_entities to find it. Without it nothing is returned.
--   :include_content (string): 'Y' returns the file data (large); anything else returns metadata only.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :intake_queue_id AS intake_queue_id,
        :applicant_id AS applicant_id,
        :entity_name AS entity_name,
        :include_content AS include_content
    FROM dual
)
-- The entity filter is mandatory: the same key value is used by unrelated entities
-- (for example '1' appears on five, including HR performance plans).
SELECT
    fad.attached_document_id,
    fd.document_id,
    fad.entity_name,
    fad.pk1_value AS intake_queue_id,
    fad.pk2_value AS applicant_id,
    fad.seq_num AS attachment_sequence,
    cat.user_name AS document_category,
    dtype.user_name AS document_datatype,
    fdt.title AS document_title,
    fdt.description AS document_notes,
    NVL(fl.file_name, fd.file_name) AS file_name,
    fl.file_content_type AS mime_type,
    DBMS_LOB.GETLENGTH(fl.file_data) AS file_size_bytes,
    TO_CHAR(NVL(fl.upload_date, fad.creation_date), 'YYYY-MM-DD') AS upload_date,
    fu.user_name AS uploaded_by,
    CASE WHEN UPPER(p.include_content) = 'Y' THEN fl.file_data END AS file_data
FROM params p
JOIN apps.fnd_attached_documents fad
    ON fad.entity_name = p.entity_name
   AND fad.pk1_value = p.intake_queue_id
   AND (p.applicant_id IS NULL OR fad.pk2_value = p.applicant_id)
JOIN apps.fnd_documents fd
    ON fad.document_id = fd.document_id
LEFT JOIN apps.fnd_documents_tl fdt
    ON fd.document_id = fdt.document_id
   AND fdt.language = USERENV('LANG')
LEFT JOIN apps.fnd_document_categories_tl cat
    ON cat.category_id = NVL(fad.category_id, fd.category_id)
   AND cat.language = USERENV('LANG')
LEFT JOIN apps.fnd_document_datatypes dtype
    ON dtype.datatype_id = fd.datatype_id
   AND dtype.language = USERENV('LANG')
LEFT JOIN apps.fnd_lobs fl
    ON fd.datatype_id = 6
   AND fd.media_id = fl.file_id
LEFT JOIN apps.fnd_user fu
    ON fu.user_id = fad.created_by
ORDER BY fad.seq_num, fad.attached_document_id
FETCH FIRST 50 ROWS ONLY;
