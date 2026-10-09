-- Checks the EBS MCP security package. Run as the Toolbox user (APPS_AI) after the install and the GRANT.
-- Prompts for the e-mail address of a real, active EBS user. This calls
-- apps.xx_ai_security_pkg.init_user_session for that user in this session only (it sets the EBS
-- context via fnd_global.apps_initialize and writes log rows to APPS.XX_GGLTOOLBOX$MCP_LOG); it
-- reads no application data.
SET SERVEROUTPUT ON
SET VERIFY OFF
ACCEPT email PROMPT 'E-mail address of an active EBS user (empty to skip): '
BEGIN
    IF '&email' IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Resolved FND user: ' || apps.xx_ai_security_pkg.resolve_user('&email'));
        apps.xx_ai_security_pkg.init_user_session('&email');
        DBMS_OUTPUT.PUT_LINE('init_user_session: OK');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM);
END;
/
-- An unknown user must be refused, not silently accepted:
BEGIN
    apps.xx_ai_security_pkg.init_user_session('nobody.at.all@example.invalid');
    DBMS_OUTPUT.PUT_LINE('UNEXPECTED: unknown user accepted');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown user refused as expected: ' || SQLERRM);
END;
/
