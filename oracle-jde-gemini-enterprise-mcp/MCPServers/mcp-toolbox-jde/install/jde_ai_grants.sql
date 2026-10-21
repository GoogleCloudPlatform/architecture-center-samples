-- One-off grants so that JDE_AI can own the MCP packages. Run as a DBA (SYS or SYSTEM) before
-- xx_ai_security_pkg.sql and xx_ai_attachment_pkg.sql. Edit jde_install_config.sql first.
-- JDE_AI itself must exist (CREATE USER jde_ai ...); it needs no other access.
@@jde_install_config.sql
GRANT CREATE SESSION, CREATE PROCEDURE, CREATE TABLE TO jde_ai;   -- CREATE TABLE: only for XX_AI_USER_MAP
ALTER USER jde_ai QUOTA 1M ON &&jde_ai_tablespace;
-- Read access, needed directly (not through a role) because the packages run with definer's rights:
GRANT SELECT ON &&jde_data_schema..f00165 TO jde_ai;   -- media objects (attachments)
GRANT SELECT ON &&jde_data_schema..f01151 TO jde_ai;   -- e-mail addresses
GRANT SELECT ON &&jde_sys_schema..f0092   TO jde_ai;   -- JDE users
GRANT SELECT ON &&jde_sys_schema..f00926  TO jde_ai;   -- user profile e-mail (AUEMLA)
-- Oracle Text, for turning PDF, Word and similar files into text:
GRANT EXECUTE ON ctxsys.ctx_ddl TO jde_ai;
GRANT EXECUTE ON ctxsys.ctx_doc TO jde_ai;
