-- Checks the JDE MCP attachment package. Run as the Toolbox user. Read-only.
-- Edit jde_install_config.sql first (the data schema name is used below).
@@jde_install_config.sql
SET VERIFY OFF
SET LINESIZE 220 PAGESIZE 100
COLUMN object_name FORMAT A12
COLUMN text_key FORMAT A24 TRUNCATED
COLUMN text_start FORMAT A60 TRUNCATED
SELECT TRIM(m.gdobnm) AS object_name, TRIM(m.gdtxky) AS text_key, m.gdmoseqn AS seq,
       jde_ai.xx_ai_attachment_pkg.get_status(m.gdobnm, m.gdtxky, m.gdmoseqn)      AS status,
       jde_ai.xx_ai_attachment_pkg.get_encoding(m.gdobnm, m.gdtxky, m.gdmoseqn)    AS encoding,
       jde_ai.xx_ai_attachment_pkg.get_bytes(m.gdobnm, m.gdtxky, m.gdmoseqn)       AS bytes,
       jde_ai.xx_ai_attachment_pkg.get_text_status(m.gdobnm, m.gdtxky, m.gdmoseqn) AS text_status,
       REPLACE(jde_ai.xx_ai_attachment_pkg.get_text_chunk(m.gdobnm, m.gdtxky, m.gdmoseqn, 1, 60), CHR(10), ' ') AS text_start
  FROM (SELECT gdobnm, gdtxky, gdmoseqn FROM &&jde_data_schema..f00165 WHERE gdgtmotype = 0 FETCH FIRST 10 ROWS ONLY) m;
-- Expect OK and readable text for text media objects; file, image and link objects show NO_CONTENT.
