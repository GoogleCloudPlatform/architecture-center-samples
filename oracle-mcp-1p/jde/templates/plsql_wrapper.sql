-- PL/SQL security wrapper for JD Edwards EnterpriseOne tools.
-- Applied to jde/tools.yaml by: python3 scripts/sync_sql_to_yaml.py --system jde --wrap
-- Each tool's SQL replaces the placeholder below. The binds declared here are added to
-- every wrapped tool's parameters (in statement order, around the tool's own binds).
-- :user_id is an authenticated parameter: MCP Toolbox fills it from the caller's verified
-- Google token (email claim), never from the agent. jde/tools.yaml must define the
-- 'google-auth' service under a top-level 'authServices:' key.
-- jde_ai.xx_ai_security_pkg is a placeholder that must be created in the JDE database:
-- it maps the email to the JDE user (DBA mapping table, else F00926 / F01151 e-mail -> F0092 user profile) and
-- applies that user's row security (F00950) to the session, e.g. through VPD policies.
-- Oracle Bind Variables:
--   :user_id (string): Email of the authenticated user; sets the JD Edwards security context for the query.
-- Auth: :user_id = google-auth.email
-- -----------------------------------------------------------------------------
DECLARE
    rc SYS_REFCURSOR;
BEGIN
    -- 1. Map the caller to a JDE user and apply their row security
    jde_ai.xx_ai_security_pkg.init_user_session(:user_id);

    -- 2. Open the cursor for the JD Edwards selection query
    OPEN rc FOR
        <<SQL_SCRIPT_GOES_HERE>>;

    -- 3. Forget the identity so a pooled connection never carries it into the next call
    jde_ai.xx_ai_security_pkg.clear_session;

    -- 4. Implicitly return the cursor back to the database client driver
    DBMS_SQL.RETURN_RESULT(rc);
END;
