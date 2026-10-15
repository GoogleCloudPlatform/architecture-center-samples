SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

-- ============================================================================
-- ORACLE PEOPLESOFT FSCM 9.2 (EP92U055) — SYSADM.GE_PSFT_MCP_TOOLS PACKAGE
-- Provides session initialization, inventory reservation/onhand, and AP voucher
-- staging operations with autonomous audit logging in SYSADM.GGLTOOLBOX$MCP_LOG.
-- ============================================================================

DECLARE
  v_seq_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_seq_exists
    FROM ALL_SEQUENCES
   WHERE SEQUENCE_OWNER = 'SYSADM'
     AND SEQUENCE_NAME = 'PS_GOV_VCHR_SEQ';
  IF v_seq_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SYSADM.PS_GOV_VCHR_SEQ START WITH 100001 INCREMENT BY 1 NOCACHE';
  END IF;
END;
/

CREATE OR REPLACE PACKAGE SYSADM.GE_PSFT_MCP_TOOLS AS

  FUNCTION ps_initialize_context (
    p_email_or_oprid   IN VARCHAR2,
    p_business_unit    IN VARCHAR2 DEFAULT 'US001',
    p_role_name        IN VARCHAR2 DEFAULT 'PeopleSoft Administrator',
    p_setid            IN VARCHAR2 DEFAULT 'SHARE'
  ) RETURN VARCHAR2;

  FUNCTION reserve_item (
    p_item             IN VARCHAR2,
    p_quantity         IN NUMBER DEFAULT 1,
    p_location         IN VARCHAR2 DEFAULT 'US001',
    p_storage_area     IN VARCHAR2 DEFAULT 'AREA1'
  ) RETURN VARCHAR2;

  FUNCTION delete_reservation (
    p_reservation_id   IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION create_onhand (
    p_item             IN VARCHAR2,
    p_quantity         IN NUMBER DEFAULT 1,
    p_location         IN VARCHAR2 DEFAULT 'US001',
    p_storage_area     IN VARCHAR2 DEFAULT 'AREA1'
  ) RETURN VARCHAR2;

  FUNCTION create_ap_voucher (
    p_vendor_id        IN VARCHAR2,
    p_invoice_num      IN VARCHAR2,
    p_amount           IN VARCHAR2,
    p_business_unit    IN VARCHAR2 DEFAULT 'US001',
    p_description      IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

END GE_PSFT_MCP_TOOLS;
/

CREATE OR REPLACE PACKAGE BODY SYSADM.GE_PSFT_MCP_TOOLS AS

  PROCEDURE write_log (
    p_level   IN VARCHAR2,
    p_unit    IN VARCHAR2,
    p_user    IN VARCHAR2,
    p_message IN CLOB
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO SYSADM.GGLTOOLBOX$MCP_LOG (
      MCP_CLIENT, LOG_LEVEL, PROGRAM_UNIT, USERNAME, LOG_MESSAGE
    ) VALUES (
      'MCP_TOOLBOX_PEOPLESOFT', p_level, p_unit, NVL(p_user, USER), p_message
    );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END write_log;

  FUNCTION ps_initialize_context (
    p_email_or_oprid   IN VARCHAR2,
    p_business_unit    IN VARCHAR2 DEFAULT 'US001',
    p_role_name        IN VARCHAR2 DEFAULT 'PeopleSoft Administrator',
    p_setid            IN VARCHAR2 DEFAULT 'SHARE'
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_oprid       VARCHAR2(30);
    v_oprdesc     VARCHAR2(120);
    v_emplid      VARCHAR2(20);
    v_email       VARCHAR2(120);
    v_bu          VARCHAR2(10) := NVL(TRIM(p_business_unit), 'US001');
    v_setid       VARCHAR2(10) := NVL(TRIM(p_setid), 'SHARE');
    v_role        VARCHAR2(60) := NVL(TRIM(p_role_name), 'PeopleSoft Administrator');
    v_result      VARCHAR2(1000);
  BEGIN
    IF v_bu IS NULL OR UPPER(v_bu) = 'NULL' THEN v_bu := 'US001'; END IF;
    IF v_setid IS NULL OR UPPER(v_setid) = 'NULL' THEN v_setid := 'SHARE'; END IF;
    IF v_role IS NULL OR UPPER(v_role) = 'NULL' THEN v_role := 'PeopleSoft Administrator'; END IF;

    BEGIN
      SELECT OPRID, OPRDEFNDESC, EMPLID, EMAILID
        INTO v_oprid, v_oprdesc, v_emplid, v_email
        FROM SYSADM.PSOPRDEFN
       WHERE UPPER(EMAILID) = UPPER(TRIM(p_email_or_oprid))
          OR UPPER(OPRID) = UPPER(TRIM(p_email_or_oprid))
        ORDER BY CASE WHEN OPRID = 'VP1' THEN 0 ELSE 1 END
       FETCH FIRST 1 ROWS ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'Unauthorized or unmapped PeopleSoft operator: ' || p_email_or_oprid);
    END;

    FOR r_key IN (
      SELECT DISTINCT column_value AS session_key
        FROM TABLE(SYS.ODCIVARCHAR2LIST(
               NVL(TO_CHAR(SYS_CONTEXT('USERENV', 'SESSIONID')), 'ACTIVE_SESSION'),
               'ACTIVE_SESSION'
             ))
    ) LOOP
      MERGE INTO SYSADM.PS_GOV_MCP_SESSION_CTX t
      USING (SELECT r_key.session_key AS SESSION_KEY FROM DUAL) s
         ON (t.SESSION_KEY = s.SESSION_KEY)
       WHEN MATCHED THEN
         UPDATE SET OPRID = v_oprid,
                    OPRDEFNDESC = v_oprdesc,
                    EMAILID = v_email,
                    EMPLID = v_emplid,
                    BUSINESS_UNIT = v_bu,
                    SETID = v_setid,
                    ROLENAME = v_role,
                    INITIALIZED_DTTM = CURRENT_TIMESTAMP
       WHEN NOT MATCHED THEN
         INSERT (SESSION_KEY, OPRID, OPRDEFNDESC, EMAILID, EMPLID, BUSINESS_UNIT, SETID, ROLENAME, INITIALIZED_DTTM)
         VALUES (s.SESSION_KEY, v_oprid, v_oprdesc, v_email, v_emplid, v_bu, v_setid, v_role, CURRENT_TIMESTAMP);
    END LOOP;

    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(v_oprid || ':' || v_bu || ':' || v_setid);
    COMMIT;

    v_result := 'SUCCESS: Initialized PeopleSoft 9.2 session context for OPRID=' || v_oprid ||
                ' (' || v_oprdesc || ', EMPLID=' || v_emplid || ', EMAIL=' || v_email ||
                '), BUSINESS_UNIT=' || v_bu || ', SETID=' || v_setid || ', ROLE=' || v_role;
    write_log('INFO', 'ps_initialize_context', v_oprid, v_result);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in ps_initialize_context: ' || SQLERRM;
      write_log('ERROR', 'ps_initialize_context', p_email_or_oprid, v_result);
      RETURN v_result;
  END ps_initialize_context;

  FUNCTION reserve_item (
    p_item             IN VARCHAR2,
    p_quantity         IN NUMBER DEFAULT 1,
    p_location         IN VARCHAR2 DEFAULT 'US001',
    p_storage_area     IN VARCHAR2 DEFAULT 'AREA1'
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_res_id NUMBER;
    v_bu     VARCHAR2(10) := CASE WHEN TRIM(p_location) IS NULL OR UPPER(TRIM(p_location)) IN ('', 'NULL', 'S1', 'M1') THEN 'US001' ELSE SUBSTR(TRIM(p_location), 1, 5) END;
    v_area   VARCHAR2(20) := NVL(TRIM(p_storage_area), 'AREA1');
    v_qty    NUMBER := NVL(p_quantity, 1);
    v_result VARCHAR2(1000);
  BEGIN
    IF TRIM(p_item) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'Item ID cannot be empty.');
    END IF;

    IF v_qty <= 0 THEN
      RAISE_APPLICATION_ERROR(-20007, 'Reservation quantity must be greater than zero.');
    END IF;

    INSERT INTO SYSADM.PS_GOV_INV_RESERVATIONS (
      BUSINESS_UNIT, INV_ITEM_ID, STORAGE_AREA, QTY_RESERVED, OPRID, STATUS
    ) VALUES (
      v_bu, TRIM(p_item), v_area, v_qty, 'VP1', 'ACTIVE'
    ) RETURNING RESERVATION_ID INTO v_res_id;

    UPDATE SYSADM.PS_GOV_INV_BALANCES
       SET QTY_RESERVED = NVL(QTY_RESERVED, 0) + v_qty,
           QTY_AVAILABLE = NVL(QTY_AVAILABLE, 0) - v_qty,
           LAST_UPDATED_DTTM = SYSTIMESTAMP
     WHERE BUSINESS_UNIT = v_bu
       AND INV_ITEM_ID = TRIM(p_item)
       AND STORAGE_AREA = v_area
       AND NVL(QTY_AVAILABLE, 0) >= v_qty;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock or item ' || TRIM(p_item) || ' not found in PS_GOV_INV_BALANCES for Business Unit ' || v_bu);
    END IF;

    COMMIT;
    v_result := 'SUCCESS: Created PeopleSoft Inventory Reservation ID ' || v_res_id ||
                ' for item ' || TRIM(p_item) || ' (Quantity: ' || v_qty ||
                ', Business Unit: ' || v_bu || ', Storage Area: ' || v_area || ')';
    write_log('INFO', 'reserve_item', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in reserve_item: ' || SQLERRM;
      write_log('ERROR', 'reserve_item', 'VP1', v_result);
      RETURN v_result;
  END reserve_item;

  FUNCTION delete_reservation (
    p_reservation_id   IN VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_id     NUMBER := TO_NUMBER(REGEXP_REPLACE(p_reservation_id, '[^0-9]', ''));
    v_item   VARCHAR2(40);
    v_bu     VARCHAR2(10);
    v_area   VARCHAR2(20);
    v_qty    NUMBER;
    v_result VARCHAR2(1000);
  BEGIN
    IF v_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20008, 'Invalid reservation ID: ' || p_reservation_id);
    END IF;

    SELECT INV_ITEM_ID, BUSINESS_UNIT, NVL(STORAGE_AREA, 'AREA1'), QTY_RESERVED
      INTO v_item, v_bu, v_area, v_qty
      FROM SYSADM.PS_GOV_INV_RESERVATIONS
     WHERE RESERVATION_ID = v_id
       AND STATUS = 'ACTIVE'
       FOR UPDATE;

    UPDATE SYSADM.PS_GOV_INV_RESERVATIONS
       SET STATUS = 'CANCELLED'
     WHERE RESERVATION_ID = v_id
       AND STATUS = 'ACTIVE';

    UPDATE SYSADM.PS_GOV_INV_BALANCES
       SET QTY_AVAILABLE = NVL(QTY_AVAILABLE, 0) + LEAST(NVL(QTY_RESERVED, 0), NVL(v_qty, 0)),
           QTY_RESERVED = GREATEST(0, NVL(QTY_RESERVED, 0) - NVL(v_qty, 0)),
           LAST_UPDATED_DTTM = SYSTIMESTAMP
     WHERE BUSINESS_UNIT = v_bu
       AND INV_ITEM_ID = v_item
       AND STORAGE_AREA = v_area;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20009, 'Inventory balance row not found in PS_GOV_INV_BALANCES for Business Unit ' || v_bu || ' and Item ' || v_item);
    END IF;

    COMMIT;
    v_result := 'SUCCESS: Deleted/Cancelled PeopleSoft Inventory Reservation ID ' || v_id ||
                ' (Item: ' || v_item || ', Released Qty: ' || v_qty || ', Business Unit: ' || v_bu || ')';
    write_log('INFO', 'delete_reservation', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      v_result := 'SUCCESS: Reservation ID ' || p_reservation_id || ' already cleared or not found.';
      write_log('INFO', 'delete_reservation', 'VP1', v_result);
      RETURN v_result;
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in delete_reservation: ' || SQLERRM;
      write_log('ERROR', 'delete_reservation', 'VP1', v_result);
      RETURN v_result;
  END delete_reservation;

  FUNCTION create_onhand (
    p_item             IN VARCHAR2,
    p_quantity         IN NUMBER DEFAULT 1,
    p_location         IN VARCHAR2 DEFAULT 'US001',
    p_storage_area     IN VARCHAR2 DEFAULT 'AREA1'
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_bu     VARCHAR2(10) := CASE WHEN TRIM(p_location) IS NULL OR UPPER(TRIM(p_location)) IN ('', 'NULL', 'S1', 'M1') THEN 'US001' ELSE SUBSTR(TRIM(p_location), 1, 5) END;
    v_area   VARCHAR2(20) := NVL(TRIM(p_storage_area), 'AREA1');
    v_qty    NUMBER := NVL(p_quantity, 1);
    v_cnt    NUMBER;
    v_result VARCHAR2(1000);
  BEGIN
    IF TRIM(p_item) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'Item ID cannot be empty.');
    END IF;

    IF v_qty <= 0 THEN
      RAISE_APPLICATION_ERROR(-20007, 'On-hand quantity must be greater than zero.');
    END IF;

    BEGIN
      INSERT INTO SYSADM.PS_GOV_INV_BALANCES (
        BUSINESS_UNIT, INV_ITEM_ID, STORAGE_AREA, QTY_ONHAND, QTY_RESERVED, QTY_AVAILABLE, LAST_UPDATED_DTTM
      ) VALUES (
        v_bu, TRIM(p_item), v_area, v_qty, 0, v_qty, SYSTIMESTAMP
      );
      v_cnt := 1;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        UPDATE SYSADM.PS_GOV_INV_BALANCES
           SET QTY_ONHAND = NVL(QTY_ONHAND, 0) + v_qty,
               QTY_AVAILABLE = NVL(QTY_AVAILABLE, 0) + v_qty,
               LAST_UPDATED_DTTM = SYSTIMESTAMP
         WHERE BUSINESS_UNIT = v_bu
           AND INV_ITEM_ID = TRIM(p_item)
           AND STORAGE_AREA = v_area;
        v_cnt := SQL%ROWCOUNT;
    END;
    COMMIT;
    v_result := 'SUCCESS: Added ' || v_qty || ' on-hand quantity for item ' ||
                TRIM(p_item) || ' in PeopleSoft Business Unit ' || v_bu ||
                ' (Rows updated in PS_GOV_INV_BALANCES: ' || v_cnt || ')';
    write_log('INFO', 'create_onhand', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in create_onhand: ' || SQLERRM;
      write_log('ERROR', 'create_onhand', 'VP1', v_result);
      RETURN v_result;
  END create_onhand;

  PROCEDURE stage_voucher_table (
    p_table_name IN VARCHAR2,
    p_bu         IN VARCHAR2,
    p_vchr_id    IN VARCHAR2,
    p_inv_id     IN VARCHAR2,
    p_vendor     IN VARCHAR2,
    p_amt        IN NUMBER,
    p_descr30    IN VARCHAR2,
    p_descr254   IN VARCHAR2
  ) IS
    v_cols CLOB := '';
    v_vals CLOB := '';
    v_sql  CLOB;
    v_expr VARCHAR2(200);
    v_sep  VARCHAR2(2) := '';
  BEGIN
    IF p_table_name NOT IN ('PS_VCHR_HDR_STG', 'PS_VCHR_LINE_STG', 'PS_VCHR_DIST_STG') THEN
      RAISE_APPLICATION_ERROR(-20004, 'Unsupported staging table: ' || p_table_name);
    END IF;

    FOR r_col IN (
      SELECT COLUMN_NAME, DATA_TYPE
        FROM ALL_TAB_COLUMNS
       WHERE OWNER = 'SYSADM'
         AND TABLE_NAME = p_table_name
         AND NULLABLE = 'N'
       ORDER BY COLUMN_ID
    ) LOOP
      CASE r_col.COLUMN_NAME
        WHEN 'BUSINESS_UNIT'    THEN v_expr := 'p.b_bu';
        WHEN 'BUSINESS_UNIT_GL' THEN v_expr := 'p.b_bu';
        WHEN 'VCHR_BLD_KEY_C1'  THEN v_expr := 'p.b_vchr_id';
        WHEN 'VOUCHER_ID'       THEN v_expr := 'p.b_vchr_id';
        WHEN 'VOUCHER_STYLE'    THEN v_expr := '''REG''';
        WHEN 'INVOICE_ID'       THEN v_expr := 'p.b_inv_id';
        WHEN 'INVOICE_DT'       THEN v_expr := 'TRUNC(SYSDATE)';
        WHEN 'ACCOUNTING_DT'    THEN v_expr := 'TRUNC(SYSDATE)';
        WHEN 'ENTERED_DT'       THEN v_expr := 'TRUNC(SYSDATE)';
        WHEN 'VENDOR_SETID'     THEN v_expr := '''SHARE''';
        WHEN 'VENDOR_ID'        THEN v_expr := 'p.b_vendor';
        WHEN 'VNDR_LOC'         THEN v_expr := '''0000000001''';
        WHEN 'ADDRESS_SEQ_NUM'  THEN v_expr := '1';
        WHEN 'ORIGIN'           THEN v_expr := '''ONL''';
        WHEN 'OPRID'            THEN v_expr := '''VP1''';
        WHEN 'GROSS_AMT'        THEN v_expr := 'p.b_amt';
        WHEN 'MERCHANDISE_AMT'  THEN v_expr := 'p.b_amt';
        WHEN 'UNIT_PRICE'       THEN v_expr := 'p.b_amt';
        WHEN 'QTY_VCHR'         THEN v_expr := '1';
        WHEN 'VOUCHER_LINE_NUM' THEN v_expr := '1';
        WHEN 'DISTRIB_LINE_NUM' THEN v_expr := '1';
        WHEN 'ACCOUNT'          THEN v_expr := '''600000''';
        WHEN 'PYMNT_TERMS_CD'   THEN v_expr := '''NET30''';
        WHEN 'TXN_CURRENCY_CD'  THEN v_expr := '''USD''';
        WHEN 'BASE_CURRENCY'    THEN v_expr := '''USD''';
        WHEN 'VCHR_SRC'         THEN v_expr := '''ONL''';
        WHEN 'DESCR'            THEN v_expr := 'p.b_descr30';
        WHEN 'DESCR254_MIXED'   THEN v_expr := 'p.b_descr254';
        ELSE
          IF r_col.DATA_TYPE IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR') THEN
            v_expr := ''' ''';
          ELSIF r_col.DATA_TYPE IN ('NUMBER', 'FLOAT', 'BINARY_FLOAT', 'BINARY_DOUBLE') THEN
            v_expr := '0';
          ELSIF r_col.DATA_TYPE = 'DATE' THEN
            v_expr := 'TRUNC(SYSDATE)';
          ELSIF r_col.DATA_TYPE LIKE 'TIMESTAMP%' THEN
            v_expr := 'SYSTIMESTAMP';
          ELSE
            v_expr := ''' ''';
          END IF;
      END CASE;

      v_cols := v_cols || v_sep || r_col.COLUMN_NAME;
      v_vals := v_vals || v_sep || v_expr;
      v_sep  := ', ';
    END LOOP;

    IF v_cols IS NULL OR DBMS_LOB.GETLENGTH(v_cols) = 0 THEN
      RAISE_APPLICATION_ERROR(-20005, 'Table SYSADM.' || p_table_name || ' not found in ALL_TAB_COLUMNS.');
    END IF;

    v_sql := 'INSERT INTO SYSADM.' || p_table_name || ' (' || v_cols || ') ' ||
             'SELECT ' || v_vals || ' FROM (' ||
             'SELECT :1 AS b_bu, :2 AS b_vchr_id, :3 AS b_inv_id, :4 AS b_vendor, ' ||
             ':5 AS b_amt, :6 AS b_descr30, :7 AS b_descr254 FROM DUAL) p';

    EXECUTE IMMEDIATE v_sql
      USING p_bu, p_vchr_id, p_inv_id, p_vendor, p_amt, p_descr30, p_descr254;
  END stage_voucher_table;

  FUNCTION create_ap_voucher (
    p_vendor_id        IN VARCHAR2,
    p_invoice_num      IN VARCHAR2,
    p_amount           IN VARCHAR2,
    p_business_unit    IN VARCHAR2 DEFAULT 'US001',
    p_description      IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_bu        VARCHAR2(5) := CASE WHEN TRIM(p_business_unit) IS NULL OR UPPER(TRIM(p_business_unit)) IN ('', 'NULL') THEN 'US001' ELSE SUBSTR(TRIM(p_business_unit), 1, 5) END;
    v_vchr_id   VARCHAR2(8);
    v_amt_str   VARCHAR2(100) := TRIM(p_amount);
    v_is_neg    BOOLEAN := FALSE;
    v_amt       NUMBER;
    v_vendor    VARCHAR2(10) := LPAD(SUBSTR(NVL(TRIM(p_vendor_id), 'USA0000002'), 1, 10), 10, '0');
    v_inv_id    VARCHAR2(30);
    v_descr30   VARCHAR2(30);
    v_descr254  VARCHAR2(254);
    v_result    VARCHAR2(1000);
  BEGIN
    IF v_amt_str LIKE '(%)' THEN
      v_is_neg := TRUE;
      v_amt_str := SUBSTR(v_amt_str, 2, LENGTH(v_amt_str) - 2);
    ELSIF v_amt_str LIKE '%-' THEN
      v_is_neg := TRUE;
      v_amt_str := SUBSTR(v_amt_str, 1, LENGTH(v_amt_str) - 1);
    END IF;
    v_amt := TO_NUMBER(REGEXP_REPLACE(v_amt_str, '[^0-9.-]', ''));
    IF v_is_neg THEN
      v_amt := -v_amt;
    END IF;
    IF TRIM(p_invoice_num) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20003, 'Invoice number cannot be empty.');
    END IF;
    IF v_amt IS NULL OR v_amt = 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Invalid voucher amount: ' || p_amount);
    END IF;
    -- Generate unique concurrency-safe 8-char VOUCHER_ID ('GV' + 6 digits) via Oracle Sequence
    v_vchr_id := 'GV' || LPAD(TO_CHAR(MOD(SYSADM.PS_GOV_VCHR_SEQ.NEXTVAL, 1000000)), 6, '0');

    IF SUBSTR(TRIM(p_vendor_id), 1, 3) = 'USA' OR SUBSTR(TRIM(p_vendor_id), 1, 3) = 'SCM' THEN
      v_vendor := SUBSTR(TRIM(p_vendor_id), 1, 10);
    END IF;

    v_inv_id   := SUBSTR(TRIM(p_invoice_num), 1, 30);
    v_descr30  := SUBSTR(NVL(p_description, 'Staged line'), 1, 30);
    v_descr254 := SUBSTR(NVL(p_description, 'Staged via Gemini Enterprise PeopleSoft MCP Tool create_ap_voucher'), 1, 254);

    -- Stage voucher header, line, and distribution in PeopleSoft Voucher Build staging tables
    -- by populating all required NOT NULL columns without modifying delivered table DDL.
    stage_voucher_table('PS_VCHR_HDR_STG',  v_bu, v_vchr_id, v_inv_id, v_vendor, v_amt, v_descr30, v_descr254);
    stage_voucher_table('PS_VCHR_LINE_STG', v_bu, v_vchr_id, v_inv_id, v_vendor, v_amt, v_descr30, v_descr254);
    stage_voucher_table('PS_VCHR_DIST_STG', v_bu, v_vchr_id, v_inv_id, v_vendor, v_amt, v_descr30, v_descr254);

    COMMIT;

    v_result := 'SUCCESS: Staged PeopleSoft AP Voucher VOUCHER_ID=' || v_vchr_id ||
                ' in PS_VCHR_HDR_STG (BUSINESS_UNIT=' || v_bu || ', INVOICE_ID=' || SUBSTR(TRIM(p_invoice_num), 1, 30) ||
                ', VENDOR_ID=' || v_vendor || ', GROSS_AMT=$' || TO_CHAR(v_amt, 'FM999,999,990.00') || ')';
    write_log('INFO', 'create_ap_voucher', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in create_ap_voucher: ' || SQLERRM;
      write_log('ERROR', 'create_ap_voucher', 'VP1', v_result);
      RETURN v_result;
  END create_ap_voucher;

END GE_PSFT_MCP_TOOLS;
/

GRANT EXECUTE ON SYSADM.GE_PSFT_MCP_TOOLS TO PSFT_AI;

SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
  FROM ALL_OBJECTS
 WHERE OWNER = 'SYSADM'
   AND OBJECT_NAME = 'GE_PSFT_MCP_TOOLS';

EXIT;
