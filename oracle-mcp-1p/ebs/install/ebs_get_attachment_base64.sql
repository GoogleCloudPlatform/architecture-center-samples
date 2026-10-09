-- Tool: ebs_get_attachment_base64
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :document_id (string): Document identifier (FND_DOCUMENTS.DOCUMENT_ID) of a file attachment, e.g. from ebs_search_policy_attachments, ebs_get_intake_attachments or ebs_get_vendor_bids. Required.
--   :chunk (string): Which piece of the file to return, starting at 1. Empty = 1. Repeat until has_more is N.
--   :chunk_bytes (string): File bytes per piece, rounded down to a multiple of 3 (default 1500, at most 2800). Use the same value for every call for one file.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :document_id AS document_id,
        :chunk AS chunk,
        :chunk_bytes AS chunk_bytes
    FROM dual
),
-- Post-install version: needs APPS.XX_AI_ATTACHMENT_PKG (ebs/install/README.md).
info AS (
    SELECT
        fd.document_id,
        fd.datatype_id,
        NVL(fl.file_name, fd.file_name) AS file_name,
        fl.file_content_type AS mime_type,
        fl.file_id,
        GREATEST(NVL(TO_NUMBER(p.chunk), 1), 1) AS chunk_no,
        FLOOR(LEAST(GREATEST(NVL(TO_NUMBER(p.chunk_bytes), 1500), 3), 2800) / 3) * 3 AS bytes_per_chunk
    FROM params p
    JOIN apps.fnd_documents fd
        ON fd.document_id = TO_NUMBER(p.document_id)
    LEFT JOIN apps.fnd_lobs fl
        ON fd.datatype_id = 6
       AND fl.file_id = fd.media_id
)
SELECT
    i.document_id,
    i.file_name,
    i.mime_type,
    CASE WHEN i.datatype_id <> 6 THEN 'NOT_A_FILE'
         ELSE apps.xx_ai_attachment_pkg.get_status(i.file_id) END AS file_status,
    apps.xx_ai_attachment_pkg.get_bytes(i.file_id) AS file_bytes,
    i.bytes_per_chunk AS chunk_bytes,
    CEIL(apps.xx_ai_attachment_pkg.get_bytes(i.file_id) / i.bytes_per_chunk) AS chunk_count,
    i.chunk_no AS chunk,
    CASE WHEN i.chunk_no * i.bytes_per_chunk < apps.xx_ai_attachment_pkg.get_bytes(i.file_id) THEN 'Y' ELSE 'N' END AS has_more,
    apps.xx_ai_attachment_pkg.get_base64_chunk(i.file_id, i.chunk_no, i.bytes_per_chunk) AS base64_chunk
FROM info i;
