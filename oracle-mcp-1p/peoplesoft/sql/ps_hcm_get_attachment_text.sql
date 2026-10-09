-- Tool: ps_hcm_get_attachment_text
-- Skill: ps_hcm_plain_language_notice_generator
-- Oracle Bind Variables:
--   :attach_sys_filename (string): Stored attachment file name (ATTACHSYSFILENAME), as returned by ps_hcm_get_person_documents or ps_hcm_search_policy_documents. Required.
--   :source (string): PS_HR_ATT_FILES, PSFILE_ATTDET, or empty to look in both.
--   :chunk_start (string): 1-based byte position to start reading the text from. Empty = 1. Use start + chunk_length for the next chunk while has_more is Y.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :attach_sys_filename AS attach_sys_filename,
        :source AS source,
        :chunk_start AS chunk_start
    FROM dual
)
SELECT * FROM (
    SELECT
        y.src AS source_table,
        y.attachsysfilename,
        y.file_seq,
        y.version AS file_version,
        y.file_size AS file_bytes,
        TO_CHAR(y.lastupddttm, 'YYYY-MM-DD HH24:MI:SS') AS last_updated,
        y.detected_format,
        y.is_text,
        y.start_pos AS chunk_start,
        CASE WHEN y.is_text = 'Y' THEN LEAST(2000, GREATEST(DBMS_LOB.GETLENGTH(y.file_data) - y.start_pos + 1, 0)) END AS chunk_length,
        CASE WHEN y.is_text = 'Y' AND y.start_pos + 2000 <= DBMS_LOB.GETLENGTH(y.file_data) THEN 'Y' ELSE 'N' END AS has_more,
        CASE WHEN y.is_text = 'Y' THEN UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(y.file_data, 2000, y.start_pos)) END AS text_chunk
    FROM (
        SELECT
            z.*,
            CASE
                WHEN z.head_hex LIKE '25504446%' THEN 'PDF'
                WHEN z.head_hex LIKE '504B0304%' THEN 'ZIP/OOXML (docx, xlsx, pptx)'
                WHEN z.head_hex LIKE 'D0CF11E0%' THEN 'OLE (doc, xls, ppt)'
                WHEN z.head_hex LIKE '89504E47%' THEN 'PNG image'
                WHEN z.head_hex LIKE 'FFD8FF%' THEN 'JPEG image'
                WHEN z.head_hex LIKE '47494638%' THEN 'GIF image'
                WHEN INSTR(z.head_txt, CHR(0)) > 0 THEN 'BINARY'
                ELSE 'TEXT'
            END AS detected_format,
            CASE
                WHEN z.head_hex LIKE '25504446%' OR z.head_hex LIKE '504B0304%' OR z.head_hex LIKE 'D0CF11E0%'
                  OR z.head_hex LIKE '89504E47%' OR z.head_hex LIKE 'FFD8FF%' OR z.head_hex LIKE '47494638%'
                  OR INSTR(z.head_txt, CHR(0)) > 0 THEN 'N'
                ELSE 'Y'
            END AS is_text
        FROM (
            SELECT
                u.*,
                GREATEST(NVL(TO_NUMBER(p.chunk_start), 1), 1) AS start_pos,
                RAWTOHEX(DBMS_LOB.SUBSTR(u.file_data, 8, 1)) AS head_hex,
                UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(u.file_data, 512, 1)) AS head_txt
            FROM params p
            JOIN (
                SELECT 'PS_HR_ATT_FILES' AS src, f.* FROM sysadm.ps_hr_att_files f
                UNION ALL
                SELECT 'PSFILE_ATTDET' AS src, d.* FROM sysadm.psfile_attdet d
            ) u
                ON u.attachsysfilename = p.attach_sys_filename
               AND (p.source IS NULL OR u.src = UPPER(p.source))
        ) z
    ) y
    ORDER BY y.src, y.file_seq, y.version
)
WHERE ROWNUM <= 10;
