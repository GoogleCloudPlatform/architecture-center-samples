-- Tool: ebs_get_attachment_text
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :document_id (string): Document identifier (FND_DOCUMENTS.DOCUMENT_ID), e.g. from ebs_search_policy_attachments, ebs_get_intake_attachments or ebs_get_vendor_bids.
--   :start_chunk (string): First chunk to return (1-based) for paging through long documents. Empty string = 1.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :document_id AS document_id,
        :start_chunk AS start_chunk
    FROM dual
),
-- Post-install version: needs APPS.XX_AI_ATTACHMENT_PKG (ebs/install/README.md).
-- One row per document with its content kind. Files are decoded with the charset in
-- the MIME type (IANA name), else FND_LOBS.ORACLE_CHARSET. Chunks are 1200 bytes for
-- files (up to 3 bytes per character in AL32UTF8 stays under the 4000-byte SQL limit)
-- and 1000 characters for long text.
doc AS (
    SELECT
        fd.document_id,
        dtype.user_name AS document_datatype,
        fdt.title AS document_title,
        NVL(fl.file_name, fd.file_name) AS file_name,
        fd.url,
        fl.file_content_type AS mime_type,
        fl.file_id,
        fl.file_data,
        st.short_text,
        lt.long_text,
        CASE
            WHEN fd.datatype_id = 1 THEN 'SHORT_TEXT'
            WHEN fd.datatype_id = 2 THEN 'LONG_TEXT'
            WHEN fd.datatype_id = 5 THEN 'WEB_PAGE'
            WHEN fd.datatype_id = 6 AND fl.file_id IS NULL THEN 'FILE_MISSING'
            WHEN fd.datatype_id = 6 AND (LOWER(fl.file_content_type) LIKE 'text/html%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/xhtml%') THEN 'HTML_FILE'
            WHEN fd.datatype_id = 6 AND (LOWER(fl.file_content_type) LIKE 'text/%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/xml%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/json%') THEN 'TEXT_FILE'
            WHEN fd.datatype_id = 6 AND (LOWER(fl.file_content_type) LIKE 'application/pdf%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/msword%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/rtf%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/vnd.ms-%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/vnd.openxmlformats-officedocument%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/vnd.oasis.opendocument%'
                                      OR LOWER(fl.file_content_type) LIKE 'application/octet-stream%') THEN 'FILTERED_FILE'
            WHEN fd.datatype_id = 6 THEN 'BINARY_FILE'
            ELSE 'OTHER'
        END AS content_kind,
        NVL(UTL_I18N.MAP_CHARSET(REGEXP_SUBSTR(fl.file_content_type, 'charset=([^; ]+)', 1, 1, 'i', 1), 0, 1),
            NVL(fl.oracle_charset, 'WE8MSWIN1252')) AS source_charset,
        CASE
            WHEN fd.datatype_id = 1 THEN 1
            WHEN fd.datatype_id = 2 THEN CEIL(NVL(DBMS_LOB.GETLENGTH(lt.long_text), 0) / 1000)
            WHEN fd.datatype_id = 6 AND fl.file_id IS NOT NULL AND NOT (
                     LOWER(fl.file_content_type) LIKE 'text/%' OR LOWER(fl.file_content_type) LIKE 'application/xhtml%'
                  OR LOWER(fl.file_content_type) LIKE 'application/xml%' OR LOWER(fl.file_content_type) LIKE 'application/json%')
                THEN CEIL(apps.xx_ai_attachment_pkg.get_text_length(fl.file_id) / 1000)
            WHEN fd.datatype_id = 6 THEN CEIL(NVL(DBMS_LOB.GETLENGTH(fl.file_data), 0) / 1200)
            ELSE 0
        END AS total_chunks,
        GREATEST(NVL(TO_NUMBER(p.start_chunk), 1), 1) AS first_chunk
    FROM params p
    JOIN apps.fnd_documents fd
        ON fd.document_id = TO_NUMBER(p.document_id)
    LEFT JOIN apps.fnd_documents_tl fdt
        ON fdt.document_id = fd.document_id
       AND fdt.language = USERENV('LANG')
    LEFT JOIN apps.fnd_document_datatypes dtype
        ON dtype.datatype_id = fd.datatype_id
       AND dtype.language = USERENV('LANG')
    LEFT JOIN apps.fnd_lobs fl
        ON fd.datatype_id = 6
       AND fl.file_id = fd.media_id
    LEFT JOIN apps.fnd_documents_short_text st
        ON fd.datatype_id = 1
       AND st.media_id = fd.media_id
    LEFT JOIN apps.fnd_documents_long_text lt
        ON fd.datatype_id = 2
       AND lt.media_id = fd.media_id
),
chunks AS (
    SELECT LEVEL - 1 AS k FROM dual CONNECT BY LEVEL <= 24
),
bounds AS (
    SELECT
        d.document_id,
        d.document_datatype,
        d.document_title,
        d.file_name,
        d.url,
        d.mime_type,
        d.content_kind,
        d.source_charset,
        d.total_chunks,
        d.short_text,
        d.long_text,
        d.file_id,
        d.file_data,
        d.first_chunk + c.k AS chunk_number,
        CASE WHEN d.source_charset IN ('AL32UTF8', 'UTF8') THEN 'Y' ELSE 'N' END AS utf8,
        (d.first_chunk + c.k - 1) * 1200 + 1 AS byte_start,
        (d.first_chunk + c.k) * 1200 + 1 AS byte_next,
        CASE WHEN d.content_kind IN ('TEXT_FILE', 'HTML_FILE')
             THEN DBMS_LOB.SUBSTR(d.file_data, 3, (d.first_chunk + c.k - 1) * 1200 + 1) END AS head_bytes,
        CASE WHEN d.content_kind IN ('TEXT_FILE', 'HTML_FILE')
             THEN DBMS_LOB.SUBSTR(d.file_data, 3, (d.first_chunk + c.k) * 1200 + 1) END AS next_head_bytes
    FROM doc d
    CROSS JOIN chunks c
    WHERE (d.content_kind IN ('SHORT_TEXT', 'LONG_TEXT', 'TEXT_FILE', 'HTML_FILE')
           AND d.first_chunk + c.k <= GREATEST(d.total_chunks, 1))
       OR (d.content_kind = 'FILTERED_FILE' AND d.total_chunks > 0 AND d.first_chunk + c.k <= d.total_chunks)
       OR (d.content_kind = 'FILTERED_FILE' AND d.total_chunks = 0 AND c.k = 0)
       OR (d.content_kind NOT IN ('SHORT_TEXT', 'LONG_TEXT', 'TEXT_FILE', 'HTML_FILE', 'FILTERED_FILE') AND c.k = 0)
),
-- For UTF-8 files each chunk boundary moves past continuation bytes (80 to BF), so a
-- multi-byte character is never split (a split character raises ORA-01890).
aligned AS (
    SELECT
        bnd.*,
        bnd.byte_start + CASE WHEN bnd.utf8 = 'Y' AND bnd.head_bytes IS NOT NULL
                  AND UTL_RAW.SUBSTR(bnd.head_bytes, 1, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN
                CASE WHEN UTL_RAW.LENGTH(bnd.head_bytes) >= 2 AND UTL_RAW.SUBSTR(bnd.head_bytes, 2, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN
                    CASE WHEN UTL_RAW.LENGTH(bnd.head_bytes) >= 3 AND UTL_RAW.SUBSTR(bnd.head_bytes, 3, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN 3 ELSE 2 END
                ELSE 1 END
            ELSE 0 END AS char_start,
        bnd.byte_next + CASE WHEN bnd.utf8 = 'Y' AND bnd.next_head_bytes IS NOT NULL
                  AND UTL_RAW.SUBSTR(bnd.next_head_bytes, 1, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN
                CASE WHEN UTL_RAW.LENGTH(bnd.next_head_bytes) >= 2 AND UTL_RAW.SUBSTR(bnd.next_head_bytes, 2, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN
                    CASE WHEN UTL_RAW.LENGTH(bnd.next_head_bytes) >= 3 AND UTL_RAW.SUBSTR(bnd.next_head_bytes, 3, 1) BETWEEN HEXTORAW('80') AND HEXTORAW('BF') THEN 3 ELSE 2 END
                ELSE 1 END
            ELSE 0 END AS char_next
    FROM bounds bnd
),
raw_text AS (
    SELECT
        a.document_id,
        a.document_datatype,
        a.document_title,
        a.file_name,
        a.url,
        a.mime_type,
        a.content_kind,
        a.source_charset,
        a.total_chunks,
        a.chunk_number,
        CASE WHEN a.content_kind = 'FILTERED_FILE' AND a.total_chunks = 0
             THEN apps.xx_ai_attachment_pkg.get_text_status(a.file_id) END AS filter_status,
        CASE
            WHEN a.content_kind = 'SHORT_TEXT' THEN a.short_text
            WHEN a.content_kind = 'LONG_TEXT' THEN DBMS_LOB.SUBSTR(a.long_text, 1000, (a.chunk_number - 1) * 1000 + 1)
            WHEN a.content_kind = 'FILTERED_FILE' AND a.total_chunks > 0
                THEN apps.xx_ai_attachment_pkg.get_text_chunk(a.file_id, a.chunk_number)
            WHEN a.content_kind IN ('TEXT_FILE', 'HTML_FILE') AND a.char_next > a.char_start
                THEN UTL_I18N.RAW_TO_CHAR(DBMS_LOB.SUBSTR(a.file_data, a.char_next - a.char_start, a.char_start), a.source_charset)
        END AS chunk_text
    FROM aligned a
)
-- HTML chunks have tags removed (including a tag cut off at either end of the chunk)
-- and common entities decoded.
SELECT
    document_id,
    document_datatype,
    document_title,
    file_name,
    url,
    mime_type,
    content_kind,
    CASE WHEN content_kind IN ('TEXT_FILE', 'HTML_FILE') THEN source_charset END AS source_charset,
    CASE WHEN content_kind = 'BINARY_FILE' THEN 0 ELSE total_chunks END AS total_chunks,
    CASE WHEN content_kind = 'BINARY_FILE' OR (content_kind = 'FILTERED_FILE' AND total_chunks = 0) THEN NULL ELSE chunk_number END AS chunk_number,
    CASE WHEN content_kind IN ('SHORT_TEXT', 'LONG_TEXT', 'TEXT_FILE', 'HTML_FILE')
           OR (content_kind = 'FILTERED_FILE' AND total_chunks > 0)
         THEN CASE WHEN chunk_number < total_chunks THEN 'Y' ELSE 'N' END END AS more_chunks_follow,
    CASE
        WHEN content_kind = 'HTML_FILE' THEN
            REGEXP_REPLACE(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(chunk_text, '^[^<>]*>', ' '), '<[^>]*$', ' '), '<[^>]*>', ' '),
                    '&nbsp;', ' '), '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&#39;', ''''), '&amp;', '&'),
                '\s+', ' ')
        ELSE chunk_text
    END AS text,
    CASE content_kind
        WHEN 'BINARY_FILE' THEN 'Binary file (' || NVL(mime_type, 'unknown type') || ') with no text to extract, such as an image. Fetch the file with ebs_get_document_attachment for an external step such as OCR.'
        WHEN 'FILTERED_FILE' THEN
            CASE
                WHEN filter_status IS NULL THEN 'Text extracted from the ' || NVL(mime_type, 'binary') || ' file by Oracle Text; page layout and tables are flattened to plain text.'
                WHEN filter_status = 'NO_TEXT' THEN 'No text found in the file; it is probably a scanned image and needs OCR.'
                WHEN filter_status = 'TOO_LARGE' THEN 'The file is larger than the 50 MB extraction limit.'
                ELSE 'Text could not be extracted: ' || filter_status
            END
        WHEN 'WEB_PAGE' THEN 'Web page attachment: the content is at the URL, not in EBS.'
        WHEN 'FILE_MISSING' THEN 'The file record is missing from FND_LOBS.'
        WHEN 'OTHER' THEN 'Attachment type ' || NVL(document_datatype, 'unknown') || ' has no text content in EBS.'
    END AS extraction_note
FROM raw_text
ORDER BY chunk_number;
