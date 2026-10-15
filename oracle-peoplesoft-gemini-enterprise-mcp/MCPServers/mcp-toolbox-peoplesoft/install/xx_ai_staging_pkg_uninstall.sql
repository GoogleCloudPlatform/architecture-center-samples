-- Removes the PeopleSoft MCP staging package (and with it the Toolbox user's EXECUTE grant). Run as a DBA or as SYSADM.
-- Rows already staged are not touched.
DROP PACKAGE sysadm.xx_ai_staging_pkg;
