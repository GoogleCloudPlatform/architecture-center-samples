#!/usr/bin/env python3
"""
test_live_ebs.py

Validates every Oracle EBS SQL file (ebs/sql/*.sql) against the live EBS database
using SQLcl by running EXPLAIN PLAN FOR with declared bind variables.

Connection is read from DB_USER, DB_PASSWORD and DB_CONNECTION_STRING.
"""

import subprocess
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sync_sql_to_yaml import BASE_DIR, SqlFileError, parse_sql_file  # noqa: E402

EBS_SQL_DIR = os.path.join(BASE_DIR, "ebs", "sql")
DB_USER = os.environ.get("DB_USER", "apps_ai")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "apps_ai")
DB_CONNECTION = os.environ.get("DB_CONNECTION_STRING", "apps.example.com:1521/EBSDB")
SQLCL_CONN = f"{DB_USER}/{DB_PASSWORD}@{DB_CONNECTION}"


def load_definitions():
    definitions = {}
    for fname in sorted(os.listdir(EBS_SQL_DIR)):
        if fname.endswith(".sql"):
            try:
                spec = parse_sql_file(os.path.join(EBS_SQL_DIR, fname))
            except SqlFileError as e:
                print(f"[!] ebs/sql/{fname}: {e}")
                sys.exit(2)
            definitions[spec["name"]] = spec
    return definitions


def test_tool(tool_name, tool_data):
    params = tool_data["parameters"]
    sql = tool_data["statement"]

    # Build VAR declarations
    var_decls = []
    for p in params:
        pname = p["name"]
        ptype = p["type"]
        if ptype == "integer":
            var_decls.append(f"VAR {pname} NUMBER;")
        else:
            var_decls.append(f"VAR {pname} VARCHAR2(4000);")

    script = "SET SQLBLANKLINES ON;\n"
    script += "\n".join(var_decls) + "\n"
    script += f"EXPLAIN PLAN FOR\n{sql};\n"
    script += "EXIT;\n"

    cmd = ["sql", "-s", SQLCL_CONN]
    proc = subprocess.run(cmd, input=script, text=True, capture_output=True)

    output = proc.stdout + proc.stderr
    if "Explained." in output:
        return True, "EXPLAINED OK"
    else:
        # Extract error
        err_lines = [l for l in output.splitlines() if "ORA-" in l or "Error" in l or "SP2-" in l]
        return False, "\n".join(err_lines) if err_lines else output.strip()


def main():
    definitions = load_definitions()
    print(f"[*] Testing {len(definitions)} EBS SQL statements against live DB: {DB_USER}@{DB_CONNECTION}...\n")
    passed = 0
    failed = 0

    for name, data in definitions.items():
        ok, msg = test_tool(name, data)
        if ok:
            print(f"  [PASS] {name}")
            passed += 1
        else:
            print(f"  [FAIL] {name}\n         -> {msg}\n")
            failed += 1

    print(f"\nSummary: {passed} passed, {failed} failed out of {len(definitions)} tools.")
    if failed > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
