-- Checks the PeopleSoft MCP security package. Run as the Toolbox user (SYSADM_AI).
-- Prompts for the e-mail address of a real, active PeopleSoft user. This calls
-- SYSADM.PS_SECURITY_PKG1.INITIALIZE_SESSION for that user in this session only (it sets the
-- security context and may write the package's own log entry); it reads no application data.
SET SERVEROUTPUT ON
SET VERIFY OFF
ACCEPT email PROMPT 'E-mail address of an active PeopleSoft user: '
DECLARE
    l_oprid VARCHAR2(30);
    l_json  VARCHAR2(4000);
BEGIN
    l_oprid := sysadm.xx_ai_security_pkg.resolve_user('&email');
    DBMS_OUTPUT.PUT_LINE('Resolved OPRID: ' || l_oprid);
    -- The raw answer, to confirm the success STATUS value that the package expects:
    l_json := sysadm.ps_security_pkg1.initialize_session(l_oprid);
    DBMS_OUTPUT.PUT_LINE('PS_SECURITY_PKG1 answer: ' || SUBSTR(l_json, 1, 300));
    sysadm.xx_ai_security_pkg.init_user_session('&email');
    DBMS_OUTPUT.PUT_LINE('init_user_session: OK');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM);
END;
/
-- An unknown user must be refused, not silently accepted:
BEGIN
    sysadm.xx_ai_security_pkg.init_user_session('nobody.at.all@example.invalid');
    DBMS_OUTPUT.PUT_LINE('UNEXPECTED: unknown user accepted');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown user refused as expected: ' || SQLERRM);
END;
/
