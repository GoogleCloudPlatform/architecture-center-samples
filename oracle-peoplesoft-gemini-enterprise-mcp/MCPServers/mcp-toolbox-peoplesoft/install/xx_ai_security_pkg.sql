-- =============================================================================
-- xx_ai_security_pkg (PeopleSoft): sets the PeopleSoft security context for an MCP call
-- =============================================================================
-- Run as SYSADM (PeopleSoft on Oracle Database 19c) through the site's normal process for
-- custom database code. See peoplesoft/install/README.md.
--
-- Called first in every wrapped tool statement (peoplesoft/templates/plsql_wrapper.sql):
--     sysadm.xx_ai_security_pkg.init_user_session(:user_id);
-- where :user_id is the e-mail address from the caller's verified Google token. The package
--   1. maps that e-mail address to an active PeopleSoft user (PSOPRDEFN.EMAILID, ACCTLOCK = 0),
--   2. calls the delivered-site function SYSADM.PS_SECURITY_PKG1.INITIALIZE_SESSION(oprid),
--      which returns JSON {"STATUS": ..., "MESSAGE": ...},
--   3. raises an error unless STATUS is the success value, so a failed security setup stops
--      the query instead of returning unrestricted rows (fail closed).
--
-- Read-only: it reads PSOPRDEFN and calls PS_SECURITY_PKG1 (which may write its own log).
-- Prerequisite: SYSADM can execute SYSADM.PS_SECURITY_PKG1 (it owns it).
-- SUCCESS VALUE: c_ok_status below is the STATUS that PS_SECURITY_PKG1 returns on success. The
-- site's package only showed the failure form ({"STATUS":"FAILURE",...}); confirm the success value
-- with xx_ai_security_pkg_verify.sql and change the constant if it differs.
-- Errors raised: -20010 no user id, -20011 no active user with that e-mail, -20012 several
-- active users with that e-mail, -20013 security setup failed (message follows).
-- Remove with xx_ai_security_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE

CREATE OR REPLACE PACKAGE xx_ai_security_pkg AUTHID DEFINER AS
    -- Sets the PeopleSoft security context for the user whose e-mail address (or, for tests, OPRID)
    -- is p_user_id. Raises an error if the user cannot be resolved or the setup fails.
    PROCEDURE init_user_session(p_user_id IN VARCHAR2);

    -- The OPRID that p_user_id resolves to (same rules and errors as init_user_session). Same name
    -- and meaning as resolve_user in the EBS and JDE packages.
    FUNCTION resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2;
END xx_ai_security_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_security_pkg AS
    c_ok_status CONSTANT VARCHAR2(30) := 'SUCCESS';

    FUNCTION resolve_user(p_user_id IN VARCHAR2) RETURN VARCHAR2 IS
        l_id    VARCHAR2(200) := TRIM(p_user_id);
        l_count NUMBER;
        l_oprid VARCHAR2(30);
    BEGIN
        IF l_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'No user id was supplied');
        END IF;
        IF INSTR(l_id, '@') > 0 THEN
            SELECT COUNT(*), MIN(oprid) INTO l_count, l_oprid
              FROM psoprdefn
             WHERE UPPER(TRIM(emailid)) = UPPER(l_id) AND acctlock = 0;
        ELSE
            SELECT COUNT(*), MIN(oprid) INTO l_count, l_oprid
              FROM psoprdefn
             WHERE oprid = UPPER(l_id) AND acctlock = 0;
        END IF;
        IF l_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'No active PeopleSoft user for ' || SUBSTR(l_id, 1, 100));
        ELSIF l_count > 1 THEN
            RAISE_APPLICATION_ERROR(-20012, 'More than one active PeopleSoft user for ' || SUBSTR(l_id, 1, 100));
        END IF;
        RETURN l_oprid;
    END resolve_user;

    PROCEDURE init_user_session(p_user_id IN VARCHAR2) IS
        l_oprid   VARCHAR2(30) := resolve_user(p_user_id);
        l_json    VARCHAR2(4000);
        l_status  VARCHAR2(200);
        l_message VARCHAR2(1000);
    BEGIN
        l_json := sysadm.ps_security_pkg1.initialize_session(l_oprid);
        BEGIN
            l_status  := JSON_OBJECT_T.parse(l_json).get_string('STATUS');
            l_message := JSON_OBJECT_T.parse(l_json).get_string('MESSAGE');
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20013, 'PeopleSoft security setup returned an unreadable answer for ' || l_oprid);
        END;
        IF UPPER(NVL(l_status, 'NONE')) <> c_ok_status THEN
            RAISE_APPLICATION_ERROR(-20013, 'PeopleSoft security setup failed for ' || l_oprid || ': '
                                            || SUBSTR(NVL(l_message, l_status), 1, 300));
        END IF;
        DBMS_SESSION.SET_IDENTIFIER(SUBSTR(TRIM(p_user_id), 1, 64));   -- shows who the session works for (audit)
    END init_user_session;
END xx_ai_security_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_security_pkg

-- Access for the MCP Toolbox user (change the grantee if yours has another name).
GRANT EXECUTE ON xx_ai_security_pkg TO sysadm_ai;
