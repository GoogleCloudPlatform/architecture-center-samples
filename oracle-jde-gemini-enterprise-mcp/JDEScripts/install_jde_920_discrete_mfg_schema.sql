-- ============================================================================
-- JD Edwards EnterpriseOne 9.2 (Release 24 / 9.2.26)
-- Discrete Manufacturing Schema & Seed Data (Branch/Plant M30)
-- Target PDB: JDEORCL on jde-demo-db (10.118.0.41:1521/jdeorcl)
-- ============================================================================

ALTER SESSION SET CONTAINER = JDEORCL;

-- 1. Create Tablespaces & JDE 9.2 Schemas
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM dba_tablespaces WHERE tablespace_name = 'PRODDTAT';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLESPACE PRODDTAT DATAFILE ''/u01/oradata/ORCL/JDEORCL/proddtat01.dbf'' SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED';
  END IF;
  SELECT COUNT(*) INTO v_cnt FROM dba_tablespaces WHERE tablespace_name = 'PRODCTLT';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLESPACE PRODCTLT DATAFILE ''/u01/oradata/ORCL/JDEORCL/prodctlt01.dbf'' SIZE 200M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED';
  END IF;
END;
/

DECLARE
  PROCEDURE ensure_user(p_user VARCHAR2, p_ts VARCHAR2) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username = UPPER(p_user);
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'CREATE USER ' || p_user || ' IDENTIFIED BY "Manager123" DEFAULT TABLESPACE ' || p_ts || ' TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ' || p_ts || ' QUOTA UNLIMITED ON USERS';
    ELSE
      EXECUTE IMMEDIATE 'ALTER USER ' || p_user || ' IDENTIFIED BY "Manager123" ACCOUNT UNLOCK';
    END IF;
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA, CREATE VIEW, CREATE PROCEDURE, CREATE SYNONYM, UNLIMITED TABLESPACE TO ' || p_user;
  END;
BEGIN
  ensure_user('PRODDTA', 'PRODDTAT');
  ensure_user('PRODCTL', 'PRODCTLT');
  ensure_user('SY920',   'USERS');
  ensure_user('SVM920',  'USERS');
  ensure_user('JDE',     'PRODDTAT');
  ensure_user('JDE_AI',  'PRODDTAT');
END;
/

-- 2. PRODCTL.F0005 - User Defined Codes (UDCs)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODCTL.F0005 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODCTL.F0005 (
  DRSY    CHAR(4)       NOT NULL,
  DRRT   CHAR(2)       NOT NULL,
  DRKY   CHAR(10)      NOT NULL,
  DRDL01 VARCHAR2(30),
  DRDL02 VARCHAR2(30),
  DRSPHD CHAR(10),
  DRUDCO CHAR(1),
  CONSTRAINT PK_F0005 PRIMARY KEY (DRSY, DRRT, DRKY)
);

INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       10 ', 'Entered - Initial', 'New Work Order', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       20 ', 'Engineering Reviewed', 'BOM/Routing Checked', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       30 ', 'Parts & Routing Attached', 'Ready for Release', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       40 ', 'Released to Shop Floor', 'Active Production', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       45 ', 'Material Issued / WIP', 'In Process at Work Center', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       50 ', 'Sub-Assembly Complete', 'Awaiting Final Test', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       80 ', 'QA Inspection Passed', 'Ready for Inventory Receipt', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       90 ', 'Manufacturing Complete', 'Inventory Received (IC)', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('00  ', 'W1', '       99 ', 'Closed - Accounting', 'Variances Posted (P31802)', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        A1', 'Purchased Material', 'Direct Material Cost', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        B1', 'Direct Labor', 'Shop Floor Labor Cost', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        B2', 'Setup Labor', 'Machine Setup Labor', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        B3', 'Machine Run', 'CNC / Robotic Machine Cost', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        C1', 'Variable Mfg Overhead', 'Shop Floor Variable OH', '          ', 'Y');
INSERT INTO PRODCTL.F0005 VALUES ('30  ', 'CA', '        C2', 'Fixed Mfg Overhead', 'Plant Fixed OH', '          ', 'Y');

-- 3. PRODDTA.F0006 - Business Unit / Branch-Plant & Work Center Master
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F0006 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F0006 (
  MCMCU  CHAR(12)      NOT NULL PRIMARY KEY,
  MCSTYL CHAR(2),
  MCDL01 VARCHAR2(30),
  MCCO   CHAR(5),
  MCAN8  NUMBER(8),
  MCRP01 CHAR(3)
);

INSERT INTO PRODDTA.F0006 VALUES ('         M30', 'BP', 'Central Discrete Mfg Plant', '00200', 3001, 'MFG');
INSERT INTO PRODDTA.F0006 VALUES ('         D30', 'BP', 'Central Distribution Center', '00200', 3002, 'DST');
INSERT INTO PRODDTA.F0006 VALUES ('     200-101', 'WC', '5-Axis CNC Machining Cell', '00200', 3010, 'M30');
INSERT INTO PRODDTA.F0006 VALUES ('     200-102', 'WC', 'Robotic Laser Welding Bay', '00200', 3011, 'M30');
INSERT INTO PRODDTA.F0006 VALUES ('     200-201', 'WC', 'Cleanroom Stator & Winding', '00200', 3012, 'M30');
INSERT INTO PRODDTA.F0006 VALUES ('     200-301', 'WC', 'Final Servo Assembly & Calibration', '00200', 3013, 'M30');
INSERT INTO PRODDTA.F0006 VALUES ('     200-401', 'WC', 'Automated Burn-In & QA Test', '00200', 3014, 'M30');

-- 4. PRODDTA.F0002 - Next Numbers
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F0002 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F0002 (
  NNSY   CHAR(4) NOT NULL PRIMARY KEY,
  NNDOCO NUMBER(8) NOT NULL
);

INSERT INTO PRODDTA.F0002 VALUES ('48  ', 480025);
INSERT INTO PRODDTA.F0002 VALUES ('41  ', 710050);
INSERT INTO PRODDTA.F0002 VALUES ('43  ', 430120);

-- 5. PRODDTA.F4101 - Item Master
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4101 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4101 (
  IMITM  NUMBER(8)     NOT NULL PRIMARY KEY,
  IMLITM CHAR(25)      NOT NULL,
  IMAITM CHAR(25),
  IMDSC1 VARCHAR2(30),
  IMDSC2 VARCHAR2(30),
  IMSRTX VARCHAR2(30),
  IMSTKT CHAR(1),
  IMGLPT CHAR(4),
  IMUOM1 CHAR(2),
  IMUOM3 CHAR(2),
  IMLNTY CHAR(2),
  IMPRP1 CHAR(3)
);

INSERT INTO PRODDTA.F4101 VALUES (800100, 'AS-5000-SERVO            ', 'SERVO-5000               ', '5-Axis Industrial Servo Actuat', 'Heavy-Duty Discrete Mfg       ', 'SERVO ACTUATOR 5-AXIS', 'M', 'IN30', 'EA', 'EA', 'S ', 'ACT');
INSERT INTO PRODDTA.F4101 VALUES (800200, 'AS-6200-ROBOT            ', 'ROBOT-6200               ', '6-DOF Articulated Welding Arm ', 'Precision Robotic Assembly    ', 'ROBOTIC WELDING ARM 6DOF', 'M', 'IN30', 'EA', 'EA', 'S ', 'ROB');
INSERT INTO PRODDTA.F4101 VALUES (800300, 'AS-7400-CTRL             ', 'CTRL-7400                ', 'Edge CNC Motion Controller Uni', 'IP67 Industrial Enclosure     ', 'MOTION CONTROLLER CNC', 'M', 'IN30', 'EA', 'EA', 'S ', 'CTR');
INSERT INTO PRODDTA.F4101 VALUES (800400, 'SA-3100-GEAR             ', 'GEAR-3100                ', 'Planetary Titanium Gearbox Sub', 'Zero-Backlash Ratio 50:1      ', 'GEARBOX SUBASSEMBLY', 'M', 'IN20', 'EA', 'EA', 'S ', 'SUB');
INSERT INTO PRODDTA.F4101 VALUES (900101, 'CM-1010-STATOR           ', 'STATOR-1010              ', 'Rare-Earth Neodymium Stator Co', '480V High-Torque Winding      ', 'STATOR CORE NEODYMIUM', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');
INSERT INTO PRODDTA.F4101 VALUES (900102, 'CM-1020-ENC              ', 'ENC-1020                 ', '24-Bit Optical Absolute Encode', 'BiSS-C High-Speed Interface   ', 'OPTICAL ENCODER 24BIT', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');
INSERT INTO PRODDTA.F4101 VALUES (900103, 'CM-1030-SHAFT            ', 'SHAFT-1030               ', 'Hardened 4140 Alloy Drive Shaf', 'CNC Precision Ground 25mm     ', 'DRIVE SHAFT 4140 ALLOY', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');
INSERT INTO PRODDTA.F4101 VALUES (900104, 'CM-1040-HOUS             ', 'HOUS-1040                ', 'Die-Cast Aluminum Housing 6061', 'Hard-Anodized IP67 Finish     ', 'ALUMINUM HOUSING 6061', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');
INSERT INTO PRODDTA.F4101 VALUES (900105, 'CM-1050-PCBA             ', 'PCBA-1050                ', 'Dual-Core FPGA Motion Driver P', 'EtherCAT + Safety SIL3        ', 'FPGA MOTION DRIVER PCBA', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');
INSERT INTO PRODDTA.F4101 VALUES (900106, 'CM-1060-BRG              ', 'BRG-1060                 ', 'Ceramic Angular Contact Bearin', 'ABEC-7 Hybrid Si3N4           ', 'CERAMIC BEARING ABEC7', 'P', 'IN10', 'EA', 'EA', 'S ', 'CMP');

-- 6. PRODDTA.F4102 - Item Branch File (Branch/Plant M30)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4102 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4102 (
  IBITM  NUMBER(8) NOT NULL,
  IBMCU  CHAR(12)  NOT NULL,
  IBLITM CHAR(25),
  IBSTKT CHAR(1),
  IBGLPT CHAR(4),
  IBLNTY CHAR(2),
  IBANPL NUMBER(8),
  IBVEND NUMBER(8),
  IBSAFE NUMBER(15),
  CONSTRAINT PK_F4102 PRIMARY KEY (IBITM, IBMCU)
);

INSERT INTO PRODDTA.F4102 VALUES (800100, '         M30', 'AS-5000-SERVO            ', 'M', 'IN30', 'S ', 7501, 0,     200000);
INSERT INTO PRODDTA.F4102 VALUES (800200, '         M30', 'AS-6200-ROBOT            ', 'M', 'IN30', 'S ', 7501, 0,     100000);
INSERT INTO PRODDTA.F4102 VALUES (800300, '         M30', 'AS-7400-CTRL             ', 'M', 'IN30', 'S ', 7502, 0,     300000);
INSERT INTO PRODDTA.F4102 VALUES (800400, '         M30', 'SA-3100-GEAR             ', 'M', 'IN20', 'S ', 7502, 0,     400000);
INSERT INTO PRODDTA.F4102 VALUES (900101, '         M30', 'CM-1010-STATOR           ', 'P', 'IN10', 'S ', 7503, 44010, 500000);
INSERT INTO PRODDTA.F4102 VALUES (900102, '         M30', 'CM-1020-ENC              ', 'P', 'IN10', 'S ', 7503, 44020, 500000);
INSERT INTO PRODDTA.F4102 VALUES (900103, '         M30', 'CM-1030-SHAFT            ', 'P', 'IN10', 'S ', 7503, 44030, 800000);
INSERT INTO PRODDTA.F4102 VALUES (900104, '         M30', 'CM-1040-HOUS             ', 'P', 'IN10', 'S ', 7503, 44040, 600000);
INSERT INTO PRODDTA.F4102 VALUES (900105, '         M30', 'CM-1050-PCBA             ', 'P', 'IN10', 'S ', 7503, 44050, 500000);
INSERT INTO PRODDTA.F4102 VALUES (900106, '         M30', 'CM-1060-BRG              ', 'P', 'IN10', 'S ', 7503, 44060, 1000000);

-- 7. PRODDTA.F41021 - Item Location File (Quantities scaled by 10,000)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F41021 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F41021 (
  LIITM  NUMBER(8) NOT NULL,
  LIMCU  CHAR(12)  NOT NULL,
  LILOCN CHAR(20)  NOT NULL,
  LILOTN CHAR(30)  NOT NULL,
  LIPBIN CHAR(1),
  LIGLPT CHAR(4),
  LILOTS CHAR(1),
  LIPQOH NUMBER(15) DEFAULT 0,
  LIPBCK NUMBER(15) DEFAULT 0,
  LIPREQ NUMBER(15) DEFAULT 0,
  LIQWBO NUMBER(15) DEFAULT 0,
  LIHCOM NUMBER(15) DEFAULT 0,
  LIPCOM NUMBER(15) DEFAULT 0,
  LIFCOM NUMBER(15) DEFAULT 0,
  CONSTRAINT PK_F41021 PRIMARY KEY (LIITM, LIMCU, LILOCN, LILOTN)
);

-- Finished goods & sub-assemblies on hand
INSERT INTO PRODDTA.F41021 VALUES (800100, '         M30', 'FG-A01              ', '                              ', 'P', 'IN30', ' ',  450000, 0,       0, 400000,      0,       0, 0);
INSERT INTO PRODDTA.F41021 VALUES (800200, '         M30', 'FG-A02              ', '                              ', 'P', 'IN30', ' ',  120000, 0,       0, 150000,      0,       0, 0);
INSERT INTO PRODDTA.F41021 VALUES (800300, '         M30', 'FG-A03              ', '                              ', 'P', 'IN30', ' ',  600000, 0,       0, 500000,      0,       0, 0);
INSERT INTO PRODDTA.F41021 VALUES (800400, '         M30', 'WIP-SUB01           ', '                              ', 'P', 'IN20', ' ',  350000, 0,       0, 400000, 200000,  100000, 0);

-- Raw components in M30 (Note: CM-1020-ENC and CM-1050-PCBA have active shortages relative to open WO commitments!)
INSERT INTO PRODDTA.F41021 VALUES (900101, '         M30', 'RM-B01              ', '                              ', 'P', 'IN10', ' ', 1800000, 0,  500000,      0, 400000,  200000, 0);
INSERT INTO PRODDTA.F41021 VALUES (900102, '         M30', 'RM-B02              ', '                              ', 'P', 'IN10', ' ',  220000, 0, 1200000,      0, 150000,   50000, 0);
INSERT INTO PRODDTA.F41021 VALUES (900103, '         M30', 'RM-B03              ', '                              ', 'P', 'IN10', ' ', 2500000, 0,       0,      0, 300000,  100000, 0);
INSERT INTO PRODDTA.F41021 VALUES (900104, '         M30', 'RM-B04              ', '                              ', 'P', 'IN10', ' ', 1600000, 0,  400000,      0, 300000,  100000, 0);
INSERT INTO PRODDTA.F41021 VALUES (900105, '         M30', 'RM-B05              ', '                              ', 'P', 'IN10', ' ',  180000, 0, 1500000,      0, 120000,   40000, 0);
INSERT INTO PRODDTA.F41021 VALUES (900106, '         M30', 'RM-B06              ', '                              ', 'P', 'IN10', ' ',  650000, 0, 1000000,      0, 400000,  150000, 0);

-- 8. PRODDTA.F4105 - Item Cost File (LEDG='07' Standard Cost, COUNCST scaled by 10,000)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4105 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4105 (
  COITM   NUMBER(8) NOT NULL,
  COMCU   CHAR(12)  NOT NULL,
  COLOCN  CHAR(20)  NOT NULL,
  COLOTN  CHAR(30)  NOT NULL,
  COLEDG  CHAR(2)   NOT NULL,
  COUNCS  NUMBER(15) DEFAULT 0,
  COCSPO  CHAR(1),
  CONSTRAINT PK_F4105 PRIMARY KEY (COITM, COMCU, COLOCN, COLOTN, COLEDG)
);

INSERT INTO PRODDTA.F4105 VALUES (800100, '         M30', '                    ', '                              ', '07', 24500000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (800200, '         M30', '                    ', '                              ', '07', 68000000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (800300, '         M30', '                    ', '                              ', '07', 15200000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (800400, '         M30', '                    ', '                              ', '07',  6400000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900101, '         M30', '                    ', '                              ', '07',  4200000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900102, '         M30', '                    ', '                              ', '07',  3850000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900103, '         M30', '                    ', '                              ', '07',  1450000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900104, '         M30', '                    ', '                              ', '07',  2100000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900105, '         M30', '                    ', '                              ', '07',  5100000, 'I');
INSERT INTO PRODDTA.F4105 VALUES (900106, '         M30', '                    ', '                              ', '07',   950000, 'I');

-- 9. PRODDTA.F3002 - Bill of Material Master (IXQNTY scaled by 10,000)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F3002 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F3002 (
  IXTBM   CHAR(3)   NOT NULL,
  IXKIT   NUMBER(8) NOT NULL,
  IXKITL  CHAR(25),
  IXMMCU  CHAR(12)  NOT NULL,
  IXITM   NUMBER(8) NOT NULL,
  IXLITM  CHAR(25),
  IXCMCU  CHAR(12),
  IXCPNB  NUMBER(8) NOT NULL,
  IXQNTY  NUMBER(15) NOT NULL,
  IXUM    CHAR(2),
  IXSCRP  NUMBER(5) DEFAULT 0,
  IXOPSQ  NUMBER(5) DEFAULT 1000,
  CONSTRAINT PK_F3002 PRIMARY KEY (IXTBM, IXKIT, IXMMCU, IXCPNB, IXITM)
);

-- BOM for 800100 (AS-5000-SERVO: 5-Axis Industrial Servo Actuator)
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 800400, 'SA-3100-GEAR             ', '         M30', 1000, 10000, 'EA', 0,   1000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 900101, 'CM-1010-STATOR           ', '         M30', 2000, 10000, 'EA', 200, 2000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 900102, 'CM-1020-ENC              ', '         M30', 3000, 10000, 'EA', 0,   3000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 900104, 'CM-1040-HOUS             ', '         M30', 4000, 10000, 'EA', 0,   1000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 900105, 'CM-1050-PCBA             ', '         M30', 5000, 10000, 'EA', 0,   3000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800100, 'AS-5000-SERVO            ', '         M30', 900106, 'CM-1060-BRG              ', '         M30', 6000, 20000, 'EA', 0,   2000);

-- BOM for 800200 (AS-6200-ROBOT: 6-DOF Articulated Welding Arm)
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800200, 'AS-6200-ROBOT            ', '         M30', 800100, 'AS-5000-SERVO            ', '         M30', 1000, 20000, 'EA', 0,   2000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800200, 'AS-6200-ROBOT            ', '         M30', 900102, 'CM-1020-ENC              ', '         M30', 2000, 20000, 'EA', 0,   3000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800200, 'AS-6200-ROBOT            ', '         M30', 900105, 'CM-1050-PCBA             ', '         M30', 3000, 20000, 'EA', 0,   3000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800200, 'AS-6200-ROBOT            ', '         M30', 900106, 'CM-1060-BRG              ', '         M30', 4000, 40000, 'EA', 0,   1000);

-- BOM for 800300 (AS-7400-CTRL: Edge CNC Motion Controller Unit)
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800300, 'AS-7400-CTRL             ', '         M30', 900104, 'CM-1040-HOUS             ', '         M30', 1000, 10000, 'EA', 0,   1000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800300, 'AS-7400-CTRL             ', '         M30', 900105, 'CM-1050-PCBA             ', '         M30', 2000, 20000, 'EA', 0,   2000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800300, 'AS-7400-CTRL             ', '         M30', 900102, 'CM-1020-ENC              ', '         M30', 3000, 10000, 'EA', 0,   3000);

-- BOM for 800400 (SA-3100-GEAR: Planetary Titanium Gearbox Sub-Assy)
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800400, 'SA-3100-GEAR             ', '         M30', 900103, 'CM-1030-SHAFT            ', '         M30', 1000, 10000, 'EA', 0,   1000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800400, 'SA-3100-GEAR             ', '         M30', 900104, 'CM-1040-HOUS             ', '         M30', 2000, 10000, 'EA', 0,   1000);
INSERT INTO PRODDTA.F3002 VALUES ('M  ', 800400, 'SA-3100-GEAR             ', '         M30', 900106, 'CM-1060-BRG              ', '         M30', 3000, 20000, 'EA', 0,   2000);

-- 10. PRODDTA.F3003 - Routing Master (IRRUNL/IRRUNM/IRSETL scaled by 100)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F3003 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F3003 (
  IRTBM   CHAR(3)   NOT NULL,
  IRKIT   NUMBER(8) NOT NULL,
  IRKITL  CHAR(25),
  IRMMCU  CHAR(12)  NOT NULL,
  IROPSQ  NUMBER(5) NOT NULL,
  IRMCU   CHAR(12)  NOT NULL,
  IRDSC1  VARCHAR2(30),
  IRRUNL  NUMBER(15) DEFAULT 0,
  IRRUNM  NUMBER(15) DEFAULT 0,
  IRSETL  NUMBER(15) DEFAULT 0,
  CONSTRAINT PK_F3003 PRIMARY KEY (IRTBM, IRKIT, IRMMCU, IROPSQ)
);

-- Routings for 800100 (AS-5000-SERVO)
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800100, 'AS-5000-SERVO            ', '         M30', 1000, '     200-101', 'CNC Housing & Gearbox Prep    ', 45, 80, 150);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800100, 'AS-5000-SERVO            ', '         M30', 2000, '     200-201', 'Stator Press & Rotor Winding  ', 60, 50, 100);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800100, 'AS-5000-SERVO            ', '         M30', 3000, '     200-301', 'Encoder & PCBA Integration    ', 50, 30,  75);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800100, 'AS-5000-SERVO            ', '         M30', 4000, '     200-401', 'Laser Burn-In & Torque QA Test', 35, 60,  50);

-- Routings for 800200 (AS-6200-ROBOT)
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800200, 'AS-6200-ROBOT            ', '         M30', 1000, '     200-102', 'Robotic Frame Laser Welding   ', 90, 140, 200);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800200, 'AS-6200-ROBOT            ', '         M30', 2000, '     200-301', 'Dual Servo Joint Integration  ', 120, 60, 150);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800200, 'AS-6200-ROBOT            ', '         M30', 3000, '     200-401', '6-DOF Kinematic Calibration   ', 75, 110, 100);

-- Routings for 800300 (AS-7400-CTRL)
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800300, 'AS-7400-CTRL             ', '         M30', 1000, '     200-101', 'Enclosure Milling & Seal Prep ', 30, 50, 100);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800300, 'AS-7400-CTRL             ', '         M30', 2000, '     200-301', 'Dual-FPGA PCBA & Harness Assy ', 55, 25,  75);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800300, 'AS-7400-CTRL             ', '         M30', 3000, '     200-401', 'HIL Firmware & Thermal Test   ', 40, 80,  50);

-- Routings for 800400 (SA-3100-GEAR)
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800400, 'SA-3100-GEAR             ', '         M30', 1000, '     200-101', '5-Axis Titanium Gear Hobbing  ', 50, 95, 175);
INSERT INTO PRODDTA.F3003 VALUES ('R  ', 800400, 'SA-3100-GEAR             ', '         M30', 2000, '     200-301', 'Ceramic Bearing Press & Lube  ', 35, 25,  50);

-- 11. PRODDTA.F4801 - Work Order Master File
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4801 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4801 (
  WADOCO NUMBER(8)    NOT NULL PRIMARY KEY,
  WADCTO CHAR(2)      NOT NULL,
  WAMCU  CHAR(12)     NOT NULL,
  WAITM  NUMBER(8)    NOT NULL,
  WALITM CHAR(25),
  WAAITM CHAR(25),
  WADSC1 VARCHAR2(30),
  WASRST CHAR(2)      NOT NULL,
  WATYPS CHAR(1)      DEFAULT '1',
  WAPRTS CHAR(1)      DEFAULT '2',
  WAUORG NUMBER(15)   DEFAULT 0,
  WASOQS NUMBER(15)   DEFAULT 0,
  WASOCN NUMBER(15)   DEFAULT 0,
  WAUOM  CHAR(2)      DEFAULT 'EA',
  WATRDJ NUMBER(6)    DEFAULT 0,
  WASTRT NUMBER(6)    DEFAULT 0,
  WADRQJ NUMBER(6)    DEFAULT 0,
  WASTRX NUMBER(6)    DEFAULT 0,
  WAAN8  NUMBER(8)    DEFAULT 0,
  WAANPA NUMBER(8)    DEFAULT 0,
  WAWR01 CHAR(4)      DEFAULT 'M30 ',
  WAUSER CHAR(10)     DEFAULT 'JDE       ',
  WAPID  CHAR(10)     DEFAULT 'P48013    ',
  WAJOBN CHAR(10)     DEFAULT 'jde-web   ',
  WAUPMJ NUMBER(6)    DEFAULT 126281,
  WATDAY NUMBER(6)    DEFAULT 120000
);

-- Helper variable: Today in JDE Julian is 126281 (2026-10-08).
-- Overdue WOs have WADRQJ < 126281 (e.g., 126275 = 6 days overdue, 126278 = 3 days overdue).
INSERT INTO PRODDTA.F4801 VALUES (480010, 'WO', '         M30', 800100, 'AS-5000-SERVO            ', 'SERVO-5000               ', 'WO: 5-Axis Servo Actuator Lot ', '45', '1', '1', 250000, 100000, 10000, 'EA', 126265, 126268, 126276, 0,      7501, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 083000);
INSERT INTO PRODDTA.F4801 VALUES (480011, 'WO', '         M30', 800200, 'AS-6200-ROBOT            ', 'ROBOT-6200               ', 'WO: 6-DOF Welding Arm Rush    ', '40', '1', '1', 100000,  20000,     0, 'EA', 126268, 126270, 126278, 0,      7501, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 091500);
INSERT INTO PRODDTA.F4801 VALUES (480012, 'WO', '         M30', 800300, 'AS-7400-CTRL             ', 'CTRL-7400                ', 'WO: Edge CNC Controller Batch ', '45', '1', '1', 300000, 150000, 20000, 'EA', 126270, 126272, 126279, 0,      7502, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 100500);
INSERT INTO PRODDTA.F4801 VALUES (480013, 'WO', '         M30', 800400, 'SA-3100-GEAR             ', 'GEAR-3100                ', 'WO: Titanium Gearbox Replenish', '45', '1', '2', 400000, 280000, 10000, 'EA', 126272, 126274, 126283, 0,      7502, 3001, 'SUB ', 'JDE', 'P48013', 'jde-web', 126281, 111000);
INSERT INTO PRODDTA.F4801 VALUES (480014, 'WO', '         M30', 800100, 'AS-5000-SERVO            ', 'SERVO-5000               ', 'WO: Servo Actuator Q4 Build   ', '30', '1', '2', 200000,      0,     0, 'EA', 126278, 126281, 126288, 0,      7501, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 121500);
INSERT INTO PRODDTA.F4801 VALUES (480015, 'WO', '         M30', 800200, 'AS-6200-ROBOT            ', 'ROBOT-6200               ', 'WO: Articulated Arm Export    ', '30', '1', '1',  80000,      0,     0, 'EA', 126279, 126282, 126290, 0,      7501, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 133000);
INSERT INTO PRODDTA.F4801 VALUES (480016, 'WO', '         M30', 800300, 'AS-7400-CTRL             ', 'CTRL-7400                ', 'WO: CNC Controller OEM Order  ', '20', '1', '3', 250000,      0,     0, 'EA', 126280, 126284, 126292, 0,      7502, 3001, 'DISC', 'JDE', 'P48013', 'jde-web', 126281, 141000);
INSERT INTO PRODDTA.F4801 VALUES (480017, 'WO', '         M30', 800100, 'AS-5000-SERVO            ', 'SERVO-5000               ', 'WO: Servo Lot #109 Completed  ', '90', '1', '2', 300000, 290000, 10000, 'EA', 126255, 126258, 126270, 126271, 7501, 3001, 'DISC', 'JDE', 'P31114', 'jde-web', 126271, 164500);
INSERT INTO PRODDTA.F4801 VALUES (480018, 'WO', '         M30', 800200, 'AS-6200-ROBOT            ', 'ROBOT-6200               ', 'WO: Welding Arm Lot #42 Closed', '99', '1', '2', 120000, 110000, 10000, 'EA', 126245, 126248, 126262, 126264, 7501, 3001, 'DISC', 'JDE', 'P31802', 'jde-web', 126265, 173000);

-- 12. PRODDTA.F3111 - Work Order Parts List
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F3111 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F3111 (
  WMDOCO NUMBER(8)    NOT NULL,
  WMDCTO CHAR(2)      NOT NULL,
  WMCPNB NUMBER(8)    NOT NULL,
  WMCMCU CHAR(12)     NOT NULL,
  WMITM  NUMBER(8)    NOT NULL,
  WMLITM CHAR(25),
  WMAITM CHAR(25),
  WMDSC1 VARCHAR2(30),
  WMUORG NUMBER(15)   DEFAULT 0,
  WMTRQT NUMBER(15)   DEFAULT 0,
  WMSOCN NUMBER(15)   DEFAULT 0,
  WMUM   CHAR(2)      DEFAULT 'EA',
  WMOPSQ NUMBER(5)    DEFAULT 1000,
  WMLOCN CHAR(20)     DEFAULT 'RM-B01              ',
  WMLOTN CHAR(30)     DEFAULT '                              ',
  WMUSER CHAR(10)     DEFAULT 'JDE       ',
  WMPID  CHAR(10)     DEFAULT 'R31410    ',
  WMUPMJ NUMBER(6)    DEFAULT 126281,
  CONSTRAINT PK_F3111 PRIMARY KEY (WMDOCO, WMCPNB, WMITM)
);

-- Parts List for WO 480010 (25 EA of AS-5000-SERVO; 10 EA completed so far)
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 1000, '         M30', 800400, 'SA-3100-GEAR             ', 'GEAR-3100                ', 'Planetary Titanium Gearbox Sub', 250000, 150000, 0, 'EA', 1000, 'WIP-SUB01           ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 2000, '         M30', 900101, 'CM-1010-STATOR           ', 'STATOR-1010              ', 'Rare-Earth Neodymium Stator Co', 250000, 150000, 0, 'EA', 2000, 'RM-B01              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 3000, '         M30', 900102, 'CM-1020-ENC              ', 'ENC-1020                 ', '24-Bit Optical Absolute Encode', 250000, 100000, 0, 'EA', 3000, 'RM-B02              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 4000, '         M30', 900104, 'CM-1040-HOUS             ', 'HOUS-1040                ', 'Die-Cast Aluminum Housing 6061', 250000, 200000, 0, 'EA', 1000, 'RM-B04              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 5000, '         M30', 900105, 'CM-1050-PCBA             ', 'PCBA-1050                ', 'Dual-Core FPGA Motion Driver P', 250000, 100000, 0, 'EA', 3000, 'RM-B05              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480010, 'WO', 6000, '         M30', 900106, 'CM-1060-BRG              ', 'BRG-1060                 ', 'Ceramic Angular Contact Bearin', 500000, 300000, 0, 'EA', 2000, 'RM-B06              ', '                              ', 'JDE', 'R31410', 126281);

-- Parts List for WO 480011 (10 EA of AS-6200-ROBOT; 2 EA completed)
INSERT INTO PRODDTA.F3111 VALUES (480011, 'WO', 1000, '         M30', 800100, 'AS-5000-SERVO            ', 'SERVO-5000               ', '5-Axis Industrial Servo Actuat', 200000,  60000, 0, 'EA', 2000, 'FG-A01              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480011, 'WO', 2000, '         M30', 900102, 'CM-1020-ENC              ', 'ENC-1020                 ', '24-Bit Optical Absolute Encode', 200000,  40000, 0, 'EA', 3000, 'RM-B02              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480011, 'WO', 3000, '         M30', 900105, 'CM-1050-PCBA             ', 'PCBA-1050                ', 'Dual-Core FPGA Motion Driver P', 200000,  40000, 0, 'EA', 3000, 'RM-B05              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480011, 'WO', 4000, '         M30', 900106, 'CM-1060-BRG              ', 'BRG-1060                 ', 'Ceramic Angular Contact Bearin', 400000, 100000, 0, 'EA', 1000, 'RM-B06              ', '                              ', 'JDE', 'R31410', 126281);

-- Parts List for WO 480012 (30 EA of AS-7400-CTRL; 15 EA completed)
INSERT INTO PRODDTA.F3111 VALUES (480012, 'WO', 1000, '         M30', 900104, 'CM-1040-HOUS             ', 'HOUS-1040                ', 'Die-Cast Aluminum Housing 6061', 300000, 200000, 0, 'EA', 1000, 'RM-B04              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480012, 'WO', 2000, '         M30', 900105, 'CM-1050-PCBA             ', 'PCBA-1050                ', 'Dual-Core FPGA Motion Driver P', 600000, 300000, 0, 'EA', 2000, 'RM-B05              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480012, 'WO', 3000, '         M30', 900102, 'CM-1020-ENC              ', 'ENC-1020                 ', '24-Bit Optical Absolute Encode', 300000, 150000, 0, 'EA', 3000, 'RM-B02              ', '                              ', 'JDE', 'R31410', 126281);

-- Parts List for WO 480013 (40 EA of SA-3100-GEAR; 28 EA completed)
INSERT INTO PRODDTA.F3111 VALUES (480013, 'WO', 1000, '         M30', 900103, 'CM-1030-SHAFT            ', 'SHAFT-1030               ', 'Hardened 4140 Alloy Drive Shaf', 400000, 320000, 0, 'EA', 1000, 'RM-B03              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480013, 'WO', 2000, '         M30', 900104, 'CM-1040-HOUS             ', 'HOUS-1040                ', 'Die-Cast Aluminum Housing 6061', 400000, 320000, 0, 'EA', 1000, 'RM-B04              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480013, 'WO', 3000, '         M30', 900106, 'CM-1060-BRG              ', 'BRG-1060                 ', 'Ceramic Angular Contact Bearin', 800000, 600000, 0, 'EA', 2000, 'RM-B06              ', '                              ', 'JDE', 'R31410', 126281);

-- Parts List for WO 480014 (20 EA of AS-5000-SERVO; Status 30 Ready for Release)
INSERT INTO PRODDTA.F3111 VALUES (480014, 'WO', 1000, '         M30', 800400, 'SA-3100-GEAR             ', 'GEAR-3100                ', 'Planetary Titanium Gearbox Sub', 200000,      0, 0, 'EA', 1000, 'WIP-SUB01           ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480014, 'WO', 2000, '         M30', 900101, 'CM-1010-STATOR           ', 'STATOR-1010              ', 'Rare-Earth Neodymium Stator Co', 200000,      0, 0, 'EA', 2000, 'RM-B01              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480014, 'WO', 3000, '         M30', 900102, 'CM-1020-ENC              ', 'ENC-1020                 ', '24-Bit Optical Absolute Encode', 200000,      0, 0, 'EA', 3000, 'RM-B02              ', '                              ', 'JDE', 'R31410', 126281);
INSERT INTO PRODDTA.F3111 VALUES (480014, 'WO', 5000, '         M30', 900105, 'CM-1050-PCBA             ', 'PCBA-1050                ', 'Dual-Core FPGA Motion Driver P', 200000,      0, 0, 'EA', 3000, 'RM-B05              ', '                              ', 'JDE', 'R31410', 126281);

-- 13. PRODDTA.F3112 - Work Order Routing Instructions (Hours scaled by 100; Qty scaled by 10,000)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F3112 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F3112 (
  WLDOCO NUMBER(8)    NOT NULL,
  WLDCTO CHAR(2)      NOT NULL,
  WLOPSQ NUMBER(5)    NOT NULL,
  WLOPST CHAR(2)      DEFAULT '20',
  WLMCU  CHAR(12)     NOT NULL,
  WLMMCU CHAR(12)     DEFAULT '         M30',
  WLDSC1 VARCHAR2(30),
  WLRUNL NUMBER(15)   DEFAULT 0,
  WLRUNM NUMBER(15)   DEFAULT 0,
  WLSETL NUMBER(15)   DEFAULT 0,
  WLHRSO NUMBER(15)   DEFAULT 0,
  WLHRSA NUMBER(15)   DEFAULT 0,
  WLUORG NUMBER(15)   DEFAULT 0,
  WLSOQS NUMBER(15)   DEFAULT 0,
  WLSOCN NUMBER(15)   DEFAULT 0,
  WLSTRT NUMBER(6)    DEFAULT 126270,
  WLDRQJ NUMBER(6)    DEFAULT 126280,
  WLUSER CHAR(10)     DEFAULT 'JDE       ',
  WLPID  CHAR(10)     DEFAULT 'R31410    ',
  WLUPMJ NUMBER(6)    DEFAULT 126281,
  CONSTRAINT PK_F3112 PRIMARY KEY (WLDOCO, WLOPSQ)
);

-- Routing steps for WO 480010 (25 EA AS-5000-SERVO)
INSERT INTO PRODDTA.F3112 VALUES (480010, 'WO', 1000, '90', '     200-101', '         M30', 'CNC Housing & Gearbox Prep    ', 1125, 2000, 150, 1200, 1950, 250000, 250000,     0, 126268, 126270, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480010, 'WO', 2000, '40', '     200-201', '         M30', 'Stator Press & Rotor Winding  ', 1500, 1250, 100,  950,  800, 250000, 150000, 10000, 126271, 126273, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480010, 'WO', 3000, '30', '     200-301', '         M30', 'Encoder & PCBA Integration    ', 1250,  750,  75,  550,  320, 250000, 100000,     0, 126273, 126275, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480010, 'WO', 4000, '20', '     200-401', '         M30', 'Laser Burn-In & Torque QA Test',  875, 1500,  50,  380,  620, 250000, 100000,     0, 126275, 126276, 'JDE', 'P311221', 126281);

-- Routing steps for WO 480011 (10 EA AS-6200-ROBOT)
INSERT INTO PRODDTA.F3112 VALUES (480011, 'WO', 1000, '40', '     200-102', '         M30', 'Robotic Frame Laser Welding   ',  900, 1400, 200,  450,  680, 100000,  40000,     0, 126270, 126273, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480011, 'WO', 2000, '30', '     200-301', '         M30', 'Dual Servo Joint Integration  ', 1200,  600, 150,  300,  150, 100000,  20000,     0, 126274, 126276, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480011, 'WO', 3000, '10', '     200-401', '         M30', '6-DOF Kinematic Calibration   ',  750, 1100, 100,  160,  220, 100000,  20000,     0, 126277, 126278, 'JDE', 'P311221', 126281);

-- Routing steps for WO 480012 (30 EA AS-7400-CTRL)
INSERT INTO PRODDTA.F3112 VALUES (480012, 'WO', 1000, '90', '     200-101', '         M30', 'Enclosure Milling & Seal Prep ',  900, 1500, 100,  940, 1520, 300000, 300000,     0, 126272, 126274, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480012, 'WO', 2000, '40', '     200-301', '         M30', 'Dual-FPGA PCBA & Harness Assy ', 1650,  750,  75,  900,  420, 300000, 150000, 20000, 126275, 126277, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480012, 'WO', 3000, '20', '     200-401', '         M30', 'HIL Firmware & Thermal Test   ', 1200, 2400,  50,  620, 1250, 300000, 150000,     0, 126278, 126279, 'JDE', 'P311221', 126281);

-- Routing steps for WO 480013 (40 EA SA-3100-GEAR)
INSERT INTO PRODDTA.F3112 VALUES (480013, 'WO', 1000, '40', '     200-101', '         M30', '5-Axis Titanium Gear Hobbing  ', 2000, 3800, 175, 1500, 2900, 400000, 280000, 10000, 126274, 126279, 'JDE', 'P311221', 126281);
INSERT INTO PRODDTA.F3112 VALUES (480013, 'WO', 2000, '30', '     200-301', '         M30', 'Ceramic Bearing Press & Lube  ', 1400, 1000,  50,  980,  700, 400000, 280000,     0, 126280, 126283, 'JDE', 'P311221', 126281);

-- Routing steps for WO 480014 (20 EA AS-5000-SERVO)
INSERT INTO PRODDTA.F3112 VALUES (480014, 'WO', 1000, '10', '     200-101', '         M30', 'CNC Housing & Gearbox Prep    ',  900, 1600, 150,    0,    0, 200000,      0,     0, 126281, 126283, 'JDE', 'R31410',  126281);
INSERT INTO PRODDTA.F3112 VALUES (480014, 'WO', 2000, '10', '     200-201', '         M30', 'Stator Press & Rotor Winding  ', 1200, 1000, 100,    0,    0, 200000,      0,     0, 126283, 126285, 'JDE', 'R31410',  126281);
INSERT INTO PRODDTA.F3112 VALUES (480014, 'WO', 3000, '10', '     200-301', '         M30', 'Encoder & PCBA Integration    ', 1000,  600,  75,    0,    0, 200000,      0,     0, 126285, 126287, 'JDE', 'R31410',  126281);
INSERT INTO PRODDTA.F3112 VALUES (480014, 'WO', 4000, '10', '     200-401', '         M30', 'Laser Burn-In & Torque QA Test',  700, 1200,  50,    0,    0, 200000,      0,     0, 126287, 126288, 'JDE', 'R31410',  126281);

-- 14. PRODDTA.F3102 - Production Costing / Work Order Cost Variances (Amounts scaled by 100)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F3102 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F3102 (
  IGDOCO NUMBER(8)    NOT NULL,
  IGDCTO CHAR(2)      NOT NULL,
  IGITM  NUMBER(8)    NOT NULL,
  IGLITM CHAR(25),
  IGMCU  CHAR(12)     NOT NULL,
  IGCOST CHAR(3)      NOT NULL,
  IGPART CHAR(1)      DEFAULT ' ',
  IGSTDC NUMBER(15)   DEFAULT 0,
  IGPLNC NUMBER(15)   DEFAULT 0,
  IGACTC NUMBER(15)   DEFAULT 0,
  IGCSMT NUMBER(15)   DEFAULT 0,
  IGSCRP NUMBER(15)   DEFAULT 0,
  IGUPMJ NUMBER(6)    DEFAULT 126281,
  CONSTRAINT PK_F3102 PRIMARY KEY (IGDOCO, IGCOST, IGPART)
);

-- Costing for WO 480010 (Active WIP with Material Scrap & CNC Overtime Variance)
INSERT INTO PRODDTA.F3102 VALUES (480010, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'A1 ', ' ', 3625000, 3625000, 3985000, 1450000, 145000, 126281);
INSERT INTO PRODDTA.F3102 VALUES (480010, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'B1 ', ' ',  950000,  950000, 1140000,  380000,  38000, 126281);
INSERT INTO PRODDTA.F3102 VALUES (480010, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'B3 ', ' ', 1100000, 1100000, 1280000,  440000,  44000, 126281);
INSERT INTO PRODDTA.F3102 VALUES (480010, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'C1 ', ' ',  450000,  450000,  510000,  180000,  18000, 126281);

-- Costing for WO 480012 (Active Edge CNC Controller Batch)
INSERT INTO PRODDTA.F3102 VALUES (480012, 'WO', 800300, 'AS-7400-CTRL             ', '         M30', 'A1 ', ' ', 2850000, 2850000, 3120000, 1425000, 190000, 126281);
INSERT INTO PRODDTA.F3102 VALUES (480012, 'WO', 800300, 'AS-7400-CTRL             ', '         M30', 'B1 ', ' ',  820000,  820000,  915000,  410000,  54000, 126281);
INSERT INTO PRODDTA.F3102 VALUES (480012, 'WO', 800300, 'AS-7400-CTRL             ', '         M30', 'B3 ', ' ',  890000,  890000,  960000,  445000,  59000, 126281);

-- Costing for WO 480017 (Completed Servo Lot #109)
INSERT INTO PRODDTA.F3102 VALUES (480017, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'A1 ', ' ', 4350000, 4350000, 4590000, 4205000, 145000, 126271);
INSERT INTO PRODDTA.F3102 VALUES (480017, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'B1 ', ' ', 1140000, 1140000, 1265000, 1102000,  38000, 126271);
INSERT INTO PRODDTA.F3102 VALUES (480017, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'B3 ', ' ', 1320000, 1320000, 1395000, 1276000,  44000, 126271);
INSERT INTO PRODDTA.F3102 VALUES (480017, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'C2 ', ' ',  540000,  540000,  580000,  522000,  18000, 126271);

-- Costing for WO 480018 (Closed Welding Arm Lot #42)
INSERT INTO PRODDTA.F3102 VALUES (480018, 'WO', 800200, 'AS-6200-ROBOT            ', '         M30', 'A1 ', ' ', 5100000, 5100000, 5620000, 4675000, 425000, 126265);
INSERT INTO PRODDTA.F3102 VALUES (480018, 'WO', 800200, 'AS-6200-ROBOT            ', '         M30', 'B1 ', ' ', 1860000, 1860000, 2110000, 1705000, 155000, 126265);
INSERT INTO PRODDTA.F3102 VALUES (480018, 'WO', 800200, 'AS-6200-ROBOT            ', '         M30', 'B3 ', ' ', 1200000, 1200000, 1340000, 1100000, 100000, 126265);

-- 15. PRODDTA.F4111 - Item Ledger File (Cardex)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4111 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4111 (
  ILUKID NUMBER(15)   NOT NULL PRIMARY KEY,
  ILDOC  NUMBER(8)    NOT NULL,
  ILDCT  CHAR(2)      NOT NULL,
  ILKCO  CHAR(5)      DEFAULT '00200',
  ILDOCO NUMBER(8)    DEFAULT 0,
  ILDCTO CHAR(2)      DEFAULT 'WO',
  ILITM  NUMBER(8)    NOT NULL,
  ILLITM CHAR(25),
  ILMCU  CHAR(12)     NOT NULL,
  ILLOCN CHAR(20),
  ILLOTN CHAR(30),
  ILTRDJ NUMBER(6)    DEFAULT 126281,
  ILTRQT NUMBER(15)   DEFAULT 0,
  ILTRUM CHAR(2)      DEFAULT 'EA',
  ILUNCS NUMBER(15)   DEFAULT 0,
  ILPAID NUMBER(15)   DEFAULT 0,
  ILTREX VARCHAR2(30),
  ILUSER CHAR(10)     DEFAULT 'JDE       ',
  ILPID  CHAR(10)     DEFAULT 'P31113    ',
  ILCRDJ NUMBER(6)    DEFAULT 126281,
  ILTDAY NUMBER(6)    DEFAULT 120000
);

CREATE SEQUENCE PRODDTA.SEQ_F4111_UKID START WITH 900010 INCREMENT BY 1;

INSERT INTO PRODDTA.F4111 VALUES (900001, 710010, 'IM', '00200', 480010, 'WO', 900101, 'CM-1010-STATOR           ', '         M30', 'RM-B01              ', '                              ', 126270, -150000, 'EA',  4200000,  -6300000, 'Component Issue WO 480010', 'JDE', 'P31113', 126270, 093000);
INSERT INTO PRODDTA.F4111 VALUES (900002, 710011, 'IM', '00200', 480010, 'WO', 900102, 'CM-1020-ENC              ', '         M30', 'RM-B02              ', '                              ', 126271, -100000, 'EA',  3850000,  -3850000, 'Component Issue WO 480010', 'JDE', 'P31113', 126271, 101500);
INSERT INTO PRODDTA.F4111 VALUES (900003, 710012, 'IC', '00200', 480010, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'FG-A01              ', '                              ', 126275,  100000, 'EA', 24500000,  24500000, 'WO Completion Partial 480010', 'JDE', 'P31114', 126275, 154000);
INSERT INTO PRODDTA.F4111 VALUES (900004, 710013, 'IC', '00200', 480017, 'WO', 800100, 'AS-5000-SERVO            ', '         M30', 'FG-A01              ', '                              ', 126271,  290000, 'EA', 24500000,  71050000, 'WO Completion Lot #109', 'JDE', 'P31114', 126271, 164500);

-- 16. PRODDTA.F4311 - Open Purchase Order Detail (for Supply/Shortage Expediting)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODDTA.F4311 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE PRODDTA.F4311 (
  PDDOCO NUMBER(8)    NOT NULL,
  PDDCTO CHAR(2)      NOT NULL,
  PDKCOO CHAR(5)      DEFAULT '00200',
  PDLNID NUMBER(6)    NOT NULL,
  PDMCU  CHAR(12)     NOT NULL,
  PDAN8  NUMBER(8)    NOT NULL,
  PDITM  NUMBER(8)    NOT NULL,
  PDLITM CHAR(25),
  PDDSC1 VARCHAR2(30),
  PDNXTR CHAR(3)      DEFAULT '400',
  PDLTTR CHAR(3)      DEFAULT '280',
  PDUORG NUMBER(15)   DEFAULT 0,
  PDUOPN NUMBER(15)   DEFAULT 0,
  PDUREC NUMBER(15)   DEFAULT 0,
  PDTRDJ NUMBER(6)    DEFAULT 126270,
  PDDRQJ NUMBER(6)    DEFAULT 126286,
  PDPDDJ NUMBER(6)    DEFAULT 126286,
  PDPRRC NUMBER(15)   DEFAULT 0,
  CONSTRAINT PK_F4311 PRIMARY KEY (PDDOCO, PDDCTO, PDKCOO, PDLNID)
);

INSERT INTO PRODDTA.F4311 VALUES (430101, 'OP', '00200', 1000, '         M30', 44020, 900102, 'CM-1020-ENC              ', '24-Bit Optical Absolute Encode', '400', '280', 1200000, 1200000, 0, 126268, 126288, 126288, 3850000);
INSERT INTO PRODDTA.F4311 VALUES (430102, 'OP', '00200', 1000, '         M30', 44050, 900105, 'CM-1050-PCBA             ', 'Dual-Core FPGA Motion Driver P', '400', '280', 1500000, 1500000, 0, 126269, 126289, 126289, 5100000);
INSERT INTO PRODDTA.F4311 VALUES (430103, 'OP', '00200', 1000, '         M30', 44060, 900106, 'CM-1060-BRG              ', 'Ceramic Angular Contact Bearin', '400', '280', 1000000, 1000000, 0, 126272, 126285, 126285,  950000);

COMMIT;
EXIT;
