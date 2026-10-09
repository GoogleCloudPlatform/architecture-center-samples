-- PL/SQL security wrapper for Oracle EBS tools.
-- Applied to ebs/tools.yaml by: python3 scripts/sync_sql_to_yaml.py --system ebs --wrap
-- Each tool's SQL replaces the placeholder below. The binds declared here are added to
-- every wrapped tool's parameters (in statement order, around the tool's own binds).
-- :user_id is an authenticated parameter: MCP Toolbox fills it from the caller's verified
-- Google token (email claim), never from the agent. ebs/tools.yaml must define the
-- 'google-auth' service under a top-level 'authServices:' key.
-- apps.xx_ai_security_pkg.init_user_session must exist in the EBS database. It maps the
-- email to the FND user and sets the application context (fnd_global.apps_initialize,
-- mo_global.init / MOAC) that the tools' queries run under.
-- Oracle Bind Variables:
--   :user_id (string): Email of the authenticated user; sets the EBS security context for the query.
-- Auth: :user_id = google-auth.email
-- -----------------------------------------------------------------------------
DECLARE
    rc SYS_REFCURSOR;
BEGIN
    -- 1. Set the EBS application/security context for the authenticated user
    apps.xx_ai_security_pkg.init_user_session(:user_id);

    -- 2. Open the cursor for the EBS selection query
    OPEN rc FOR
        <<SQL_SCRIPT_GOES_HERE>>;


    -- 3. Implicitly return the cursor back to the database client driver
    DBMS_SQL.RETURN_RESULT(rc);
END;
