-- Run as JDE_RS_LAB. Rules go into the LAB copy of F00950 and are cleared at the start of each case.
-- Each case prints PASS/FAIL against an independently computed expected count taken from F0101_RAW (no policy on it).
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
DECLARE
    -- note: BORKUR is the user; LABROLE the role it belongs to (F95921 lab copy)
    PROCEDURE rule(p_user VARCHAR2, p_alias VARCHAR2, p_from VARCHAR2, p_thru VARCHAR2, p_view VARCHAR2) IS
    BEGIN
        INSERT INTO f00950 (fssety, fsuser, fsobnm, fsdtai, fsfrdv, fsthdv, fsvwyn, fsa, fschng, fsdlt)
        VALUES ('4', p_user, '*ALL', p_alias, p_from, p_thru, p_view, 'N', 'N', 'N');
    END;
    PROCEDURE reset_(p_mode VARCHAR2) IS BEGIN DELETE FROM f00950; UPDATE rs_config SET rs_mode=p_mode; COMMIT; END;
    FUNCTION visible RETURN NUMBER IS n NUMBER; BEGIN SELECT COUNT(*) INTO n FROM f0101; RETURN n; END;
    FUNCTION raw(p_where VARCHAR2) RETURN NUMBER IS n NUMBER;
    BEGIN EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM f0101_raw WHERE '||p_where INTO n; RETURN n; END;
    PROCEDURE chk(p_name VARCHAR2, p_exp NUMBER, p_act NUMBER) IS
    BEGIN DBMS_OUTPUT.PUT_LINE(RPAD(p_name,74)||' expected '||LPAD(p_exp,4)||' actual '||LPAD(p_act,4)||'  '||CASE WHEN p_exp=p_act THEN 'PASS' ELSE 'FAIL' END); END;
    PROCEDURE login(p VARCHAR2) IS BEGIN rs_pkg.init_user_session(p); END;
    -- right-justified 12-char MCU literal
    FUNCTION m(v VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN 'N'''||LPAD(v,12)||''''; END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- identity ---');
    rs_pkg.clear_session;
    chk('T01 no identity: fail closed (0 rows)', 0, visible);
    BEGIN login('nobody@example.com'); DBMS_OUTPUT.PUT_LINE('T02 unknown e-mail: FAIL (no error)'); EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('T02 unknown e-mail refused: '||SQLERRM||'  PASS'); END;
    chk('T02b still no identity after refused login (0 rows)', 0, visible);
    login('Borkur@Pythian.com');
    DBMS_OUTPUT.PUT_LINE('T03 e-mail (mixed case) maps to JDE user '||SYS_CONTEXT('JDE_RS_CTX','JDE_USER'));
    reset_('EXCLUSIVE');
    chk('T04 identified, no rules at any level: unrestricted', raw('1=1'), visible);

    DBMS_OUTPUT.PUT_LINE('--- exclusive: Oracle doc example (F0101, MCU) ---');
    rule('BORKUR','MCU','1','20','Y');  rule('BORKUR','MCU','21','50','N');
    rule('BORKUR','MCU','51','70','Y'); rule('BORKUR','MCU','71','ZZZZZZZZ','N'); COMMIT;
    chk('T05 EXCLUSIVE: hide 21-50 and 71-ZZZZZZZZ',
        raw('NOT (abmcu BETWEEN '||m('21')||' AND '||m('50')||') AND NOT (abmcu BETWEEN '||m('71')||' AND '||m('ZZZZZZZZ')||')'), visible);

    DBMS_OUTPUT.PUT_LINE('--- inclusive: same rules ---');
    reset_('INCLUSIVE');
    rule('BORKUR','MCU','1','20','Y');  rule('BORKUR','MCU','21','50','N');
    rule('BORKUR','MCU','51','70','Y'); rule('BORKUR','MCU','71','ZZZZZZZZ','N'); COMMIT;
    chk('T06 INCLUSIVE: show only 1-20 and 51-70',
        raw('abmcu BETWEEN '||m('1')||' AND '||m('20')||' OR abmcu BETWEEN '||m('51')||' AND '||m('70')), visible);
    reset_('INCLUSIVE');
    rule('BORKUR','MCU','1','20','N'); COMMIT;
    chk('T07 INCLUSIVE: rules exist but none grants View: nothing visible', 0, visible);

    DBMS_OUTPUT.PUT_LINE('--- precedence: user over role over *PUBLIC ---');
    reset_('INCLUSIVE');
    rule('*PUBLIC','MCU','1','20','Y'); COMMIT;
    chk('T08 only *PUBLIC rule (1-20) applies', raw('abmcu BETWEEN '||m('1')||' AND '||m('20')), visible);
    rule('LABROLE','MCU','51','70','Y'); COMMIT;
    chk('T09 role rule (51-70) hides *PUBLIC rule', raw('abmcu BETWEEN '||m('51')||' AND '||m('70')), visible);
    rule('BORKUR','MCU','21','50','Y'); COMMIT;
    chk('T10 user rule (21-50) hides role and *PUBLIC', raw('abmcu BETWEEN '||m('21')||' AND '||m('50')), visible);

    DBMS_OUTPUT.PUT_LINE('--- second data item, numeric (AN8) combined with MCU ---');
    reset_('INCLUSIVE');
    rule('BORKUR','MCU','1','20','Y'); rule('BORKUR','AN8','1','1000','Y'); COMMIT;
    chk('T11 MCU 1-20 AND AN8 1-1000 (both must allow)',
        raw('abmcu BETWEEN '||m('1')||' AND '||m('20')||' AND aban8 BETWEEN 1 AND 1000'), visible);

    DBMS_OUTPUT.PUT_LINE('--- table-specific rule vs *ALL ---');
    reset_('INCLUSIVE');
    INSERT INTO f00950 (fssety,fsuser,fsobnm,fsdtai,fsfrdv,fsthdv,fsvwyn,fsa,fschng,fsdlt) VALUES ('4','BORKUR','F0006','MCU','1','5','Y','N','N','N'); COMMIT;
    chk('T12 rule on another table (F0006) does not touch F0101: unrestricted', raw('1=1'), visible);
    reset_('EXCLUSIVE');
END;
/
EXIT
