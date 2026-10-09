-- Tool: ebs_search_policy_attachments
-- Skill: policy_and_statute_assistant
-- Oracle Bind Variables:
--   :keyword (string): Search keyword or policy topic, matched against title, description and file name. Empty string = any.
--   :policy_category (string): Document category name or part of it (e.g. 'Standard Operating Procedures'), matched against the attachment category. Empty string = any.
--   :entity_name (string): Optional entity the documents are attached to (use ebs_list_attachment_entities). Empty string = any.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :keyword AS keyword,
        :policy_category AS policy_category,
        :entity_name AS entity_name
    FROM dual
)
-- One row per document (a document can be attached to many records; attachment_count
-- says how many). created_date is when the document was added to EBS; effective_from
-- and effective_to are its active dates and are empty when not maintained.
SELECT
    attached_document_id, document_id, entity_name, attachment_count, document_category,
    document_datatype, policy_title, policy_summary, file_name, url, mime_type,
    file_size_bytes, created_date, last_updated_date, effective_from, effective_to
FROM (
SELECT
    ROW_NUMBER() OVER (PARTITION BY fd.document_id ORDER BY fad.attached_document_id) AS rn,
    COUNT(*) OVER (PARTITION BY fd.document_id) AS attachment_count,
    fd.last_update_date AS sort_date,
    fad.attached_document_id,
    fd.document_id,
    fad.entity_name,
    cat.user_name AS document_category,
    dtype.user_name AS document_datatype,
    fdt.title AS policy_title,
    fdt.description AS policy_summary,
    NVL(fl.file_name, fd.file_name) AS file_name,
    fd.url,
    fl.file_content_type AS mime_type,
    DBMS_LOB.GETLENGTH(fl.file_data) AS file_size_bytes,
    TO_CHAR(fd.creation_date, 'YYYY-MM-DD') AS created_date,
    TO_CHAR(fd.last_update_date, 'YYYY-MM-DD') AS last_updated_date,
    TO_CHAR(fd.start_date_active, 'YYYY-MM-DD') AS effective_from,
    TO_CHAR(fd.end_date_active, 'YYYY-MM-DD') AS effective_to
FROM params p
JOIN apps.fnd_attached_documents fad
    ON (p.entity_name IS NULL OR fad.entity_name = p.entity_name)
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
WHERE (p.policy_category IS NULL OR UPPER(cat.user_name) LIKE UPPER('%' || p.policy_category || '%'))
  AND (p.keyword IS NULL
    OR UPPER(fdt.title) LIKE UPPER('%' || p.keyword || '%')
    OR UPPER(fdt.description) LIKE UPPER('%' || p.keyword || '%')
    OR UPPER(NVL(fl.file_name, fd.file_name)) LIKE UPPER('%' || p.keyword || '%'))
)
WHERE rn = 1
ORDER BY sort_date DESC, document_id DESC
FETCH FIRST 20 ROWS ONLY;
