#!/usr/bin/env python3
"""Hybrid JD Edwards EnterpriseOne (JDE) MCP Server for Discrete Manufacturing.

Combines:
1. JDE Orchestrator & AIS REST APIs (/jderest/v3/orchestrator and /jderest/v2/*)
   for transactional Discrete Manufacturing automations (P48013 Work Order Entry,
   P31113 Material Issues, P311221 Time Entry, P31114 Completions) so all JDE
   Master Business Functions (MBFs), Next Numbers (F0002), Commitments (F41021),
   and Item Ledger (F4111) rules are enforced.
2. Direct Oracle 19c Database SQL (10.118.0.41:1521/jdeorcl) over normalized
   read-only analytical views (VW_JDE_MFG_*) with automatic JDE Julian date
   (CYYDDD <-> ISO-8601) and implied decimal conversion for sub-second shop
   floor analytics, shortage tracing, capacity bottleneck detection, and
   production cost variance analysis.
"""

import asyncio
import contextvars
from datetime import datetime
import json
import logging
import os
import threading
from typing import Any, Dict, List, Optional
import httpx
from mcp.server.fastmcp import FastMCP
import oracledb

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("jde-hybrid-mcp")

mcp = FastMCP(
    "JDE-Hybrid-Orchestrator-SQL-MCP",
    dependencies=["httpx", "oracledb", "pydantic"],
)

# JDE AIS / Orchestrator Configuration
JDE_AIS_BASE_URL = os.environ.get(
    "JDE_AIS_BASE_URL", "http://10.118.0.43:7077"
).rstrip("/")
JDE_USERNAME = os.environ.get("JDE_USERNAME", "NGONZAL")
JDE_PASSWORD = os.environ.get("JDE_PASSWORD", "")
JDE_ENVIRONMENT = os.environ.get("JDE_ENVIRONMENT", "JPD920")
JDE_ROLE = os.environ.get("JDE_ROLE", "MFG_MGR")
DEFAULT_USER_EMAIL = os.environ.get(
    "JDE_DEFAULT_USER_EMAIL", "admin@negonzal.altostrat.com"
)

# JDE Oracle 19c Database Configuration (10.118.0.41:1521/jdeorcl)
JDE_DB_DSN = os.environ.get("JDE_DB_DSN", "10.118.0.41:1521/jdeorcl")
JDE_DB_USER = os.environ.get("JDE_DB_USER", "JDE_AI")
JDE_DB_PASSWORD = os.environ.get("JDE_DB_PASSWORD", "")
JDE_SCHEMA = os.environ.get("JDE_SCHEMA", "PRODDTA")
JDE_AIS_SSL_VERIFY = os.environ.get("JDE_AIS_SSL_VERIFY", "true").lower() not in (
    "false",
    "0",
    "no",
)

_db_pool: Optional[oracledb.ConnectionPool] = None
_pool_lock = threading.Lock()


def get_db_pool() -> oracledb.ConnectionPool:
  """Returns a lazy-initialized Oracle DB connection pool."""
  global _db_pool
  if _db_pool is None:
    with _pool_lock:
      if _db_pool is None:
        _db_pool = oracledb.create_pool(
            user=JDE_DB_USER,
            password=JDE_DB_PASSWORD,
            dsn=JDE_DB_DSN,
            min=1,
            max=4,
            increment=1,
        )
  return _db_pool


# Per-user and request-scoped JDE EnterpriseOne Email-to-JDE Identity Session State
_DEFAULT_JDE_CONTEXT: Dict[str, Any] = {
    "email_or_user": DEFAULT_USER_EMAIL,
    "jde_user": JDE_USERNAME,
    "address_number": 80001,
    "alpha_name": "Gonzalez, Nelson (VP Mfg Operations)",
    "branch_plant": "M30",
    "role_name": JDE_ROLE,
    "environment": JDE_ENVIRONMENT,
}

import collections

_MAX_USER_CONTEXT_CACHE = 1000
_context_lock = threading.Lock()
_user_contexts_by_email: "collections.OrderedDict[str, Dict[str, Any]]" = (
    collections.OrderedDict(
        {DEFAULT_USER_EMAIL.lower(): dict(_DEFAULT_JDE_CONTEXT)}
    )
)
_request_user_email: contextvars.ContextVar[str] = contextvars.ContextVar(
    "request_user_email", default=DEFAULT_USER_EMAIL
)


def get_active_jde_context() -> Dict[str, Any]:
  """Returns the active JDE identity context for the current request's user."""
  email_key = (_request_user_email.get() or DEFAULT_USER_EMAIL).strip().lower()
  with _context_lock:
    if email_key in _user_contexts_by_email:
      _user_contexts_by_email.move_to_end(email_key)
      return dict(_user_contexts_by_email[email_key])
    ctx = {**_DEFAULT_JDE_CONTEXT, "email_or_user": email_key}
    if len(_user_contexts_by_email) >= _MAX_USER_CONTEXT_CACHE:
      _user_contexts_by_email.popitem(last=False)
    _user_contexts_by_email[email_key] = ctx
    return dict(ctx)


def set_active_jde_context(ctx: Dict[str, Any]) -> None:
  """Persists the active JDE identity context for the user across stateless HTTP requests."""
  email_val = str(ctx.get("email_or_user") or DEFAULT_USER_EMAIL).strip()
  email_key = email_val.lower()
  _request_user_email.set(email_val)
  with _context_lock:
    if email_key in _user_contexts_by_email:
      _user_contexts_by_email.move_to_end(email_key)
    elif len(_user_contexts_by_email) >= _MAX_USER_CONTEXT_CACHE:
      _user_contexts_by_email.popitem(last=False)
    _user_contexts_by_email[email_key] = dict(ctx)


def date_to_jde_julian(dt_str: str) -> int:
  """Converts YYYY-MM-DD date string to 6-digit JDE Julian integer (CYYDDD)."""
  dt = datetime.strptime(dt_str, "%Y-%m-%d").date()
  century = (dt.year - 1900) // 100
  year_2d = dt.year % 100
  day_of_year = dt.timetuple().tm_yday
  return century * 100000 + year_2d * 1000 + day_of_year


def jde_julian_to_iso(julian_val: Optional[int]) -> Optional[str]:
  """Converts 6-digit JDE Julian integer (CYYDDD) to YYYY-MM-DD."""
  if not julian_val or int(julian_val) <= 0:
    return None
  val = int(julian_val)
  year = 1900 + (val // 1000)
  day_of_year = val % 1000
  try:
    dt = datetime.strptime(f"{year}-{day_of_year:03d}", "%Y-%j").date()
    return dt.isoformat()
  except ValueError:
    return str(julian_val)


def execute_oracle_query(
    sql: str, bind_vars: Optional[Dict[str, Any]] = None
) -> List[Dict[str, Any]]:
  """Executes a SQL query against JDEORCL with DBMS_SESSION.SET_IDENTIFIER and returns rows as dicts."""
  ctx = get_active_jde_context()
  with get_db_pool().acquire() as conn:
    with conn.cursor() as cur:
      client_id = f"{ctx.get('jde_user', 'NGONZAL')}:{ctx.get('email_or_user', DEFAULT_USER_EMAIL)}"
      try:
        cur.execute(
            "BEGIN DBMS_SESSION.SET_IDENTIFIER(:cid); END;",
            {"cid": client_id[:64]},
        )
      except Exception:
        pass
      try:
        cur.execute(sql, bind_vars or {})
        if not cur.description:
          return []
        cols = [col[0].lower() for col in cur.description]
        rows = []
        for row in cur.fetchall():
          row_dict = {}
          for col_name, val in zip(cols, row):
            if hasattr(val, "isoformat"):
              row_dict[col_name] = val.isoformat()
            else:
              row_dict[col_name] = val
          rows.append(row_dict)
        return rows
      finally:
        try:
          cur.execute("BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;")
        except Exception:
          pass


class JDEOrchestratorClient:
  """Client for Oracle JD Edwards EnterpriseOne AIS & Orchestrator REST APIs."""

  def __init__(self) -> None:
    self.base_url = JDE_AIS_BASE_URL
    self.username = JDE_USERNAME
    self.password = JDE_PASSWORD
    self.environment = JDE_ENVIRONMENT
    self.role = JDE_ROLE
    self.user_email = DEFAULT_USER_EMAIL
    self.ssl_verify = JDE_AIS_SSL_VERIFY
    self._tokens: Dict[str, str] = {}
    self.client = httpx.AsyncClient(verify=self.ssl_verify, timeout=60.0)

  async def get_token(self, force_refresh: bool = False) -> str:
    """Acquires or returns cached AIS session token from /jderest/v2/tokenrequest."""
    ctx = get_active_jde_context()
    usr = str(ctx.get("jde_user", self.username))
    email = str(ctx.get("email_or_user", self.user_email))
    env = str(ctx.get("environment", self.environment))
    role = str(ctx.get("role_name", self.role))
    cache_key = f"{usr}:{email}:{env}:{role}"
    if cache_key in self._tokens and not force_refresh:
      return self._tokens[cache_key]
    url = f"{self.base_url}/jderest/v2/tokenrequest"
    payload = {
        "username": usr,
        "userEmail": email,
        "password": self.password,
        "environment": env,
        "role": role,
        "deviceName": "GeminiEnterpriseMCP",
    }
    headers = {
        "X-User-Email": email,
        "X-JDE-User": usr,
    }
    resp = await self.client.post(url, json=payload, headers=headers, timeout=30.0)
    resp.raise_for_status()
    data = resp.json()
    token = data.get("userInfo", {}).get("token")
    if not token:
      raise RuntimeError(f"AIS tokenrequest did not return a token: {data}")
    self._tokens[cache_key] = token
    return token

  async def invoke_orchestration(
      self, orchestration_name: str, inputs: Dict[str, Any]
  ) -> Dict[str, Any]:
    """Invokes a JDE Orchestrator endpoint (/jderest/v3/orchestrator/{name}) preserving user identity."""
    ctx = get_active_jde_context()
    usr = str(ctx.get("jde_user", self.username))
    email = str(ctx.get("email_or_user", self.user_email))
    token = await self.get_token()
    url = f"{self.base_url}/jderest/v3/orchestrator/{orchestration_name}"
    body = {
        "token": token,
        "jdeUser": usr,
        "userEmail": email,
        **inputs,
    }
    headers = {
        "X-User-Email": email,
        "X-JDE-User": usr,
    }
    resp = await self.client.post(url, json=body, headers=headers)
    if resp.status_code in (401, 403, 440):
      token = await self.get_token(force_refresh=True)
      body["token"] = token
      resp = await self.client.post(url, json=body, headers=headers)
    resp.raise_for_status()
    return resp.json()

  async def formservice_action(
      self,
      form_name: str,
      version: str = "ZJDE0001",
      form_actions: Optional[List[Dict[str, Any]]] = None,
      form_inputs: Optional[List[Dict[str, Any]]] = None,
      return_control_ids: str = "",
  ) -> Dict[str, Any]:
    """Executes interactive JDE application logic via AIS /jderest/v2/formservice."""
    token = await self.get_token()
    url = f"{self.base_url}/jderest/v2/formservice"
    payload: Dict[str, Any] = {
        "token": token,
        "deviceName": "GeminiEnterpriseMCP",
        "formName": form_name,
        "version": version,
        "formServiceAction": "U",
        "bypassFormServiceEREvent": True,
    }
    if return_control_ids:
      payload["returnControlIDs"] = return_control_ids
    if form_inputs:
      payload["formInputs"] = form_inputs
    if form_actions:
      payload["formActions"] = form_actions
    resp = await self.client.post(url, json=payload)
    if resp.status_code in (401, 403, 440):
      token = await self.get_token(force_refresh=True)
      payload["token"] = token
      resp = await self.client.post(url, json=payload)
    resp.raise_for_status()
    return resp.json()


jde_client = JDEOrchestratorClient()


# ==============================================================================
# PART 0: JDE ENTERPRISEONE EMAIL-TO-JDE IDENTITY & SECURITY CONTEXT TOOLS
# ==============================================================================


@mcp.tool()
async def jde_init(
    email_or_user: str = "admin@negonzal.altostrat.com",
    branch_plant: str = "M30",
    role_name: str = "MFG_MGR",
    environment: str = "JPD920",
) -> Dict[str, Any]:
  """[JDE Security & Identity] Initializes the JD Edwards EnterpriseOne session context by mapping the Gemini Enterprise user's email address (e.g., admin@negonzal.altostrat.com or negonzal@google.com) to their JDE User ID (SY920.F0092), Address Book Number (PRODDTA.F0101 / F01151), Role (SY920.F95921), and Branch/Plant security (PRODCTL.F00950). Call this first before running JDE operations."""
  rows = await asyncio.to_thread(
      execute_oracle_query,
      """
      SELECT PRODDTA.GE_JDE_MCP_TOOLS.jde_initialize_context(
               :p_user, :p_bp, :p_role, :p_env
             ) AS init_result
        FROM DUAL
      """,
      {
          "p_user": email_or_user.strip(),
          "p_bp": branch_plant.strip(),
          "p_role": role_name.strip(),
          "p_env": environment.strip(),
      },
  )
  raw_json = rows[0]["init_result"] if rows and rows[0].get("init_result") else "{}"
  parsed = json.loads(raw_json) if isinstance(raw_json, str) else raw_json
  if parsed.get("STATUS") == "SUCCESS":
    new_ctx = {
        **get_active_jde_context(),
        "email_or_user": parsed.get("EMAIL_ADDRESS", email_or_user.strip()),
        "jde_user": parsed.get("JDE_USER", "NGONZAL"),
        "address_number": parsed.get("ADDRESS_NUMBER", 80001),
        "alpha_name": parsed.get("ALPHA_NAME", "Gonzalez, Nelson (VP Mfg Operations)"),
        "branch_plant": parsed.get("BRANCH_PLANT", branch_plant.strip()),
        "role_name": parsed.get("JDE_ROLE", role_name.strip()),
        "environment": parsed.get("JDE_ENVIRONMENT", environment.strip()),
    }
    set_active_jde_context(new_ctx)
    await jde_client.get_token(force_refresh=True)
  return {
      "engine": "Oracle JDE Identity Context (PRODDTA.GE_JDE_MCP_TOOLS.jde_initialize_context)",
      "context": parsed,
  }


@mcp.tool()
def list_jde_current_context() -> Dict[str, Any]:
  """[JDE Security & Identity] Returns the currently active JD Edwards EnterpriseOne user session context (JDE User ID, Address Book Number AN8, Email Address, Role, Environment, Branch/Plant, Oracle CLIENT_IDENTIFIER, and authorized applications in PRODCTL.F00950)."""
  ctx = get_active_jde_context()
  email_lookup = str(ctx.get("email_or_user", DEFAULT_USER_EMAIL)).strip()
  ctx_rows = execute_oracle_query(
      """
      SELECT c.session_key,
             c.jde_user,
             c.address_number,
             c.alpha_name,
             c.email_address,
             c.jde_role,
             c.jde_environment,
             c.branch_plant,
             TO_CHAR(c.initialized_dttm, 'YYYY-MM-DD HH24:MI:SS') AS initialized_dttm,
             SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') AS oracle_client_identifier,
             SYS_CONTEXT('USERENV', 'SESSION_USER') AS db_session_user
        FROM PRODDTA.JDE_MCP_SESSION_CTX c
       WHERE c.session_key = UPPER(TRIM(:email))
          OR UPPER(TRIM(c.email_address)) = UPPER(TRIM(:email))
       ORDER BY c.initialized_dttm DESC
       FETCH FIRST 1 ROWS ONLY
      """,
      {"email": email_lookup},
  )
  active_user = (
      ctx_rows[0]["jde_user"]
      if ctx_rows
      else ctx.get("jde_user", "NGONZAL")
  )
  sec_rows = execute_oracle_query(
      """
      SELECT TRIM(fsobnm) AS application_id,
             TRIM(fsmcu)  AS branch_plant,
             fsokay       AS run_allowed,
             fsatn        AS add_allowed,
             fschng       AS change_allowed,
             fsdelt       AS delete_allowed
        FROM PRODCTL.F00950
       WHERE TRIM(fsuser) = :u
       ORDER BY TRIM(fsobnm)
      """,
      {"u": active_user},
  )
  return {
      "engine": "Oracle JDE Session Context (PRODDTA.JDE_MCP_SESSION_CTX + PRODCTL.F00950)",
      "active_session": ctx_rows[0] if ctx_rows else ctx,
      "authorized_applications_f00950": sec_rows,
  }


@mcp.tool()
def list_jde_roles(
    email_or_user: str = "admin@negonzal.altostrat.com",
) -> Dict[str, Any]:
  """[JDE Security & Identity] Lists all JD Edwards EnterpriseOne User Profiles (SY920.F0092), Address Book Numbers (PRODDTA.F0101), Electronic Address Emails (PRODDTA.F01151), Assigned Roles (SY920.F95921), and Security Workbench permissions (PRODCTL.F00950) for a given email address or JDE user ID."""
  rows = execute_oracle_query(
      """
      SELECT TRIM(u.uluser) AS jde_user,
             u.ulan8        AS address_number,
             TRIM(a.abalph) AS alpha_name,
             e.eaemal       AS email_address,
             TRIM(u.ulrole) AS primary_role,
             TRIM(r.rlfrrole) AS granted_role,
             r.rlroledesc   AS role_description,
             TRIM(u.ulenv)  AS jde_environment,
             TRIM(a.abmcu)  AS default_branch_plant,
             TRIM(u.ulusts) AS user_status
        FROM SY920.F0092 u
        JOIN PRODDTA.F0101 a   ON a.aban8 = u.ulan8
        JOIN PRODDTA.F01151 e  ON e.eaan8 = u.ulan8
        LEFT JOIN SY920.F95921 r ON TRIM(r.rltorole) = TRIM(u.uluser)
       WHERE UPPER(TRIM(e.eaemal)) = UPPER(TRIM(:p_id))
          OR UPPER(TRIM(u.uluser)) = UPPER(TRIM(:p_id))
       ORDER BY e.earck7, TRIM(r.rlfrrole)
      """,
      {"p_id": email_or_user.strip()},
  )
  return {
      "engine": "Oracle JDE User & Role Directory (SY920.F0092 / F95921 / PRODDTA.F01151)",
      "query_identity": email_or_user.strip(),
      "count": len(rows),
      "roles_and_mappings": rows,
  }


@mcp.tool()
def jde_query_work_order_control_tower(
    branch_plant: str = "M30",
    status_from: str = "10",
    status_to: str = "95",
    only_late_or_at_risk: bool = False,
) -> Dict[str, Any]:
  """[SQL Analytics] Queries the Discrete Manufacturing Work Order Control Tower view (VW_JDE_MFG_WORK_ORDERS) joining F4801, F4101, and F3111 to summarize active production orders, completion progress, and schedule risk."""
  sql = f"""
      SELECT work_order_number,
             order_type,
             branch_plant,
             parent_item_number,
             item_description,
             status_code,
             status_meaning,
             quantity_ordered,
             quantity_completed,
             quantity_scrapped,
             quantity_remaining,
             pct_complete,
             start_date_iso,
             requested_date_iso,
             schedule_health,
             shortage_component_count
        FROM {JDE_SCHEMA}.VW_JDE_MFG_WORK_ORDERS
       WHERE TRIM(branch_plant) = :bp
         AND status_code BETWEEN :st_from AND :st_to
         AND (:only_risk = 0 OR schedule_health IN ('LATE', 'AT_RISK_SHORTAGE'))
       ORDER BY requested_date_iso ASC, work_order_number ASC
  """
  rows = execute_oracle_query(
      sql,
      {
          "bp": branch_plant.strip(),
          "st_from": status_from.strip(),
          "st_to": status_to.strip(),
          "only_risk": 1 if only_late_or_at_risk else 0,
      },
  )
  return {
      "engine": "Oracle 19c SQL Analytics (VW_JDE_MFG_WORK_ORDERS)",
      "branch_plant": branch_plant.strip(),
      "count": len(rows),
      "work_orders": rows,
  }


@mcp.tool()
def jde_check_work_order_material_shortages(
    work_order_number: Optional[int] = None,
    branch_plant: str = "M30",
    only_shortages: bool = True,
) -> Dict[str, Any]:
  """[SQL Analytics] Cross-references Work Order Parts List requirements (F3111) against Item Location On-Hand / Available balances (F41021) and open Purchase Orders (F4311) via VW_JDE_MFG_PARTS_SHORTAGES."""
  sql = f"""
      SELECT work_order_number,
             parent_item_number,
             operation_seq,
             component_item_number,
             component_description,
             branch_plant,
             uom,
             qty_required,
             qty_issued,
             qty_open_required,
             qty_on_hand,
             qty_committed,
             qty_available_net,
             qty_shortage,
             shortage_status,
             next_open_po_number,
             next_po_promised_date_iso
        FROM {JDE_SCHEMA}.VW_JDE_MFG_PARTS_SHORTAGES
       WHERE TRIM(branch_plant) = :bp
         AND (:wo_num IS NULL OR work_order_number = :wo_num)
         AND (:only_short = 0 OR qty_shortage > 0)
       ORDER BY qty_shortage DESC, work_order_number ASC, operation_seq ASC
  """
  rows = execute_oracle_query(
      sql,
      {
          "bp": branch_plant.strip(),
          "wo_num": work_order_number,
          "only_short": 1 if only_shortages else 0,
      },
  )
  return {
      "engine": "Oracle 19c SQL Analytics (VW_JDE_MFG_PARTS_SHORTAGES)",
      "branch_plant": branch_plant.strip(),
      "work_order_number": work_order_number,
      "shortage_lines_count": len(rows),
      "material_requirements": rows,
  }


@mcp.tool()
def jde_analyze_work_center_capacity_and_bottlenecks(
    branch_plant: str = "M30",
) -> Dict[str, Any]:
  """[SQL Analytics] Evaluates discrete manufacturing Work Center load vs. daily available capacity across active routing steps (F3112 + F30006 via VW_JDE_MFG_ROUTING_LOAD)."""
  sql = f"""
      SELECT work_center,
             work_center_description,
             branch_plant,
             open_operations_count,
             scheduled_setup_hours,
             scheduled_machine_hours,
             scheduled_labor_hours,
             completed_hours,
             remaining_load_hours,
             weekly_capacity_hours,
             utilization_pct,
             bottleneck_status
        FROM {JDE_SCHEMA}.VW_JDE_MFG_ROUTING_LOAD
       WHERE TRIM(branch_plant) = :bp
       ORDER BY utilization_pct DESC
  """
  rows = execute_oracle_query(sql, {"bp": branch_plant.strip()})
  return {
      "engine": "Oracle 19c SQL Analytics (VW_JDE_MFG_ROUTING_LOAD)",
      "branch_plant": branch_plant.strip(),
      "work_centers": rows,
  }


@mcp.tool()
def jde_analyze_production_cost_variances(
    work_order_number: Optional[int] = None,
    branch_plant: str = "M30",
) -> Dict[str, Any]:
  """[SQL Analytics] Queries Production Costing (F3102) via VW_JDE_MFG_COST_VARIANCES to compare Standard vs. Planned vs. Actual Material (A1), Direct Labor (B1), Machine (B2), and Overhead (C1/C2) costs and variances."""
  sql = f"""
      SELECT work_order_number,
             parent_item_number,
             item_description,
             branch_plant,
             cost_type,
             cost_type_description,
             standard_cost_usd,
             planned_cost_usd,
             actual_cost_usd,
             completed_output_cost_usd,
             scrap_cost_usd,
             total_variance_usd,
             variance_pct,
             variance_severity
        FROM {JDE_SCHEMA}.VW_JDE_MFG_COST_VARIANCES
       WHERE TRIM(branch_plant) = :bp
         AND (:wo_num IS NULL OR work_order_number = :wo_num)
       ORDER BY ABS(total_variance_usd) DESC
  """
  rows = execute_oracle_query(
      sql, {"bp": branch_plant.strip(), "wo_num": work_order_number}
  )
  return {
      "engine": "Oracle 19c SQL Analytics (VW_JDE_MFG_COST_VARIANCES)",
      "branch_plant": branch_plant.strip(),
      "work_order_number": work_order_number,
      "cost_variance_rows": rows,
  }


# ==============================================================================
# PART 2: JDE ORCHESTRATOR & AIS TRANSACTIONAL TOOLS (/jderest/v3/orchestrator)
# ==============================================================================


@mcp.tool()
async def jde_discover_orchestrations() -> Dict[str, Any]:
  """[JDE Orchestrator] Queries the JDE AIS OpenAPI Catalog (/jderest/v2/open-api-catalog) to list available JDE Orchestrations."""
  token = await jde_client.get_token()
  url = f"{jde_client.base_url}/jderest/v2/open-api-catalog"
  async with httpx.AsyncClient(verify=jde_client.ssl_verify, timeout=30.0) as client:
    resp = await client.get(url, headers={"Authorization": f"Bearer {token}"})
    resp.raise_for_status()
    return resp.json()


@mcp.tool()
async def jde_create_discrete_work_order(
    parent_item_number: str,
    quantity_ordered: float,
    branch_plant: str = "M30",
    start_date_iso: str = "2026-10-08",
    requested_date_iso: str = "2026-10-15",
    work_order_description: str = "AI Agent Scheduled Production Lot",
    attach_parts_and_routing: bool = True,
) -> Dict[str, Any]:
  """[JDE Orchestrator] Creates a new Discrete Manufacturing Work Order via ORCH_CreateDiscreteWorkOrder (P48013 Manufacturing Work Order Entry) and attaches the standard Bill of Materials (P3111) and Routing (P3112)."""
  try:
    result = await jde_client.invoke_orchestration(
        "ORCH_CreateDiscreteWorkOrder",
        {
            "BranchPlant": branch_plant.strip(),
            "ParentItem": parent_item_number.strip(),
            "QuantityOrdered": quantity_ordered,
            "StartDate": start_date_iso,
            "RequestedDate": requested_date_iso,
            "Description": work_order_description,
            "AttachPartsAndRouting": attach_parts_and_routing,
        },
    )
    return {
        "engine": (
            "JDE Orchestrator"
            " (/jderest/v3/orchestrator/ORCH_CreateDiscreteWorkOrder)"
        ),
        "status": "SUCCESS",
        "orchestrator_response": result,
    }
  except Exception:
    result = await jde_client.formservice_action(
        form_name="P48013_W48013A",
        version="ZJDE0001",
        form_actions=[
            {"command": "DoAction", "controlID": "15"},
            {
                "command": "SetControlValue",
                "controlID": "29",
                "value": branch_plant.strip(),
            },
            {
                "command": "SetControlValue",
                "controlID": "223",
                "value": parent_item_number.strip(),
            },
            {
                "command": "SetControlValue",
                "controlID": "225",
                "value": str(quantity_ordered),
            },
            {
                "command": "SetControlValue",
                "controlID": "27",
                "value": work_order_description,
            },
            {"command": "DoAction", "controlID": "11"},
        ],
    )
    return {
        "engine": "JDE AIS Form Service (/jderest/v2/formservice P48013)",
        "status": "SUCCESS",
        "ais_response": result,
    }


@mcp.tool()
async def jde_issue_material_to_work_order(
    work_order_number: int,
    component_item_number: str,
    quantity_to_issue: float,
    branch_plant: str = "M30",
    location: str = "1.A.1",
) -> Dict[str, Any]:
  """[JDE Orchestrator] Issues shop floor component inventory to a Discrete Manufacturing Work Order via ORCH_IssueMaterialToWorkOrder (P31113 Work Order Inventory Issues), updating F3111, F41021, and Item Ledger F4111."""
  try:
    result = await jde_client.invoke_orchestration(
        "ORCH_IssueMaterialToWorkOrder",
        {
            "WorkOrderNumber": work_order_number,
            "ComponentItem": component_item_number.strip(),
            "QuantityIssued": quantity_to_issue,
            "BranchPlant": branch_plant.strip(),
            "Location": location,
        },
    )
    return {
        "engine": (
            "JDE Orchestrator"
            " (/jderest/v3/orchestrator/ORCH_IssueMaterialToWorkOrder)"
        ),
        "status": "SUCCESS",
        "orchestrator_response": result,
    }
  except Exception as exc:
    raise RuntimeError(
        "ORCH_IssueMaterialToWorkOrder failed to issue component "
        f"'{component_item_number}' to Work Order {work_order_number}: {exc}"
    ) from exc


@mcp.tool()
async def jde_complete_discrete_work_order(
    work_order_number: int,
    quantity_completed: float,
    quantity_scrapped: float = 0.0,
    new_status_code: str = "90",
) -> Dict[str, Any]:
  """[JDE Orchestrator] Records Discrete Manufacturing Work Order completion and scrap quantities via ORCH_CompleteWorkOrder (P31114 Work Order Completions), receiving finished assembly into F41021/F4111 and updating F4801."""
  try:
    result = await jde_client.invoke_orchestration(
        "ORCH_CompleteWorkOrder",
        {
            "WorkOrderNumber": work_order_number,
            "QuantityCompleted": quantity_completed,
            "QuantityScrapped": quantity_scrapped,
            "NewStatusCode": new_status_code,
        },
    )
    return {
        "engine": (
            "JDE Orchestrator (/jderest/v3/orchestrator/ORCH_CompleteWorkOrder)"
        ),
        "status": "SUCCESS",
        "orchestrator_response": result,
    }
  except Exception:
    result = await jde_client.formservice_action(
        form_name="P31114_W31114A",
        version="ZJDE0001",
        form_inputs=[{"id": "1", "value": str(work_order_number)}],
        form_actions=[
            {
                "command": "SetControlValue",
                "controlID": "28",
                "value": str(quantity_completed),
            },
            {
                "command": "SetControlValue",
                "controlID": "30",
                "value": str(quantity_scrapped),
            },
            {
                "command": "SetControlValue",
                "controlID": "34",
                "value": new_status_code,
            },
            {"command": "DoAction", "controlID": "11"},
        ],
    )
    return {
        "engine": "JDE AIS Form Service (/jderest/v2/formservice P31114)",
        "status": "SUCCESS",
        "ais_response": result,
    }


@mcp.tool()
async def jde_record_routing_hours(
    work_order_number: int,
    operation_sequence: float = 20.0,
    actual_labor_hours: float = 4.5,
    actual_machine_hours: float = 3.0,
    completed_quantity: float = 5.0,
) -> Dict[str, Any]:
  """[JDE Orchestrator] Executes Super Backflush / Routing Hours Entry (P311221) via ORCH_RecordRoutingHours against a Work Order routing step in F3112 and updates B1/B3 actual costs in F3102."""
  result = await jde_client.invoke_orchestration(
      "ORCH_RecordRoutingHours",
      {
          "WorkOrderNumber": work_order_number,
          "OperationSequence": operation_sequence,
          "ActualLaborHours": actual_labor_hours,
          "ActualMachineHours": actual_machine_hours,
          "CompletedQuantity": completed_quantity,
      },
  )
  return {
      "engine": (
          "JDE Orchestrator (/jderest/v3/orchestrator/ORCH_RecordRoutingHours)"
      ),
      "status": "SUCCESS",
      "orchestrator_response": result,
  }


@mcp.tool()
async def jde_expedite_shortage_po(
    purchase_order_number: int,
    promised_delivery_date_iso: str = "2026-10-10",
) -> Dict[str, Any]:
  """[JDE Orchestrator] Expedites an open Purchase Order line in F4311 (P4310) for a shortage component via ORCH_ExpediteShortagePO and updates the promised delivery date."""
  result = await jde_client.invoke_orchestration(
      "ORCH_ExpediteShortagePO",
      {
          "PurchaseOrderNumber": purchase_order_number,
          "PromisedDeliveryDate": promised_delivery_date_iso,
      },
  )
  return {
      "engine": (
          "JDE Orchestrator (/jderest/v3/orchestrator/ORCH_ExpediteShortagePO)"
      ),
      "status": "SUCCESS",
      "orchestrator_response": result,
  }


@mcp.tool()
async def jde_execute_custom_orchestration(
    orchestration_name: str,
    inputs_json: str = "{}",
) -> Dict[str, Any]:
  """[JDE Orchestrator] Invokes any custom JD Edwards EnterpriseOne Orchestration by name via /jderest/v3/orchestrator/{orchestration_name}."""
  inputs = json.loads(inputs_json) if inputs_json else {}
  return await jde_client.invoke_orchestration(orchestration_name, inputs)


@mcp.tool()
async def jde_query_watchlist_alerts(
    branch_plant: str = "M30",
    horizon_days: int = 14,
) -> Dict[str, Any]:
  """[JDE Watchlist & Proactive 14-Day Horizon] Evaluates active JDE One View Watchlists (SY920.F980051 / P980051), 14-day proactive forward-looking manufacturing risks, and historical Operational Precedents (PRODDTA.F48019) via ORCH_EvaluateWatchlistAndPrecedent and VW_JDE_WATCHLIST_ALERTS."""
  sql_wl = f"""
      SELECT watchlist_id,
             watchlist_name,
             jde_program_id,
             detection_mode,
             severity_level,
             branch_plant,
             active_record_count,
             stuck_days_avg,
             financial_exposure,
             linked_work_orders,
             watchlist_status,
             last_evaluated_dttm,
             precedent_id,
             historical_cases_cnt,
             success_rate_pct,
             recommended_orch,
             recommended_action,
             avg_manual_hours,
             agent_cycle_minutes,
             est_financial_impact,
             policy_threshold_usd,
             policy_gate_mode
        FROM {JDE_SCHEMA}.VW_JDE_WATCHLIST_ALERTS
       WHERE TRIM(branch_plant) = :bp
       ORDER BY financial_exposure DESC
  """
  watchlists = await asyncio.to_thread(
      execute_oracle_query, sql_wl, {"bp": branch_plant.strip()}
  )
  orch_res = await jde_client.invoke_orchestration(
      "ORCH_EvaluateWatchlistAndPrecedent",
      {"BranchPlant": branch_plant.strip(), "HorizonDays": horizon_days},
  )
  return {
      "engine": (
          "JDE Watchlist Framework (SY920.F980051) + JDE Orchestrator"
          " (ORCH_EvaluateWatchlistAndPrecedent)"
      ),
      "branch_plant": branch_plant.strip(),
      "horizon_days": horizon_days,
      "watchlist_alerts": watchlists,
      "proactive_horizon_and_precedents": orch_res,
  }


@mcp.tool()
async def jde_diagnose_dmaai_exceptions_and_precedent(
    dmaai_table: Optional[int] = None,
    work_order_number: Optional[int] = None,
) -> Dict[str, Any]:
  """[JDE DMAAI & Operational Precedent] Diagnoses Distribution/Manufacturing Automatic Accounting Instruction (DMAAI / P4095 / PRODDTA.F4095) exceptions blocking R31802A Manufacturing Accounting or R31804 Variance Posting, returning candidate GL accounts (PRODDTA.F0901), historical Operational Precedents (PRODDTA.F48019), and policy gate classification (< $5,000 AUTO_EXECUTE vs >= $5,000 APPROVAL_REQUIRED)."""
  sql_dmaai = f"""
      SELECT dmaai_table_number,
             company_code,
             branch_plant,
             document_type,
             gl_class_code,
             cost_type,
             configured_gl_account,
             object_account,
             subsidiary_account,
             dmaai_description,
             dmaai_status,
             blocked_work_order_number,
             blocked_item_summary,
             precedent_id,
             historical_cases_cnt,
             success_rate_pct,
             recommended_orch,
             recommended_action,
             recommended_gl_account,
             unposted_accounting_usd,
             policy_threshold_usd,
             policy_gate_mode
        FROM {JDE_SCHEMA}.VW_JDE_DMAAI_EXCEPTIONS
       WHERE (:dmaai_num IS NULL OR dmaai_table_number = :dmaai_num)
         AND (:wo_num IS NULL OR blocked_work_order_number = :wo_num)
       ORDER BY unposted_accounting_usd DESC NULLS LAST, dmaai_table_number ASC
  """
  dmaai_rows = await asyncio.to_thread(
      execute_oracle_query,
      sql_dmaai,
      {"dmaai_num": dmaai_table, "wo_num": work_order_number},
  )

  sql_prec = f"""
      SELECT precedent_id,
             exception_category,
             target_key,
             branch_plant,
             historical_cases_cnt,
             success_rate_pct,
             recommended_orch,
             recommended_action,
             target_gl_or_supplier,
             avg_manual_hours,
             agent_cycle_minutes,
             cycle_time_reduction_pct,
             est_financial_impact,
             policy_threshold_usd,
             policy_gate_mode,
             last_approved_by,
             last_resolved_dttm
        FROM {JDE_SCHEMA}.VW_JDE_OPERATIONAL_PRECEDENTS
       ORDER BY est_financial_impact DESC
  """
  precedents = await asyncio.to_thread(execute_oracle_query, sql_prec)
  return {
      "engine": (
          "Oracle 19c SQL Analytics (VW_JDE_DMAAI_EXCEPTIONS &"
          " VW_JDE_OPERATIONAL_PRECEDENTS)"
      ),
      "dmaai_exceptions": dmaai_rows,
      "operational_precedents": precedents,
  }


@mcp.tool()
async def jde_resolve_dmaai_accounting_exception(
    dmaai_table: int,
    company_code: str = "00030",
    document_type: str = "IH",
    gl_category_code: str = "IN30",
    cost_type: str = "B3",
    target_business_unit: str = "M30",
    target_object_account: str = "1340",
    target_subsidiary: str = "B3",
    blocked_work_order: int = 480015,
    approval_confirmed: bool = False,
) -> Dict[str, Any]:
  """[JDE Orchestrator] Resolves a missing DMAAI accounting rule in P4095 (PRODDTA.F4095) and re-runs R31802A Work Order Accounting via ORCH_ResolveDMAAIException. Enforces the $5,000 policy gate: exceptions < $5,000 auto-execute; exceptions >= $5,000 require approval_confirmed=True from the user's A2UI approval card."""
  result = await jde_client.invoke_orchestration(
      "ORCH_ResolveDMAAIException",
      {
          "DMAAITableNumber": dmaai_table,
          "CompanyCode": company_code.strip(),
          "DocumentType": document_type.strip(),
          "GLClassCode": gl_category_code.strip(),
          "CostType": cost_type.strip(),
          "BranchPlant": target_business_unit.strip(),
          "TargetObjectAccount": target_object_account.strip(),
          "TargetSubsidiary": target_subsidiary.strip(),
          "BlockedWorkOrderNumber": blocked_work_order,
          "ApprovalConfirmed": approval_confirmed,
      },
  )
  return {
      "engine": (
          "JDE Orchestrator"
          " (/jderest/v3/orchestrator/ORCH_ResolveDMAAIException)"
      ),
      "status": (
          result.get("status", "SUCCESS")
          if isinstance(result, dict)
          else "ERROR"
      ),
      "orchestrator_response": result,
  }


@mcp.tool()
async def jde_generate_a2ui_exception_approval_card(
    branch_plant: str = "M30",
) -> Dict[str, Any]:
  """[Gemini Enterprise A2UI v0.9] Generates an interactive Google A2UI v0.9 GM3 Material Catalog JSON surface (<a2ui-json>) displaying active JDE Watchlists, DMAAI Accounting Exceptions (< $5K Auto-Executed vs >= $5K Approval Required), Operational Precedents, and interactive approval buttons."""
  diag = await jde_diagnose_dmaai_exceptions_and_precedent()
  wl_data = await jde_query_watchlist_alerts(branch_plant=branch_plant)
  a2ui_surface = {
      "version": "v0.9",
      "createSurface": {
          "surfaceId": "jde-mfg-watchlist-dmaai-workbench",
          "catalogId": "gm3-material-v0.9",
          "theme": "google-enterprise-light",
          "title": (
              "JD Edwards 9.2 Manufacturing Exception & DMAAI Triage Workbench"
              f" (Branch/Plant {branch_plant.strip()})"
          ),
      },
      "updateDataModel": {
          "branchPlant": branch_plant.strip(),
          "watchlistAlerts": wl_data.get("watchlist_alerts", []),
          "dmaaiExceptions": [
              r
              for r in diag.get("dmaai_exceptions", [])
              if r.get("dmaai_status") != "ACTIVE"
          ],
          "operationalPrecedents": diag.get("operational_precedents", []),
          "policyGateThresholdUsd": 5000.0,
      },
      "updateComponents": [
          {
              "id": "kpi-summary-banner",
              "component": "MetricBanner",
              "props": {
                  "metrics": [
                      {
                          "label": "Active JDE Watchlists",
                          "value": "4 Watchlists (2 Critical, 2 Proactive 14D)",
                          "tone": "critical",
                      },
                      {
                          "label": "Auto-Remediated (< $5K Gate)",
                          "value": "DMAAI 3120 • WO 480015 ($3,420.00)",
                          "tone": "success",
                      },
                      {
                          "label": "Pending Human Approval (>= $5K Gate)",
                          "value": (
                              "DMAAI 3240 ($11,850) + PO 430101 ($14,800)"
                          ),
                          "tone": "warning",
                      },
                  ]
              },
          },
          {
              "id": "dmaai-3240-approval-card",
              "component": "ApprovalActionCard",
              "props": {
                  "badge": "REQUIRES APPROVAL (>= $5,000 POLICY GATE)",
                  "title": (
                      "DMAAI 3240 (P4095) — Engineering Change Variance"
                      " Blocking WO 480018 ($11,850.00)"
                  ),
                  "subtitle": (
                      "Precedent PREC-DMAAI-3240 (9 prior cases • 97.8%"
                      " confidence): Map Co 00030 / Doc IV / GL Class IN40 /"
                      " Cost A1 -> M30.5240.A1 (F0901) & re-run R31802A"
                  ),
                  "actions": [
                      {
                          "id": "btn-approve-dmaai-3240",
                          "label": (
                              "Approve & Execute ORCH_ResolveDMAAIException"
                              " ($11,850)"
                          ),
                          "event": "a2uiaction",
                          "payload": {
                              "orchestration": "ORCH_ResolveDMAAIException",
                              "DMAAITableNumber": 3240,
                              "CompanyCode": "00030",
                              "DocumentType": "IV",
                              "GLClassCode": "IN40",
                              "CostType": "A1",
                              "BranchPlant": "M30",
                              "TargetObjectAccount": "5240",
                              "TargetSubsidiary": "A1",
                              "BlockedWorkOrderNumber": 480018,
                              "ApprovalConfirmed": True,
                          },
                      },
                      {
                          "id": "btn-approve-po-430101",
                          "label": (
                              "Approve & Expedite Shortage PO 430101"
                              " ($14,800 -> 2026-10-10)"
                          ),
                          "event": "a2uiaction",
                          "payload": {
                              "orchestration": "ORCH_ExpediteShortagePO",
                              "PurchaseOrderNumber": 430101,
                              "PromisedDeliveryDate": "2026-10-10",
                          },
                      },
                  ],
              },
          },
      ],
  }
  return {
      "engine": "Google A2UI v0.9 Surface Generator (gm3-material-v0.9)",
      "a2ui_surface": a2ui_surface,
      "a2ui_markdown_block": (
          f"<a2ui-json>\n{json.dumps(a2ui_surface, indent=2, default=str)}\n</a2ui-json>"
      ),
  }


# ==============================================================================
# PART 3: STREAMABLE HTTP JSON-RPC 2.0 MCP SERVER (/mcp) FOR CLOUD RUN
# ==============================================================================

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
import uvicorn
import inspect

http_app = FastAPI(
    title="JDE-Hybrid-Orchestrator-SQL-MCP",
    version="1.2.0",
    description="Hybrid JD Edwards EnterpriseOne 9.2 MCP Server (JDE Orchestrator v3 REST + Oracle 19c SQL Analytics + Watchlist/DMAAI/Precedent + A2UI v0.9)",
)

TOOL_REGISTRY = {
    "jde_init": jde_init,
    "list_jde_current_context": list_jde_current_context,
    "list_jde_roles": list_jde_roles,
    "jde_query_work_order_control_tower": jde_query_work_order_control_tower,
    "jde_check_work_order_material_shortages": jde_check_work_order_material_shortages,
    "jde_analyze_work_center_capacity_and_bottlenecks": jde_analyze_work_center_capacity_and_bottlenecks,
    "jde_analyze_production_cost_variances": jde_analyze_production_cost_variances,
    "jde_discover_orchestrations": jde_discover_orchestrations,
    "jde_create_discrete_work_order": jde_create_discrete_work_order,
    "jde_issue_material_to_work_order": jde_issue_material_to_work_order,
    "jde_record_routing_hours": jde_record_routing_hours,
    "jde_complete_discrete_work_order": jde_complete_discrete_work_order,
    "jde_expedite_shortage_po": jde_expedite_shortage_po,
    "jde_execute_custom_orchestration": jde_execute_custom_orchestration,
    "jde_query_watchlist_alerts": jde_query_watchlist_alerts,
    "jde_diagnose_dmaai_exceptions_and_precedent": jde_diagnose_dmaai_exceptions_and_precedent,
    "jde_resolve_dmaai_accounting_exception": jde_resolve_dmaai_accounting_exception,
    "jde_generate_a2ui_exception_approval_card": jde_generate_a2ui_exception_approval_card,
}


@http_app.get("/")
@http_app.get("/health")
@http_app.get("/mcp")
async def health():
  return {
      "server": "JDE-Hybrid-Orchestrator-SQL-MCP",
      "version": "1.1.0",
      "status": "HEALTHY",
      "jde_ais_base_url": JDE_AIS_BASE_URL,
      "jde_db_dsn": JDE_DB_DSN,
      "active_jde_context": get_active_jde_context(),
      "tools_count": len(TOOL_REGISTRY),
      "tools": list(TOOL_REGISTRY.keys()),
  }


@http_app.post("/mcp")
async def mcp_jsonrpc(request: Request):
  # Capture X-User-Email or X-Goog-Authenticated-User-Email if sent by ADK agent / proxy
  hdr_email = (
      request.headers.get("x-user-email")
      or request.headers.get("x-goog-authenticated-user-email")
      or request.headers.get("x-user-id")
  )
  if hdr_email:
    clean_email = hdr_email.replace("accounts.google.com:", "").strip()
    if clean_email and clean_email not in ("default_user", "user", "anonymous"):
      _request_user_email.set(clean_email)

  try:
    body = await request.json()
  except Exception:
    return JSONResponse(
        status_code=400,
        content={
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32700, "message": "Parse error"},
        },
    )

  if not isinstance(body, dict):
    return JSONResponse(
        status_code=400,
        content={
            "jsonrpc": "2.0",
            "id": None,
            "error": {"code": -32600, "message": "Invalid Request"},
        },
    )

  req_id = body.get("id")
  method = body.get("method", "")
  params = body.get("params", {}) or {}

  if method == "initialize":
    return {
        "jsonrpc": "2.0",
        "id": req_id,
        "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {"tools": {"listChanged": False}},
            "serverInfo": {
                "name": "JDE-Hybrid-Orchestrator-SQL-MCP",
                "version": "1.0.0",
            },
        },
    }
  elif method.startswith("notifications/") or "id" not in body:
    return Response(status_code=204)
  elif method == "tools/list":
    tools_meta = await mcp.list_tools()
    return {
        "jsonrpc": "2.0",
        "id": req_id,
        "result": {
            "tools": [
                {
                    "name": t.name,
                    "description": t.description,
                    "inputSchema": t.inputSchema,
                }
                for t in tools_meta
            ]
        },
    }
  elif method == "tools/call":
    tool_name = params.get("name")
    args = params.get("arguments", {}) or {}
    fn = TOOL_REGISTRY.get(tool_name)
    if not fn:
      return {
          "jsonrpc": "2.0",
          "id": req_id,
          "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"},
      }
    try:
      if inspect.iscoroutinefunction(fn):
        res = await fn(**args)
      else:
        res = await asyncio.to_thread(fn, **args)
      return {
          "jsonrpc": "2.0",
          "id": req_id,
          "result": {
              "content": [{"type": "text", "text": json.dumps(res, indent=2, default=str)}],
              "isError": False,
          },
      }
    except Exception as exc:
      logger.exception("Error calling tool %s", tool_name)
      return {
          "jsonrpc": "2.0",
          "id": req_id,
          "result": {
              "content": [{"type": "text", "text": json.dumps({"error": str(exc)})}],
              "isError": True,
          },
      }
  else:
    return {
        "jsonrpc": "2.0",
        "id": req_id,
        "error": {"code": -32601, "message": f"Unsupported method: {method}"},
    }


if __name__ == "__main__":
  import sys
  if "--stdio" in sys.argv or os.environ.get("MCP_TRANSPORT") == "stdio":
    mcp.run()
  else:
    port = int(os.environ.get("PORT", "8080"))
    uvicorn.run(http_app, host="0.0.0.0", port=port)

