-- Site settings for the JDE install scripts in this folder (edit, then run the other scripts).
-- They are SQL*Plus / SQLcl substitution variables, referenced as &&name.
--   jde_data_schema    : business data schema holding F00165 and F01151 (TESTDTA, PS920DTA or PRODDTA)
--   jde_sys_schema     : system schema holding F0092 (SY920, or your release's system library)
--   jde_ai_tablespace  : tablespace for the small mapping table JDE_AI.XX_AI_USER_MAP (JDE_AI gets a quota on it)
--   jde_toolbox_user   : database user the MCP Toolbox connects as (it gets EXECUTE on the packages)
-- The packages are created in the schema you connect as, which must be JDE_AI because
-- jde/templates/plsql_wrapper.sql calls jde_ai.xx_ai_security_pkg.
DEFINE jde_data_schema  = TESTDTA
DEFINE jde_sys_schema   = SY920
DEFINE jde_ai_tablespace = USERS
DEFINE jde_toolbox_user = JDE_AI_RO
