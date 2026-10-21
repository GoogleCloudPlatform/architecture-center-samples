-- Takes the staging package away from the MCP Toolbox user again (disabling the jde_stage_* tools). Run as a DBA.
@@jde_install_config.sql
REVOKE EXECUTE ON jde_ai.xx_ai_staging_pkg FROM &&jde_toolbox_user;
