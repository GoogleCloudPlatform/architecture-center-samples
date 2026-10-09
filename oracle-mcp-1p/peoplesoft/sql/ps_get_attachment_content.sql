-- Tool: ps_get_attachment_content
-- Skill: plain_language_notice_generator
-- Oracle Bind Variables:
--   :attach_sys_filename (string): System attachment filename key (ATTACHSYSFILENAME).
--   :attach_user_filename (string): User-facing display filename.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT
        :attach_sys_filename AS attach_sys_filename,
        :attach_user_filename AS attach_user_filename
    FROM dual
)
SELECT
    att.attachsysfilename,
    att.attachuserfile,
    att.file_size,
    att.file_type AS mime_type,
    fs.file_data
FROM params p
JOIN sysadm.ps_attachment_tbl att
    ON (att.attachsysfilename = p.attach_sys_filename
     OR (p.attach_user_filename IS NOT NULL AND att.attachuserfile = p.attach_user_filename))
JOIN sysadm.psfile_attdet det
    ON att.attachsysfilename = det.attachsysfilename
LEFT JOIN sysadm.ps_file_storage fs
    ON att.attachsysfilename = fs.attachsysfilename
FETCH FIRST 1 ROWS ONLY;
