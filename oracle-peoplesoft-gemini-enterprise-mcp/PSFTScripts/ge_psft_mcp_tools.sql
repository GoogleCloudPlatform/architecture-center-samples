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
        SELECT OPRID, OPRDEFNDESC, EMPLID, EMAILID
          INTO v_oprid, v_oprdesc, v_emplid, v_email
          FROM SYSADM.PSOPRDEFN
         WHERE OPRID = 'VP1';
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
    v_result VARCHAR2(1000);
  BEGIN
    INSERT INTO SYSADM.PS_GOV_INV_RESERVATIONS (
      BUSINESS_UNIT, INV_ITEM_ID, STORAGE_AREA, QTY_RESERVED, OPRID, STATUS
    ) VALUES (
      v_bu, TRIM(p_item), NVL(TRIM(p_storage_area), 'AREA1'), NVL(p_quantity, 1), 'VP1', 'ACTIVE'
    ) RETURNING RESERVATION_ID INTO v_res_id;

    UPDATE SYSADM.PS_BU_ITEMS_INV
      SET QTY_RESERVED = QTY_RESERVED + NVL(p_quantity, 1),
          QTY_AVAILABLE = QTY_AVAILABLE - NVL(p_quantity, 1)
     WHERE BUSINESS_UNIT = v_bu
       AND INV_ITEM_ID = TRIM(p_item)
       AND QTY_AVAILABLE >= NVL(p_quantity, 1);

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock or item ' || TRIM(p_item) || ' not found in PS_BU_ITEMS_INV for Business Unit ' || v_bu);
    END IF;

    COMMIT;
    v_result := 'SUCCESS: Created PeopleSoft Inventory Reservation ID ' || v_res_id ||
                ' for item ' || TRIM(p_item) || ' (Quantity: ' || NVL(p_quantity, 1) ||
                ', Business Unit: ' || v_bu || ', Storage Area: ' || NVL(TRIM(p_storage_area), 'AREA1') || ')';
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
    v_qty    NUMBER;
    v_result VARCHAR2(1000);
  BEGIN
    SELECT INV_ITEM_ID, BUSINESS_UNIT, QTY_RESERVED
      INTO v_item, v_bu, v_qty
      FROM SYSADM.PS_GOV_INV_RESERVATIONS
     WHERE RESERVATION_ID = v_id
       AND STATUS = 'ACTIVE';

    UPDATE SYSADM.PS_GOV_INV_RESERVATIONS
       SET STATUS = 'CANCELLED'
     WHERE RESERVATION_ID = v_id
       AND STATUS = 'ACTIVE';

    UPDATE SYSADM.PS_BU_ITEMS_INV
       SET QTY_RESERVED = GREATEST(0, QTY_RESERVED - v_qty),
           QTY_AVAILABLE = QTY_AVAILABLE + v_qty
     WHERE BUSINESS_UNIT = v_bu
       AND INV_ITEM_ID = v_item;

    COMMIT;
    v_result := 'SUCCESS: Deleted/Cancelled PeopleSoft Inventory Reservation ID ' || v_id ||
                ' (Item: ' || v_item || ', Released Qty: ' || v_qty || ', Business Unit: ' || v_bu || ')';
    write_log('INFO', 'delete_reservation', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
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
    v_cnt    NUMBER;
    v_result VARCHAR2(1000);
  BEGIN
    UPDATE SYSADM.PS_BU_ITEMS_INV
       SET QTY_ONHAND = QTY_ONHAND + NVL(p_quantity, 1),
           QTY_AVAILABLE = QTY_AVAILABLE + NVL(p_quantity, 1)
     WHERE BUSINESS_UNIT = v_bu
       AND INV_ITEM_ID = TRIM(p_item);
    v_cnt := SQL%ROWCOUNT;
    COMMIT;
    v_result := 'SUCCESS: Added ' || NVL(p_quantity, 1) || ' on-hand quantity for item ' ||
                TRIM(p_item) || ' in PeopleSoft Business Unit ' || v_bu ||
                ' (Rows updated in PS_BU_ITEMS_INV: ' || v_cnt || ')';
    write_log('INFO', 'create_onhand', 'VP1', v_result);
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      v_result := 'ERROR in create_onhand: ' || SQLERRM;
      write_log('ERROR', 'create_onhand', 'VP1', v_result);
      RETURN v_result;
  END create_onhand;

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
    v_amt       NUMBER := TO_NUMBER(REGEXP_REPLACE(p_amount, '[^0-9.-]', ''));
    v_vendor    VARCHAR2(10) := LPAD(SUBSTR(NVL(TRIM(p_vendor_id), 'USA0000002'), 1, 10), 10, '0');
    v_hdr       SYSADM.PS_VCHR_HDR_STG%ROWTYPE;
    v_line      SYSADM.PS_VCHR_LINE_STG%ROWTYPE;
    v_dist      SYSADM.PS_VCHR_DIST_STG%ROWTYPE;
    v_result    VARCHAR2(1000);
  BEGIN
    -- Generate unique concurrency-safe 8-char VOUCHER_ID ('GV' + 6 digits) via Oracle Sequence
    v_vchr_id := 'GV' || LPAD(TO_CHAR(MOD(SYSADM.PS_GOV_VCHR_SEQ.NEXTVAL, 1000000)), 6, '0');

    IF SUBSTR(TRIM(p_vendor_id), 1, 3) = 'USA' OR SUBSTR(TRIM(p_vendor_id), 1, 3) = 'SCM' THEN
      v_vendor := SUBSTR(TRIM(p_vendor_id), 1, 10);
    END IF;

    -- Stage voucher header, line, and distribution in PeopleSoft Voucher Build staging tables
    -- (PS_VCHR_HDR_STG, PS_VCHR_LINE_STG, PS_VCHR_DIST_STG) using %ROWTYPE template initialization
    -- so all PeopleSoft NOT NULL fields are populated cleanly for AP_VCHRBLD
    SELECT * INTO v_hdr FROM SYSADM.PS_VCHR_HDR_STG WHERE ROWNUM = 1;
    v_hdr.BUSINESS_UNIT   := v_bu;
    v_hdr.VCHR_BLD_KEY_C1 := v_vchr_id;
    v_hdr.VCHR_BLD_KEY_C2 := ' ';
    v_hdr.VCHR_BLD_KEY_N1 := 0;
    v_hdr.VCHR_BLD_KEY_N2 := 0;
    v_hdr.VOUCHER_ID      := v_vchr_id;
    v_hdr.VOUCHER_STYLE   := 'REG';
    v_hdr.INVOICE_ID      := SUBSTR(TRIM(p_invoice_num), 1, 30);
    v_hdr.INVOICE_DT      := TRUNC(SYSDATE);
    v_hdr.VENDOR_SETID    := 'SHARE';
    v_hdr.VENDOR_ID       := v_vendor;
    v_hdr.VNDR_LOC        := '0000000001';
    v_hdr.ADDRESS_SEQ_NUM := 1;
    v_hdr.ORIGIN          := 'ONL';
    v_hdr.OPRID           := 'VP1';
    v_hdr.ACCOUNTING_DT   := TRUNC(SYSDATE);
    v_hdr.GROSS_AMT       := v_amt;
    v_hdr.PYMNT_TERMS_CD  := 'NET30';
    v_hdr.ENTERED_DT      := TRUNC(SYSDATE);
    v_hdr.TXN_CURRENCY_CD := 'USD';
    v_hdr.VCHR_SRC        := 'ONL';
    v_hdr.DESCR254_MIXED  := SUBSTR(NVL(p_description, 'Staged via Gemini Enterprise PeopleSoft MCP Tool create_ap_voucher'), 1, 254);
    INSERT INTO SYSADM.PS_VCHR_HDR_STG VALUES v_hdr;

    SELECT * INTO v_line FROM SYSADM.PS_VCHR_LINE_STG WHERE ROWNUM = 1;
    v_line.BUSINESS_UNIT    := v_bu;
    v_line.VCHR_BLD_KEY_C1  := v_vchr_id;
    v_line.VCHR_BLD_KEY_C2  := ' ';
    v_line.VCHR_BLD_KEY_N1  := 0;
    v_line.VCHR_BLD_KEY_N2  := 0;
    v_line.VOUCHER_ID       := v_vchr_id;
    v_line.VOUCHER_LINE_NUM := 1;
    v_line.MERCHANDISE_AMT  := v_amt;
    v_line.QTY_VCHR         := 1;
    v_line.UNIT_PRICE       := v_amt;
    v_line.BUSINESS_UNIT_GL := v_bu;
    v_line.DESCR            := SUBSTR(NVL(p_description, 'Staged line'), 1, 30);
    v_line.DESCR254_MIXED   := SUBSTR(NVL(p_description, 'Staged line'), 1, 254);
    INSERT INTO SYSADM.PS_VCHR_LINE_STG VALUES v_line;

    SELECT * INTO v_dist FROM SYSADM.PS_VCHR_DIST_STG WHERE ROWNUM = 1;
    v_dist.BUSINESS_UNIT    := v_bu;
    v_dist.VCHR_BLD_KEY_C1  := v_vchr_id;
    v_dist.VCHR_BLD_KEY_C2  := ' ';
    v_dist.VCHR_BLD_KEY_N1  := 0;
    v_dist.VCHR_BLD_KEY_N2  := 0;
    v_dist.VOUCHER_ID       := v_vchr_id;
    v_dist.VOUCHER_LINE_NUM := 1;
    v_dist.DISTRIB_LINE_NUM := 1;
    v_dist.BUSINESS_UNIT_GL := v_bu;
    v_dist.ACCOUNT          := '600000';
    v_dist.MERCHANDISE_AMT  := v_amt;
    v_dist.QTY_VCHR         := 1;
    INSERT INTO SYSADM.PS_VCHR_DIST_STG VALUES v_dist;

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
