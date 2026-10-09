# Database change log (JDE row security research)

Every statement that changes the database (DDL, DML, grants, policies) is logged here with how to undo it.
Connection: `system@jde-db:1523/jdeorcl` (Oracle 19c, tunnel `sshjde`), plus the lab user below. Read-only queries are not logged.

**Principle:** nothing in `TESTDTA`, `PS920DTA`, `SY920`, `DD920`, or any real JDE schema is changed. All work is in the isolated schema `JDE_RS_LAB`, built from copies. **Full undo of everything below: `lab/99_teardown_lab.sql`** (as SYSTEM).
The lab user's password is not stored in the repo (it is substituted from `&&lab_password`).

| # | When (2026-10-08) | As | Change | Undo | Status |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 1 | session start | SYSTEM | `CREATE USER JDE_RS_LAB` (default ts USERS, 200M quota); `GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE VIEW` | `DROP USER jde_rs_lab CASCADE` | done |
| 2 | session start | SYSTEM | `GRANT EXECUTE ON dbms_rls TO jde_rs_lab` **failed** (ORA-01031, SYSTEM has no grant option); not retried, removed from the script | n/a | failed, no effect |
| 3 | session start | SYSTEM | `CREATE TABLE jde_rs_lab.{f0101,f0006,f01151,f0092,f95921} AS SELECT *` from `TESTDTA`/`SY920` (copies); `jde_rs_lab.f00950` structure only (0 rows) | dropped with the user | done |
| 4 | | SYSTEM | `CREATE CONTEXT jde_rs_ctx USING jde_rs_lab.rs_pkg` (`lab/02_context_and_package.sql`) | `DROP CONTEXT jde_rs_ctx` | done |
| 5 | | JDE_RS_LAB | `rs_config` table, package `RS_PKG` (identity mapping + predicate builder), `lab/02b_package.sql` | dropped with the user | done |
| 6 | | JDE_RS_LAB | Seed rows in the **lab copies** only (`lab/02c_seed_users.sql`): `f0092` user `BORKUR` (ULAN8 999001), `f01151` e-mail `borkur@pythian.com` for AN8 999001, `f95921` role link BORKUR to LABROLE. 1 row each | dropped with the user | done |
| 7 | | SYSTEM | `DBMS_RLS.ADD_POLICY` `JDE_RS_F0101_SELECT` on **`JDE_RS_LAB.F0101`** (the lab copy), SELECT only (`lab/03_policies.sql`) | `DBMS_RLS.DROP_POLICY('JDE_RS_LAB','F0101','JDE_RS_F0101_SELECT')` | done |
| 8 | | SYSTEM | `CREATE TABLE jde_rs_lab.f0101_raw AS SELECT * FROM testdta.f0101` (unfiltered reference copy, no policy, used to compute expected counts) | dropped with the user | done |
| 9 | later | SYSTEM | `CREATE TABLE jde_rs_lab.f00926 AS SELECT * FROM sy920.f00926` (copy, for the identity tests of PR `feat/jde-identity-resolution`) | dropped with the user | done |
| 10 | later | JDE_RS_LAB | Installed `xx_ai_security_pkg` (new version, from `jde/install/`) and table `xx_ai_user_map` in the lab schema, with schema names pointed at `JDE_RS_LAB`; the script's `GRANT EXECUTE ON xx_ai_security_pkg TO JDE_AI_RO` ran, so **the real user `JDE_AI_RO` holds EXECUTE on a lab object** | dropped with the user (the grant goes with the package) | done |
| 11 | later | JDE_RS_LAB | 20 identity tests with temporary inserts/updates in the lab copies and the map table, all rolled back (verified: map has 0 rows afterwards) | n/a | rolled back |

## State at end of session
Lab left in place for expert review: user `JDE_RS_LAB` (password not recorded in the repo), 7 tables, `RS_PKG`, context `JDE_RS_CTX`, policy `JDE_RS_F0101_SELECT`. The lab `F00950` has test rules left over from the last test case (cleared: rule set empty, mode `EXCLUSIVE`). **Real JDE schemas: unchanged.** Remove everything with `lab/99_teardown_lab.sql`.
