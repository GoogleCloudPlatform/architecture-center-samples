-- Lets the MCP Toolbox user call the staging package. Run as a DBA when you ENABLE the ps_stage_* tools, not before.
-- Why separate: the Toolbox user can call any function it may execute through the execute_sql tool (a SELECT may call
-- an autonomous function), so this grant is what makes writing to the staging tables reachable at all, whether or
-- not the ps_stage_* tools are enabled. Change the grantee if your Toolbox user has another name.
GRANT EXECUTE ON sysadm.xx_ai_staging_pkg TO sysadm_ai;
