-- Checks xx_ai_attachment_pkg as the MCP Toolbox user (APPS_AI). Run after the
-- install; it changes nothing. Expect status OK and readable text for most PDF and
-- Word rows; NO_TEXT is normal for scanned (image-only) PDFs.
SET LINESIZE 220
COLUMN mime FORMAT A30
COLUMN status FORMAT A40
COLUMN text_start FORMAT A90
SELECT l.file_id,
       apps.xx_ai_attachment_pkg.get_status(l.file_id) AS file_status,
       apps.xx_ai_attachment_pkg.get_bytes(l.file_id) AS file_bytes,
       SUBSTR(apps.xx_ai_attachment_pkg.get_base64_chunk(l.file_id, 1, 12), 1, 16) AS b64_first_12_bytes,
       SUBSTR(l.file_content_type, 1, 30) AS mime,
       DBMS_LOB.GETLENGTH(l.file_data) AS bytes,
       apps.xx_ai_attachment_pkg.get_text_status(l.file_id) AS status,
       apps.xx_ai_attachment_pkg.get_text_length(l.file_id) AS text_chars,
       SUBSTR(REGEXP_REPLACE(apps.xx_ai_attachment_pkg.get_text_chunk(l.file_id, 1), '\s+', ' '), 1, 90) AS text_start
FROM apps.fnd_lobs l
WHERE l.file_id IN (
    SELECT file_id FROM (
        SELECT file_id, ROW_NUMBER() OVER (PARTITION BY LOWER(file_content_type) ORDER BY file_id DESC) rn
        FROM apps.fnd_lobs
        WHERE LOWER(file_content_type) IN ('application/pdf', 'application/msword',
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
          AND DBMS_LOB.GETLENGTH(file_data) < 5242880
    ) WHERE rn <= 3
)
ORDER BY l.file_id;
