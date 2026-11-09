-- Checks the JDE MCP security package. Run as the Toolbox user. Read-only.
-- Prompts for the e-mail address of a JDE user that can be identified (mapping table, F00926.AUEMLA or
-- an address book e-mail linked through F0092.ULAN8).
SET SERVEROUTPUT ON
SET VERIFY OFF
ACCEPT email PROMPT 'E-mail address of a JDE user (empty to skip): '
BEGIN
    IF '&email' IS NOT NULL THEN
        jde_ai.xx_ai_security_pkg.init_user_session('&email');
        DBMS_OUTPUT.PUT_LINE('Resolved JDE user: ' || jde_ai.xx_ai_security_pkg.get_jde_user);
        jde_ai.xx_ai_security_pkg.clear_session;
        IF jde_ai.xx_ai_security_pkg.get_jde_user IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('clear_session removed the identity as expected');
        ELSE
            DBMS_OUTPUT.PUT_LINE('UNEXPECTED: identity still set after clear_session');
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM);
END;
/
-- An unknown user must be refused, not silently accepted, and must leave no identity behind
-- (not even the one resolved above):
BEGIN
    IF '&email' IS NOT NULL THEN
        jde_ai.xx_ai_security_pkg.init_user_session('&email');
    END IF;
    jde_ai.xx_ai_security_pkg.init_user_session('nobody.at.all@example.invalid');
    DBMS_OUTPUT.PUT_LINE('UNEXPECTED: unknown user accepted');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown user refused as expected: ' || SQLERRM);
        IF jde_ai.xx_ai_security_pkg.get_jde_user IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('No identity left after the refused call, as expected');
        ELSE
            DBMS_OUTPUT.PUT_LINE('UNEXPECTED: previous identity still set after a refused call');
        END IF;
END;
/
