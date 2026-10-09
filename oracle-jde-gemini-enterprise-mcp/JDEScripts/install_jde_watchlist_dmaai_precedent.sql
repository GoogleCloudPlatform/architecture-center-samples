-- =============================================================================
-- Oracle JD Edwards EnterpriseOne (JDE) 9.2 — Discrete Manufacturing
-- Watchlist Framework (SY920.F980051), DMAAI Accounting Instructions (PRODDTA.F4095),
-- General Ledger Account Master (PRODDTA.F0901), and Operational Precedent Engine (PRODDTA.F48019)
-- =============================================================================
WHENEVER SQLERROR CONTINUE;
SET DEFINE OFF;
ALTER SESSION SET CONTAINER = JDEORCL;

-- =============================================================================
-- 2. PRODDTA.F0901 — JDE General Ledger Account Master (Chart of Accounts for Co 00030 / M30)
-- =============================================================================
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables WHERE owner = 'PRODDTA' AND table_name = 'F0901';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE TABLE PRODDTA.F0901 (
        gmco     VARCHAR2(5)   NOT NULL,
        gmaid    VARCHAR2(8)   NOT NULL,
        gmmcu    VARCHAR2(12)  NOT NULL,
        gmobj    VARCHAR2(6)   NOT NULL,
        gmsUB    VARCHAR2(8)   DEFAULT '' '',
        gmdl01   VARCHAR2(30)  NOT NULL,
        gmpec    VARCHAR2(1)   DEFAULT '' '',
        gmuser   VARCHAR2(10)  DEFAULT ''JDE'',
        gmpid    VARCHAR2(10)  DEFAULT ''P0901'',
        gmupmj   NUMBER(6)     DEFAULT 126282,
        CONSTRAINT pk_f0901 PRIMARY KEY (gmaid)
      )';
  END IF;
END;
/

DELETE FROM PRODDTA.F0901 WHERE TRIM(gmco) = '00030';
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030131', '         M30', '1310', 'A1', 'M30 Raw Material & Comp Inv', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030132', '         M30', '1320', 'A1', 'M30 WIP Material Inventory', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030133', '         M30', '1330', 'B1', 'M30 WIP Direct Labor Absorb', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030134', '         M30', '1340', 'B3', 'M30 WIP Machine Run Absorb', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030135', '         M30', '1350', 'FG', 'M30 Finished Goods Inventory', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030522', '         M30', '5220', 'B1', 'M30 Direct Labor Eff Variance', ' ');
INSERT INTO PRODDTA.F0901 (gmco, gmaid, gmmcu, gmobj, gmsub, gmdl01, gmpec) VALUES ('00030', '00030524', '         M30', '5240', 'A1', 'M30 Material Usage & Scrap Var', ' ');
COMMIT;

-- =============================================================================
-- 3. PRODDTA.F4095 — Distribution/Manufacturing Automatic Accounting Instructions (DMAAIs)
--    Standard JDE Mfg DMAAIs:
--      3110: Material Issues to WIP
--      3120: Routing Labor / Machine WIP Absorption
--      3130: Work Order Completions to Finished Goods
--      3220: Labor Rate / Efficiency Variance
--      3240: Material Usage / Scrap Variance
-- =============================================================================
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables WHERE owner = 'PRODDTA' AND table_name = 'F4095';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE TABLE PRODDTA.F4095 (
        mlanid   NUMBER(4)     NOT NULL,
        mlco     VARCHAR2(5)   NOT NULL,
        mlani    VARCHAR2(29),
        mlmcu    VARCHAR2(12)  NOT NULL,
        mlobj    VARCHAR2(6),
        mlsub    VARCHAR2(8),
        mldcto   VARCHAR2(2)   NOT NULL,
        mlglpt   VARCHAR2(4)   NOT NULL,
        mlcost   VARCHAR2(3)   NOT NULL,
        mldl01   VARCHAR2(30),
        mlstat   VARCHAR2(20)  DEFAULT ''ACTIVE'',
        mluser   VARCHAR2(10)  DEFAULT ''JDE'',
        mlpid    VARCHAR2(10)  DEFAULT ''P4095'',
        mlupmj   NUMBER(6)     DEFAULT 126282,
        CONSTRAINT pk_f4095 PRIMARY KEY (mlanid, mlco, mldcto, mlglpt, mlcost)
      )';
  END IF;
END;
/

DELETE FROM PRODDTA.F4095;
-- Seed valid active DMAAIs in M30
INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3110, '00030', '         M30.1320.A1', '         M30', '1320', 'A1', 'IM', 'IN20', 'A1', 'WIP Material Issue - Std Comp', 'ACTIVE');

INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3110, '00030', '         M30.1320.A1', '         M30', '1320', 'A1', 'IM', 'IN30', 'A1', 'WIP Material Issue - Servo', 'ACTIVE');

INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3120, '00030', '         M30.1330.B1', '         M30', '1330', 'B1', 'IH', 'IN30', 'B1', 'WIP Direct Labor - Servo', 'ACTIVE');

-- INTENTIONAL DMAAI EXCEPTION #1 (< $5,000 Auto-Policy Band):
-- DMAAI 3120 for Co 00030, Doc Type IH, GL Class IN30, Cost Type B3 (Machine Run) has NULL GL Account!
-- Blocks Work Order 480015 ($3,420.00 Machine Run WIP absorption in R31802A)
INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3120, '00030', NULL, '         M30', NULL, NULL, 'IH', 'IN30', 'B3', 'MISSING GL: WIP Machine Run B3', 'MISSING_GL_EXCEPTION');

INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3130, '00030', '         M30.1350.FG', '         M30', '1350', 'FG', 'IC', 'IN30', 'A1', 'FG Completion Receipt - Servo', 'ACTIVE');

-- INTENTIONAL DMAAI EXCEPTION #2 (>= $5,000 Approval Required Band):
-- DMAAI 3240 for Co 00030, Doc Type IV, GL Class IN40, Cost Type A1 (Material Usage Variance) has NULL GL Account!
-- Blocks Work Order 480018 ($11,850.00 Material Usage & Scrap Variance in R31802A)
INSERT INTO PRODDTA.F4095 (mlanid, mlco, mlani, mlmcu, mlobj, mlsub, mldcto, mlglpt, mlcost, mldl01, mlstat)
VALUES (3240, '00030', NULL, '         M30', NULL, NULL, 'IV', 'IN40', 'A1', 'MISSING GL: Matl Usage IN40', 'MISSING_GL_EXCEPTION');

-- Remove any ad-hoc test Work Orders (> 480018) so only authentic JDE 9.2 Discrete Mfg WOs (480010..480018) appear
DELETE FROM PRODDTA.F3111 WHERE WMDOCO > 480018;
DELETE FROM PRODDTA.F3112 WHERE WLDOCO > 480018;
DELETE FROM PRODDTA.F3102 WHERE IGDOCO > 480018;
DELETE FROM PRODDTA.F4801 WHERE WADOCO > 480018;

-- Reset Open Purchase Order 430101 (CM-1020-ENC Optical Encoder) to pre-expedite Promised Date 2026-10-22 (126295)
UPDATE PRODDTA.F4311
   SET PDPDDJ = 126295,
       PDNXTR = '280',
       PDLTTR = '230',
       PDUSER = 'JDE       '
 WHERE PDDOCO = 430101;

-- Reset Audit Log to clean pre-remediation manufacturing baseline
DELETE FROM PRODDTA.GGLTOOLBOX$MCP_LOG;
INSERT INTO PRODDTA.GGLTOOLBOX$MCP_LOG (TOOL_NAME, JDE_USER, WORK_ORDER_NUM, PARAMETERS, EXECUTION_MODE, STATUS)
VALUES ('R31802A:ManufacturingAccountingBatch', 'JDE', 480015, '{"batch":"R31802A","branchPlant":"M30","blockedWOs":[480015,480018]}', 'JDE_UBE_BATCH', 'DMAAI_HOLD');
INSERT INTO PRODDTA.GGLTOOLBOX$MCP_LOG (TOOL_NAME, JDE_USER, WORK_ORDER_NUM, PARAMETERS, EXECUTION_MODE, STATUS)
VALUES ('P980051:OneViewWatchlistMonitor', 'JDE', NULL, '{"branchPlant":"M30","activeWatchlists":4,"totalAlerts":8}', 'WATCHLIST_SCAN', '8_ALERTS_OPEN');

-- Ensure Work Orders 480015 and 480018 exist in PRODDTA.F4801 and PRODDTA.F3102 (Status 45 - Blocked on R31802A DMAAI)
DELETE FROM PRODDTA.F4801 WHERE WADOCO IN (480015, 480018);
INSERT INTO PRODDTA.F4801
  (WADOCO, WADCTO, WAMCU, WAITM, WALITM, WAAITM, WADSC1, WASRST,
   WATYPS, WAPRTS, WAUORG, WASOQS, WASOCN, WAUOM, WATRDJ, WASTRT,
   WADRQJ, WASTRX, WAAN8, WAANPA, WAWR01, WAUSER, WAPID, WAJOBN, WAUPMJ, WATDAY)
VALUES
  (480015, 'WO', '         M30', 50001, 'AS-5000-SERVO            ', 'AS-5000-SERVO            ',
   'Servo Actuator Lot (R31802A)  ', '45', '1', '1', 200000, 200000, 0, 'EA',
   126275, 126276, 126280, 0, 80001, 80001, 'DMAI', 'JDE       ', 'R31802A   ', 'JDE-BATCH ', 126281, 83000);

INSERT INTO PRODDTA.F4801
  (WADOCO, WADCTO, WAMCU, WAITM, WALITM, WAAITM, WADSC1, WASRST,
   WATYPS, WAPRTS, WAUORG, WASOQS, WASOCN, WAUOM, WATRDJ, WASTRT,
   WADRQJ, WASTRX, WAAN8, WAANPA, WAWR01, WAUSER, WAPID, WAJOBN, WAUPMJ, WATDAY)
VALUES
  (480018, 'WO', '         M30', 50002, 'AS-6200-ROBOT            ', 'AS-6200-ROBOT            ',
   '6-Axis Robot Arm (R31802A Var)', '45', '1', '1', 100000, 100000, 10000, 'EA',
   126274, 126275, 126279, 0, 80001, 80001, 'DMAI', 'JDE       ', 'R31802A   ', 'JDE-BATCH ', 126281, 91500);

DELETE FROM PRODDTA.F3102 WHERE IGDOCO IN (480015, 480018);
INSERT INTO PRODDTA.F3102 (IGDOCO, IGDCTO, IGITM, IGLITM, IGMCU, IGCOST, IGPART, IGSTDC, IGPLNC, IGACTC, IGCSMT, IGSCRP, IGUPMJ)
VALUES (480015, 'WO', 50001, 'AS-5000-SERVO            ', '         M30', 'B3 ', ' ', 2800000, 2800000, 3142000, 2800000, 0, 126281);
INSERT INTO PRODDTA.F3102 (IGDOCO, IGDCTO, IGITM, IGLITM, IGMCU, IGCOST, IGPART, IGSTDC, IGPLNC, IGACTC, IGCSMT, IGSCRP, IGUPMJ)
VALUES (480018, 'WO', 50002, 'AS-6200-ROBOT            ', '         M30', 'A1 ', ' ', 8500000, 8500000, 9685000, 8500000, 1185000, 126281);

COMMIT;

-- =============================================================================
-- 4. PRODDTA.F48019 — JDE Operational Precedent & Exception Resolution Ledger
--    Stores verified historical resolutions across M30 shop-floor & accounting
-- =============================================================================
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables WHERE owner = 'PRODDTA' AND table_name = 'F48019';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE TABLE PRODDTA.F48019 (
        precedent_id          VARCHAR2(20)  NOT NULL,
        exception_category    VARCHAR2(30)  NOT NULL,
        target_key            VARCHAR2(40)  NOT NULL,
        branch_plant          VARCHAR2(12)  DEFAULT ''M30'',
        historical_cases_cnt  NUMBER(6)     NOT NULL,
        success_rate_pct      NUMBER(5,2)   NOT NULL,
        recommended_orch      VARCHAR2(60)  NOT NULL,
        recommended_action    VARCHAR2(200) NOT NULL,
        target_gl_or_supplier VARCHAR2(60)  NOT NULL,
        avg_manual_hours      NUMBER(6,2)   NOT NULL,
        agent_cycle_minutes   NUMBER(6,2)   NOT NULL,
        est_financial_impact  NUMBER(12,2)  NOT NULL,
        policy_threshold_usd  NUMBER(12,2)  DEFAULT 5000.00,
        policy_gate_mode      VARCHAR2(30)  NOT NULL,
        last_approved_by      VARCHAR2(20)  DEFAULT ''NGONZAL'',
        last_resolved_dttm    VARCHAR2(20)  DEFAULT ''2026-10-04'',
        CONSTRAINT pk_f48019 PRIMARY KEY (precedent_id)
      )';
  END IF;
END;
/

DELETE FROM PRODDTA.F48019;

INSERT INTO PRODDTA.F48019 VALUES (
  'PREC-DMAAI-3120',
  'DMAAI_GL_EXCEPTION',
  '3120:IH:IN30:B3',
  'M30',
  14,
  100.00,
  'ORCH_ResolveDMAAIException',
  'Map DMAAI 3120 (Doc IH, GL Class IN30, Cost B3) to M30.1340.B3 (AID 00030134) and re-run R31802A WIP Accounting',
  'M30.1340.B3 (00030134)',
  3.25,
  1.50,
  3420.00,
  5000.00,
  'AUTO_EXECUTE_UNDER_5K',
  'NGONZAL',
  '2026-09-29'
);

INSERT INTO PRODDTA.F48019 VALUES (
  'PREC-DMAAI-3240',
  'DMAAI_GL_EXCEPTION',
  '3240:IV:IN40:A1',
  'M30',
  9,
  97.80,
  'ORCH_ResolveDMAAIException',
  'Map DMAAI 3240 (Doc IV, GL Class IN40, Cost A1) to M30.5240.A1 (AID 00030524) and post $11,850 R31802A Variance Journal',
  'M30.5240.A1 (00030524)',
  3.25,
  1.50,
  11850.00,
  5000.00,
  'APPROVAL_REQUIRED_OVER_5K',
  'NGONZAL',
  '2026-09-22'
);

INSERT INTO PRODDTA.F48019 VALUES (
  'PREC-SHORT-ENC',
  'COMPONENT_SHORTAGE',
  'CM-1020-ENC',
  'M30',
  19,
  96.50,
  'ORCH_ExpediteShortagePO',
  'Expedite Open PO 430101 (200 EA CM-1020-ENC from Supplier 30001 Apex Precision Optics) to 2026-10-10 to clear 70 EA deficit across WO 480010, 480013, 480014',
  'PO 430101 / Supplier 30001',
  2.33,
  2.20,
  14800.00,
  5000.00,
  'APPROVAL_REQUIRED_OVER_5K',
  'NGONZAL',
  '2026-10-01'
);

INSERT INTO PRODDTA.F48019 VALUES (
  'PREC-SHORT-PCBA',
  'COMPONENT_SHORTAGE',
  'CM-1050-PCBA',
  'M30',
  11,
  95.00,
  'ORCH_ExpediteShortagePO',
  'Expedite Open PO 430102 (150 EA Dual-Core FPGA Motion Driver PCBA from Supplier 30002) to 2026-10-10 to unblock WO 480012',
  'PO 430102 / Supplier 30002',
  2.33,
  2.20,
  4250.00,
  5000.00,
  'AUTO_EXECUTE_UNDER_5K',
  'NGONZAL',
  '2026-09-25'
);

INSERT INTO PRODDTA.F48019 VALUES (
  'PREC-CAP-200101',
  'WORK_CENTER_BOTTLENECK',
  '200-101',
  'M30',
  16,
  94.20,
  'ORCH_RecordRoutingHours',
  'Split/Offload Op 10 CNC Housing Milling on WO 480011 from overloaded WC 200-101 (138.5% load) to alternate cell WC 200-102',
  'WC 200-101 -> WC 200-102',
  4.00,
  3.00,
  8900.00,
  5000.00,
  'APPROVAL_REQUIRED_OVER_5K',
  'NGONZAL',
  '2026-09-19'
);

COMMIT;

-- =============================================================================
-- 5. SY920.F980051 — JDE One View Watchlist Definition & Alert Queue
-- =============================================================================
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables WHERE owner = 'SY920' AND table_name = 'F980051';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE TABLE SY920.F980051 (
        watchlist_id         VARCHAR2(20)  NOT NULL,
        watchlist_name       VARCHAR2(80)  NOT NULL,
        jde_program_id       VARCHAR2(15)  NOT NULL,
        detection_mode       VARCHAR2(20)  NOT NULL,
        severity_level       VARCHAR2(15)  NOT NULL,
        branch_plant         VARCHAR2(12)  DEFAULT ''M30'',
        warning_threshold    NUMBER(6)     DEFAULT 1,
        critical_threshold   NUMBER(6)     DEFAULT 2,
        active_record_count  NUMBER(6)     NOT NULL,
        stuck_days_avg       NUMBER(5,1)   NOT NULL,
        financial_exposure   NUMBER(14,2)  NOT NULL,
        linked_work_orders   VARCHAR2(120) NOT NULL,
        precedent_id         VARCHAR2(20)  NOT NULL,
        watchlist_status     VARCHAR2(20)  DEFAULT ''ALERT_ACTIVE'',
        last_evaluated_dttm  VARCHAR2(25)  DEFAULT ''2026-10-09 06:55:00'',
        CONSTRAINT pk_f980051 PRIMARY KEY (watchlist_id)
      )';
  END IF;
END;
/

GRANT SELECT, INSERT, UPDATE, DELETE ON SY920.F980051 TO PRODDTA WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON SY920.F980051 TO JDE_AI;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODDTA.F0901 TO JDE_AI;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODDTA.F4095 TO JDE_AI;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODDTA.F48019 TO JDE_AI;

DELETE FROM SY920.F980051;

INSERT INTO SY920.F980051 VALUES (
  'WL-MFG-01',
  'Stuck Shop-Floor Work Orders (> 72 Hours Without Status Movement)',
  'P48013',
  'REACTIVE_ALERT',
  'CRITICAL',
  'M30',
  1,
  2,
  3,
  3.8,
  142500.00,
  'WO 480010, WO 480011, WO 480012',
  'PREC-SHORT-ENC',
  'ALERT_ACTIVE',
  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
);

INSERT INTO SY920.F980051 VALUES (
  'WL-MFG-02',
  'DMAAI Manufacturing Accounting Exceptions (R31802A Unposted WIP/Var)',
  'P4095',
  'REACTIVE_ALERT',
  'CRITICAL',
  'M30',
  1,
  1,
  2,
  2.5,
  15270.00,
  'WO 480015 ($3,420 Auto <$5K), WO 480018 ($11,850 Approval >=$5K)',
  'PREC-DMAAI-3120',
  'ALERT_ACTIVE',
  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
);

INSERT INTO SY920.F980051 VALUES (
  'WL-MFG-03',
  'Proactive 14-Day Component Shortage Horizon (Pre-Watchlist Radar)',
  'P31113',
  'PROACTIVE_14D',
  'WARNING',
  'M30',
  1,
  2,
  2,
  0.0,
  96400.00,
  'WO 480013, WO 480014 (70 EA Deficit on CM-1020-ENC; PO 430101 Open)',
  'PREC-SHORT-ENC',
  'PROACTIVE_RISK',
  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
);

INSERT INTO SY920.F980051 VALUES (
  'WL-MFG-04',
  'Proactive 14-Day Work Center Capacity Bottleneck (> 120% Load)',
  'P311221',
  'PROACTIVE_14D',
  'WARNING',
  'M30',
  1,
  1,
  1,
  0.0,
  68000.00,
  'WC 200-101 (5-Axis CNC Cell at 138.5% Utilization on WO 480011)',
  'PREC-CAP-200101',
  'PROACTIVE_RISK',
  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
);

COMMIT;

-- Authorize P4095 and P980051 in PRODCTL.F00950 for NGONZAL and JDE
MERGE INTO PRODCTL.F00950 tgt
USING (
  SELECT 'NGONZAL' AS fsuser, 'P4095'   AS fsobnm, '         M30' AS fsmcu FROM DUAL UNION ALL
  SELECT 'NGONZAL' AS fsuser, 'P980051' AS fsobnm, '         M30' AS fsmcu FROM DUAL UNION ALL
  SELECT 'JDE'     AS fsuser, 'P4095'   AS fsobnm, '         M30' AS fsmcu FROM DUAL UNION ALL
  SELECT 'JDE'     AS fsuser, 'P980051' AS fsobnm, '         M30' AS fsmcu FROM DUAL
) src
ON (TRIM(tgt.fsuser) = src.fsuser AND TRIM(tgt.fsobnm) = src.fsobnm AND TRIM(tgt.fsmcu) = TRIM(src.fsmcu))
WHEN NOT MATCHED THEN
  INSERT (FSUSER, FSOBNM, FSMCU, FSFRDV, FSTHRV, FSATN, FSCHNG, FSDELT, FSOKAY)
  VALUES (src.fsuser, src.fsobnm, src.fsmcu, src.fsmcu, src.fsmcu, 'Y', 'Y', 'Y', 'Y');
COMMIT;

-- =============================================================================
-- 6. Analytical Views for Watchlists, DMAAI Exceptions, & Operational Precedent
-- =============================================================================
CREATE OR REPLACE VIEW PRODDTA.VW_JDE_WATCHLIST_ALERTS AS
SELECT w.watchlist_id,
       w.watchlist_name,
       w.jde_program_id,
       w.detection_mode,
       w.severity_level,
       w.branch_plant,
       w.active_record_count,
       w.stuck_days_avg,
       w.financial_exposure,
       w.linked_work_orders,
       w.watchlist_status,
       w.last_evaluated_dttm,
       p.precedent_id,
       p.historical_cases_cnt,
       p.success_rate_pct,
       p.recommended_orch,
       p.recommended_action,
       p.avg_manual_hours,
       p.agent_cycle_minutes,
       p.est_financial_impact,
       p.policy_threshold_usd,
       p.policy_gate_mode
  FROM SY920.F980051 w
  LEFT JOIN PRODDTA.F48019 p ON p.precedent_id = w.precedent_id
 ORDER BY CASE w.detection_mode WHEN 'REACTIVE_ALERT' THEN 1 ELSE 2 END,
          w.watchlist_id;

CREATE OR REPLACE VIEW PRODDTA.VW_JDE_DMAAI_EXCEPTIONS AS
SELECT d.mlanid AS dmaai_table_number,
       d.mlco   AS company_code,
       TRIM(d.mlmcu) AS branch_plant,
       d.mldcto AS document_type,
       d.mlglpt AS gl_class_code,
       d.mlcost AS cost_type,
       NVL(TRIM(d.mlani), 'MISSING_GL_ACCOUNT') AS configured_gl_account,
       NVL(TRIM(d.mlobj), 'NONE') AS object_account,
       NVL(TRIM(d.mlsub), 'NONE') AS subsidiary_account,
       d.mldl01 AS dmaai_description,
       d.mlstat AS dmaai_status,
       CASE
         WHEN d.mlanid = 3120 AND d.mlcost = 'B3' THEN 480015
         WHEN d.mlanid = 3240 AND d.mlglpt = 'IN40' THEN 480018
         ELSE NULL
       END AS blocked_work_order_number,
       CASE
         WHEN d.mlanid = 3120 AND d.mlcost = 'B3' THEN 'AS-5000-SERVO (Servo Actuator Lot)'
         WHEN d.mlanid = 3240 AND d.mlglpt = 'IN40' THEN 'AS-6200-ROBOT (6-Axis Robot Arm)'
         ELSE 'Standard Configured Mapping'
       END AS blocked_item_summary,
       p.precedent_id,
       p.historical_cases_cnt,
       p.success_rate_pct,
       p.recommended_orch,
       p.recommended_action,
       p.target_gl_or_supplier AS recommended_gl_account,
       p.est_financial_impact  AS unposted_accounting_usd,
       p.policy_threshold_usd,
       p.policy_gate_mode
  FROM PRODDTA.F4095 d
  LEFT JOIN PRODDTA.F48019 p
    ON p.target_key = TO_CHAR(d.mlanid) || ':' || d.mldcto || ':' || d.mlglpt || ':' || d.mlcost
 ORDER BY CASE d.mlstat WHEN 'MISSING_GL_EXCEPTION' THEN 1 ELSE 2 END,
          d.mlanid, d.mlglpt, d.mlcost;

CREATE OR REPLACE VIEW PRODDTA.VW_JDE_OPERATIONAL_PRECEDENTS AS
SELECT precedent_id,
       exception_category,
       target_key,
       branch_plant,
       historical_cases_cnt,
       success_rate_pct,
       recommended_orch,
       recommended_action,
       target_gl_or_supplier,
       avg_manual_hours,
       agent_cycle_minutes,
       ROUND((avg_manual_hours * 60.0 - agent_cycle_minutes) / (avg_manual_hours * 60.0) * 100, 1) AS cycle_time_reduction_pct,
       est_financial_impact,
       policy_threshold_usd,
       policy_gate_mode,
       last_approved_by,
       last_resolved_dttm
  FROM PRODDTA.F48019
 ORDER BY est_financial_impact DESC;

GRANT SELECT ON PRODDTA.VW_JDE_WATCHLIST_ALERTS TO JDE_AI;
GRANT SELECT ON PRODDTA.VW_JDE_DMAAI_EXCEPTIONS TO JDE_AI;
GRANT SELECT ON PRODDTA.VW_JDE_OPERATIONAL_PRECEDENTS TO JDE_AI;

SET LINESIZE 220 PAGESIZE 100
SELECT watchlist_id, severity_level, active_record_count, financial_exposure, precedent_id FROM PRODDTA.VW_JDE_WATCHLIST_ALERTS;
SELECT dmaai_table_number, document_type, gl_class_code, cost_type, configured_gl_account, blocked_work_order_number, unposted_accounting_usd, policy_gate_mode FROM PRODDTA.VW_JDE_DMAAI_EXCEPTIONS;
SELECT precedent_id, exception_category, historical_cases_cnt, success_rate_pct, cycle_time_reduction_pct, policy_gate_mode FROM PRODDTA.VW_JDE_OPERATIONAL_PRECEDENTS;

EXIT;
