# JD Edwards database objects for the MCP tools

Objects a DBA creates in the JD Edwards database for the MCP Toolbox. The Toolbox's database user (`JDE_AI_RO` here, `JDE_AI` in the wrapper template) only has `CREATE SESSION` and `SELECT`, so anything that needs PL/SQL lives here. Both packages are owned by `JDE_AI` (the name `jde/templates/plsql_wrapper.sql` calls), run with definer's rights, and each call is read-only. Written for Oracle Database 19c and tested on Oracle Database Free with stand-in tables; JD Edwards itself has not run them yet.

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
| `get_base64_chunk(..., chunk, bytes)` | the stored bytes as Base64 in pieces of a multiple of 3 bytes (default 1,500, at most 2,800), no line breaks |

**Prerequisites:** run `jde_ai_grants.sql`; the database home has the Oracle Text filter binaries (`$ORACLE_HOME/ctx/bin/ctxhx`).

## Steps

1. **Edit `jde/install/jde_install_config.sql`** to your schema names and Toolbox user; create the `JDE_AI` user if it does not exist.
2. **Grants and install (DBA)**, from the `jde/install` folder:
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
   cp jde/install/jde_get_media_object_text.{sql,txt} jde/install/jde_get_media_object_base64.{sql,txt} jde/sql/
   python3 scripts/sync_sql_to_yaml.py --system jde
   python3 scripts/build_and_validate.py --system jde
   ```
   Commit through a PR; the copies in this folder can then be deleted.
5. **Turn the wrapper on** when ready (`--wrap`, README §2.6), knowing the row-security limit above.

## Rollback
Delete `jde/sql/jde_get_media_object_text.*` and `jde_get_media_object_base64.*`, sync, deploy; then as `JDE_AI` run `xx_ai_attachment_pkg_uninstall.sql` and `xx_ai_security_pkg_uninstall.sql`.

## How it was tested
On Oracle Database Free (26ai, Oracle Text) with stand-in `TESTDTA`/`SY920` tables, users `JDE_AI` (owner) and `JDE_AI_RO` (Toolbox), using the real scripts:
- **Install:** `jde_ai_grants.sql` as `SYS`, then both packages as `JDE_AI`, twice.
- **Attachments:** UTF-16 RTF, accented UTF-16 plain text, UTF-16 with a byte order mark, a PDF stored in the BLOB, a NULL BLOB, a 2-byte empty text and 5,500 characters of text (paged). Base64 round trips were byte-identical.
- **Tools:** both `.sql` tool statements ran as `JDE_AI_RO` and paged correctly.
- **Security:** user by e-mail (any case) and by JDE user ID; an unknown e-mail, a shared address book number (two users) and an empty id were refused.
- **Identity update (2026-10-08), 20 checks** on the 19c JDE test database in a scratch schema holding copies of `F0092`, `F00926` and `F01151` (everything rolled back): both data routes and agreement between them, two profiles sharing one e-mail, profile and address book naming different users (refused), mapping table (mapped, switched off, switched off beats a matching profile, mapped to a missing user, map resolving a clash), the check constraint, user ID, and identity lifetime (refused call and `clear_session` both clear it, `CLIENT_IDENTIFIER` set and cleared). Not tested: the wrapped tool end to end with a real Google token.
