-- Lets the MCP Toolbox user call the staging package. Run as a DBA when you ENABLE the jde_stage_* tools, not before.
-- Why separate: the Toolbox user can call any function it may execute through the execute_sql tool (a SELECT may call
-- an autonomous function), so this grant is what makes writing to the Z-files reachable at all, whether or not the
-- jde_stage_* tools are enabled. Without it the package cannot be reached by the Toolbox user.
@@jde_install_config.sql
GRANT EXECUTE ON jde_ai.xx_ai_staging_pkg TO &&jde_toolbox_user;
