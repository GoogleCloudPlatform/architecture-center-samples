-- Checks the PeopleSoft MCP attachment package. Run as the Toolbox user (SYSADM_AI).
-- Read-only: lists up to 10 stored attachments, their size, text status and the start of their text.
SET LINESIZE 200 PAGESIZE 100
COLUMN attachsysfilename FORMAT A48 TRUNCATED
COLUMN text_start FORMAT A60 TRUNCATED
SELECT f.attachsysfilename,
       sysadm.xx_ai_attachment_pkg.get_status(f.attachsysfilename)      AS status,
       sysadm.xx_ai_attachment_pkg.get_bytes(f.attachsysfilename)       AS bytes,
       sysadm.xx_ai_attachment_pkg.get_text_status(f.attachsysfilename) AS text_status,
       REPLACE(sysadm.xx_ai_attachment_pkg.get_text_chunk(f.attachsysfilename, 1, 60), CHR(10), ' ') AS text_start
  FROM (SELECT DISTINCT attachsysfilename FROM sysadm.ps_hr_att_files FETCH FIRST 10 ROWS ONLY) f;
-- Expect OK and readable text for most rows; NO_TEXT is normal for scanned PDFs. Base64 of the first file:
SELECT sysadm.xx_ai_attachment_pkg.get_base64_chunk(attachsysfilename, 1, 30) AS first_30_bytes_base64
  FROM (SELECT attachsysfilename FROM sysadm.ps_hr_att_files FETCH FIRST 1 ROWS ONLY);
