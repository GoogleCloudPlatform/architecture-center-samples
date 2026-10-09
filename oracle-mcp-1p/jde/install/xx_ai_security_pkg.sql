-- =============================================================================
-- xx_ai_security_pkg (JD Edwards): identifies the JDE user behind an MCP call
-- =============================================================================
-- Run as JDE_AI (JD Edwards EnterpriseOne on Oracle Database 19c) after jde_ai_grants.sql, through
-- the site's normal process for custom database code. See jde/install/README.md.
--
-- Called first in every wrapped tool statement (jde/templates/plsql_wrapper.sql):
--     jde_ai.xx_ai_security_pkg.init_user_session(:user_id);
-- where :user_id is the e-mail address from the caller's verified Google token. The package
--   1. maps the e-mail address to ONE JDE user, in this order:
--        a. the DBA-owned mapping table XX_AI_USER_MAP (explicit; wins when it has the address,
--           and a row with ACTIVE = 'N' blocks the address even if JDE data would match),
--        b. otherwise the JDE data: F00926.AUEMLA (user profile e-mail) and F01151 (address book
--           e-mail of the user's F0092.ULAN8). Users found by either route are counted together,
--      a plain JDE user ID is also accepted, for tests,
--   2. raises an error if there is no such user or more than one (fail closed),
--   3. records the user for this database session (DBMS_SESSION.SET_IDENTIFIER and get_jde_user).
-- clear_session removes the identity again; the wrapper calls it after opening the cursor so a pooled
-- connection never carries one caller's identity into the next call. A FAILED init_user_session also
-- clears the previous identity (it never leaves the last caller in place).
--
-- LIMIT, read this: JDE enforces row security (F00950) and column security only in its application
-- server, not in the database. This package identifies and records the user; it does NOT filter rows.
-- Until row-level filtering is built on top of get_jde_user (for example Oracle VPD policies that read
-- F00950), a wrapped tool shows the same rows as the unwrapped tool to anyone who is a known JDE user.
-- The wrapper therefore proves who is asking and refuses unknown users, nothing more.
--
-- Not checked (unknown semantics, see research/jde-row-security): whether the JDE user is active or
-- disabled (F00926.AUACTINACT). Use XX_AI_USER_MAP.ACTIVE to switch a person off.
-- Data note: in the TESTDTA demo data all users with an address book number share AN8 1 (no e-mail) and
-- F00926.AUEMLA is empty, so only the mapping table can identify anyone there.
-- Errors raised: -20010 no user id, -20011 no JDE user for that e-mail/ID, -20012 several JDE users,
-- -20013 address switched off in XX_AI_USER_MAP.
-- Remove with xx_ai_security_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE
@@jde_install_config.sql

-- DBA-owned mapping from a sign-in e-mail to a JDE user. Created empty; kept when the package is removed.
-- The Toolbox user gets EXECUTE on the package only, never access to this table.
DECLARE
    l_n NUMBER;
BEGIN
    SELECT COUNT(*) INTO l_n FROM user_tables WHERE table_name = 'XX_AI_USER_MAP';
    IF l_n = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE xx_ai_user_map (
            email     VARCHAR2(200) NOT NULL,
            jde_user  VARCHAR2(10)  NOT NULL,
            active    CHAR(1)       DEFAULT ''Y'' NOT NULL,
            note      VARCHAR2(200),
            CONSTRAINT xx_ai_user_map_pk PRIMARY KEY (email),
            CONSTRAINT xx_ai_user_map_email_ck CHECK (email = UPPER(TRIM(email))),
            CONSTRAINT xx_ai_user_map_user_ck  CHECK (jde_user = UPPER(TRIM(jde_user))),
            CONSTRAINT xx_ai_user_map_act_ck   CHECK (active IN (''Y'', ''N'')))';
    END IF;
END;
/

CREATE OR REPLACE PACKAGE xx_ai_security_pkg AUTHID DEFINER AS
    -- Identifies the JDE user whose e-mail address (or JDE user ID) is p_user_id and records it for this
    -- session. Raises an error if the user cannot be resolved; any earlier identity is cleared first.
    PROCEDURE init_user_session(p_user_id IN VARCHAR2);

    -- Forgets the identity recorded for this session (get_jde_user returns NULL afterwards).
    PROCEDURE clear_session;

    -- The JDE user ID that p_user_id resolves to (same rules and errors as init_user_session).
    FUNCTION resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2;

    -- The JDE user recorded by the last init_user_session in this session; NULL if none.
    FUNCTION get_jde_user RETURN VARCHAR2;
END xx_ai_security_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_security_pkg AS
    g_user VARCHAR2(10);

    FUNCTION resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2 IS
        l_id     VARCHAR2(200) := TRIM(p_user_id);
        l_key    VARCHAR2(200) := UPPER(TRIM(p_user_id));
        l_count  NUMBER;
        l_user   VARCHAR2(10);
        l_active VARCHAR2(1);
    BEGIN
        IF l_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'No user id was supplied');
        END IF;
        IF INSTR(l_id, '@') > 0 THEN
            -- a. explicit mapping owned by the DBA
            SELECT COUNT(*), MIN(jde_user), MIN(active) INTO l_count, l_user, l_active
              FROM xx_ai_user_map
             WHERE email = l_key;
            IF l_count > 0 THEN
                IF l_active = 'N' THEN
                    RAISE_APPLICATION_ERROR(-20013, 'E-mail address switched off: ' || SUBSTR(l_id, 1, 100));
                END IF;
                SELECT COUNT(*) INTO l_count FROM &&jde_sys_schema..f0092 WHERE TRIM(uluser) = l_user;
                IF l_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20011, 'Mapped JD Edwards user does not exist for ' || SUBSTR(l_id, 1, 100));
                END IF;
                RETURN l_user;
            END IF;
            -- b. JDE data: user profile e-mail (F00926) and address book e-mail (F0092 -> F01151), counted together
            SELECT COUNT(DISTINCT u), MIN(u) INTO l_count, l_user
              FROM (SELECT TO_CHAR(TRIM(a.auuser)) u
                      FROM &&jde_sys_schema..f00926 a
                      JOIN &&jde_sys_schema..f0092 p ON TRIM(p.uluser) = TRIM(a.auuser)
                     WHERE UPPER(TRIM(a.auemla)) = l_key
                    UNION
                    SELECT TO_CHAR(TRIM(u.uluser))
                      FROM &&jde_sys_schema..f0092 u
                      JOIN &&jde_data_schema..f01151 e ON e.eaan8 = u.ulan8
                     WHERE u.ulan8 > 0
                       AND UPPER(TRIM(e.eaemal)) = l_key);
        ELSE
            SELECT COUNT(DISTINCT TRIM(uluser)), MIN(TO_CHAR(TRIM(uluser))) INTO l_count, l_user
              FROM &&jde_sys_schema..f0092
             WHERE TRIM(uluser) = l_key;
        END IF;
        IF l_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'No JD Edwards user for ' || SUBSTR(l_id, 1, 100));
        ELSIF l_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20012, 'More than one JD Edwards user for ' || SUBSTR(l_id, 1, 100));
        END IF;
        RETURN l_user;
    END resolve_user;

    PROCEDURE clear_session IS
    BEGIN
        g_user := NULL;
        DBMS_SESSION.SET_IDENTIFIER(NULL);
    END clear_session;

    PROCEDURE init_user_session(p_user_id IN VARCHAR2) IS
        l_user VARCHAR2(10);
    BEGIN
        clear_session;                       -- first: a refused caller must not keep the previous caller's identity
        l_user := resolve_user(p_user_id);
        g_user := l_user;
        DBMS_SESSION.SET_IDENTIFIER(SUBSTR(TRIM(p_user_id), 1, 64));   -- shows who the session works for (audit)
    END init_user_session;

    FUNCTION get_jde_user RETURN VARCHAR2 IS
    BEGIN
        RETURN g_user;
    END get_jde_user;
END xx_ai_security_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_security_pkg

-- Access for the MCP Toolbox user
GRANT EXECUTE ON xx_ai_security_pkg TO &&jde_toolbox_user;
