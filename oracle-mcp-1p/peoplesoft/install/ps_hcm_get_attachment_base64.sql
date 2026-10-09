-- Tool: ps_hcm_get_attachment_base64
-- Skill: ps_hcm_plain_language_notice_generator
-- Oracle Bind Variables:
--   :attach_sys_filename (string): Stored attachment file name (ATTACHSYSFILENAME). Required.
--   :chunk (string): Which piece of the file to return, starting at 1. Empty = 1. Repeat until has_more is N.
--   :chunk_bytes (string): File bytes per piece, rounded down to a multiple of 3 (default 1500, at most 2800). Use the same value for every call for one file.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :attach_sys_filename AS attach_sys_filename,
        :chunk AS chunk,
        :chunk_bytes AS chunk_bytes
    FROM dual
),
info AS (
    SELECT
        p.attach_sys_filename,
        GREATEST(NVL(TO_NUMBER(p.chunk), 1), 1) AS chunk_no,
        FLOOR(LEAST(GREATEST(NVL(TO_NUMBER(p.chunk_bytes), 1500), 3), 2800) / 3) * 3 AS bytes_per_chunk,
        sysadm.xx_ai_attachment_pkg.get_bytes(p.attach_sys_filename) AS file_bytes
    FROM params p
    WHERE p.attach_sys_filename IS NOT NULL
)
SELECT
    i.attach_sys_filename AS attachsysfilename,
    sysadm.xx_ai_attachment_pkg.get_status(i.attach_sys_filename) AS file_status,
    i.file_bytes,
    i.bytes_per_chunk AS chunk_bytes,
    CEIL(i.file_bytes / i.bytes_per_chunk) AS chunk_count,
    i.chunk_no AS chunk,
    CASE WHEN i.chunk_no * i.bytes_per_chunk < i.file_bytes THEN 'Y' ELSE 'N' END AS has_more,
    sysadm.xx_ai_attachment_pkg.get_base64_chunk(i.attach_sys_filename, i.chunk_no, i.bytes_per_chunk) AS base64_chunk
FROM info i;
