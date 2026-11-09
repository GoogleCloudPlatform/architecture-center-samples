-- OPTIONAL hardening: make JDE_AI a schema that only owns the MCP packages, and cannot log in or change its own code.
-- Run as a DBA after the packages are installed (xx_ai_security_pkg.sql, xx_ai_attachment_pkg.sql, xx_ai_staging_pkg.sql).
--
-- The packages run with definer's rights, so JDE_AI keeps its OBJECT grants (SELECT on the JDE tables, INSERT on the
-- Z-files, quota for XX_AI_USER_MAP): they are what the packages need and nothing else holds them. What it loses is
-- everything that lets a person or a stolen password change code or data directly: it cannot log in, and it holds no
-- system privilege. The Toolbox user was never JDE_AI (it is the read-only user), and the execute_sql tool cannot run
-- DDL, so this protects against a stolen JDE_AI password and against someone logging in as the owner.
--
-- Afterwards, install or upgrade packages as a DBA (the install scripts set CURRENT_SCHEMA = JDE_AI themselves; the
-- DBA needs CREATE ANY PROCEDURE). To undo: ALTER USER jde_ai ACCOUNT UNLOCK; GRANT CREATE SESSION ... TO jde_ai;
REVOKE CREATE SESSION, CREATE PROCEDURE, CREATE TABLE FROM jde_ai;
ALTER USER jde_ai ACCOUNT LOCK;
