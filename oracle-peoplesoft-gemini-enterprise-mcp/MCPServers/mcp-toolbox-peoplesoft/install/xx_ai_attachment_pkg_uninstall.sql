-- Removes the PeopleSoft MCP attachment package, its Oracle Text policy and preference. Run as SYSADM.
DROP PACKAGE xx_ai_attachment_pkg;
BEGIN
    ctx_ddl.drop_policy('XX_AI_ATTACH_TEXT_POLICY');
    ctx_ddl.drop_preference('XX_AI_ATTACH_TEXT_FILTER');
END;
/
