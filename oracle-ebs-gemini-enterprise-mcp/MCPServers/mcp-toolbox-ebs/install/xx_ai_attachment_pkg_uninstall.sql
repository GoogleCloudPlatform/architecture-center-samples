-- Removes what xx_ai_attachment_pkg.sql created (the package and the Oracle Text policy and
-- preference). Run as APPS. Before running it, switch ebs_get_attachment_text and
-- ebs_get_attachment_base64 back to versions without the package (see ebs/install/README.md),
-- or those tools fail with ORA-00904.
WHENEVER SQLERROR CONTINUE
DROP PACKAGE xx_ai_attachment_pkg;
BEGIN
    ctx_ddl.drop_policy('XX_AI_ATTACH_TEXT_POLICY');
END;
/
BEGIN
    ctx_ddl.drop_preference('XX_AI_ATTACH_TEXT_FILTER');
END;
/
