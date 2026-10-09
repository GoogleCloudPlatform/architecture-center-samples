-- Tool: ps_hcm_get_attachment_text
-- Skill: ps_hcm_plain_language_notice_generator
-- Oracle Bind Variables:
--   :attach_sys_filename (string): Stored attachment file name (ATTACHSYSFILENAME), as returned by ps_hcm_get_person_documents or ps_hcm_search_policy_documents. Required.
--   :chunk (string): Which 1,000-character piece of the text to return, starting at 1. Empty = 1. Repeat with 2, 3 ... until has_more is N.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :attach_sys_filename AS attach_sys_filename,
        :chunk AS chunk
    FROM dual
),
info AS (
    SELECT
        p.attach_sys_filename,
        GREATEST(NVL(TO_NUMBER(p.chunk), 1), 1) AS chunk_no,
        sysadm.xx_ai_attachment_pkg.get_text_length(p.attach_sys_filename) AS text_characters
    FROM params p
    WHERE p.attach_sys_filename IS NOT NULL
)
SELECT
    i.attach_sys_filename AS attachsysfilename,
    sysadm.xx_ai_attachment_pkg.get_status(i.attach_sys_filename) AS file_status,
    sysadm.xx_ai_attachment_pkg.get_bytes(i.attach_sys_filename) AS file_bytes,
    sysadm.xx_ai_attachment_pkg.get_text_status(i.attach_sys_filename) AS text_status,
    i.text_characters,
    CEIL(i.text_characters / 1000) AS chunk_count,
    i.chunk_no AS chunk,
    CASE WHEN i.chunk_no * 1000 < i.text_characters THEN 'Y' ELSE 'N' END AS has_more,
    sysadm.xx_ai_attachment_pkg.get_text_chunk(i.attach_sys_filename, i.chunk_no, 1000) AS text_chunk
FROM info i;
