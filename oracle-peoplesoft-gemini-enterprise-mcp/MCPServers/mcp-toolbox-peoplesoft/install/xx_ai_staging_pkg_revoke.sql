-- Takes the staging package away from the MCP Toolbox user again (disabling the ps_stage_* tools). Run as a DBA.
REVOKE EXECUTE ON sysadm.xx_ai_staging_pkg FROM sysadm_ai;
