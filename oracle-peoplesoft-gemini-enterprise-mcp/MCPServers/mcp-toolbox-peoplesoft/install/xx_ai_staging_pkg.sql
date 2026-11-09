-- =============================================================================
-- xx_ai_staging_pkg: stage transactions in PeopleSoft's documented load tables (FSCM)
-- =============================================================================
--
-- Run in SQL*Plus or SQLcl as a DBA or as SYSADM (the owner of the PS_ tables), on a PeopleSoft FSCM database.
-- It does NOT install on an HCM-only database such as HR92U054: the staging tables are missing there
-- (PLS-00201), which is why the tools that use it are disabled in mcp-toolbox-peoplesoft/sql/*.txt.
--
-- PeopleSoft has no PL/SQL business API. What Oracle documents for loading transactions from outside
-- is a set of staging tables that a delivered batch process (Application Engine) validates and turns
-- into the real transaction:
--   vouchers      PS_VCHR_HDR_STG, PS_VCHR_LINE_STG, PS_VCHR_DIST_STG, PS_VCHR_PYMT_STG  -> Voucher Build (AP_VCHRBLD)
--   requisitions  PS_PO_REQLOAD_RQST, PS_PO_REQLOAD_CMT                                   -> Requisition Loader (PO_REQLOAD)
--   journals      PS_JGEN_ACCT_ENTRY                                                      -> Journal Generator (FS_JGEN)
-- This package inserts rows into exactly those tables, nothing else. It does not start the batch
-- process: the Process Scheduler runs it on its schedule (check with the tool ps_get_process_status).
--
-- No column list is hardcoded, on purpose: the column lists of these records could not be confirmed
-- from Oracle's public documentation, and they differ by release and by customisation. Every row is a
-- JSON object {"COLUMN":value,...}. A key is accepted only if it is a column of that table in the data
-- dictionary (so the caller cannot reach any other column or table); values are bound, never concatenated.
--   NUMBER columns   a JSON number
--   DATE columns     "YYYY-MM-DD"
--   TIMESTAMP        "YYYY-MM-DDTHH24:MI:SS"
--   other columns    a JSON string (a JSON number is converted to text); null is allowed
-- The tool ps_describe_staging_table lists the real columns (and which are NOT NULL) first.
-- All rows of one call go in together or not at all: any error rolls the whole call back.
-- At most 500 rows per table and call. Every function returns JSON and never raises:
--   {"STATUS":"SUCCESS","ROWS":{"VCHR_HDR_STG":1,"VCHR_LINE_STG":2,...}}  or  {"STATUS":"ERROR","MESSAGE":"..."}
--
-- Needs the PeopleSoft security wrapper (mcp-toolbox-peoplesoft/templates/plsql_wrapper.sql): the Toolbox user itself
-- only gets EXECUTE on this package, never INSERT on the tables.
-- Remove with xx_ai_staging_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE

-- The tools call sysadm.xx_ai_staging_pkg, and the package (definer's rights) needs INSERT on the SYSADM tables, so it
-- belongs to SYSADM. The script always creates it there: connected as a DBA it installs into SYSADM without SYSADM's
-- password (needs CREATE ANY PROCEDURE); connected as SYSADM it changes nothing. SYSADM is the PeopleSoft owner and
-- cannot be locked the way JDE_AI can; the staging code is small, whitelisted and bound, but note that it runs with
-- SYSADM's rights.
ALTER SESSION SET CURRENT_SCHEMA = SYSADM;

CREATE OR REPLACE PACKAGE sysadm.xx_ai_staging_pkg AUTHID DEFINER AS
    -- Voucher: header, lines and distributions are required, payments are optional. Each is a JSON array of row objects.
    FUNCTION stage_voucher(p_headers CLOB, p_lines CLOB, p_distribs CLOB, p_payments CLOB DEFAULT NULL) RETURN VARCHAR2;
    -- Requisition load requests (PO_REQLOAD_RQST) and optional comments (PO_REQLOAD_CMT).
    FUNCTION stage_requisition(p_requests CLOB, p_comments CLOB DEFAULT NULL) RETURN VARCHAR2;
    -- Generic accounting entries (JGEN_ACCT_ENTRY) for the Journal Generator.
    FUNCTION stage_journal_entry(p_entries CLOB) RETURN VARCHAR2;
END xx_ai_staging_pkg;
/

CREATE OR REPLACE PACKAGE BODY sysadm.xx_ai_staging_pkg AS

    c_max_rows CONSTANT PLS_INTEGER := 500;

    TYPE t_counts IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);

    -- Insert every object of the JSON array p_json into the record p_record (table PS_<record>); returns the row count.
    -- Raises -20001 with a readable message on bad input or a database error.
    FUNCTION insert_rows(p_record VARCHAR2, p_json CLOB) RETURN PLS_INTEGER IS
        TYPE t_types IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(128);
        l_types   t_types;
        l_arr     JSON_ARRAY_T;
        l_obj     JSON_OBJECT_T;
        l_el      JSON_ELEMENT_T;
        l_keys    JSON_KEY_LIST;
        l_cur     INTEGER;
        l_cols    VARCHAR2(32767);
        l_vals    VARCHAR2(32767);
        l_sql     VARCHAR2(32767);
        l_col     VARCHAR2(128);
        l_n       NUMBER;
        l_dummy   INTEGER;
        l_table   CONSTANT VARCHAR2(128) := 'PS_' || p_record;
    BEGIN
        FOR c IN (SELECT column_name, data_type FROM all_tab_columns
                   WHERE owner = 'SYSADM' AND table_name = l_table) LOOP
            l_types(c.column_name) := c.data_type;
        END LOOP;
        IF l_types.COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Record ' || p_record || ' does not exist in this database');
        END IF;

        BEGIN
            l_el := JSON_ELEMENT_T.parse(p_json);
        EXCEPTION WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, p_record || ': not valid JSON');
        END;
        IF NOT l_el.is_array THEN
            RAISE_APPLICATION_ERROR(-20001, p_record || ': expected a JSON array of row objects');
        END IF;
        l_arr := TREAT(l_el AS JSON_ARRAY_T);
        IF l_arr.get_size = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, p_record || ': the array is empty');
        ELSIF l_arr.get_size > c_max_rows THEN
            RAISE_APPLICATION_ERROR(-20001, p_record || ': more than ' || c_max_rows || ' rows in one call');
        END IF;

        FOR i IN 0 .. l_arr.get_size - 1 LOOP
            IF NOT l_arr.get(i).is_object THEN
                RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': expected a JSON object');
            END IF;
            l_obj  := TREAT(l_arr.get(i) AS JSON_OBJECT_T);
            l_keys := l_obj.get_keys;
            IF l_keys.COUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': no columns given');
            END IF;
            l_cols := NULL; l_vals := NULL;
            FOR k IN 1 .. l_keys.COUNT LOOP
                l_col := UPPER(l_keys(k));
                IF NOT l_types.EXISTS(l_col) THEN
                    RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': ' || SUBSTR(l_keys(k), 1, 60)
                                                    || ' is not a column of this record (ps_describe_staging_table lists them)');
                END IF;
                l_cols := l_cols || CASE WHEN k > 1 THEN ',' END || '"' || l_col || '"';   -- l_col is a dictionary name
                l_vals := l_vals || CASE WHEN k > 1 THEN ',' END || ':b' || k;
            END LOOP;
            l_sql := 'INSERT INTO sysadm."' || l_table || '" (' || l_cols || ') VALUES (' || l_vals || ')';
            l_cur := DBMS_SQL.OPEN_CURSOR;
            BEGIN
                DBMS_SQL.PARSE(l_cur, l_sql, DBMS_SQL.NATIVE);
                FOR k IN 1 .. l_keys.COUNT LOOP
                    l_col := UPPER(l_keys(k));
                    l_el  := l_obj.get(l_keys(k));
                    IF l_el.is_null THEN
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, CAST(NULL AS VARCHAR2));
                    ELSIF l_types(l_col) = 'NUMBER' THEN
                        IF NOT l_el.is_number THEN
                            RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': ' || l_col || ' needs a JSON number');
                        END IF;
                        l_n := l_el.to_number;
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, l_n);
                    ELSIF l_types(l_col) = 'DATE' THEN
                        IF NOT l_el.is_string THEN
                            RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': ' || l_col || ' needs a date string "YYYY-MM-DD"');
                        END IF;
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, TO_DATE(SUBSTR(l_obj.get_string(l_keys(k)), 1, 10), 'YYYY-MM-DD'));
                    ELSIF l_types(l_col) LIKE 'TIMESTAMP%' THEN
                        IF NOT l_el.is_string THEN
                            RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': ' || l_col || ' needs a string "YYYY-MM-DDTHH24:MI:SS" (fractional seconds and a time zone suffix are ignored)');
                        END IF;
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, TO_TIMESTAMP(SUBSTR(l_obj.get_string(l_keys(k)), 1, 19), 'YYYY-MM-DD"T"HH24:MI:SS'));
                    ELSIF l_el.is_string THEN
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, l_obj.get_string(l_keys(k)));   -- get_string: without the JSON quotes
                    ELSE
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, l_el.to_string);               -- a number or true/false as text
                    END IF;
                END LOOP;
                l_dummy := DBMS_SQL.EXECUTE(l_cur);
                DBMS_SQL.CLOSE_CURSOR(l_cur);
            EXCEPTION
                WHEN OTHERS THEN
                    IF DBMS_SQL.IS_OPEN(l_cur) THEN DBMS_SQL.CLOSE_CURSOR(l_cur); END IF;
                    IF SQLCODE = -20001 THEN RAISE; END IF;
                    RAISE_APPLICATION_ERROR(-20001, p_record || ' row ' || (i + 1) || ': ' || SUBSTR(SQLERRM, 1, 300));
            END;
        END LOOP;
        RETURN l_arr.get_size;
    END insert_rows;

    FUNCTION result_json(p_counts t_counts) RETURN VARCHAR2 IS
        l_rows JSON_OBJECT_T := JSON_OBJECT_T();
        l_res  JSON_OBJECT_T := JSON_OBJECT_T();
        l_name VARCHAR2(30) := p_counts.FIRST;
    BEGIN
        WHILE l_name IS NOT NULL LOOP
            l_rows.put(l_name, p_counts(l_name));
            l_name := p_counts.NEXT(l_name);
        END LOOP;
        l_res.put('STATUS', 'SUCCESS');
        l_res.put('ROWS', l_rows);
        RETURN l_res.to_string;
    END result_json;

    FUNCTION error_json(p_message VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN JSON_OBJECT('STATUS' VALUE 'ERROR', 'MESSAGE' VALUE SUBSTR(p_message, 1, 600));
    END error_json;

    FUNCTION stage_voucher(p_headers CLOB, p_lines CLOB, p_distribs CLOB, p_payments CLOB DEFAULT NULL) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts;
    BEGIN
        l_counts('VCHR_HDR_STG')  := insert_rows('VCHR_HDR_STG',  p_headers);
        l_counts('VCHR_LINE_STG') := insert_rows('VCHR_LINE_STG', p_lines);
        l_counts('VCHR_DIST_STG') := insert_rows('VCHR_DIST_STG', p_distribs);
        IF p_payments IS NOT NULL AND DBMS_LOB.GETLENGTH(p_payments) > 0 THEN
            l_counts('VCHR_PYMT_STG') := insert_rows('VCHR_PYMT_STG', p_payments);
        END IF;
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_voucher;

    FUNCTION stage_requisition(p_requests CLOB, p_comments CLOB DEFAULT NULL) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts;
    BEGIN
        l_counts('PO_REQLOAD_RQST') := insert_rows('PO_REQLOAD_RQST', p_requests);
        IF p_comments IS NOT NULL AND DBMS_LOB.GETLENGTH(p_comments) > 0 THEN
            l_counts('PO_REQLOAD_CMT') := insert_rows('PO_REQLOAD_CMT', p_comments);
        END IF;
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_requisition;

    FUNCTION stage_journal_entry(p_entries CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts;
    BEGIN
        l_counts('JGEN_ACCT_ENTRY') := insert_rows('JGEN_ACCT_ENTRY', p_entries);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_journal_entry;

END xx_ai_staging_pkg;
/

SHOW ERRORS PACKAGE BODY sysadm.xx_ai_staging_pkg

-- No GRANT EXECUTE to the Toolbox user here, on purpose: it lets the Toolbox user (and so the execute_sql tool, which
-- can call any function the Toolbox user may execute) write to the staging tables. Grant it only when the ps_stage_*
-- tools are enabled: xx_ai_staging_pkg_grant.sql (xx_ai_staging_pkg_revoke.sql takes it away again).
