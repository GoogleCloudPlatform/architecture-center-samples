# EBS database objects for the MCP tools

Objects a DBA creates in the EBS database for the MCP Toolbox. The Toolbox's database user (`APPS_AI`) only has `CREATE SESSION` and `SELECT` grants, so anything that needs PL/SQL lives here.

## `xx_ai_security_pkg`: who is asking

The PL/SQL wrapper (`ebs/templates/plsql_wrapper.sql`) calls `apps.xx_ai_security_pkg.init_user_session(:user_id)` first in every tool, where `:user_id` is the e-mail address of the signed-in user. The procedure resolves that address to an active FND user, calls `ebs_initialize_context` (which runs `fnd_global.apps_initialize`, `MO_GLOBAL.INIT` and sets the MOAC policy context), and **raises an error unless the answer is `SUCCESS`**, so a failed setup stops the query (fail closed). Errors: `-20010` no id, `-20011` no active user, `-20012` several users, `-20013` setup failed.

The same two entry points exist in the PeopleSoft and JD Edwards packages, so every system's wrapper calls the package the same way:

| Subprogram | Meaning |
| :--- | :--- |
| `init_user_session(p_user_id)` | set the system's security context for the user, or raise `-20010` to `-20013` |
| `resolve_user(p_user_id)` | the system's own user name for `p_user_id` (EBS: FND user name; PeopleSoft: OPRID; JDE: user ID) |

| File | Purpose |
| :--- | :--- |
| `xx_ai_security_pkg.sql` | creates `APPS.XX_AI_SECURITY_PKG` (also `MCP_TOOLBOX_LOG`, which writes `APPS.XX_GGLTOOLBOX$MCP_LOG`, and `ebs_initialize_context`) and `GRANT EXECUTE ... TO apps_ai` |
| `xx_ai_security_pkg_verify.sql` | as `APPS_AI`: resolves a real user's e-mail, sets the context, and checks an unknown user is refused |
| `xx_ai_security_pkg_uninstall.sql` | drops the package |

Install as `APPS` through the normal process for custom code (`APPS` objects are editioned), then run the verify script as `APPS_AI`. A package installed without `init_user_session` (an older version) makes `build_and_validate.py --system ebs --compile-variants` report `init_user_session not found`.

### Changing the EBS context: `set_context`, `reset_context`, `get_session_context`

The package now lets a signed-in user switch their own operating unit, responsibility and application, through the tools `ebs_change_my_context`, `ebs_reset_my_context` and `ebs_get_my_context`. The lists of valid values are the tools `ebs_list_my_responsibilities` and `ebs_list_my_operating_units`.

**Why a table:** the Toolbox pools database connections and runs `init_user_session` at the start of every call, so a context set inside one call would be gone, or sit on another connection, at the next. `set_context` therefore validates the values with `ebs_initialize_context` and, only if EBS accepts them for that user, stores them in `APPS.XX_AI_USER_CONTEXT` (one row per e-mail; created empty by the install script and kept when the package is removed; the Toolbox user gets no access to it). `init_user_session` applies the stored choice on every call. A pooled session remembers what it applied and does not redo it.

**Who it acts for:** `set_context` and `reset_context` take no user parameter. They act for the identity that `init_user_session` verified in this session (the `user_id` the Toolbox takes from the Google token), so a caller cannot change somebody else's context, and a failed `init_user_session` leaves no identity behind. EBS itself refuses a responsibility or operating unit the user does not have. If a stored choice stops working (responsibility end-dated, for example) `init_user_session` logs a `WARN` row and uses the default context instead of locking the user out.

**Other changes in this version:** `ebs_initialize_context` takes `p_user_id` (was `p_email_address`) and a new `p_reinitialize` (`'Y'` skips the "already initialised" shortcut); an operating unit given by name is looked up in `HR_OPERATING_UNITS` first, as the default branch names it, then by inventory organization name as before. Reinstalling the package does not touch stored contexts.

**Tools (all in `ebs/sql/`, wrapper-only):** `ebs_change_my_context` and `ebs_reset_my_context` (toolset `context_switching`, they change state) and `ebs_get_my_context`, `ebs_list_my_responsibilities`, `ebs_list_my_operating_units` (toolset `context_discovery`, read-only). They need this package: install `xx_ai_security_pkg.sql` as `APPS` (an editioned object: normal custom-code process) before deploying a `tools_agent.yaml` / `tools_sec.yaml` that contains them, or they fail with `PLS-00302`. The package logic was also run on an Oracle 23 stub with stand-ins for the EBS objects (set, refused values, stored choice on a new connection, reset of a stale pooled session, fallback of a broken stored context, unknown user).

### Grants and the `ebs_execute_sql` tool

The Toolbox user (`APPS_AI`) can call every function it may execute through `ebs_execute_sql` (a `SELECT` may call an autonomous function), whether or not a dedicated tool exists for it. So the `EXECUTE` grants on `xx_ai_security_pkg` (context functions, needed by the wrapper) and on `apps.ge_ebs_mcp_tools` (reserve, on-hand, supplier, AP invoice: its source is not in this repository) decide what an agent with `ebs_execute_sql` can change, always as the signed-in user. `APPS` is the application owner and cannot be locked down, so the controls are: grant `EXECUTE` on write packages only where the write tools are meant to be enabled, and do not enable `ebs_execute_sql` where that is not intended. A DBA can list what is granted with `SELECT table_name, privilege FROM dba_tab_privs WHERE grantee = 'APPS_AI' AND (table_name LIKE 'GE_EBS%' OR table_name LIKE 'XX_AI%');`. DECISIONS.md section 23.

## `xx_ai_attachment_pkg`: text and Base64 of attachments

**Why:** The skills that read documents (notice, policy, intake, RFP) get their text from `ebs_get_attachment_text`. Plain SQL can decode text and HTML attachments, but not PDF, Word, Excel or PowerPoint files, which are about a quarter of the files in `FND_LOBS`. EBS's own Oracle Text index on `FND_LOBS` (`FND_LOBS_CTX`) uses a charset filter and doesn't index binary documents. This package uses Oracle Text's `AUTO_FILTER` to convert one file to plain text on request.

**What the install creates** (`xx_ai_attachment_pkg.sql`, run as `APPS`). The package has the same six functions as the PeopleSoft and JD Edwards `xx_ai_attachment_pkg`; only the key differs (here the `FND_LOBS` file id):

| Object | Purpose |
| :--- | :--- |
| Oracle Text preference `XX_AI_ATTACH_TEXT_FILTER` (`AUTO_FILTER`) and policy `XX_AI_ATTACH_TEXT_POLICY`, owned by `APPS` | Filter settings only. A policy is not an index: nothing is indexed, synchronized or stored. |
| Package `APPS.XX_AI_ATTACHMENT_PKG` (definer's rights) | `get_status`, `get_bytes`, `get_base64_chunk` (the file itself) and `get_text_status`, `get_text_length`, `get_text_chunk` (Oracle Text plain text): callable from SQL, read-only. |
| `GRANT EXECUTE ... TO apps_ai` | Only the MCP Toolbox user can call it. Change the grantee if your Toolbox user has another name. |

**How it behaves**
- **Read-only:** it reads `FND_LOBS.FILE_DATA` and writes nothing. Filtering runs in an autonomous transaction so it can be called from a query.
- **Per-session cache:** the last filtered file is kept as a temporary CLOB in the database session, so paging through a document filters it once, not once per chunk. Memory use is about the size of that file's text.
- **Limits:** files over 50 MB are not filtered (`TOO_LARGE`). Scanned image-only PDFs return `NO_TEXT` (they need OCR). Damaged or encrypted files return `ERROR: <Oracle Text message>`. None of these raise an error into the caller's query.
- **Data exposure:** the package can read any file in `FND_LOBS`. That is the same data `APPS_AI` can already select from `FND_LOBS` today, now as text instead of binary.

**Prerequisites**
- `APPS` can use `CTX_DDL` and `CTX_DOC`. In the instance this was written against, `APPS` already owns three `AUTO_FILTER` preferences (`ENDECA_FILTER`, `JTF_NOTE_FILTER`, `SGD_FILTER`), so this holds there.
- The database home has the Oracle Text filter binaries (`$ORACLE_HOME/ctx/bin/ctxhx`). A standard 19c home includes them, and the existing `AUTO_FILTER` preferences above suggest they are in use.

### Steps

1. **Install (DBA).** EBS R12.2 editions code objects in `APPS`, so deploy through your normal process for custom code: an `adop` hotpatch, or the next patch cycle.
   ```sql
   -- connected as APPS
   @ebs/install/xx_ai_attachment_pkg.sql
   ```
   The script stops on the first error and can be run again (it skips the preference and policy if they exist).
2. **Verify (as `APPS_AI`).** Read-only; it lists three recent PDF and Word files of each type with their file status, size, the start of their Base64 and the start of their text:
   ```sql
   @ebs/install/xx_ai_attachment_pkg_verify.sql
   ```
   Expect `OK` and readable text for most rows. `NO_TEXT` is normal for scanned PDFs.
3. **Switch the tools over (repo).** Done on 2026-10-12, after the package had been installed and checked: `ebs_get_attachment_text` (new version, replaces the SQL-only one) and the new `ebs_get_attachment_base64` (the counterpart of `ps_hcm_get_attachment_base64` and `jde_get_media_object_base64`) moved from this folder to `ebs/sql/`, with a sample payload for the Base64 tool in `test_live_toolbox.py`. **Consequence:** the committed `ebs/tools/` now contains two tools that need `APPS.XX_AI_ATTACHMENT_PKG`; on an EBS database without it they fail with `ORA-00904` when called, so install the package before deploying the config there.
4. **Retire the old package (DBA).** An earlier version of this package was installed as `APPS.XX_AI_ATTACHMENT_TEXT_PKG` (functions `get_status`, `get_length`, `get_chunk`). Once the tools use `xx_ai_attachment_pkg`, drop it as `APPS`: `@ebs/install/xx_ai_attachment_text_pkg_retire.sql`. It leaves the Oracle Text policy and preference alone, because the new package uses the same ones.

### Rollback
1. Revert the switch commit (it restores the previous SQL-only `ebs/sql/ebs_get_attachment_text.sql` and `.txt` and removes the Base64 tool), sync and deploy.
2. Then, as `APPS`: `@ebs/install/xx_ai_attachment_pkg_uninstall.sql`.

### How it was tested
The text functions (as `get_chunk`, `get_length` and `get_status` of the earlier `XX_AI_ATTACHMENT_TEXT_PKG`) were tested on Oracle Database Free with Oracle Text, against stub `APPS` attachment tables and an `APPS_AI` user with `SELECT` and `EXECUTE` only:
- **Install:** run in SQLcl as `APPS`, both fresh and a second time.
- **Content:** `.doc`, `.docx`, `.rtf` and `.pdf` all returned their text, and a 6-page PDF paged correctly. An image-only PDF returned `NO_TEXT`, and a damaged PDF returned the filter's "corrupted" message.
- **Tool:** the post-install `ebs_get_attachment_text` ran directly, through `toolbox invoke` (go-ora), and inside the PL/SQL security wrapper.
- **Uninstall:** removed all three objects, and a reinstall afterwards worked.

**Checked on the live EBS instance (2026-10-12), through the Toolbox (`toolbox` 1.14.0, go-ora):**
- **Text:** a Word document (`Travel Policy.doc`, 24 chunks) and a PDF (`RELEASE_204_6349_0_US.pdf`) returned their text with `CONTENT_KIND = FILTERED_FILE` and the Oracle Text extraction note; paging to chunk 2 worked; an HTML file (document 969) returned `HTML_FILE`.
- **Base64:** the PDF came back in 3 chunks (4,022 bytes at 1,500 per chunk) and a chunk decoded to a valid PDF (`%PDF-1.4`).
- **Not exercised:** scanned (image-only) and damaged files on EBS, a file larger than the 50 MB limit, and `xx_ai_attachment_pkg_verify.sql`. The old `XX_AI_ATTACHMENT_TEXT_PKG` is still installed (step 4).
