-- Run as JDE_RS_LAB. Prototype of "reproduce F00950 type-4 (row) security in the database".
-- NOT production code: the open questions in ../FINDINGS.md decide whether this design is right.
WHENEVER SQLERROR EXIT FAILURE

-- lab-only switch; the real location of the inclusive/exclusive flag is an open question (Q3)
CREATE TABLE rs_config (rs_mode VARCHAR2(10) NOT NULL CHECK (rs_mode IN ('EXCLUSIVE','INCLUSIVE')));
INSERT INTO rs_config VALUES ('EXCLUSIVE');
COMMIT;

CREATE OR REPLACE PACKAGE rs_pkg AUTHID DEFINER AS
    PROCEDURE init_user_session(p_user_id IN VARCHAR2);   -- email or JDE user id; fail closed
    PROCEDURE clear_session;
    FUNCTION  vpd_policy(p_schema IN VARCHAR2, p_table IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION  predicate_for(p_user IN VARCHAR2, p_table IN VARCHAR2, p_alias IN VARCHAR2, p_column IN VARCHAR2, p_op IN VARCHAR2) RETURN VARCHAR2;
END rs_pkg;
/
CREATE OR REPLACE PACKAGE BODY rs_pkg AS
    -- (alias, column) pairs secured per table in this lab; real JDE derives the column from the data dictionary / table spec (Q5)
    TYPE t_map IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);

    FUNCTION resolve_user(p_id IN VARCHAR2) RETURN VARCHAR2 IS
        l_n NUMBER; l_u VARCHAR2(10); l_id VARCHAR2(200) := TRIM(p_id);
    BEGIN
        IF l_id IS NULL THEN RAISE_APPLICATION_ERROR(-20010,'No user id'); END IF;
        IF INSTR(l_id,'@')>0 THEN
            SELECT COUNT(DISTINCT TRIM(u.uluser)), MIN(TRIM(u.uluser)) INTO l_n, l_u
              FROM f0092 u JOIN f01151 e ON e.eaan8=u.ulan8
             WHERE u.ulan8>0 AND UPPER(TRIM(e.eaemal))=UPPER(l_id);
        ELSE
            SELECT COUNT(DISTINCT TRIM(uluser)), MIN(TRIM(uluser)) INTO l_n, l_u FROM f0092 WHERE TRIM(uluser)=UPPER(l_id);
        END IF;
        IF l_n=0 THEN RAISE_APPLICATION_ERROR(-20011,'No JDE user'); ELSIF l_n>1 THEN RAISE_APPLICATION_ERROR(-20012,'Several JDE users'); END IF;
        RETURN l_u;
    END;

    PROCEDURE clear_session IS
    BEGIN
        DBMS_SESSION.CLEAR_CONTEXT('JDE_RS_CTX','JDE_USER');
    END;

    PROCEDURE init_user_session(p_user_id IN VARCHAR2) IS
        l_u VARCHAR2(10);
    BEGIN
        DBMS_SESSION.CLEAR_CONTEXT('JDE_RS_CTX','JDE_USER');       -- clear first so a failed call leaves no identity
        l_u := resolve_user(p_user_id);
        DBMS_SESSION.SET_CONTEXT('JDE_RS_CTX','JDE_USER',l_u);
    END;

    -- Builds the predicate fragment for ONE alias on ONE table for the effective level (user, else role, else *PUBLIC).
    FUNCTION predicate_for(p_user IN VARCHAR2, p_table IN VARCHAR2, p_alias IN VARCHAR2, p_column IN VARCHAR2, p_op IN VARCHAR2) RETURN VARCHAR2 IS
        l_mode  VARCHAR2(10);
        l_level VARCHAR2(20);
        l_flagcol VARCHAR2(10) := CASE p_op WHEN 'VIEW' THEN 'fsvwyn' WHEN 'ADD' THEN 'fsa' WHEN 'CHANGE' THEN 'fschng' ELSE 'fsdlt' END;
        l_isnum NUMBER;
        l_n NUMBER; l_nyes NUMBER; l_out VARCHAR2(4000);
        l_lit VARCHAR2(200);
        FUNCTION lit(p_v VARCHAR2) RETURN VARCHAR2 IS
        BEGIN
            IF l_isnum=1 THEN RETURN TO_CHAR(TO_NUMBER(TRIM(p_v)));
            ELSE RETURN 'N''' || REPLACE(LPAD(TRIM(p_v),12),'''','''''') || ''''; END IF;
        END;
    BEGIN
        SELECT rs_mode INTO l_mode FROM rs_config;
        SELECT CASE WHEN data_type IN ('NUMBER') THEN 1 ELSE 0 END INTO l_isnum
          FROM user_tab_columns WHERE table_name=p_table AND column_name=UPPER(p_column);
        -- effective level: first of user, any of the user's roles, *PUBLIC that has type-4 rows for this table/alias
        FOR lv IN (SELECT 1 ord, p_user subj FROM dual
                   UNION ALL SELECT 2, TO_CHAR(TRIM(rltorole)) FROM f95921 WHERE TRIM(rlfrrole)=p_user
                   UNION ALL SELECT 3, '*PUBLIC' FROM dual ORDER BY 1) LOOP
            SELECT COUNT(*) INTO l_n FROM f00950
             WHERE fssety='4' AND TRIM(fsuser)=lv.subj AND TRIM(fsobnm) IN (p_table,'*ALL') AND TRIM(fsdtai)=p_alias;
            IF l_n>0 THEN l_level := lv.subj; EXIT; END IF;
        END LOOP;
        IF l_level IS NULL THEN RETURN NULL; END IF;       -- no rules anywhere: unrestricted (Q7: confirm for inclusive mode)
        IF l_mode='EXCLUSIVE' THEN
            FOR r IN (SELECT TRIM(fsfrdv) f, TRIM(fsthdv) t FROM f00950
                       WHERE fssety='4' AND TRIM(fsuser)=l_level AND TRIM(fsobnm) IN (p_table,'*ALL') AND TRIM(fsdtai)=p_alias
                         AND CASE l_flagcol WHEN 'fsvwyn' THEN TRIM(fsvwyn) WHEN 'fsa' THEN TRIM(fsa) WHEN 'fschng' THEN TRIM(fschng) ELSE TRIM(fsdlt) END = 'N') LOOP
                l_out := l_out || CASE WHEN l_out IS NOT NULL THEN ' AND ' END ||
                         p_column||' NOT BETWEEN '||lit(r.f)||' AND '||lit(NVL(r.t,r.f));
            END LOOP;
        ELSE
            FOR r IN (SELECT TRIM(fsfrdv) f, TRIM(fsthdv) t FROM f00950
                       WHERE fssety='4' AND TRIM(fsuser)=l_level AND TRIM(fsobnm) IN (p_table,'*ALL') AND TRIM(fsdtai)=p_alias
                         AND CASE l_flagcol WHEN 'fsvwyn' THEN TRIM(fsvwyn) WHEN 'fsa' THEN TRIM(fsa) WHEN 'fschng' THEN TRIM(fschng) ELSE TRIM(fsdlt) END = 'Y') LOOP
                l_out := l_out || CASE WHEN l_out IS NOT NULL THEN ' OR ' END ||
                         p_column||' BETWEEN '||lit(r.f)||' AND '||lit(NVL(r.t,r.f));
            END LOOP;
            l_out := CASE WHEN l_out IS NULL THEN '1=0' ELSE '('||l_out||')' END;  -- rules exist but none grant this op: nothing visible
        END IF;
        RETURN l_out;
    END;

    FUNCTION vpd_policy(p_schema IN VARCHAR2, p_table IN VARCHAR2) RETURN VARCHAR2 IS
        l_user VARCHAR2(10) := SYS_CONTEXT('JDE_RS_CTX','JDE_USER');
        l_out  VARCHAR2(4000);
        l_p    VARCHAR2(4000);
    BEGIN
        IF l_user IS NULL THEN RETURN '1=0'; END IF;          -- no identified user: fail closed
        -- lab: F0101 secured on MCU (ABMCU) and AN8 (ABAN8)
        IF p_table='F0101' THEN
            l_p := predicate_for(l_user,p_table,'MCU','ABMCU','VIEW');
            l_out := l_p;
            l_p := predicate_for(l_user,p_table,'AN8','ABAN8','VIEW');
            IF l_p IS NOT NULL THEN l_out := CASE WHEN l_out IS NULL THEN l_p ELSE '('||l_out||') AND ('||l_p||')' END; END IF;
        END IF;
        RETURN l_out;
    END;
END rs_pkg;
/
SHOW ERRORS PACKAGE BODY rs_pkg
EXIT
