# BUILD: Changing SQL Tools Safely

This guide is for **functional EBS, PeopleSoft and JD Edwards analysts** who change the SQL behind the MCP tools. It covers what to edit, the checks to run **before every push**, and how to test the tools locally with MCP Toolbox.

> [!IMPORTANT]
> The automated GitHub check (`Sync SQL into tools.yaml`) is currently **not running**. Until it is, nothing on GitHub will update `tools.yaml` or catch a broken SQL file for you. **Run section 4 on your machine before every push**, and do not edit files through the GitHub web editor, because it can't run these steps.

---

## 1. What you edit (and what you don't)

Each tool is a pair of files in `ebs/sql/`, `peoplesoft/sql/` or `jde/sql/`:

| File | You edit it? | What it holds |
| :--- | :--- | :--- |
| `<tool>.sql` | **Yes** | The query, its bind parameters (in the header), and its skill (toolset). |
| `<tool>.txt` | **Yes** | The tool description the AI agent reads to decide when to use the tool and what it returns. |
| `<system>/tools.yaml` | **No, it's generated** | Rebuilt from the `.sql` and `.txt` files by `scripts/sync_sql_to_yaml.py`. Commit it, but never hand-edit it. |

---

## 2. One-time setup

1. **Python 3.10+** and the project dependency (a virtual environment is recommended):
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate            # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```
   Run `source .venv/bin/activate` again in each new terminal.

2. **MCP Toolbox** (`toolbox`), version 1.13.1 or later:
   * macOS (Homebrew): `brew install mcp-toolbox`
   * Direct download (pick your platform):
     ```bash
     # macOS Apple Silicon: darwin/arm64, Intel Mac: darwin/amd64, Linux: linux/amd64
     curl -Lo toolbox https://storage.googleapis.com/mcp-toolbox-for-databases/v1.13.1/darwin/arm64/toolbox
     chmod +x toolbox && sudo mv toolbox /usr/local/bin/
     ```
     Windows: download `https://storage.googleapis.com/mcp-toolbox-for-databases/v1.13.1/windows/amd64/toolbox.exe` and put it on your `PATH`.
   * Check it: `toolbox --version`

3. **Database credentials.** One pair of git-ignored files per system serves both local testing and Cloud Run deploys: `<system>/.env` (settings) and `<system>/.env.database` (`DB_CONNECTION_STRING`, `DB_USER`, `DB_PASSWORD`). Create them, fill in the second one, and load it in each terminal before testing:
   ```bash
   ./scripts/deploy_mcp_server.sh --system ebs --init-env     # also: peoplesoft, jde
   $EDITOR ebs/.env.database
   eval "$(./scripts/env_export.sh --system ebs)"              # replaces `source ebs.env`
   ```
   See README sections 3.3 and 3.7.

4. **Network access** to the EBS / PeopleSoft / JD Edwards databases (VPN, port 1521).

5. *Optional:* [Oracle SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) (`sql` on your `PATH`) for the EBS `EXPLAIN PLAN` check in section 5.5.
6. *JD Edwards analysts:* [Docker](https://docs.docker.com/get-docker/), for the stub-database tests in section 5.6.

---

## 3. Writing a tool's SQL file

### 3.1 File layout
Every `.sql` file starts with a header block that ends at the `-- ----` line. Below it is exactly **one** statement, ending with `;`.

```sql
-- Tool: ebs_list_operating_units
-- Skill: schema_discovery_and_lovs
-- Oracle Bind Variables:
--   :name_pattern (string): Optional search pattern to filter operating units by name.
-- -----------------------------------------------------------------------------
WITH params AS (
    SELECT :name_pattern AS name_pattern FROM dual
)
SELECT
    hou.organization_id,
    hou.name AS operating_unit_name
FROM apps.hr_operating_units hou, params p
WHERE (p.name_pattern IS NULL OR UPPER(hou.name) LIKE UPPER(p.name_pattern))
ORDER BY hou.name
FETCH FIRST 50 ROWS ONLY;
```

### 3.2 Rules the scripts enforce
* **`-- Tool:` must match the file name** (`ebs_list_operating_units.sql` → `-- Tool: ebs_list_operating_units`).
* **Every parameter is declared in the header** as `--   :name (type): description`. The type is one of `string`, `integer`, `float`, or `boolean`. The description is shown to the AI agent, so make it meaningful.
* **Each parameter is bound exactly once**, inside the `WITH params AS (SELECT ... FROM dual)` block. Everywhere else, refer to it as `p.name`, never `:name` again. (The Toolbox's Oracle driver fails with `ORA-01008` when a bind repeats.)
* **Optional filters** use `(p.name IS NULL OR column = p.name)`.
* **One statement per file.** A `;` is allowed only at the very end.
* **Don't start the statement with a comment.** The first line after the `-- ----` separator must be SQL (usually `WITH params AS (`). The Toolbox's driver rejects a leading comment with `ORA-00900`. Put notes after the `WITH params` block instead.
* **Bound the result set** with `FETCH FIRST n ROWS ONLY` for searches and lists.
* **Avoid `:word` inside comments.** The driver may treat it as a bind variable. The sync script warns about this.
* Use schema-qualified tables: `apps.` for EBS, `sysadm.` for PeopleSoft, `proddta.` (business data) and `prodctl.` (control tables such as UDCs) for JD Edwards.
* **JD Edwards data conventions** (not checked by the scripts):
  * Dates are Julian numbers (`CYYDDD`, 0 = blank). Show one with `CASE WHEN d > 0 THEN TO_CHAR(TO_DATE(TO_CHAR(d + 1900000), 'YYYYDDD'), 'YYYY-MM-DD') END`, and compare against an input date with `TO_NUMBER(TO_CHAR(TO_DATE(p.x, 'YYYY-MM-DD'), 'YYYYDDD')) - 1900000`.
  * Amounts and rates are stored without the decimal point. Divide by `10^decimals` from the data dictionary: usually 100 for amounts and 10000 for unit costs.
  * Codes are blank-padded. Pad input to the column's length for an exact match (`RPAD(p.x, 10)`; business units are right-justified, so `LPAD(TRIM(p.x), 12)`; companies are `LPAD(p.x, 5, '0')`), and `TRIM` values you return.
  * Unicode JDE databases use `NCHAR` columns. Mixing one with a plain text literal in `UNION ALL`, `CASE` or `NULLIF` fails with `ORA-12704: character set mismatch`, so wrap the column in `TO_CHAR()`.

### 3.3 Changing a query
Edit the `.sql` file. If you add or remove a parameter, update **both** the header line and the `WITH params` block. If the change affects what the tool returns or when to use it, update the `.txt` description too.

### 3.4 Adding a new tool
1. Create `<system>/sql/<tool_name>.sql`, using an existing file as a template. Names start with `ebs_`, `ps_` or `jde_`.
2. Set `-- Skill:` to the toolset it belongs to (for example `expense_auditor` or `schema_discovery_and_lovs`). A new skill name creates a new toolset.
3. Create `<system>/sql/<tool_name>.txt` with the description. Say what the tool returns, when an agent should use it, and the underlying tables. If you skip this, the sync script will ask you to type the description and save it to the `.txt` file for you.

### 3.5 Moving or removing a tool
* To move a tool to another toolset, change its `-- Skill:` line.
* To remove a tool, delete its `.sql` and `.txt`, then run the sync with `--prune` (section 4, step 1).
* To **disable** a tool without deleting it (for example, its tables don't exist in the connected database), add a line `DISABLED: <reason>` to its `.txt` file and run the sync. The tool is left out of `tools.yaml` and its toolset, and removed from them if it was there; the sync prints a `[disabled]` line for it. The `.sql` is still checked, so header errors still show. Delete the line and sync again to enable the tool.

---

## 4. Before every push: checklist

Run these from the repository root, with your virtual environment activated.

**1. Merge your changes into `tools.yaml`:**
```bash
python3 scripts/sync_sql_to_yaml.py --diff
```
The output lists each change it made (`[drift] ... statement changed`, `new tool added`, and so on). If it prints `[error]` lines, it changed nothing. Fix the file it names and run it again (see section 6).

**2. Validate everything:**
```bash
python3 scripts/build_and_validate.py
```
Besides validating, it regenerates each system's `tools_agent.yaml` (wrapped, `user_id` supplied by the agent) and then `tools_sec.yaml` (seeded from it, `user_id` verified by the Toolbox from the Google token). These are the files you deploy with `deploy_mcp_server.sh --variant agent` and `--variant sec`; they are git-ignored. Skip that with `--no-generate`.

It must end with `[SUCCESS] All configurations validated.` By default it also parses every statement in the system's database (`--compile`), so you need the tunnel and `pip install -r requirements.txt` (python-oracledb); a statement that would fail on the MCP server fails here. If python-oracledb cannot log in (EBS: DPY-3015, old password verifier) the same check runs through SQLcl, so `sql` must be on `PATH`. Use `--nocompile` only when no database is reachable. For JDE, set `JDE_DATA_SCHEMA` and `JDE_CTL_SCHEMA` (in `jde.env`) when the database has no PRODDTA/PRODCTL. Run it per system with `--system` if only some databases are up.

**3. Test your tool against a real database** (section 5). At minimum, invoke every tool you changed or added with realistic parameters, and check that the rows make sense. For JD Edwards, until a JDE database is available, run `python3 scripts/test_stub_jde.py --toolbox --wrap` instead (section 5.6); it must end with `[SUCCESS] All checks passed.`

**4. Review and commit the SQL, descriptions, and regenerated `tools.yaml` together:**
```bash
git status                      # expect your .sql/.txt files and the tools.yaml you changed
git diff ebs/tools.yaml         # sanity-check the generated change
git add ebs/sql/<tool>.sql ebs/sql/<tool>.txt ebs/tools.yaml
git commit -m "Describe what changed and why"
git push
```
Never commit `<system>/.env` or `<system>/.env.database` (they are git-ignored; keep it that way).

---

## 5. Testing the MCP Toolbox locally

Load the credentials first (`eval "$(./scripts/env_export.sh --system ebs)"`, or `peoplesoft` / `jde`). Every `toolbox` command connects to the database at startup, so if it can't reach the database, nothing runs.

### 5.1 Run one tool from the command line (fastest)
```bash
toolbox invoke ebs_list_operating_units '{"name_pattern": "%Vision%"}' --config ebs/tools.yaml
toolbox invoke ps_list_business_units '{"bu_type": "FS"}' --config peoplesoft/tools.yaml
```
* Parameters are a JSON object keyed by the names in your header. Numbers can be unquoted.
* For an optional parameter you don't want to filter on, pass an empty string (`""`).
* The rows are printed as JSON.
* If a system's `tools.yaml` has a `# PL/SQL wrapper:` line near the top, its tools run inside a security block that needs your verified Google identity (`user_id` comes from your login token, not from the parameters). `toolbox invoke` can't send a token, so test those tools through the HTTP API with an ID token; see [README §2.6](README.md#26-optional-plsql-security-wrapper). You don't need to change anything else: the sync keeps the wrapper on. Never declare a bind the template already uses (such as `:user_id`) in your own `.sql` file.

### 5.2 Interactive web UI
```bash
toolbox --config ebs/tools.yaml --ui -p 5000          # EBS        → http://localhost:5000
toolbox --config peoplesoft/tools.yaml --ui -p 5001   # PeopleSoft → http://localhost:5001
```
The UI lists every tool with its description and parameters, so you can fill in values and run them. Use a separate port per system, because both define toolsets with the same names. The server reloads `tools.yaml` when it changes, so after re-running the sync script you can test again without restarting. Stop it with `Ctrl+C`.

### 5.3 See your tools the way an AI agent does
The agent chooses tools only from their names, descriptions, and parameter descriptions. To check yours read well, connect an MCP client to the toolbox:

* **MCP Inspector** (needs Node.js):
  ```bash
  npx @modelcontextprotocol/inspector toolbox --config ebs/tools.yaml --stdio
  ```
* **An MCP-capable assistant** (such as Gemini CLI or Antigravity): add a server entry to its MCP settings file:
  ```json
  {
    "mcpServers": {
      "oracle-ebs": {
        "command": "toolbox",
        "args": ["--config", "/absolute/path/to/oracle-mcp-1p/ebs/tools.yaml", "--stdio"],
        "env": {
          "DB_CONNECTION_STRING": "host:1521/SERVICE",
          "DB_USER": "apps_ai",
          "DB_PASSWORD": "your_password"
        }
      }
    }
  }
  ```
  Then ask it a question that the tool should answer, and check that it picks your tool with sensible parameters.
* **Over HTTP:** a server started as in 5.2 also serves MCP at `http://localhost:5000/mcp`.

### 5.4 Keeping several test configurations
To compare versions (for example with and without the security wrapper) without overwriting `tools.yaml`, write each one to its own file with `--out`:
```bash
python3 scripts/sync_sql_to_yaml.py --system peoplesoft --out tools.wrapped.yaml --wrap
python3 scripts/sync_sql_to_yaml.py --system peoplesoft --out tools.plain.yaml
python3 scripts/build_and_validate.py --system peoplesoft --config tools.wrapped.yaml
toolbox --config peoplesoft/tools.wrapped.yaml --ui -p 5001
```
* The first run seeds the file from `tools.yaml`. Later runs with the same `--out` update only that file and keep its settings.
* Use names starting with `tools.`, `tools_` or `tools-` (for example `tools.wrapped.yaml` or `tools_sec.yaml`); git ignores them. Only `tools.yaml` is committed, so still run section 4 without `--out` before pushing.

### 5.5 Batch tests (EBS)
```bash
python3 scripts/test_live_ebs.py       # EXPLAIN PLAN for every ebs/sql/*.sql (needs SQLcl)
python3 scripts/test_live_toolbox.py   # 'toolbox invoke' on every EBS tool
```
Both use the `DB_*` variables, so run `eval "$(./scripts/env_export.sh --system ebs)"` first. `test_live_toolbox.py` takes its sample parameters from the `SAMPLE_INVOCATION_PAYLOADS` table at the top of the script. When you add an EBS tool, add an entry for it there, or the tool is invoked with no parameters.

### 5.6 JD Edwards tests without a JDE database
There is no live JDE database yet. `scripts/test_stub_jde.py` builds one locally in Docker from `jde/stub/schema.sql` and `jde/stub/seed.sql` and runs every JDE tool against it:
```bash
python3 scripts/test_stub_jde.py --toolbox --wrap
```
* It needs Docker and python-oracledb (`pip install -r requirements.txt`). The first run downloads the Oracle Database Free image (about 1 GB) and takes a minute or two; later runs take seconds.
* When you add a JDE tool, add an entry for it to the `SAMPLES` table at the top of the script: its parameters, the minimum number of rows, and a few values you expect back.
* If your query uses a column the stub doesn't have, you get `ORA-00904: invalid identifier`. Check the column in the JDE data dictionary, then add it to `jde/stub/schema.sql` (and to `seed.sql` if the test needs data in it).
* A pass here means the SQL is valid and its logic works on JDE-shaped data. It doesn't prove the query is right for a customer's JDE setup, which still needs a real JDE database.

### 5.7 Reading toolbox errors
| Message contains | Meaning | What to do |
| :--- | :--- | :--- |
| `unable to parse config file` | `tools.yaml` is invalid | Re-run section 4 steps 1–2; don't hand-edit `tools.yaml`. |
| `unable to initialize source ... unable to connect to Oracle` | Database unreachable or wrong credentials | Check VPN, load the right system with `eval "$(./scripts/env_export.sh --system <system>)"`, and verify the connection string. |
| `ORA-01008: not all variables bound` | A bind is used more than once | Bind each parameter only in the `WITH params` block (3.2). |
| `ORA-00942: table or view does not exist` | Missing grant or wrong schema prefix | Check the `apps.` / `sysadm.` / `proddta.` prefix and grants for the AI user. |
| `ORA-00904: invalid identifier` | Column name is wrong for this release | Check the column in the data dictionary. |
| `ORA-00900: invalid SQL statement` | The statement starts with a comment | Move the comment below the `WITH params` block (3.2). |
| `ORA-12704: character set mismatch` | A JD Edwards `NCHAR` column is mixed with a text literal | Wrap the column in `TO_CHAR()` (3.2). |

---

## 6. Sync script errors and fixes

| `[error]` message | Fix |
| :--- | :--- |
| `header '-- Tool: X' does not match file name 'Y'` | Make the `-- Tool:` line match the file name. |
| `missing '-- -----' header separator line` | Add the `-- ------...` line between the header and the SQL. |
| `bind :x is used N times` | Bind `:x` once in `WITH params`; use `p.x` everywhere else. |
| `binds used but not declared in the header: :x` | Add `--   :x (type): description` to the header. |
| `declared bind :x is not used in the statement` | Remove the header line, or add `:x` to the `WITH params` block. |
| `bind :x has unsupported type` | Use `string`, `integer`, `float`, or `boolean`. |
| `more than one statement` | Remove the extra `;` or split the query into two tools. |
| `new tool has no description; add .../<tool>.txt` | Create the `.txt` file, or run the sync in a terminal to be prompted. |
| `header declares binds in the order ... but the statement uses them in the order ...` | Reorder the `--   :name` header lines to match the order of the `WITH params` block. |
| `declares :x, which .../plsql_wrapper.sql already binds` | Rename your parameter; the security wrapper supplies `:x`. |
| `statement starts with a comment, which go-ora rejects` | Move the comment above the `-- -----` separator or after the `WITH params` block. |
| `description file is empty` | Put the description in the `.txt` file, or delete the file. |

Warnings (`[warn]`) don't block the sync, but read them. For example, a `.txt` file with no matching `.sql` is ignored.

---

For the conventions behind these rules, see [README.md](README.md) §2.

---

## 7. Deploying (not part of the analyst checklist)

Deploying the Toolbox is a separate, scripted workflow with its own per-system settings, `--variant` support and rotation commands: see README section 3.7 (`deploy_mcp_server.sh`). `python3 scripts/build_and_validate.py` already generates the two files those scripts deploy (`<system>/tools_agent.yaml` and `<system>/tools_sec.yaml`), so a clean validation is also the last step before a deploy.
