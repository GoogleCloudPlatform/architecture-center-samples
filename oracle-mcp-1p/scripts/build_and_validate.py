#!/usr/bin/env python3
"""
build_and_validate.py

Static validator for the Oracle EBS R12.2 and PeopleSoft 9.2 MCP Toolbox configs.

The SQL files in <system>/sql/ are the source of truth for statements, bind
parameters and skills; scripts/sync_sql_to_yaml.py merges them into
<system>/tools.yaml. Besides validating, it (re)generates the two secured variants every run
(--no-generate to skip), in this order:
  1. <system>/tools_agent.yaml  = tools.yaml wrapped in the PL/SQL security block, user_id a plain parameter
                                   the calling agent fills with an identity it verified (--identity agent).
                                   Deploy it as the Toolbox the agent talks to: deploy_mcp_server.sh --variant agent.
  2. <system>/tools_sec.yaml    = seeded from tools_agent.yaml, wrapped, user_id verified by the Toolbox from the
                                   caller's Google token (--identity token; authServices + authRequired).
                                   Deploy it with: deploy_mcp_server.sh --variant sec.
Both are git-ignored like every tools_*.yaml. This is the same as running sync_sql_to_yaml.py --out ... --wrap
--identity ... for each. It checks that:

- Every SQL file parses and follows the single-bind CTE rules (see sync_sql_to_yaml.py).
- tools.yaml is in sync with the SQL files (run sync_sql_to_yaml.py if not).
- Sources use a unified 'connectionString:' (no host / port / service_name keys).
- Every tool is an oracle-sql tool on a declared source, with a description.
- Statements have no trailing semicolon (Go/OCI raises ORA-00933); PL/SQL blocks end with 'END;'.
- Every declared parameter is bound exactly once as :param_name, in parameter order; no undeclared binds.
- Every tool belongs to exactly one toolset, and toolsets only reference real tools.
- Every auth service a tool or parameter references is defined under top-level authServices.

By default (--compile) it also connects to each system's database and PARSES every statement exactly as it
is written in tools.yaml (wrapper included), so SQL that would fail on the MCP server (missing table or column,
bad syntax, missing package) is caught before it is pushed. Nothing is executed and no data is read. Use
--nocompile where no database is reachable (CI, a laptop without the tunnel).

Connection per system, first match wins:
  1. environment variables <SYSTEM>_DB_USER, <SYSTEM>_DB_PASSWORD, <SYSTEM>_DB_CONNECTION_STRING (for example JDE_DB_USER)
  2. jde only: the local stub database of scripts/test_stub_jde.py, when it is running (JDE has no live system)
  3. <system>/.env.database (DB_USER, DB_PASSWORD, DB_CONNECTION_STRING; the file deploy_mcp_server.sh uses), with
     <system>/.env for the other settings (such as JDE_DATA_SCHEMA)
"""

import argparse
import os
import re
import shutil
import socket
import subprocess
import sys
import tempfile

import yaml

try:
    import oracledb
except ImportError:  # only needed for --compile
    oracledb = None

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sync_sql_to_yaml import (  # noqa: E402
    BASE_DIR, BIND_RE, DEFAULT_YAML, SYSTEMS, VALID_TYPES, strip_literals_and_comments, sync_system,
)


def validate_config(system, filename=DEFAULT_YAML):
    """Returns a list of problems found in <system>/<filename>."""
    yaml_file = os.path.join(BASE_DIR, system, filename)
    with open(yaml_file, encoding="utf-8") as f:
        data = yaml.safe_load(f)

    problems = []
    sources = data.get("sources") or {}
    tools = data.get("tools") or {}
    toolsets = data.get("toolsets") or {}

    if not sources:
        problems.append("no sources defined")
    for sname, sdef in sources.items():
        if "connectionString" not in sdef:
            problems.append(f"source {sname}: missing 'connectionString'")
        for key in ("host", "port", "service_name"):
            if key in sdef:
                problems.append(f"source {sname}: illegal '{key}'; connection details belong in connectionString")
        if sdef.get("kind") != "oracle":
            problems.append(f"source {sname}: expected kind 'oracle', got {sdef.get('kind')!r}")

    if not tools:
        problems.append("no tools defined")
    for name, tdef in tools.items():
        if tdef.get("kind") != "oracle-sql":
            problems.append(f"{name}: expected kind 'oracle-sql', got {tdef.get('kind')!r}")
        if tdef.get("source") not in sources:
            problems.append(f"{name}: unknown source {tdef.get('source')!r}")
        if not (tdef.get("description") or "").strip():
            problems.append(f"{name}: missing description")

        stmt = tdef.get("statement") or ""
        if not stmt.strip():
            problems.append(f"{name}: empty statement")
            continue
        code, _ = strip_literals_and_comments(stmt)
        if re.match(r"\s*(DECLARE|BEGIN)\b", code, re.IGNORECASE):
            if not code.rstrip().upper().endswith("END;"):
                problems.append(f"{name}: PL/SQL block must end with 'END;'")
        elif stmt.strip().endswith(";"):
            problems.append(f"{name}: statement must not end with ';' in tools.yaml")

        used = BIND_RE.findall(code)
        declared = []
        for p in tdef.get("parameters") or []:
            pname = p.get("name")
            declared.append(pname)
            if p.get("type") not in VALID_TYPES:
                problems.append(f"{name}: parameter {pname} has unsupported type {p.get('type')!r}")
            count = used.count(pname)
            if count != 1:
                problems.append(f"{name}: bind :{pname} appears {count} times in statement (expected exactly 1)")
        for u in sorted(set(used) - set(declared)):
            problems.append(f"{name}: bind :{u} is used but not declared under parameters")
        if sorted(used) == sorted(declared) and used != declared:
            problems.append(f"{name}: parameters are not in statement bind order {used} (Toolbox binds by position)")

    auth_defined = data.get("authServices") or {}
    for name, tdef in tools.items():
        for svc in tdef.get("authRequired") or []:
            if svc not in auth_defined:
                problems.append(f"{name}: authRequired names undefined auth service {svc!r}")
        for p in tdef.get("parameters") or []:
            for binding in p.get("authServices") or []:
                if binding.get("name") not in auth_defined:
                    problems.append(f"{name}: parameter {p.get('name')} uses undefined auth service {binding.get('name')!r}")

    membership = {}
    for ts_name, members in toolsets.items():
        for t in members or []:
            if t not in tools:
                problems.append(f"toolset {ts_name}: references unknown tool {t}")
            membership.setdefault(t, []).append(ts_name)
    for name in tools:
        sets = membership.get(name, [])
        if len(sets) != 1:
            problems.append(f"{name}: belongs to {len(sets)} toolsets {sets} (expected exactly 1)")

    return problems, len(tools), len(toolsets)


# DBMS_SQL.PARSE checks a query's syntax, tables and columns without running it. Oracle compiles an anonymous
# PL/SQL block (the security wrapper) only when it is executed, and executing it would run the wrapper, so for
# blocks the query inside 'OPEN cursor FOR ...' is parsed this way and the packages the block calls are checked
# in the dictionary instead (see plan_checks).
PARSE_BLOCK = """
DECLARE
    c INTEGER := DBMS_SQL.OPEN_CURSOR;
BEGIN
    DBMS_SQL.PARSE(c, :stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.CLOSE_CURSOR(c);
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(c) THEN DBMS_SQL.CLOSE_CURSOR(c); END IF;
        RAISE;
END;"""
PROC_SQL = ("SELECT COUNT(*) FROM all_procedures WHERE owner = UPPER(:o) AND object_name = UPPER(:p) "
            "AND procedure_name = UPPER(:r)")

BLOCK_QUERY_RE = re.compile(r"\bOPEN\s+\w+\s+FOR\s+(.+?)\s*;\s*(?:--[^\n]*\n\s*)*(?:DBMS_SQL\s*\.\s*RETURN_RESULT|END\s*;)", re.IGNORECASE | re.DOTALL)
BLOCK_CALL_RE = re.compile(r"\b([A-Za-z][\w$#]*)\s*\.\s*([A-Za-z][\w$#]*)\s*\.\s*([A-Za-z][\w$#]*)\s*\(")
ENV_VAR_RE = re.compile(r"\$\{(\w+)(?::([^}]*))?\}")


class CompileSetupError(Exception):
    """The database to compile against could not be determined or reached."""


def read_env_file(path):
    values = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.match(r'\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*?)\s*$', line)
            if m and not line.lstrip().startswith("#"):
                v = m.group(2).strip()
                if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
                    v = v[1:-1]  # one pair of surrounding quotes, nothing else: passwords may contain quotes, $ or #
                values[m.group(1)] = v
    return values


def expand_env_vars(text, env):
    """Expands ${VAR} and ${VAR:default} the way the Toolbox does when it loads tools.yaml."""
    def repl(m):
        value = env.get(m.group(1))
        if value:
            return value
        if m.group(2) is None:
            raise CompileSetupError(f"environment variable {m.group(1)} is not set (used in tools.yaml as ${{{m.group(1)}}})")
        return m.group(2)
    return ENV_VAR_RE.sub(repl, text)


def stub_is_running():
    port = int(os.environ.get("JDE_STUB_PORT", "1531"))
    try:
        with socket.create_connection(("localhost", port), timeout=1):
            return True
    except OSError:
        return False


def compile_target(system):
    """Returns (user, password, dsn, where, env): the database to compile this system's statements against, and the
    environment (process variables over <system>/.env and <system>/.env.database) used to expand ${VAR:default} placeholders in the statements."""
    file_env = {}
    for name in (".env", ".env.database"):  # credentials file last: it wins
        env_path = os.path.join(BASE_DIR, system, name)
        if os.path.exists(env_path):
            file_env.update(read_env_file(env_path))
    env = {**file_env, **os.environ}
    prefix = system.upper() + "_"
    over = {k: os.environ.get(prefix + k) for k in ("DB_USER", "DB_PASSWORD", "DB_CONNECTION_STRING")}
    if all(over.values()):
        return over["DB_USER"], over["DB_PASSWORD"], over["DB_CONNECTION_STRING"], f"{prefix}DB_* environment", env
    if system == "jde" and stub_is_running():
        port = os.environ.get("JDE_STUB_PORT", "1531")
        # the stub's schemas are the default names
        env = {k: v for k, v in env.items() if k not in ("JDE_DATA_SCHEMA", "JDE_CTL_SCHEMA")}
        return "JDE_AI", os.environ.get("JDE_STUB_PASSWORD", "StubPwd_2026"), f"localhost:{port}/FREEPDB1", "local JDE stub database", env
    if all(file_env.get(k) for k in ("DB_USER", "DB_PASSWORD", "DB_CONNECTION_STRING")):
        return file_env["DB_USER"], file_env["DB_PASSWORD"], file_env["DB_CONNECTION_STRING"], f"{system}/.env.database", env
    raise CompileSetupError(
        f"no database configured: set {prefix}DB_USER, {prefix}DB_PASSWORD and {prefix}DB_CONNECTION_STRING, "
        f"or fill in {system}/.env.database (./scripts/deploy_mcp_server.sh --system {system} --init-env)" + (", or start the stub with scripts/test_stub_jde.py" if system == "jde" else "")
    )


def plan_checks(tools, env):
    """Turns the tool statements into checks: ('parse', tool, sql) and ('proc', tool, (owner, package, procedure)).
    Returns (checks, notes). ${VAR:default} placeholders are expanded first."""
    checks, notes = [], []
    for name, tdef in tools.items():
        statement = expand_env_vars(tdef.get("statement") or "", env)
        code, _ = strip_literals_and_comments(statement)
        if re.match(r"\s*(DECLARE|BEGIN)\b", code, re.IGNORECASE):
            for call in sorted(set(BLOCK_CALL_RE.findall(code))):
                checks.append(("proc", name, call))
            m = BLOCK_QUERY_RE.search(statement)
            if m:
                checks.append(("parse", name, m.group(1)))
            else:
                notes.append(f"{name}: PL/SQL block has no 'OPEN cursor FOR query;' that could be parsed; only package names were checked")
        else:
            checks.append(("parse", name, statement))
    return checks, notes


def _first_line(e):
    return str(e).strip().splitlines()[0] if str(e).strip() else repr(e)


def run_checks_oracledb(user, password, dsn, checks):
    """Returns [(tool, problem)]. Raises CompileSetupError if the connection fails."""
    try:
        con = oracledb.connect(user=user, password=password, dsn=dsn, tcp_connect_timeout=8)
    except oracledb.Error as e:
        err = CompileSetupError(f"cannot connect to {dsn} as {user}: {_first_line(e)}")
        err.verifier_unsupported = "DPY-3015" in str(e)  # old password verifier: thin mode cannot connect
        raise err
    problems = []
    with con:
        cur = con.cursor()
        for kind, name, payload in checks:
            if kind == "proc":
                owner, package, proc = payload
                cur.execute(PROC_SQL, o=owner, p=package, r=proc)
                if cur.fetchone()[0] == 0:
                    problems.append((name, f"{owner}.{package}.{proc} not found (or no EXECUTE privilege) in the database"))
                continue
            try:
                cur.execute(PARSE_BLOCK, stmt=payload)
            except oracledb.Error as e:
                problems.append((name, _first_line(e)))
    return problems


def sqlcl_quote(text):
    for delim in "~!^#|@%":
        if delim + "'" not in text:
            return f"q'{delim}{text}{delim}'"
    raise CompileSetupError("a statement contains every quote delimiter the SQLcl fallback can use")


def run_checks_sqlcl(user, password, dsn, checks):
    """Same checks through SQLcl (`sql`), for databases python-oracledb thin mode cannot log in to.
    One PL/SQL block calls DBMS_SQL.PARSE per statement and prints a line per result. Returns [(tool, problem)]."""
    sqlcl = shutil.which("sql")
    if not sqlcl:
        raise CompileSetupError("python-oracledb cannot connect and SQLcl (`sql`) is not on PATH for the fallback")
    lines = [
        "DECLARE",
        "  PROCEDURE chk(p_id PLS_INTEGER, p_sql VARCHAR2) IS c INTEGER;",
        "  BEGIN",
        "    c := DBMS_SQL.OPEN_CURSOR;",
        "    DBMS_SQL.PARSE(c, p_sql, DBMS_SQL.NATIVE);",
        "    DBMS_SQL.CLOSE_CURSOR(c);",
        "    DBMS_OUTPUT.PUT_LINE('CHK|' || p_id || '|OK');",
        "  EXCEPTION WHEN OTHERS THEN",
        "    IF DBMS_SQL.IS_OPEN(c) THEN DBMS_SQL.CLOSE_CURSOR(c); END IF;",
        "    DBMS_OUTPUT.PUT_LINE('CHK|' || p_id || '|' || REPLACE(REPLACE(SQLERRM, CHR(10), ' '), CHR(13), ' '));",
        "  END;",
        "  PROCEDURE proc(p_id PLS_INTEGER, p_o VARCHAR2, p_p VARCHAR2, p_r VARCHAR2) IS n NUMBER;",
        "  BEGIN",
        "    SELECT COUNT(*) INTO n FROM all_procedures WHERE owner = UPPER(p_o) AND object_name = UPPER(p_p) AND procedure_name = UPPER(p_r);",
        "    DBMS_OUTPUT.PUT_LINE('CHK|' || p_id || '|' || CASE WHEN n = 0 THEN 'NOTFOUND' ELSE 'OK' END);",
        "  END;",
        "BEGIN",
    ]
    for i, (kind, name, payload) in enumerate(checks):
        if kind == "proc":
            lines.append(f"  proc({i}, '{payload[0]}', '{payload[1]}', '{payload[2]}');")
        else:
            lines.append(f"  chk({i}, {sqlcl_quote(payload)});")
    lines += ["END;", "/"]
    script = "\n".join([
        f'connect {user}/"{password}"@{dsn}',
        "SET SERVEROUTPUT ON SIZE UNLIMITED", "SET SQLBLANKLINES ON", "SET DEFINE OFF", "SET FEEDBACK OFF", "SET HEADING OFF",
        "SET LINESIZE 4000", "SET TRIMOUT ON", "SET SQLPROMPT ''",
    ] + lines + ["EXIT"]) + "\n"
    with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False) as f:  # mode 0600; holds the password
        f.write(script)
    try:
        proc = subprocess.run([sqlcl, "-S", "-L", "/nolog", "@" + f.name], capture_output=True, text=True, timeout=300)
    finally:
        os.unlink(f.name)
    results = {}
    for line in proc.stdout.splitlines():
        if line.startswith("CHK|"):
            _, idx, msg = line.split("|", 2)
            results[int(idx)] = msg.strip()
    if not results:
        detail = [l for l in (proc.stdout + proc.stderr).splitlines() if "ORA-" in l or "Error" in l or "SP2-" in l]
        raise CompileSetupError(f"SQLcl could not connect to {dsn} as {user}: " + (detail[0].strip() if detail else "no output"))
    problems = []
    for i, (kind, name, payload) in enumerate(checks):
        msg = results.get(i, "no result")
        if msg == "OK":
            continue
        if kind == "proc":
            problems.append((name, f"{payload[0]}.{payload[1]}.{payload[2]} not found (or no EXECUTE privilege) in the database"))
        else:
            problems.append((name, msg.splitlines()[0]))
    return problems


def compile_statements(system, filename):
    """Parses every tool statement of <system>/<filename> in the database. Returns (problems, count, where)."""
    user, password, dsn, where, env = compile_target(system)
    with open(os.path.join(BASE_DIR, system, filename), encoding="utf-8") as f:
        tools = (yaml.safe_load(f) or {}).get("tools") or {}
    checks, notes = plan_checks(tools, env)
    for note in notes:
        print(f"    [note] {note}")
    via = "python-oracledb"
    try:
        if oracledb is None:
            raise CompileSetupError("python-oracledb is not installed (pip install -r requirements.txt)")
        found = run_checks_oracledb(user, password, dsn, checks)
    except CompileSetupError as e:
        if oracledb is not None and not getattr(e, "verifier_unsupported", False):
            raise
        print(f"    [note] {system}: {e}; using SQLcl instead")
        found = run_checks_sqlcl(user, password, dsn, checks)
        via = "SQLcl"
    problems = [f"{name}: does not compile: {msg}" for name, msg in found]
    return problems, len(tools), f"{user}@{dsn} ({where}, via {via})"


# Generated secured variants, in generation order: (file, seed file, sync options)
AGENT_YAML, SEC_YAML = "tools_agent.yaml", "tools_sec.yaml"


def generate_variants(system):
    """Writes <system>/tools_agent.yaml from tools.yaml, then <system>/tools_sec.yaml from tools_agent.yaml.
    Returns a list of error strings (empty on success)."""
    steps = [
        (AGENT_YAML, DEFAULT_YAML, "agent"),
        (SEC_YAML, AGENT_YAML, "token"),
    ]
    for out, seed, identity in steps:
        gen_args = argparse.Namespace(check=False, diff=False, prune=False, no_input=True, wrap=True,
                                      identity=identity, seed_from=seed, out=out)
        drift, errors = sync_system(system, gen_args)
        if errors:
            return [f"cannot generate {system}/{out}: {e}" for e in errors]
        print(f"    [gen] {system}/{out} ({'agent' if identity == 'agent' else 'token'} identity): "
              + (f"{len(drift)} change(s)" if drift else "up to date"))
    return []


def validate_file(system, filename, do_compile):
    """Validates <system>/<filename>. Returns True when everything passed."""
    sync_args = argparse.Namespace(check=True, diff=False, prune=False, no_input=True, wrap=None, out=filename)
    print(f"[*] Validating {system}/{filename}...")
    if not os.path.exists(os.path.join(BASE_DIR, system, filename)):
        print(f"    [FAIL] {system}/{filename} does not exist")
        return False
    drift, errors = sync_system(system, sync_args)
    problems = [f"SQL file error: {e}" for e in errors]
    problems += [f"out of sync with SQL files: {d}" for d in drift]
    config_problems, n_tools, n_toolsets = validate_config(system, filename)
    problems += config_problems
    compiled = ""
    if do_compile:
        try:
            compile_problems, n_compiled, where = compile_statements(system, filename)
            problems += compile_problems
            compiled = f"; {n_compiled} compiled on {where}"
        except CompileSetupError as e:
            problems.append(f"cannot compile: {e} (use --nocompile to skip this check)")
    else:
        print(f"    [skip] {system}/{filename}: statements not compiled")

    if problems:
        for p in problems:
            print(f"    [FAIL] {p}")
        if drift and not errors:
            out_flag = f" --out {filename}" if filename != DEFAULT_YAML else ""
            print(f"    -> run: python3 scripts/sync_sql_to_yaml.py{out_flag}")
        return False
    print(f"[+] {system}/{filename}: {n_tools} tools across {n_toolsets} toolsets validated{compiled}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Validate MCP Toolbox configs against the SQL source files, and "
                                     "generate the tools_agent.yaml and tools_sec.yaml variants.")
    parser.add_argument("--system", choices=SYSTEMS, action="append", help="limit to one system (repeatable)")
    parser.add_argument("--config", metavar="FILENAME", default=None,
                        help=f"validate only <system>/FILENAME (e.g. a --out test file); generates nothing")
    parser.add_argument("--no-generate", dest="generate", action="store_false",
                        help="do not (re)generate tools_agent.yaml and tools_sec.yaml")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--compile", dest="compile", action="store_true", default=True,
                       help="(default) also parse every statement of tools.yaml in each system's database")
    group.add_argument("--nocompile", dest="compile", action="store_false",
                       help="skip the database check (CI, or no database reachable)")
    parser.add_argument("--compile-variants", action="store_true",
                        help="also compile the generated variants. Their wrapper calls a security package "
                             "(for example apps.xx_ai_security_pkg) that must exist in the database")
    args = parser.parse_args()

    failed = False
    for system in args.system or SYSTEMS:
        if args.config:
            failed |= not validate_file(system, args.config, args.compile)
            continue
        files = [(DEFAULT_YAML, args.compile)]
        if args.generate:
            print(f"[*] Generating {system} variants...")
            errors = generate_variants(system)
            for e in errors:
                print(f"    [FAIL] {e}")
            if errors:
                failed = True
                continue
            files += [(AGENT_YAML, args.compile and args.compile_variants),
                      (SEC_YAML, args.compile and args.compile_variants)]
        for filename, do_compile in files:
            failed |= not validate_file(system, filename, do_compile)

    if failed:
        sys.exit(1)
    print("\n[SUCCESS] All configurations validated.")


if __name__ == "__main__":
    main()
