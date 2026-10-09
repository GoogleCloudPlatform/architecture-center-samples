-- PL/SQL security wrapper for PeopleSoft tools.
-- Applied to peoplesoft/tools.yaml by: python3 scripts/sync_sql_to_yaml.py --system peoplesoft --wrap
-- Each tool's SQL replaces the placeholder below. The binds declared here are added to
-- every wrapped tool's parameters (in statement order, around the tool's own binds).
-- :user_id is an authenticated parameter: MCP Toolbox fills it from the caller's verified
-- Google token (email claim), never from the agent. peoplesoft/tools.yaml must define the
-- 'google-auth' service under a top-level 'authServices:' key.
-- Oracle Bind Variables:
--   :user_id (string): Email of the authenticated user; sets the PeopleSoft security context for the query.
-- Auth: :user_id = google-auth.email
-- -----------------------------------------------------------------------------
DECLARE
    rc SYS_REFCURSOR;
BEGIN
    -- 1. Correctly set the user session context
    sysadm.xx_ai_security_pkg.init_user_session(:user_id);

    -- 2. Open the cursor for the PeopleSoft selection query
    OPEN rc FOR
        <<SQL_SCRIPT_GOES_HERE>>;


    -- 3. Implicitly return the cursor back to the database client driver
    DBMS_SQL.RETURN_RESULT(rc);
END;
