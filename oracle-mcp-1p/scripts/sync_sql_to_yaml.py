#!/usr/bin/env python3
"""
sync_sql_to_yaml.py

Detects drift between the standalone SQL files maintained by functional analysts
(ebs/sql/*.sql, peoplesoft/sql/*.sql) and the MCP Toolbox configs (*/tools.yaml),
and merges the SQL changes into tools.yaml.

Source of truth:
- <system>/sql/<tool>.sql owns each tool's statement, bind parameters and skill.
- <system>/sql/<tool>.txt (optional) owns the tool's description.
- <system>/tools.yaml owns sources, descriptions of tools without a .txt file, and any extra keys.

Disabled tools: a line starting with "DISABLED:" in <tool>.txt (the rest of the line is the
reason) keeps the .sql and .txt files but leaves the tool out of tools.yaml and its toolsets,
and removes it if it is already there. The line is not part of the description. Delete the
line to enable the tool again. The SQL file is still parsed, so header errors are reported.

New tools: adding <system>/sql/<tool>.sql adds the tool to tools.yaml. Its description
comes from <tool>.txt, else from '-- Description:' header lines, else the script prompts
for it (when run in a terminal) and saves the answer to <tool>.txt. Without a terminal
(CI, --no-input) a new tool with no description is an error.

SQL file format (the header block ends at the "-- -----" separator line):

    -- Tool: ebs_get_expense_reports
    -- Skill: expense_auditor
    -- Description: Optional; a <tool>.txt file takes precedence. Repeat the
    -- Description: line for multi-line descriptions.
    -- Oracle Bind Variables:
    --   :report_header_id (integer): Expense report header ID.
    -- -----------------------------------------------------------------------------
    WITH params AS (
        SELECT :report_header_id AS report_header_id FROM dual
    )
    SELECT ...;

Every SQL file is validated before anything is written:
- The Tool: name matches the file name.
- Every declared bind is used exactly once (single-bind CTE rule for go-ora).
- Header binds are declared in the order the statement uses them (the Toolbox binds
  parameters by position, not by name).
- No bind is used without being declared in the header.
- Exactly one statement; the trailing ';' is stripped for tools.yaml.
- The statement doesn't start with a comment (go-ora rejects it with ORA-00900).

Optional PL/SQL security wrapper (--wrap / --no-wrap):
<system>/templates/plsql_wrapper.sql is an anonymous PL/SQL block containing the
placeholder <<SQL_SCRIPT_GOES_HERE>>, e.g. one that sets a security context and returns
the query through DBMS_SQL.RETURN_RESULT. With --wrap, every tool's statement in
<system>/tools.yaml is rendered into that block and the binds declared in the template's
header are added to each tool's parameters. The .sql files themselves stay plain SQL.
The choice is recorded as a '# PL/SQL wrapper:' line in the tools.yaml header, so later
runs keep it until --no-wrap is given.

A template bind can be an authenticated parameter, filled by MCP Toolbox from the caller's
verified token instead of by the agent. Declare it in the template header:

    -- Auth: :user_id = google-auth.email

Each wrapped tool then gets 'authRequired: [google-auth]', and the user_id parameter gets
'required: true' and 'authServices: [{name: google-auth, field: email}]'. The auth service
itself ('authServices: google-auth: ...' at the top of tools.yaml, shipped commented out)
is environment config maintained by hand, like 'sources:'; the sync checks that it exists.

Who verifies the user (--identity {token,agent}, with --wrap):
    token (default)  the Toolbox fills user_id from the caller's verified Google token, as above
                     (authServices + authRequired). Variant name by convention: tools_sec.yaml.
    agent            user_id stays a plain required parameter: no authServices, no authRequired. The
                     calling agent must fill it with an identity it verified itself, so this file must
                     only be deployed behind a PRIVATE service that only that agent can invoke.
                     Variant name by convention: tools_agent.yaml.
The choice is recorded as a '# Identity:' header line, like the wrapper marker. scripts/build_and_validate.py
generates both variants (tools_agent.yaml, then tools_sec.yaml from it) for you.

Usage:
    python3 scripts/sync_sql_to_yaml.py            # merge SQL changes into tools.yaml
    python3 scripts/sync_sql_to_yaml.py --check    # report drift, exit 1 if any (CI)
    python3 scripts/sync_sql_to_yaml.py --diff     # also print statement diffs
    python3 scripts/sync_sql_to_yaml.py --prune    # remove tools that have no SQL file
    python3 scripts/sync_sql_to_yaml.py --no-input # never prompt for descriptions
    python3 scripts/sync_sql_to_yaml.py --system peoplesoft --wrap     # enable PL/SQL wrapper
    python3 scripts/sync_sql_to_yaml.py --system peoplesoft --no-wrap  # disable it
    python3 scripts/sync_sql_to_yaml.py --out tools.test1.yaml         # write <system>/tools.test1.yaml
    python3 scripts/sync_sql_to_yaml.py --out tools_agent.yaml --wrap --identity agent
    python3 scripts/sync_sql_to_yaml.py --out tools_sec.yaml --seed-from tools_agent.yaml --wrap --identity token

--out FILENAME writes <system>/FILENAME instead of <system>/tools.yaml, for testers who
want several variants side by side. The first run seeds the file from <system>/tools.yaml
(sources, authServices, descriptions, wrapper state); later runs with the same --out
update that file and keep its own settings. tools.yaml itself is never touched.
--seed-from FILENAME seeds a NEW --out file from <system>/FILENAME instead of tools.yaml. A new file that
needs the 'google-auth' service (--wrap with --identity token) gets it defined automatically as
{type: google, clientId: ${GOOGLE_CLIENT_ID}}; tools.yaml itself still must define it by hand.
"""

import argparse
import difflib
import os
import re
import sys

import yaml

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SYSTEMS = ["ebs", "peoplesoft", "jde"]
VALID_TYPES = {"string", "integer", "float", "boolean"}
# Schema prefixes that tools.yaml reads from environment variables, so one set of SQL files serves databases that
# name their schemas differently (a JDE site may have PS920DTA or TESTDTA but no PRODDTA). The .sql files keep the
# literal prefix (they stay runnable in SQLcl); the sync writes ${VAR:default} into tools.yaml, which the Toolbox
# expands at start-up, like ${DB_CONNECTION_STRING:...}.
SCHEMA_VARS = {"jde": {"proddta": "JDE_DATA_SCHEMA", "prodctl": "JDE_CTL_SCHEMA"}}

SEPARATOR_RE = re.compile(r"^--\s*-{10,}\s*$")
PARAM_RE = re.compile(r"^--\s+:([A-Za-z_]\w*)\s*\((\w+)\)\s*:\s*(.*)$")
BIND_RE = re.compile(r"(?<![:\w]):([A-Za-z_]\w*)")

DEFAULT_YAML = "tools.yaml"
WRAPPER_REL = os.path.join("templates", "plsql_wrapper.sql")
WRAPPER_PLACEHOLDER = "<<SQL_SCRIPT_GOES_HERE>>"
WRAPPER_MARKER = "# PL/SQL wrapper:"
IDENTITY_MARKER = "# Identity:"
AUTH_RE = re.compile(r"^--\s*Auth:\s*:([A-Za-z_]\w*)\s*=\s*([\w.-]+)\.(\w+)\s*$")


class SqlFileError(Exception):
    pass


def strip_literals_and_comments(sql):
    """Returns (code, comments): SQL with string literals and comments blanked, and the comment text."""
    code, comments = [], []
    i, n = 0, len(sql)
    while i < n:
        if sql.startswith("--", i):
            end = sql.find("\n", i)
            end = n if end == -1 else end
            comments.append(sql[i:end])
            i = end
        elif sql.startswith("/*", i):
            end = sql.find("*/", i + 2)
            end = n if end == -1 else end + 2
            comments.append(sql[i:end])
            i = end
        elif sql.startswith("${", i) and sql.find("}", i) != -1:
            code.append("X")  # a Toolbox ${VAR:default} placeholder, not a bind variable
            i = sql.find("}", i) + 1
        elif sql[i] == "'":
            j = i + 1
            while j < n:
                if sql[j] == "'" and j + 1 < n and sql[j + 1] == "'":
                    j += 2
                elif sql[j] == "'":
                    break
                else:
                    j += 1
            code.append("''")
            i = j + 1
        else:
            code.append(sql[i])
            i += 1
    return "".join(code), comments


_LITERAL_OR_COMMENT_RE = re.compile(r"('(?:[^']|'')*'|--[^\n]*|/\*.*?\*/)", re.DOTALL)


def apply_schema_vars(system, statement):
    """Replaces each configurable schema prefix (for example proddta.) with ${VAR:prefix}. outside literals and comments."""
    mapping = SCHEMA_VARS.get(system)
    if not mapping:
        return statement
    pattern = re.compile(r"\b(" + "|".join(mapping) + r")\.", re.IGNORECASE)
    parts = _LITERAL_OR_COMMENT_RE.split(statement)
    for i in range(0, len(parts), 2):  # even parts are code; odd parts are literals and comments
        parts[i] = pattern.sub(lambda m: "${" + mapping[m.group(1).lower()] + ":" + m.group(1).lower() + "}.", parts[i])
    return "".join(parts)


def parse_sql_file(path):
    """Parses a tool SQL file into {name, skill, description, parameters, statement, warnings}."""
    with open(path, encoding="utf-8-sig") as f:
        lines = [line.rstrip() for line in f.read().splitlines()]

    sep = next((i for i, line in enumerate(lines) if SEPARATOR_RE.match(line)), None)
    if sep is None:
        raise SqlFileError("missing '-- -----' header separator line")

    tool = skill = None
    description, params = [], []
    for line in lines[:sep]:
        m = PARAM_RE.match(line)
        if m:
            pname, ptype, pdesc = m.groups()
            if ptype not in VALID_TYPES:
                raise SqlFileError(f"bind :{pname} has unsupported type '{ptype}' (use one of {sorted(VALID_TYPES)})")
            params.append({"name": pname, "type": ptype, "description": pdesc.strip()})
        elif line.startswith("-- Tool:"):
            tool = line.split(":", 1)[1].strip()
        elif line.startswith("-- Skill:"):
            skill = line.split(":", 1)[1].strip()
        elif line.startswith("-- Description:"):
            description.append(line.split(":", 1)[1].strip())

    expected = os.path.splitext(os.path.basename(path))[0]
    if tool != expected:
        raise SqlFileError(f"header '-- Tool: {tool}' does not match file name '{expected}'")
    if not skill:
        raise SqlFileError("missing '-- Skill:' header line")

    body = "\n".join(lines[sep + 1:]).strip()
    code, comments = strip_literals_and_comments(body)
    code = code.rstrip()
    if code.endswith(";"):
        cut = body.rstrip().rfind(";")
        body = body[:cut].rstrip()
        code = code[:-1]
    if not code.strip():
        raise SqlFileError("empty SQL statement")
    if ";" in code:
        raise SqlFileError("more than one statement (found ';' before the end of the file)")
    if body.startswith("--") or body.startswith("/*"):
        raise SqlFileError(
            "statement starts with a comment, which go-ora rejects (ORA-00900); "
            "move the comment above the '-- -----' separator or after the params CTE"
        )

    declared = [p["name"] for p in params]
    if len(set(declared)) != len(declared):
        raise SqlFileError("duplicate bind variables declared in header")
    used = BIND_RE.findall(code)
    for pname in declared:
        count = used.count(pname)
        if count == 0:
            raise SqlFileError(f"declared bind :{pname} is not used in the statement")
        if count > 1:
            raise SqlFileError(
                f"bind :{pname} is used {count} times; bind each parameter once in the "
                f"WITH params AS (SELECT ... FROM dual) CTE and reference p.{pname} elsewhere"
            )
    undeclared = sorted(set(used) - set(declared))
    if undeclared:
        raise SqlFileError(
            "binds used but not declared in the header: " + ", ".join(":" + u for u in undeclared)
            + " (add a '--   :name (type): description' line)"
        )
    if used != declared:
        raise SqlFileError(
            "header declares binds in the order " + ", ".join(":" + d for d in declared)
            + " but the statement uses them in the order " + ", ".join(":" + u for u in used)
            + "; the Toolbox binds parameters by position, so reorder the header lines to match"
        )

    warnings = [
        f"comment contains bind-like text {c.strip()!r}; go-ora may treat it as a bind variable"
        for c in comments if BIND_RE.search(c)
    ]
    return {
        "name": tool,
        "skill": skill,
        "description": "\n".join(description),
        "parameters": params,
        "statement": body,
        "warnings": warnings,
    }


def parse_wrapper(path):
    """Parses a PL/SQL wrapper template into {body, before, after} (bind params around the placeholder)."""
    with open(path, encoding="utf-8-sig") as f:
        lines = [line.rstrip() for line in f.read().splitlines()]
    sep = next((i for i, line in enumerate(lines) if SEPARATOR_RE.match(line)), None)
    params, auth = {}, {}
    for line in lines[:sep] if sep is not None else []:
        a = AUTH_RE.match(line)
        if a:
            auth[a.group(1)] = {"name": a.group(2), "field": a.group(3)}
            continue
        if line.startswith("-- Auth:"):
            raise SqlFileError(f"cannot parse {line!r}; expected '-- Auth: :bind = <auth-service>.<token-field>'")
        m = PARAM_RE.match(line)
        if m:
            pname, ptype, pdesc = m.groups()
            if ptype not in VALID_TYPES:
                raise SqlFileError(f"bind :{pname} has unsupported type '{ptype}' (use one of {sorted(VALID_TYPES)})")
            params[pname] = {"name": pname, "type": ptype, "description": pdesc.strip()}

    body = "\n".join(lines[sep + 1 if sep is not None else 0:]).strip()
    code, _ = strip_literals_and_comments(body)
    if code.count(WRAPPER_PLACEHOLDER) != 1:
        raise SqlFileError(f"must contain {WRAPPER_PLACEHOLDER} exactly once, outside comments and strings")
    if not re.match(r"\s*(DECLARE|BEGIN)\b", code, re.IGNORECASE):
        raise SqlFileError("must be an anonymous PL/SQL block starting with DECLARE or BEGIN")
    before_code, after_code = code.split(WRAPPER_PLACEHOLDER)
    before, after = BIND_RE.findall(before_code), BIND_RE.findall(after_code)
    used = before + after
    for pname in params:
        if used.count(pname) != 1:
            raise SqlFileError(f"declared bind :{pname} must be used exactly once (found {used.count(pname)})")
    undeclared = sorted(set(used) - set(params))
    if undeclared:
        raise SqlFileError(
            "binds used but not declared in the header: " + ", ".join(":" + u for u in undeclared)
            + " (add a '--   :name (type): description' line above the '-- -----' separator)"
        )
    for pname, svc in auth.items():
        if pname not in params:
            raise SqlFileError(f"'-- Auth:' line names :{pname}, which is not declared as a bind in the header")
        params[pname]["required"] = True
        params[pname]["authServices"] = [svc]
    return {
        "body": body,
        "before": [params[n] for n in before],
        "after": [params[n] for n in after],
        "auth_services": sorted({svc["name"] for svc in auth.values()}),
    }


def render_wrapper(wrapper, statement):
    """Places the statement at the placeholder, indenting continuation lines to match it."""
    body = wrapper["body"]
    idx = body.index(WRAPPER_PLACEHOLDER)
    lead = body[body.rfind("\n", 0, idx) + 1:idx]
    indent = lead if not lead.strip() else ""
    lines = statement.splitlines()
    inner = lines[0] + "".join("\n" + (indent + line if line.strip() else "") for line in lines[1:])
    return body[:idx] + inner + body[idx + len(WRAPPER_PLACEHOLDER):]


def set_wrapper_marker(header, enabled, rel_template):
    """Adds or removes the '# PL/SQL wrapper:' line at the end of the tools.yaml comment header."""
    lines = [line for line in header.splitlines(keepends=True) if not line.startswith(WRAPPER_MARKER)]
    if enabled:
        insert_at = len(lines)
        while insert_at > 0 and not lines[insert_at - 1].strip():
            insert_at -= 1
        lines.insert(insert_at, f"{WRAPPER_MARKER} {rel_template} (sync_sql_to_yaml.py --wrap / --no-wrap)\n")
    return "".join(lines)


def set_identity_marker(header, identity):
    """Adds the '# Identity: agent' line (agent-supplied user_id) or removes it (token, the default)."""
    lines = [line for line in header.splitlines(keepends=True) if not line.startswith(IDENTITY_MARKER)]
    if identity == "agent":
        insert_at = len(lines)
        while insert_at > 0 and not lines[insert_at - 1].strip():
            insert_at -= 1
        lines.insert(insert_at, f"{IDENTITY_MARKER} agent (user_id is supplied by the calling agent; "
                                "sync_sql_to_yaml.py --identity agent / token)\n")
    return "".join(lines)


DISABLED_MARKER = "DISABLED:"


def read_description_file(path):
    """Returns (description, disabled_reason); disabled_reason is None unless a DISABLED: line is present."""
    with open(path, encoding="utf-8-sig") as f:
        lines = [line.rstrip() for line in f.read().splitlines()]
    reasons = [line.strip()[len(DISABLED_MARKER):].strip() for line in lines if line.strip().startswith(DISABLED_MARKER)]
    kept = [line for line in lines if not line.strip().startswith(DISABLED_MARKER)]
    return "\n".join(kept).strip(), (reasons[0] or "no reason given") if reasons else None


def prompt_description(system, name, skill, txt_rel):
    """Asks for a new tool's description on the terminal; finishes on an empty line."""
    print(f"\n    New tool '{name}' ({system}, skill: {skill}) has no description ({txt_rel} not found).")
    print("    The description tells the AI agent what the tool returns and when to use it.")
    print("    Type the description; finish with an empty line (empty to skip):")
    lines = []
    while True:
        try:
            line = input("    > ")
        except EOFError:
            break
        if not line.strip():
            break
        lines.append(line.rstrip())
    return "\n".join(lines).strip()


def normalize(stmt):
    return "\n".join(line.rstrip() for line in (stmt or "").strip().splitlines())


def merge_parameters(existing, declared):
    """Header params win for name/type/description; extra keys on existing params are kept."""
    by_name = {p.get("name"): p for p in existing or []}
    merged = []
    for p in declared:
        entry = dict(by_name.get(p["name"], {}))
        if "authServices" not in p:
            entry.pop("authServices", None)
        entry.update(p)
        merged.append(entry)
    return merged


def rebuild_toolsets(existing, tools, skills):
    """Moves tools between toolsets per their SQL skill, keeping existing order where possible."""
    result = {}
    for ts_name, members in (existing or {}).items():
        kept = [t for t in members if t in tools and skills.get(t, ts_name) == ts_name]
        result[ts_name] = kept
    for tool, skill in skills.items():
        if tool not in result.setdefault(skill, []):
            result[skill].append(tool)
    return {k: v for k, v in result.items() if v}


class CustomDumper(yaml.SafeDumper):
    def ignore_aliases(self, data):
        return True  # write shared values (e.g. wrapper authServices) out in full, never as &id/*id


def _str_representer(dumper, data):
    if "\n" in data:
        clean = "\n".join(line.rstrip() for line in data.splitlines())
        return dumper.represent_scalar("tag:yaml.org,2002:str", clean, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


CustomDumper.add_representer(str, _str_representer)


def dump_yaml(config, header):
    return header + yaml.dump(config, Dumper=CustomDumper, sort_keys=False)


# ${PS_DB_USER}, ${EBS_GOOGLE_CLIENT_ID}, ... -> ${DB_USER}, ${GOOGLE_CLIENT_ID}: a tools file is already
# per system, so its variables carry no system prefix (the deploy script and the .env.<system>
# files use the plain names). JDE_DATA_SCHEMA / JDE_CTL_SCHEMA are real JDE settings and stay.
_SYSTEM_PREFIXED_VAR = re.compile(r"\$\{(?:PS|EBS|JDE|PEOPLESOFT)_(DB_[A-Z0-9_]+|GOOGLE_CLIENT_ID)((?::[^}]*)?)\}")


def strip_system_prefix(obj):
    """Recursively rewrite system-prefixed ${VAR} placeholders in every string of obj."""
    if isinstance(obj, str):
        return _SYSTEM_PREFIXED_VAR.sub(lambda m: "${" + m.group(1) + m.group(2) + "}", obj)
    if isinstance(obj, list):
        return [strip_system_prefix(v) for v in obj]
    if isinstance(obj, dict):
        return {k: strip_system_prefix(v) for k, v in obj.items()}
    return obj


def sync_system(system, args):
    """Returns (drift_messages, error_messages) for one system; writes tools.yaml unless --check."""
    sys_dir = os.path.join(BASE_DIR, system)
    out_name = getattr(args, "out", None) or DEFAULT_YAML
    yaml_path = os.path.join(sys_dir, out_name)
    seed_name = getattr(args, "seed_from", None) or DEFAULT_YAML
    seed_path = yaml_path if os.path.exists(yaml_path) else os.path.join(sys_dir, seed_name)
    sql_dir = os.path.join(sys_dir, "sql")
    rel_yaml = os.path.relpath(yaml_path, BASE_DIR)

    with open(seed_path, encoding="utf-8") as f:
        raw = f.read()
    new_file = seed_path != yaml_path
    header_lines = []
    for line in raw.splitlines(keepends=True):
        if line.startswith("#") or not line.strip():
            header_lines.append(line)
        else:
            break
    header = strip_system_prefix("".join(header_lines))
    config = strip_system_prefix(yaml.safe_load(raw))
    tools = config.setdefault("tools", {})
    sources = list((config.get("sources") or {}).keys())

    parsed, errors, drift = {}, [], []
    disabled = {}
    for fname in sorted(os.listdir(sql_dir)):
        if not fname.endswith(".sql"):
            continue
        path = os.path.join(sql_dir, fname)
        rel = os.path.relpath(path, BASE_DIR)
        try:
            spec = parse_sql_file(path)
        except SqlFileError as e:
            errors.append(f"{rel}: {e}")
            continue
        for w in spec["warnings"]:
            print(f"    [warn] {rel}: {w}")
        txt_path = os.path.splitext(path)[0] + ".txt"
        if os.path.exists(txt_path):
            spec["description"], reason = read_description_file(txt_path)
            if reason is not None:
                disabled[spec["name"]] = reason
                continue
            if not spec["description"]:
                errors.append(f"{os.path.relpath(txt_path, BASE_DIR)}: description file is empty")
                continue
        spec["statement"] = apply_schema_vars(system, spec["statement"])
        parsed[spec["name"]] = spec

    for fname in sorted(os.listdir(sql_dir)):
        if fname.endswith(".txt") and os.path.splitext(fname)[0] not in parsed and os.path.splitext(fname)[0] not in disabled:
            if not os.path.exists(os.path.join(sql_dir, os.path.splitext(fname)[0] + ".sql")):
                print(f"    [warn] {system}/sql/{fname}: no matching .sql file; ignored")

    for name, reason in sorted(disabled.items()):
        print(f"    [disabled] {system}/{name}: {reason}")

    if errors:
        return drift, errors

    wrapped_before = any(line.startswith(WRAPPER_MARKER) for line in header.splitlines())
    wrap = wrapped_before if args.wrap is None else args.wrap
    identity_before = "agent" if any(line.startswith(IDENTITY_MARKER) and "agent" in line
                                     for line in header.splitlines()) else "token"
    identity = identity_before if getattr(args, "identity", None) is None else args.identity
    wrapper = None
    rel_template = os.path.join(system, WRAPPER_REL)
    if wrap:
        if not os.path.exists(os.path.join(BASE_DIR, rel_template)):
            if args.wrap:
                return drift, [f"{rel_template}: not found; create the template before using --wrap for {system}"]
            return drift, [
                f"{rel_template}: not found, but {rel_yaml} has a '{WRAPPER_MARKER}' line "
                "(restore the template, or run with --no-wrap to stop wrapping)"
            ]
        try:
            wrapper = parse_wrapper(os.path.join(BASE_DIR, rel_template))
        except SqlFileError as e:
            return drift, [f"{rel_template}: {e}"]
        if identity == "agent":
            # user_id is a plain parameter: the agent fills it; no service verifies a token
            for prm in wrapper["before"] + wrapper["after"]:
                prm.pop("authServices", None)
            wrapper["auth_services"] = []
        defined = config.get("authServices") or {}
        if new_file and "google-auth" in wrapper["auth_services"] and "google-auth" not in defined:
            # a generated variant defines the standard service itself; tools.yaml's is hand-maintained
            config = {"authServices": {**defined, "google-auth": {"type": "google", "clientId": "${GOOGLE_CLIENT_ID}"}},
                      **{k: v for k, v in config.items() if k != "authServices"}}
            tools = config.setdefault("tools", {})
            defined = config["authServices"]
        missing = [svc for svc in wrapper["auth_services"] if svc not in defined]
        if missing:
            services = ", ".join(missing)
            if new_file:
                how = (f"{rel_yaml} does not exist yet: run once without --wrap to create it, uncomment the "
                       "'authServices:' block at its top, then run again with --wrap (see README §2.6)")
            else:
                how = f"uncomment the 'authServices:' block at the top of {rel_yaml} (see README §2.6)"
            return drift, [f"{rel_template} uses auth service(s) {services}, which {rel_yaml} does not define; {how}"]
        wrapper_names = {p["name"] for p in wrapper["before"] + wrapper["after"]}
        for name, spec in parsed.items():
            clash = wrapper_names & {p["name"] for p in spec["parameters"]}
            if clash:
                errors.append(
                    f"{system}/sql/{name}.sql: declares " + ", ".join(":" + c for c in sorted(clash))
                    + f", which {rel_template} already binds"
                )
            spec["statement"] = render_wrapper(wrapper, spec["statement"])
            spec["parameters"] = wrapper["before"] + spec["parameters"] + wrapper["after"]
        if errors:
            return drift, errors
    toggled = wrap != wrapped_before
    if toggled:
        drift.append(f"PL/SQL wrapper {'enabled' if wrap else 'disabled'} ({rel_template})")
        header = set_wrapper_marker(header, wrap, rel_template)
    if wrap and identity != identity_before:
        toggled = True
        drift.append(f"identity {identity_before} -> {identity}")
    if not wrap:
        identity = "token"
    if identity != identity_before or (identity == "agent") != any(l.startswith(IDENTITY_MARKER) for l in header.splitlines()):
        header = set_identity_marker(header, identity)
    # While the wrapper is switched on or off every tool changes; summarise instead of one line per change.
    toggled_tools, toggled_kinds = set(), []

    def note(name, kind, message):
        if toggled:
            toggled_tools.add(name)
            if kind not in toggled_kinds:
                toggled_kinds.append(kind)
        else:
            drift.append(f"{name}: {message}")

    new_tools = {}
    for name, tdef in tools.items():
        if name in disabled:
            drift.append(f"{name}: removed (disabled)")
        elif name in parsed:
            new_tools[name] = tdef
        elif args.prune:
            drift.append(f"{name}: removed (no SQL file)")
        else:
            drift.append(f"{name}: in {rel_yaml} but has no SQL file (use --prune to remove)")
            new_tools[name] = tdef

    for name, spec in parsed.items():
        tdef = new_tools.get(name)
        if tdef is None:
            txt_rel = f"{system}/sql/{name}.txt"
            if not spec["description"] and not args.check and not args.no_input and sys.stdin.isatty():
                spec["description"] = prompt_description(system, name, spec["skill"], txt_rel)
                if spec["description"]:
                    with open(os.path.join(BASE_DIR, txt_rel), "w", encoding="utf-8") as f:
                        f.write(spec["description"] + "\n")
                    print(f"    [+] saved description to {txt_rel}")
            if not spec["description"]:
                errors.append(
                    f"{system}/sql/{name}.sql: new tool has no description; add {txt_rel} "
                    "(or run this script in a terminal to be prompted)"
                )
                continue
            if len(sources) != 1:
                errors.append(f"{rel_yaml}: cannot pick a source for new tool {name} ({len(sources)} sources)")
                continue
            new_tools[name] = {
                "kind": "oracle-sql",
                "source": sources[0],
                "description": spec["description"],
                "parameters": spec["parameters"],
                "statement": spec["statement"],
            }
            if wrapper and wrapper["auth_services"]:
                new_tools[name]["authRequired"] = list(wrapper["auth_services"])
            drift.append(f"{name}: new tool added")
            continue

        if normalize(tdef.get("statement")) != normalize(spec["statement"]):
            note(name, "statement", "statement changed")
            if args.diff:
                for line in difflib.unified_diff(
                    normalize(tdef.get("statement")).splitlines(),
                    normalize(spec["statement"]).splitlines(),
                    fromfile=f"{rel_yaml}:{name}", tofile=f"{system}/sql/{name}.sql", lineterm="",
                ):
                    print(f"      {line}")
            tdef["statement"] = spec["statement"]

        merged = merge_parameters(tdef.get("parameters"), spec["parameters"])
        if merged != tdef.get("parameters"):
            old = [p.get("name") for p in tdef.get("parameters") or []]
            new = [p["name"] for p in merged]
            detail = f" ({old} -> {new})" if old != new else " (type/description)"
            note(name, "parameters", f"parameters changed{detail}")
            tdef["parameters"] = merged

        if spec["description"] and normalize(tdef.get("description")) != normalize(spec["description"]):
            drift.append(f"{name}: description changed")
            tdef["description"] = spec["description"]

        auth_required = list(wrapper["auth_services"]) if wrapper else []
        if (tdef.get("authRequired") or []) != auth_required:
            note(name, "authRequired", f"authRequired changed ({tdef.get('authRequired') or []} -> {auth_required})")
            if auth_required:
                tdef["authRequired"] = auth_required
            else:
                tdef.pop("authRequired", None)

    if errors:
        return drift, errors
    if toggled_tools:
        drift.append(
            f"{len(toggled_tools)} tools {'wrapped' if wrap else 'unwrapped'} "
            f"({', '.join(toggled_kinds)} updated; use --diff to see each statement)"
        )

    skills = {name: spec["skill"] for name, spec in parsed.items()}
    old_toolsets = config.get("toolsets") or {}
    new_toolsets = rebuild_toolsets(old_toolsets, new_tools, skills)
    if new_toolsets != old_toolsets:
        old_skill = {t: ts for ts, members in old_toolsets.items() for t in members}
        for tool, skill in skills.items():
            if old_skill.get(tool) not in (None, skill):
                drift.append(f"{tool}: moved from toolset '{old_skill[tool]}' to '{skill}'")
        if not any("toolset" in d for d in drift):
            drift.append("toolsets reorganised")

    config["tools"] = new_tools
    config["toolsets"] = new_toolsets
    output = dump_yaml(config, header)

    if new_file:
        drift.insert(0, f"new file {rel_yaml} (seeded from {system}/{seed_name})")
    elif output != raw and not drift:
        drift.append(f"formatting only ({rel_yaml} will be re-serialised)")
    if drift and not args.check:
        with open(yaml_path, "w", encoding="utf-8") as f:
            f.write(output)
    return drift, errors


def main():
    parser = argparse.ArgumentParser(description="Merge analyst-edited SQL files into MCP Toolbox tools.yaml.")
    parser.add_argument("--check", action="store_true", help="report drift and exit 1 without writing")
    parser.add_argument("--diff", action="store_true", help="print unified diffs of changed statements")
    parser.add_argument("--prune", action="store_true", help="remove tools.yaml tools that have no SQL file")
    parser.add_argument("--no-input", action="store_true", help="never prompt for new tool descriptions")
    parser.add_argument("--system", choices=SYSTEMS, action="append", help="limit to one system (repeatable)")
    parser.add_argument("--out", metavar="FILENAME",
                        help=f"write <system>/FILENAME instead of <system>/{DEFAULT_YAML} (seeded from it on first run)")
    parser.add_argument("--identity", choices=("token", "agent"), default=None,
                        help="with --wrap: who supplies user_id. token (default) = Toolbox verifies the Google token "
                             "(authServices); agent = a plain parameter the calling agent fills (remembered in the header)")
    parser.add_argument("--seed-from", metavar="FILENAME", default=None,
                        help="seed a NEW --out file from <system>/FILENAME instead of tools.yaml")
    wrap = parser.add_mutually_exclusive_group()
    wrap.add_argument("--wrap", dest="wrap", action="store_const", const=True,
                      help="wrap statements in <system>/templates/plsql_wrapper.sql (remembered in tools.yaml)")
    wrap.add_argument("--no-wrap", dest="wrap", action="store_const", const=False,
                      help="stop wrapping statements (remembered in tools.yaml)")
    args = parser.parse_args()
    if args.out is not None:
        if os.path.basename(args.out) != args.out or not args.out.endswith((".yaml", ".yml")):
            parser.error("--out takes a file name ending in .yaml or .yml, without a directory "
                         "(it is written into each system's folder)")

    any_drift = any_error = False
    for system in args.system or SYSTEMS:
        print(f"[*] {system}: comparing {system}/sql/*.sql with {system}/{args.out or DEFAULT_YAML}")
        drift, errors = sync_system(system, args)
        for e in errors:
            print(f"    [error] {e}")
        for d in drift:
            print(f"    [drift] {d}")
        if errors:
            any_error = True
            print(f"[!] {system}: SQL validation failed; {args.out or DEFAULT_YAML} left unchanged")
        elif drift:
            any_drift = True
            verb = "would update" if args.check else "updated"
            print(f"[+] {system}: {verb} {system}/{args.out or DEFAULT_YAML} ({len(drift)} change(s))")
        else:
            print(f"[+] {system}: in sync")

    if any_error:
        sys.exit(2)
    if args.check and any_drift:
        out_flag = f" --out {args.out}" if args.out else ""
        print(f"\n[!] {args.out or DEFAULT_YAML} is out of date. Run: python3 scripts/sync_sql_to_yaml.py{out_flag}")
        sys.exit(1)


if __name__ == "__main__":
    main()
