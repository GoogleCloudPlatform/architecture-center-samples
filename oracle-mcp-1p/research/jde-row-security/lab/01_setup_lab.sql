-- Run as SYSTEM. Creates the isolated lab schema JDE_RS_LAB; touches nothing in TESTDTA/SY920/PS920*.
-- Define lab_password first (SQLcl: DEFINE lab_password=...). Undo: 99_teardown_lab.sql
WHENEVER SQLERROR EXIT FAILURE
CREATE USER jde_rs_lab IDENTIFIED BY "&&lab_password" DEFAULT TABLESPACE users QUOTA 200M ON users;
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE VIEW TO jde_rs_lab;
-- DBMS_RLS: SYSTEM has no grant option, so policies are added by SYSTEM (see 03_policies.sql)
GRANT EXECUTE ON dbms_session TO jde_rs_lab;
-- copies (made as SYSTEM so no grants on the real schemas are needed)
CREATE TABLE jde_rs_lab.f0101  AS SELECT * FROM testdta.f0101;
CREATE TABLE jde_rs_lab.f0006  AS SELECT * FROM testdta.f0006;
CREATE TABLE jde_rs_lab.f01151 AS SELECT * FROM testdta.f01151;
CREATE TABLE jde_rs_lab.f0092  AS SELECT * FROM sy920.f0092;
CREATE TABLE jde_rs_lab.f95921 AS SELECT * FROM sy920.f95921;
-- structure only: lab rules are inserted by the test scripts, never copied from SY920
CREATE TABLE jde_rs_lab.f00950 AS SELECT * FROM sy920.f00950 WHERE 1=0;
EXIT
