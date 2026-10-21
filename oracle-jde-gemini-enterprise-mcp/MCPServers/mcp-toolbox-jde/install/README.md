# JD Edwards database objects for the MCP tools

Objects a DBA creates in the JD Edwards database for the MCP Toolbox. The Toolbox's database user (`JDE_AI_RO` here, `JDE_AI` in the wrapper template) only has `CREATE SESSION` and `SELECT`, so anything that needs PL/SQL lives here. Both packages are owned by `JDE_AI` (the name `mcp-toolbox-jde/templates/plsql_wrapper.sql` calls), run with definer's rights, and each call is read-only. Written for Oracle Database 19c and tested on Oracle Database Free with stand-in tables; JD Edwards itself has not run them yet.

| Script | Purpose |
| :--- | :--- |
| `jde_install_config.sql` | the site's names: data schema (`TESTDTA`), system schema (`SY920`), tablespace for the mapping table, Toolbox user. **Edit first.** |
| `jde_ai_grants.sql` | run once by a DBA: gives `JDE_AI` the `SELECT` (including `F00926`), `CREATE TABLE` (mapping table only, 1 MB quota) and Oracle Text rights the packages need |
| `xx_ai_security_pkg.sql` | `JDE_AI.XX_AI_SECURITY_PKG` for the PL/SQL security wrapper |
| `xx_ai_attachment_pkg.sql` | `JDE_AI.XX_AI_ATTACHMENT_PKG` and Oracle Text policy `XX_AI_ATTACH_TEXT_POLICY`; used by `jde_get_media_object_text` and `jde_get_media_object_base64` (the `.sql`/`.txt` copies in this folder) |

Each package has an `_uninstall.sql` and a `_verify.sql`. The schema names are SQL*Plus/SQLcl substitution variables (`&&jde_data_schema`), so the same scripts serve a database with `PRODDTA`, `PS920DTA` or `TESTDTA`.

## `xx_ai_security_pkg`: who is asking, and what it does not do

`init_user_session(p_user_id)` is the first statement of every wrapped tool. `p_user_id` is the e-mail address from the caller's verified Google token. It finds exactly one JDE user and records it for the session (`get_jde_user`, `DBMS_SESSION.SET_IDENTIFIER`). After the cursor is opened the wrapper calls `clear_session`, and a failed `init_user_session` also clears any earlier identity, so a pooled connection never carries one caller's identity into the next call.

**How an e-mail becomes a JDE user, in this order:**

1. **`XX_AI_USER_MAP`** (created empty by the install, owned by `JDE_AI`; the Toolbox user can only call the package, never read the table). One row per person: `EMAIL` (upper case), `JDE_USER` (upper case), `ACTIVE` (`Y`/`N`). A row **wins** over JDE data. `ACTIVE = 'N'` refuses the address even if JDE data would match. This is the safe choice when address book data is untidy, and the way to switch a person off.
2. Otherwise the **JDE data**: `F00926.AUEMLA` (user profile e-mail) and `F01151.EAEMAL` for the user's address book number (`F0092.ULAN8`). Users found by both routes are counted together: the same user twice is fine, two different users are refused.
3. A plain **JDE user ID** is also accepted (for tests).

Errors: `-20010` no id, `-20011` no JDE user (or the mapped user does not exist), `-20012` several JDE users, `-20013` address switched off.

```sql
-- as JDE_AI (DBA decision, one row per person)
INSERT INTO xx_ai_user_map (email, jde_user, note) VALUES ('JANE.DOE@AGENCY.GOV', 'JDOE', 'ticket 1234');
UPDATE xx_ai_user_map SET active = 'N' WHERE email = 'JANE.DOE@AGENCY.GOV';   -- switch off
COMMIT;
```

**Not checked:** whether the JDE user is active or disabled (`F00926.AUACTINACT`): the meaning of its values is unconfirmed (`research/jde-row-security`, question 9). Use the map's `ACTIVE`.

**It does not filter rows.** JDE enforces row security (`F00950`) and column security only in its application server. This package proves who is asking and refuses unknown users; a known user still sees the same rows as an unwrapped tool. Reproducing `F00950` in the database (for example Oracle VPD policies that read it and `get_jde_user`) is separate work that needs a design decision. Until then, do not rely on the wrapper for JDE data segregation.

**Data limit:** in the `TESTDTA` demo data no user can be identified by e-mail: the 5 users with an address book number all share AN8 1 (no e-mail) and `F00926.AUEMLA` is empty. Use `XX_AI_USER_MAP` there, or give users address book records with an e-mail.

## `xx_ai_attachment_pkg`: text and Base64 of media objects

Media objects are in `F00165` (key `GDOBNM`, `GDTXKY`, `GDMOSEQN`; content `GDTXFT`). In the `TESTDTA` demo data, text media objects (type 0, plus some type 3) hold UTF-16 text, very often RTF; file, image and link objects (types 1, 2, 5) hold no BLOB at all, because those files are on the JDE server and not in the database, so they return `NO_CONTENT` and the tools tell the agent to report the file name instead. Functions, all callable from SQL, each taking object name, text key and sequence:

| Function | Returns |
| :--- | :--- |
| `get_status`, `get_encoding`, `get_bytes` | `OK`, `NOT_FOUND`, `NO_CONTENT`, `TOO_LARGE` (over 50 MB); `UTF-16LE`, `OTHER` or `NONE`; size in bytes |
| `get_text_status`, `get_text_length`, `get_text_chunk(..., chunk, chars)` | plain text, 1,000 characters at a time: UTF-16 converted to text, RTF stripped through Oracle Text, PDF/Word/other files in the BLOB through `AUTO_FILTER` |
| `get_base64_chunk(..., chunk, bytes)` | the stored bytes as Base64 in pieces of a multiple of 3 bytes (default 1,500, at most 1,998), no line breaks |

**Prerequisites:** run `jde_ai_grants.sql`; the database home has the Oracle Text filter binaries (`$ORACLE_HOME/ctx/bin/ctxhx`).

## `xx_ai_staging_pkg`: stage transactions for JDE's batch processors

**JD Edwards has no PL/SQL business API.** The rules live in business functions and batch programs (UBEs), and Oracle's documentation says not to bypass them (updating F0411 or F0911 without the batch process and the Z-files "might compromise your voucher information"). What it documents for loading transactions from outside are the **batch interface tables (Z-files)** that a batch processor edits and turns into the real transaction: journal entries (`F0911Z1` -> R09110Z), vouchers (`F0411Z1` + `F0911Z1` -> R04110Z / R04110ZA), sales orders (`F4201Z1` + `F4211Z1`), purchase orders (`F4301Z1` + `F4311Z1`) and address book (`F0101Z2`). `xx_ai_staging_pkg.sql` (run as `JDE_AI`, after `jde_ai_staging_grants.sql` run by the owner of the data schema) lets the tools `jde_stage_journal_entry`, `jde_stage_voucher`, `jde_stage_sales_order`, `jde_stage_purchase_order` and `jde_stage_address_book` insert into exactly those seven tables, nothing else. It does not run the batch processor; `jde_get_batch_status` (F0011) and `jde_list_staged_transactions` show what happened.

| Design point | Why |
| :--- | :--- |
| Rows are JSON objects; a key is accepted only if it is a column of that table in `ALL_TAB_COLUMNS`; values are bound | No column list is hardcoded: layouts differ by release and customisation (`jde_describe_staging_table` lists the live ones; `mcp-toolbox-jde/stub/staging_schema.sql` is a snapshot of a real 9.2 database). A caller cannot reach another table or column, or inject SQL. |
| The EDI user (`...EDUS`) is the caller's verified JDE user (`jde_ai.xx_ai_security_pkg.get_jde_user`): filled in when missing, a different value is refused | A caller can only stage rows under its own user, and no row is staged without an authenticated user. |
| `...EDSP` (processed) and `...EDER` (error) cannot be given | The batch processor owns them; a staged row cannot claim to be processed. |
| All rows of a call go in together or not at all; at most 500 rows per table and call; JSON text up to about 30,000 characters per argument | A half-staged voucher or order would be processed into a wrong transaction. |
| The Toolbox user gets `EXECUTE` on the package only | `JDE_AI` holds the `INSERT` grants (`jde_ai_staging_grants.sql`); the package runs with definer's rights. |

**Install (DBA), in this order:**
1. `@jde_ai_staging_grants.sql` as the owner of the JDE data schema or a DBA (it needs `jde_data_schema` in `jde_install_config.sql`): `INSERT, SELECT` on the seven Z-files to `JDE_AI`, directly, not through a role.
2. `@xx_ai_staging_pkg.sql` as a **DBA (recommended)** or as `JDE_AI`. The script sets `CURRENT_SCHEMA = JDE_AI` itself, so the package always becomes `JDE_AI.XX_AI_STAGING_PKG` (created in any other schema it would fail with `PLS-00904: insufficient privilege to access object JDE_AI.XX_AI_SECURITY_PKG`). A DBA installs it without `JDE_AI` logging in or holding `CREATE PROCEDURE`; it needs `CREATE ANY PROCEDURE`, which `SYSTEM` has. If an earlier attempt left the package in another schema: `DROP PACKAGE <that schema>.xx_ai_staging_pkg;`.
3. **Enable the tools:** `@xx_ai_staging_pkg_grant.sql` (DBA) gives the Toolbox user `EXECUTE`; then remove the `DISABLED:` line in the `.txt` of the five `jde_stage_*` tools, run `python3 scripts/sync_sql_to_yaml.py` and `python3 scripts/build_and_validate.py --compile --compile-variants`. The grant is a separate step on purpose: the Toolbox user can call any function it may execute through the `execute_sql` tool (a `SELECT` may call an autonomous function), so this grant is what makes writing to the Z-files reachable at all, with or without the `jde_stage_*` tools. `@xx_ai_staging_pkg_revoke.sql` takes it away again.
4. **Optional hardening:** `@jde_ai_lock_owner.sql` (DBA) revokes `CREATE SESSION`, `CREATE PROCEDURE` and `CREATE TABLE` from `JDE_AI` and locks the account, so `JDE_AI` only owns the packages and its object grants: nobody can log in as the owner and change code or data with its `INSERT` rights, and a stolen `JDE_AI` password is worth nothing. Do it after all packages are installed; later installs are done as a DBA (step 2). Undo: `ALTER USER jde_ai ACCOUNT UNLOCK;` and grant the privileges back. The Toolbox user was never `JDE_AI` (it is the read-only user) and `execute_sql` cannot run DDL, so this guards against the owner account, not against the Toolbox.

Rollback: `xx_ai_staging_pkg_revoke.sql`, then `xx_ai_staging_pkg_uninstall.sql` (and revoke the `INSERT` grants if you want them gone).

**Already live without the package:** `jde_describe_staging_table`, `jde_list_staged_transactions` and `jde_get_batch_status` only read, and work on the live JDE database today.

**Tested:** the package on the Oracle 23 stub against stand-in Z-file tables created from the real column layouts (`scripts/test_stub_jde_staging.py`: 22 checks, installed by a DBA into `JDE_AI` with the owner locked, including that the Toolbox user cannot reach the package before the grant script and after the revoke script, and all-or-nothing, own-user rule, refused flags, SQL-injection keys, JSON type checks, limits, and the Toolbox user having no direct table access). The three read tools were compiled and called through the Toolbox on the live JDE database. **Not tested on a real JDE:** the write path against the live Z-files (JDE_AI has no `INSERT` grants there) and, above all, what the batch processors require of a row (required fields per transaction type, batch control record F0011, the processor's own checks and its data selection). Stage a test batch in a development environment and run the processor in proof mode first.

## Steps

1. **Edit `mcp-toolbox-jde/install/jde_install_config.sql`** to your schema names and Toolbox user; create the `JDE_AI` user if it does not exist.
2. **Grants and install (DBA)**, from the `mcp-toolbox-jde/install` folder:
   ```sql
   -- connected as a DBA
   @jde_ai_grants.sql
   -- connected as JDE_AI
   @xx_ai_security_pkg.sql
   @xx_ai_attachment_pkg.sql
   ```
   Each stops on the first error and can be run again.
3. **Verify (as the Toolbox user):** `@xx_ai_security_pkg_verify.sql` and `@xx_ai_attachment_pkg_verify.sql`.
4. **Add the tools (repo)**, only after step 3 succeeds (they fail with `PLS-00201` while the packages are missing):
   ```bash
   cp mcp-toolbox-jde/install/jde_get_media_object_text.{sql,txt} mcp-toolbox-jde/install/jde_get_media_object_base64.{sql,txt} mcp-toolbox-jde/sql/
   python3 scripts/sync_sql_to_yaml.py --system jde
   python3 scripts/build_and_validate.py --system jde
   ```
   Commit through a PR; the copies in this folder can then be deleted.
5. **Turn the wrapper on** when ready (`--wrap`, README §2.6), knowing the row-security limit above.

## Rollback
Delete `mcp-toolbox-jde/sql/jde_get_media_object_text.*` and `jde_get_media_object_base64.*`, sync, deploy; then as `JDE_AI` run `xx_ai_attachment_pkg_uninstall.sql` and `xx_ai_security_pkg_uninstall.sql`.

## How it was tested
On Oracle Database Free (26ai, Oracle Text) with stand-in `TESTDTA`/`SY920` tables, users `JDE_AI` (owner) and `JDE_AI_RO` (Toolbox), using the real scripts:
- **Install:** `jde_ai_grants.sql` as `SYS`, then both packages as `JDE_AI`, twice.
- **Attachments:** UTF-16 RTF, accented UTF-16 plain text, UTF-16 with a byte order mark, a PDF stored in the BLOB, a NULL BLOB, a 2-byte empty text and 5,500 characters of text (paged). Base64 round trips were byte-identical.
- **Tools:** both `.sql` tool statements ran as `JDE_AI_RO` and paged correctly.
- **Security:** user by e-mail (any case) and by JDE user ID; an unknown e-mail, a shared address book number (two users) and an empty id were refused.
- **Identity update (2026-10-08), 20 checks** on the 19c JDE test database in a scratch schema holding copies of `F0092`, `F00926` and `F01151` (everything rolled back): both data routes and agreement between them, two profiles sharing one e-mail, profile and address book naming different users (refused), mapping table (mapped, switched off, switched off beats a matching profile, mapped to a missing user, map resolving a clash), the check constraint, user ID, and identity lifetime (refused call and `clear_session` both clear it, `CLIENT_IDENTIFIER` set and cleared). Not tested: the wrapped tool end to end with a real Google token.
