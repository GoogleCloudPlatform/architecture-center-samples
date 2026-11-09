# PeopleSoft database objects for the MCP tools

Objects a DBA creates in the PeopleSoft database for the MCP Toolbox. The Toolbox's database user (`SYSADM_AI`) only has `CREATE SESSION` and `SELECT` grants, so anything that needs PL/SQL lives here. Both packages are owned by `SYSADM`, run with definer's rights, and each call is read-only. They were written for Oracle Database 19c and tested on Oracle Database Free (Oracle Text, stand-in `SYSADM` tables and a stand-in `PS_SECURITY_PKG1`); PeopleSoft itself has not run them yet.

| Script | Creates | Used by |
| :--- | :--- | :--- |
| `xx_ai_security_pkg.sql` | `SYSADM.XX_AI_SECURITY_PKG` | the PL/SQL security wrapper (`mcp-toolbox-peoplesoft/templates/plsql_wrapper.sql`) |
| `xx_ai_attachment_pkg.sql` | `SYSADM.XX_AI_ATTACHMENT_PKG`, Oracle Text policy `XX_AI_ATTACH_TEXT_POLICY` | `ps_hcm_get_attachment_text`, `ps_hcm_get_attachment_base64` (the `.sql`/`.txt` copies in this folder) |

Each has an `_uninstall.sql` and a `_verify.sql`. Change the `GRANT ... TO sysadm_ai` line at the end of each install script if your Toolbox user has another name.

## `xx_ai_security_pkg`: who is asking

`init_user_session(p_user_id)` is the first statement of every wrapped tool. `p_user_id` is the e-mail address from the caller's verified Google token. It:
1. finds the one active PeopleSoft user whose `PSOPRDEFN.EMAILID` matches (`ACCTLOCK = 0`; an OPRID is also accepted, for tests);
2. calls `SYSADM.PS_SECURITY_PKG1.INITIALIZE_SESSION(oprid)`, the site's function, which returns JSON `{"STATUS":..., "MESSAGE":...}`;
3. **raises an error unless STATUS is the success value**, so a failed security setup stops the query (fail closed). Errors: `-20010` no id, `-20011` no active user, `-20012` several users, `-20013` setup failed.

**Confirm one thing before relying on it:** the delivered `PS_SECURITY_PKG1` only showed its failure answer (`{"STATUS":"FAILURE","MESSAGE":"Username not found ..."}`). The package expects `"SUCCESS"` (constant `c_ok_status`). Run `xx_ai_security_pkg_verify.sql` with a real user's e-mail: it prints the raw answer. If the success value is different, change the constant and re-run the install. The verify script calls `INITIALIZE_SESSION` for that user in your session, which may write the package's own log row; it reads no application data.

Only 22 of 141 users in the HCM instance checked on 2026-10-08 have an e-mail on their `PSOPRDEFN` row, so users without one cannot be identified and are refused.

## `xx_ai_attachment_pkg`: text and Base64 of attachments

PeopleSoft stores an attachment as several rows (`PS_HR_ATT_FILES` or `PSFILE_ATTDET`: the same `ATTACHSYSFILENAME`, `FILE_SEQ` 0, 1, 2 ... of about 28,000 bytes). The package joins the parts of the newest version in the session and offers, all callable from SQL:

| Function | Returns |
| :--- | :--- |
| `get_status(name)`, `get_bytes(name)` | `OK`, `NOT_FOUND`, `NO_CONTENT` or `TOO_LARGE` (over 50 MB), and the size |
| `get_text_status(name)`, `get_text_length(name)`, `get_text_chunk(name, chunk, chars)` | plain text of PDF, Word, Excel, PowerPoint, RTF, HTML and text files, 1,000 characters at a time, through Oracle Text `AUTO_FILTER`; `NO_TEXT` for scanned image PDFs, `ERROR: ...` for encrypted or damaged files |
| `get_base64_chunk(name, chunk, bytes)` | the file as Base64, in pieces of a multiple of 3 bytes (default 1,500, at most 1,998), no line breaks, so the pieces join into valid Base64 |

The last file used is cached for the session so paging reads it once. It can read any file in those two tables, which `SYSADM_AI` could already select as binary; it now also gets them as text.

**Prerequisites:** `SYSADM` can use `CTX_DDL` and `CTX_DOC` (direct `EXECUTE`, because the package runs with definer's rights; the `CTXAPP` role alone is not enough), and the database home has the Oracle Text filter binaries (`$ORACLE_HOME/ctx/bin/ctxhx`, in a standard 19c home).

## `xx_ai_staging_pkg`: stage transactions for PeopleSoft's batch processes (FSCM only)

**There is no PL/SQL business API in PeopleSoft.** The rules live in PeopleCode and Application Engine. What Oracle documents for loading transactions from outside is a set of staging tables that a delivered batch process validates and turns into the real transaction: vouchers (`PS_VCHR_HDR_STG`, `_LINE_STG`, `_DIST_STG`, `_PYMT_STG` -> Voucher Build), requisitions (`PS_PO_REQLOAD_RQST`, `_CMT` -> `PO_REQLOAD`) and journals (`PS_JGEN_ACCT_ENTRY` -> `FS_JGEN`). `xx_ai_staging_pkg.sql` (run as `SYSADM`; the script stops in any other schema) lets the tools `ps_stage_voucher`, `ps_stage_requisition` and `ps_stage_journal_entry` insert into exactly those tables, nothing else. It does not start the batch process: the Process Scheduler does, on its schedule, and `ps_get_process_status` shows how a run went.

| Design point | Why |
| :--- | :--- |
| Rows are JSON objects; a key is accepted only if it is a column of that table in `ALL_TAB_COLUMNS`; values are bound | The column lists of these records could not be confirmed from Oracle's public documentation and differ by release and customisation, so none is hardcoded. `ps_describe_staging_table` lists the real columns and which are required. A caller cannot reach another table or column, or inject SQL. |
| All rows of a call go in together or not at all (autonomous transaction, rollback on any error) | A half-staged voucher would be built into a wrong voucher. |
| At most 500 rows per table and call; JSON text of an argument up to about 30,000 characters (the PL/SQL limit inside the wrapper) | Keeps a call bounded. |
| The Toolbox user gets `EXECUTE` on the package only | It never gets `INSERT` on the tables; the package runs with definer's rights. |

**Installs on an FSCM database only.** `HR92U054` is an HCM database without these tables, so the package fails to compile there (`PLS-00201`), and the four tools that use it (`ps_stage_*`, `ps_describe_staging_table`) are disabled with a `DISABLED:` line in their `.txt` files. `ps_get_process_status` needs only `PSPRCSRQST` and works on HCM today.

**To enable on an FSCM database:**
1. `@xx_ai_staging_pkg.sql` as a DBA (needs `CREATE ANY PROCEDURE`) or as `SYSADM`; the script sets `CURRENT_SCHEMA = SYSADM` itself, so it always lands in `SYSADM`. `SYSADM` is the PeopleSoft owner and cannot be locked down the way `JDE_AI` can, so this package runs with `SYSADM`'s rights: it is small, only inserts into seven whitelisted tables, and only binds values, but that is the trade-off. A dedicated owner schema with `INSERT` on those seven tables would be tighter (the tools would then call that schema; not done).
2. `@xx_ai_staging_pkg_grant.sql` (DBA) gives the Toolbox user `EXECUTE`; remove the `DISABLED:` lines in the four `.txt` files, run `python3 scripts/sync_sql_to_yaml.py` and `python3 scripts/build_and_validate.py --compile --compile-variants`, then call `ps_describe_staging_table` for each record and check that the voucher build setup (AP origin, build defaults) accepts staged data. The grant is separate on purpose: the Toolbox user can call any function it may execute through the `execute_sql` tool, so the grant is what makes writing to the staging tables reachable at all. `@xx_ai_staging_pkg_revoke.sql` takes it away; `@xx_ai_staging_pkg_uninstall.sql` removes the package.

**Tested:** on the Oracle 23 stub with stand-in tables with invented columns (`scripts/test_stub_ps_staging.py`: success, a failing later table rolls back the earlier ones, unknown column and SQL-injection keys refused, JSON type checks, limits, the Toolbox user cannot write the tables). **Not tested on a PeopleSoft FSCM database**: nothing about the real record layouts, required columns, the build processes or the AP origin setup is verified.

## Steps

1. **Install (DBA)**, connected as `SYSADM`, through your normal process for custom code:
   ```sql
   @mcp-toolbox-peoplesoft/install/xx_ai_security_pkg.sql
   @mcp-toolbox-peoplesoft/install/xx_ai_attachment_pkg.sql
   ```
   Each stops on the first error and can be run again.
2. **Verify (as `SYSADM_AI`):**
   ```sql
   @mcp-toolbox-peoplesoft/install/xx_ai_security_pkg_verify.sql
   @mcp-toolbox-peoplesoft/install/xx_ai_attachment_pkg_verify.sql
   ```
3. **Switch the tools over (repo)**, only after step 2 succeeds, because the new tool versions fail with `ORA-00904`/`PLS-00201` while the packages are missing:
   ```bash
   cp mcp-toolbox-peoplesoft/install/ps_hcm_get_attachment_text.sql mcp-toolbox-peoplesoft/install/ps_hcm_get_attachment_text.txt \
      mcp-toolbox-peoplesoft/install/ps_hcm_get_attachment_base64.sql mcp-toolbox-peoplesoft/install/ps_hcm_get_attachment_base64.txt mcp-toolbox-peoplesoft/sql/
   python3 scripts/sync_sql_to_yaml.py --system peoplesoft
   python3 scripts/build_and_validate.py --system peoplesoft
   ```
   The new `ps_hcm_get_attachment_text` replaces the current one (it takes `chunk` instead of `source` and `chunk_start`, and it joins multi-part files and reads PDF and Word). Commit through a PR; the copies in this folder can then be deleted.
4. **Turn the wrapper on** when ready (`--wrap`, README §2.6). `build_and_validate.py` reports `sysadm.xx_ai_security_pkg` as not found until step 1 is done.

## Rollback
Restore the previous `mcp-toolbox-peoplesoft/sql/ps_hcm_get_attachment_text.*` (and delete `ps_hcm_get_attachment_base64.*`), sync, deploy; then as `SYSADM` run `xx_ai_attachment_pkg_uninstall.sql` and `xx_ai_security_pkg_uninstall.sql`.

## How it was tested
On Oracle Database Free (26ai, Oracle Text), with stand-in `SYSADM` tables and a stand-in `PS_SECURITY_PKG1` returning the failure JSON seen on the real database and a success JSON:
- **Install:** the real scripts through SQLcl as `SYSADM`, twice.
- **Attachments:** a file in 3 parts, a Word file, a PDF, a file only in `PSFILE_ATTDET`, a file with two versions (newest used), an empty file and a missing one. Base64 round trips were byte-identical at chunk sizes 7 (rounded to 6), 700, 1,500 and 2,800.
- **Tools:** both `.sql` tool statements ran as `SYSADM_AI` and paged correctly.
- **Security:** user by e-mail and by OPRID; a locked, an unknown, a duplicated and an empty user were refused; a `FAILURE` answer and an unreadable answer were refused.
