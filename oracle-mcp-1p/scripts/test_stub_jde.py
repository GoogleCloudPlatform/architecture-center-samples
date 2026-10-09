#!/usr/bin/env python3
"""
test_stub_jde.py

Tests every JD Edwards tool (jde/sql/*.sql) against a local stub JDE database, for when no
live JDE system is available.

The stub is an Oracle Database Free container with the PRODDTA / PRODCTL tables from
jde/stub/schema.sql (only the columns the tools use; JDE 9.2 names, types and lengths, NCHAR
strings as in a Unicode JDE database) and the scenario in jde/stub/seed.sql. Each run drops
and rebuilds both schemas, so edits to either file take effect immediately.

Checks, per tool:
- the statement runs as the read-only JDE_AI user and returns at least the expected rows;
- key values in the result match the seed scenario (Julian dates, implied decimals, lookups);
- with --toolbox: the same through 'toolbox invoke' and jde/tools.yaml (go-ora, positional binds);
- with --wrap: the statement inside jde/templates/plsql_wrapper.sql, with a no-op security package.

Usage:
    python3 scripts/test_stub_jde.py                  # start the container if needed, test directly
    python3 scripts/test_stub_jde.py --toolbox --wrap # also through toolbox and the PL/SQL wrapper
    python3 scripts/test_stub_jde.py --stop           # stop the container when done

The first start pulls container-registry.oracle.com/database/free:latest-lite (about 1 GB, no
login needed) and takes a minute or two; later runs reuse the container. Needs Docker, and
python-oracledb (pip install -r requirements.txt).

Environment (all optional): JDE_STUB_PORT (default 1531, so it can't clash with a tunnel on
1521), JDE_STUB_PASSWORD (default below; a throwaway local password, not a real credential).

Exit codes: 0 all passed; 1 a tool failed; 2 setup failed (Docker, database or stub SQL files).
"""

import argparse
import glob
import json
import os
import re
import subprocess
import sys
import time

import oracledb

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sync_sql_to_yaml import BASE_DIR, SqlFileError, parse_sql_file, parse_wrapper, render_wrapper  # noqa: E402

CONTAINER = "jde-stub-db"
IMAGE = "container-registry.oracle.com/database/free:latest-lite"
PORT = int(os.environ.get("JDE_STUB_PORT", "1531"))
PASSWORD = os.environ.get("JDE_STUB_PASSWORD", "StubPwd_2026")
DSN = f"localhost:{PORT}/FREEPDB1"
STUB_DIR = os.path.join(BASE_DIR, "jde", "stub")
JDE_YAML = os.path.join(BASE_DIR, "jde", "tools.yaml")
WRAPPER = os.path.join(BASE_DIR, "jde", "templates", "plsql_wrapper.sql")

# tool: (parameters, minimum rows, {column: value expected in the first row})
SAMPLES = {
    "jde_get_customer_notice_details": (
        {"doc_number": 84920, "doc_type": "", "company": "1"}, 1,
        {"notice_date": "2026-09-01", "billed_amount": 1250, "outstanding_balance": 1000,
         "pay_status_description": "Approved - open", "program_or_grant_name": "Federal Grant 2024 Vaccination",
         "disputed_amount": 250}),
    "jde_get_media_object_attachment": (
        {"object_name": "GT03B11", "text_key": "84920", "sequence": ""}, 1,
        {"text_key": "00001|RI|84920|001", "content_kind": "TEXT"}),
    "jde_search_foia_records": (
        {"search_keyword": "", "category": "ALL", "start_date": "2015-01-01", "end_date": "2026-12-31", "company": "00001"}, 4,
        {"record_category": "AP", "reference_id": "9001", "record_summary": "Voucher for invoice INV-778"}),
    "jde_get_employee_personnel_file": (
        {"employee_an8": "", "employee_number": "E3001"}, 1,
        {"first_name": "John", "date_of_birth": "1980-04-09", "home_address": "12 Main St", "annual_salary": 65000,
         "hourly_rate": 31.25, "hr_history": "2020-01-01 JBST=II (reason PRO)"}),
    "jde_get_agency_policy_rules": (
        {"policy_category": "ALL", "rule_name": ""}, 3,
        {"policy_category": "AUDIT", "threshold_amount": 1000, "rate_or_percent": 20}),
    "jde_search_policy_documents": (
        {"keyword": "travel", "object_name": "", "document_type": ""}, 1,
        {"policy_title": "Travel Policy Manual", "document_type": "POLICY", "effective_from": "2026-01-01"}),
    "jde_get_intake_attachments": (
        {"applicant_an8": "1001", "object_name": "", "document_type": "PAYSTB"}, 1,
        {"applicant_name": "Jane Q. Citizen", "verification_status": "PEND", "content_kind": "FILE_OR_LINK"}),
    "jde_verify_address_book_identity": (
        # SHA-256 of '123-45-6789', the seeded tax ID
        {"legal_name": "Jane Q. Citizen", "tax_id_hash": "01A54629EFB952287E554EB23EF69C52097A75AECC0E3A93CA0855AB6D7A31A0",
         "postal_code": "12207", "an8": ""}, 1,
        {"name_match_confidence": 100, "tax_id_hash_verification": "VERIFIED_MATCH", "postal_code_verification": "VERIFIED_MATCH"}),
    "jde_get_rfq_details": (
        {"order_number": 7001, "order_type": "", "order_company": ""}, 1,
        {"estimated_unit_cost": 12.5, "suppliers_invited": 2, "response_due_date": "2026-08-31"}),
    "jde_get_supplier_quotes": (
        {"order_number": 7001, "order_type": "", "supplier_an8": ""}, 2,
        {"supplier_name": "Beta Health Partners", "quoted_unit_price": 11.25, "response_timeliness": "LATE"}),
    "jde_get_expense_reports": (
        {"report_number": "", "employee_an8": "3001", "start_date": "2026-09-28", "end_date": "2026-09-30"}, 1,
        {"expense_amount": 450, "policy_status": "EXCEPTION: OVR", "policy_daily_allowance": 150}),
    "jde_get_voucher_match": (
        {"voucher_number": "", "company": "", "po_number": "7002", "supplier_invoice": ""}, 1,
        {"quantity_received": 900, "amount_vouchered": 11250, "match_variance": 1125,
         "three_way_match_status": "BILLED_OVER_RECEIVED", "grant_subledger": "00012024 (A)"}),
    "jde_list_business_units": (
        {"name_pattern": "%GRANT%", "company": ""}, 1,
        {"business_unit": "GR2024", "company_name": "State Department of Health"}),
    "jde_list_media_object_types": (
        {"keyword": ""}, 3,
        {}),
    "jde_list_udc_values": (
        {"product_code": "00", "udc_type": "DT", "keyword": ""}, 2,
        {"code": "OQ", "udc_type_description": "Document Type"}),
    "jde_lookup_address_book": (
        {"search_name": "a", "search_type": "V"}, 2,
        {"party_name": "Acme Medical Supply", "postal_code": "12207"}),
    "jde_lookup_employees": (
        {"name_keyword": "smith", "employee_number": ""}, 1,
        {"ssn_masked": "XXX-XX-3456"}),
    "jde_lookup_recent_transactions": (
        {"doc_type": "QUOTE", "doc_number": "7001", "company": ""}, 1,
        {"doc_type": "QUOTE", "doc_date": "2026-08-01"}),
}


class SetupError(Exception):
    pass


def docker(*args, check=True):
    proc = subprocess.run(["docker", *args], capture_output=True, text=True)
    if check and proc.returncode != 0:
        raise SetupError(f"docker {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc


def ensure_container():
    try:
        state = docker("inspect", "-f", "{{.State.Running}}", CONTAINER, check=False)
    except FileNotFoundError:
        raise SetupError("docker is not installed or not on PATH")
    if state.returncode != 0:
        print(f"[*] Creating container {CONTAINER} from {IMAGE} on port {PORT} (first run pulls the image)...")
        docker("run", "-d", "--name", CONTAINER, "-p", f"{PORT}:1521", "-e", f"ORACLE_PWD={PASSWORD}", IMAGE)
    elif state.stdout.strip() != "true":
        print(f"[*] Starting container {CONTAINER}...")
        docker("start", CONTAINER)
    deadline = time.time() + 600
    while True:
        try:
            return oracledb.connect(user="system", password=PASSWORD, dsn=DSN)
        except oracledb.Error as e:
            if time.time() > deadline:
                raise SetupError(f"database at {DSN} not ready after 10 minutes: {e}")
            time.sleep(5)


def sql_statements(path):
    """Splits a stub .sql file into statements (one per ';' at end of line; no PL/SQL)."""
    with open(path, encoding="utf-8") as f:
        text = "\n".join(line for line in f.read().splitlines() if not line.lstrip().startswith("--"))
    return [s.strip() for s in re.split(r";\s*$", text, flags=re.M) if s.strip()]


def build(con):
    cur = con.cursor()
    for user in ("JDE_AI", "PRODDTA", "PRODCTL"):
        cur.execute("SELECT COUNT(*) FROM dba_users WHERE username = :u", u=user)
        if cur.fetchone()[0]:
            cur.execute(f"DROP USER {user} CASCADE")
        cur.execute(f'CREATE USER {user} IDENTIFIED BY "{PASSWORD}"')
    cur.execute("GRANT UNLIMITED TABLESPACE TO PRODDTA, PRODCTL")
    cur.execute("GRANT CREATE SESSION TO JDE_AI")
    tables = []
    for stmt in sql_statements(os.path.join(STUB_DIR, "schema.sql")):
        try:
            cur.execute(stmt)
        except oracledb.DatabaseError as e:
            raise SetupError(f"jde/stub/schema.sql: {e}\n    in: {stmt.splitlines()[0]}")
        tables.append(re.match(r"CREATE TABLE (\S+)", stmt, re.I).group(1))
    for table in tables:
        cur.execute(f"GRANT SELECT ON {table} TO JDE_AI")
    for stmt in sql_statements(os.path.join(STUB_DIR, "seed.sql")):
        try:
            cur.execute(stmt)
        except oracledb.DatabaseError as e:
            raise SetupError(f"jde/stub/seed.sql: {e}\n    in: {stmt[:120]}")
    con.commit()
    print(f"[+] Built {len(tables)} stub tables in PRODDTA/PRODCTL and loaded jde/stub/seed.sql")


def stub_security_package(con, wrapper_body):
    """Creates a no-op version of the package the wrapper calls, e.g. jde_ai.xx_ai_security_pkg."""
    m = re.search(r"(\w+)\.(\w+)\.(\w+)\s*\(\s*:user_id\s*\)", wrapper_body)
    if not m:
        raise SetupError("could not find '<schema>.<package>.<procedure>(:user_id)' in the wrapper template")
    owner, pkg, proc = m.groups()
    cur = con.cursor()
    cur.execute(f"CREATE OR REPLACE PACKAGE {owner}.{pkg} AS PROCEDURE {proc}(p_user_id VARCHAR2); END;")
    cur.execute(f"CREATE OR REPLACE PACKAGE BODY {owner}.{pkg} AS PROCEDURE {proc}(p_user_id VARCHAR2) IS BEGIN NULL; END; END;")


def plain(value):
    if hasattr(value, "read"):
        value = value.read()
    return value.decode(errors="replace") if isinstance(value, bytes) else value


def check(rows, min_rows, expected):
    """Returns a list of problems with a result given as a list of {column: value} dicts."""
    problems = []
    if len(rows) < min_rows:
        problems.append(f"expected at least {min_rows} row(s), got {len(rows)}")
    if rows:
        for col, want in expected.items():
            got = rows[0].get(col)
            if isinstance(want, (int, float)) and isinstance(got, (int, float)):
                ok = abs(got - want) < 1e-9
            else:
                ok = got == want
            if not ok:
                problems.append(f"{col}: expected {want!r}, got {got!r}")
    return problems


def run_direct(specs, statement_for, extra_binds):
    failed = 0
    for name, spec in specs.items():
        args, min_rows, expected = SAMPLES[name]
        binds = {**extra_binds, **{k: (None if v == "" else v) for k, v in args.items()}}
        try:
            with oracledb.connect(user="JDE_AI", password=PASSWORD, dsn=DSN) as con:
                cur = con.cursor()
                cur.execute(statement_for(spec), binds)
                cursors = cur.getimplicitresults() if extra_binds else [cur]
                rows = []
                for c in cursors:
                    cols = [d[0].lower() for d in c.description]
                    rows += [{k: plain(v) for k, v in zip(cols, r)} for r in c.fetchall()]
            problems = check(rows, min_rows, expected)
        except oracledb.DatabaseError as e:
            problems = [str(e).splitlines()[0]]
        failed += report(name, problems)
    return failed


def run_toolbox(specs):
    with open(JDE_YAML, encoding="utf-8") as f:
        text = f.read()
    if re.search(r"^\s*authRequired:", text, re.M):
        print("    [skip] jde/tools.yaml is wrapped; 'toolbox invoke' can't send an ID token (use --wrap instead)")
        return 0
    env = {**os.environ, "DB_CONNECTION_STRING": DSN, "DB_USER": "JDE_AI", "DB_PASSWORD": PASSWORD,
           "JDE_DATA_SCHEMA": "proddta", "JDE_CTL_SCHEMA": "prodctl"}  # the stub uses the default schema names
    failed = 0
    for name in specs:
        args, min_rows, expected = SAMPLES[name]
        proc = subprocess.run(["toolbox", "invoke", name, json.dumps(args), "--config", JDE_YAML],
                              capture_output=True, text=True, env=env)
        payload = "\n".join(line for line in proc.stdout.splitlines() if not line[:4].isdigit()).strip()
        if proc.returncode != 0:
            errors = [line for line in (proc.stderr + proc.stdout).splitlines() if "ERROR" in line or "Error:" in line]
            problems = [(errors[-1] if errors else "toolbox exited with " + str(proc.returncode)).strip()]
        else:
            try:
                rows = json.loads(payload) if payload else []
            except json.JSONDecodeError:
                rows, payload = None, payload[:200]
            problems = check(rows, min_rows, {}) if isinstance(rows, list) else [f"unexpected output: {payload}"]
        failed += report(name, problems)
    return failed


def report(name, problems):
    if problems:
        print(f"    [FAIL] {name}")
        for p in problems:
            print(f"           -> {p}")
        return 1
    print(f"    [PASS] {name}")
    return 0


def main():
    parser = argparse.ArgumentParser(description="Test the JD Edwards tools against a local stub database.")
    parser.add_argument("--toolbox", action="store_true", help="also run each tool through 'toolbox invoke' and jde/tools.yaml")
    parser.add_argument("--wrap", action="store_true", help="also run each tool inside jde/templates/plsql_wrapper.sql")
    parser.add_argument("--stop", action="store_true", help="stop the container when done")
    args = parser.parse_args()

    specs, errors = {}, []
    for path in sorted(glob.glob(os.path.join(BASE_DIR, "jde", "sql", "*.sql"))):
        try:
            spec = parse_sql_file(path)
        except SqlFileError as e:
            errors.append(f"{os.path.relpath(path, BASE_DIR)}: {e}")
            continue
        if spec["name"] not in SAMPLES:
            errors.append(f"{spec['name']}: no entry in SAMPLES at the top of scripts/test_stub_jde.py; add one")
            continue
        specs[spec["name"]] = spec
    if errors:
        for e in errors:
            print(f"[!] {e}")
        sys.exit(2)

    try:
        con = ensure_container()
        build(con)
        wrapper = parse_wrapper(WRAPPER) if args.wrap else None
        if wrapper:
            stub_security_package(con, wrapper["body"])
        con.close()
    except (SetupError, SqlFileError, oracledb.Error) as e:
        print(f"[!] Setup failed: {e}")
        sys.exit(2)

    print(f"\n[*] Running {len(specs)} tools directly as JDE_AI...")
    failed = run_direct(specs, lambda s: s["statement"], {})
    if args.toolbox:
        print(f"\n[*] Running {len(specs)} tools through 'toolbox invoke' ({os.path.relpath(JDE_YAML, BASE_DIR)})...")
        failed += run_toolbox(specs)
    if wrapper:
        print(f"\n[*] Running {len(specs)} tools inside the PL/SQL wrapper (no-op security package)...")
        failed += run_direct(specs, lambda s: render_wrapper(wrapper, s["statement"]), {"user_id": "tester@example.gov"})

    if args.stop:
        docker("stop", CONTAINER, check=False)
        print(f"\n[*] Stopped {CONTAINER}")
    print(f"\n{'[SUCCESS] All checks passed.' if not failed else f'[FAILED] {failed} check(s) failed.'}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
