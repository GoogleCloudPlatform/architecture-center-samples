-- Removes the JDE MCP staging package (and with it the Toolbox user's EXECUTE grant). Run as a DBA or as JDE_AI.
-- Rows already staged are not touched. The INSERT grants of jde_ai_staging_grants.sql stay until you revoke them
-- (REVOKE INSERT, SELECT ON <schema>.<table> FROM jde_ai).
DROP PACKAGE jde_ai.xx_ai_staging_pkg;
