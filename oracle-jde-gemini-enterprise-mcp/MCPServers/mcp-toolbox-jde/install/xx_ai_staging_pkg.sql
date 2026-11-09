-- =============================================================================
-- xx_ai_staging_pkg: stage transactions in JD Edwards' batch interface tables (Z-files)
-- =============================================================================
--
-- Run in SQL*Plus or SQLcl as a DBA (recommended: JDE_AI then needs no login and no system privilege) or as JDE_AI,
-- after jde_ai_staging_grants.sql. Edit mcp-toolbox-jde/install/jde_install_config.sql first (jde_data_schema = the schema that holds the Z-files).
--
-- JD Edwards has no PL/SQL business API: its rules live in business functions and batch programs (UBEs), and
-- Oracle's documentation says not to bypass them ("if you attempt to update F0411 or F0911 without using the
-- batch process and the Z files, you might compromise your voucher information"). What it documents for loading
-- transactions from outside are the batch interface tables (Z-files) that a batch processor edits and turns into
-- the real transaction:
--   journal entries  F0911Z1                -> Journal Entries Batch Processor (R09110Z)
--   vouchers         F0411Z1 + F0911Z1      -> Voucher Transactions - Batch Processor (R04110Z / R04110ZA)
--   sales orders     F4201Z1 + F4211Z1      -> Sales Order batch processing (see Oracle's Sales Order Batch Import Programs)
--   purchase orders  F4301Z1 + F4311Z1      -> Purchase Order batch processing
--   address book     F0101Z2                -> Address Book batch processing
-- This package inserts rows into exactly those seven tables, nothing else. It does NOT run the batch processor:
-- someone (a scheduled UBE, an operator) does, and ps/jde tools show the result: jde_list_staged_transactions
-- (processed and error flags per row) and jde_get_batch_status (F0011 batch control).
--
-- Column lists are not hardcoded. Every row is a JSON object {"COLUMN":value,...}; a key is accepted only if it is a
-- column of that table in the data dictionary, values are bound. Layouts were read from a real E1 9.2 database
-- (mcp-toolbox-jde/stub/staging_schema.sql is a snapshot); jde_describe_staging_table lists the live ones. JDE conventions:
--   amounts          NUMBER with implied decimals (12345 = 123.45 for 2 decimals), also unit costs (/10000)
--   dates            NUMBER, Julian CYYDDD (126285 = 12 Oct 2026); a JSON number
--   text columns     JSON strings (NCHAR); a number is converted to text; null is allowed
-- The package adds or checks two things the caller cannot decide:
--   * the EDI user (column ...EDUS) is the verified JDE user of this session (jde_ai.xx_ai_security_pkg.get_jde_user);
--     it is filled in when missing and a different value is refused, so a caller can only stage under its own user
--   * the system-controlled flags ...EDSP (processed) and ...EDER (error) cannot be set; the batch processor owns them
-- All rows of a call go in together or not at all: any error rolls the whole call back.
-- At most 500 rows per table and call. Every function returns JSON and never raises:
--   {"STATUS":"SUCCESS","ROWS":{"F0411Z1":1,"F0911Z1":2}}  or  {"STATUS":"ERROR","MESSAGE":"..."}
--
-- Needs the JDE security wrapper (mcp-toolbox-jde/templates/plsql_wrapper.sql), which identifies the user. The Toolbox user
-- itself only gets EXECUTE on this package, never INSERT on the tables.
-- Remove with xx_ai_staging_pkg_uninstall.sql.
-- =============================================================================

WHENEVER SQLERROR EXIT FAILURE
@@jde_install_config.sql

-- The package must be JDE_AI.XX_AI_STAGING_PKG: the wrapper and the tools call it by that name, and it reads
-- jde_ai.xx_ai_security_pkg without a grant. Created in another schema it would compile with
-- "PLS-00904: insufficient privilege to access object JDE_AI.XX_AI_SECURITY_PKG". So the script always creates it
-- in JDE_AI: connected as a DBA (SYSTEM, needs CREATE ANY PROCEDURE) it installs into JDE_AI without JDE_AI having
-- to log in or to hold any system privilege (see jde_ai_lock_owner.sql); connected as JDE_AI it changes nothing.
ALTER SESSION SET CURRENT_SCHEMA = JDE_AI;

CREATE OR REPLACE PACKAGE xx_ai_staging_pkg AUTHID DEFINER AS
    -- Journal entry lines (F0911Z1), a JSON array of row objects.
    FUNCTION stage_journal_entry(p_lines CLOB) RETURN VARCHAR2;
    -- Voucher: header rows (F0411Z1) and their G/L distribution lines (F0911Z1).
    FUNCTION stage_voucher(p_headers CLOB, p_gl_lines CLOB) RETURN VARCHAR2;
    -- Sales order: header rows (F4201Z1) and detail lines (F4211Z1).
    FUNCTION stage_sales_order(p_headers CLOB, p_details CLOB) RETURN VARCHAR2;
    -- Purchase order: header rows (F4301Z1) and detail lines (F4311Z1).
    FUNCTION stage_purchase_order(p_headers CLOB, p_details CLOB) RETURN VARCHAR2;
    -- Address book records (F0101Z2).
    FUNCTION stage_address_book(p_rows CLOB) RETURN VARCHAR2;
END xx_ai_staging_pkg;
/

CREATE OR REPLACE PACKAGE BODY xx_ai_staging_pkg AS

    c_owner    CONSTANT VARCHAR2(30) := UPPER('&&jde_data_schema');
    c_max_rows CONSTANT PLS_INTEGER := 500;

    TYPE t_counts IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);

    -- Insert every object of the JSON array p_json into table p_table of the data schema; returns the row count.
    -- Raises -20001 with a readable message on bad input or a database error.
    FUNCTION insert_rows(p_table VARCHAR2, p_json CLOB, p_user VARCHAR2) RETURN PLS_INTEGER IS
        TYPE t_types IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(128);
        l_types    t_types;
        l_arr      JSON_ARRAY_T;
        l_obj      JSON_OBJECT_T;
        l_el       JSON_ELEMENT_T;
        l_keys     JSON_KEY_LIST;
        l_cur      INTEGER;
        l_cols     VARCHAR2(32767);
        l_vals     VARCHAR2(32767);
        l_sql      VARCHAR2(32767);
        l_col      VARCHAR2(128);
        l_edus     VARCHAR2(128);
        l_given    BOOLEAN;
        l_n        NUMBER;
        l_dummy    INTEGER;
        l_idx      PLS_INTEGER;
        l_names    DBMS_SQL.VARCHAR2_TABLE;   -- dictionary column names of the current row, in bind order
        l_orig     DBMS_SQL.VARCHAR2_TABLE;   -- the key as written in the JSON (NULL for the EDI user added by this package)
    BEGIN
        FOR c IN (SELECT column_name, data_type FROM all_tab_columns
                   WHERE owner = c_owner AND table_name = p_table) LOOP
            l_types(c.column_name) := c.data_type;
            IF c.column_name LIKE '%EDUS' THEN l_edus := c.column_name; END IF;
        END LOOP;
        IF l_types.COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Table ' || p_table || ' does not exist in ' || c_owner);
        END IF;

        BEGIN
            l_el := JSON_ELEMENT_T.parse(p_json);
        EXCEPTION WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, p_table || ': not valid JSON');
        END;
        IF NOT l_el.is_array THEN
            RAISE_APPLICATION_ERROR(-20001, p_table || ': expected a JSON array of row objects');
        END IF;
        l_arr := TREAT(l_el AS JSON_ARRAY_T);
        IF l_arr.get_size = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, p_table || ': the array is empty');
        ELSIF l_arr.get_size > c_max_rows THEN
            RAISE_APPLICATION_ERROR(-20001, p_table || ': more than ' || c_max_rows || ' rows in one call');
        END IF;

        FOR i IN 0 .. l_arr.get_size - 1 LOOP
            IF NOT l_arr.get(i).is_object THEN
                RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': expected a JSON object');
            END IF;
            l_obj  := TREAT(l_arr.get(i) AS JSON_OBJECT_T);
            l_keys := l_obj.get_keys;
            l_cols := NULL; l_vals := NULL; l_names.DELETE; l_orig.DELETE; l_idx := 0; l_given := FALSE;

            FOR k IN 1 .. l_keys.COUNT LOOP
                l_col := UPPER(l_keys(k));
                IF NOT l_types.EXISTS(l_col) THEN
                    RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': ' || SUBSTR(l_keys(k), 1, 60)
                                                    || ' is not a column of this table (jde_describe_staging_table lists them)');
                END IF;
                IF l_col LIKE '%EDSP' OR l_col LIKE '%EDER' THEN
                    RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': ' || l_col
                                                    || ' is set by the batch processor and cannot be given');
                END IF;
                IF l_col = l_edus THEN
                    l_given := TRUE;
                    IF NOT l_obj.get(l_keys(k)).is_string
                       OR UPPER(TRIM(l_obj.get_string(l_keys(k)))) <> p_user THEN
                        RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': ' || l_col
                                                        || ' must be your own JDE user (' || p_user || ') or left out');
                    END IF;
                END IF;
                l_idx := l_idx + 1; l_names(l_idx) := l_col; l_orig(l_idx) := l_keys(k);
            END LOOP;
            IF NOT l_given AND l_edus IS NOT NULL THEN          -- the caller's own user is the EDI user of the row
                l_idx := l_idx + 1; l_names(l_idx) := l_edus; l_orig(l_idx) := NULL;
            END IF;
            IF l_idx = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': no columns given');
            END IF;

            FOR k IN 1 .. l_idx LOOP
                l_cols := l_cols || CASE WHEN k > 1 THEN ',' END || '"' || l_names(k) || '"';   -- dictionary names only
                l_vals := l_vals || CASE WHEN k > 1 THEN ',' END || ':b' || k;
            END LOOP;
            l_sql := 'INSERT INTO ' || c_owner || '."' || p_table || '" (' || l_cols || ') VALUES (' || l_vals || ')';
            l_cur := DBMS_SQL.OPEN_CURSOR;
            BEGIN
                DBMS_SQL.PARSE(l_cur, l_sql, DBMS_SQL.NATIVE);
                FOR k IN 1 .. l_idx LOOP
                    l_col := l_names(k);
                    IF l_orig(k) IS NULL THEN           -- the EDI user added by this package
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, p_user);
                        CONTINUE;
                    END IF;
                    l_el := l_obj.get(l_orig(k));
                    IF l_el.is_null THEN
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, CAST(NULL AS VARCHAR2));
                    ELSIF l_types(l_col) = 'NUMBER' THEN
                        IF NOT l_el.is_number THEN
                            RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': ' || l_col || ' needs a JSON number');
                        END IF;
                        l_n := l_el.to_number;
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, l_n);
                    ELSIF l_el.is_string THEN
                        DBMS_SQL.BIND_VARIABLE(l_cur, ':b' || k, l_obj.get_string(l_orig(k)));   -- get_string: without the JSON quotes
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
                    RAISE_APPLICATION_ERROR(-20001, p_table || ' row ' || (i + 1) || ': ' || SUBSTR(SQLERRM, 1, 300));
            END;
        END LOOP;
        RETURN l_arr.get_size;
    END insert_rows;

    FUNCTION current_user_id RETURN VARCHAR2 IS
        l_user VARCHAR2(30) := UPPER(TRIM(jde_ai.xx_ai_security_pkg.get_jde_user));
    BEGIN
        IF l_user IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'No authenticated JDE user in this session (the security wrapper has not run)');
        END IF;
        RETURN l_user;
    END current_user_id;

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

    FUNCTION stage_journal_entry(p_lines CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts; l_user VARCHAR2(30);
    BEGIN
        l_user := current_user_id;
        l_counts('F0911Z1') := insert_rows('F0911Z1', p_lines, l_user);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_journal_entry;

    FUNCTION stage_voucher(p_headers CLOB, p_gl_lines CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts; l_user VARCHAR2(30);
    BEGIN
        l_user := current_user_id;
        l_counts('F0411Z1') := insert_rows('F0411Z1', p_headers, l_user);
        l_counts('F0911Z1') := insert_rows('F0911Z1', p_gl_lines, l_user);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_voucher;

    FUNCTION stage_sales_order(p_headers CLOB, p_details CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts; l_user VARCHAR2(30);
    BEGIN
        l_user := current_user_id;
        l_counts('F4201Z1') := insert_rows('F4201Z1', p_headers, l_user);
        l_counts('F4211Z1') := insert_rows('F4211Z1', p_details, l_user);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_sales_order;

    FUNCTION stage_purchase_order(p_headers CLOB, p_details CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts; l_user VARCHAR2(30);
    BEGIN
        l_user := current_user_id;
        l_counts('F4301Z1') := insert_rows('F4301Z1', p_headers, l_user);
        l_counts('F4311Z1') := insert_rows('F4311Z1', p_details, l_user);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_purchase_order;

    FUNCTION stage_address_book(p_rows CLOB) RETURN VARCHAR2 IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_counts t_counts; l_user VARCHAR2(30);
    BEGIN
        l_user := current_user_id;
        l_counts('F0101Z2') := insert_rows('F0101Z2', p_rows, l_user);
        COMMIT;
        RETURN result_json(l_counts);
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        RETURN error_json(REPLACE(SQLERRM, 'ORA-20001: ', ''));
    END stage_address_book;

END xx_ai_staging_pkg;
/

SHOW ERRORS PACKAGE BODY xx_ai_staging_pkg

-- No GRANT EXECUTE to the Toolbox user here, on purpose: the grant lets the Toolbox user (and so the execute_sql tool,
-- which can call any function the Toolbox user may execute) write to the Z-files. Grant it only when the jde_stage_*
-- tools are enabled: xx_ai_staging_pkg_grant.sql (and xx_ai_staging_pkg_revoke.sql takes it away again).
