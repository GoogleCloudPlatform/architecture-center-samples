#!/usr/bin/env python3
"""
JD Edwards EnterpriseOne 9.2 (Release 24 / 9.2.26)
Application Interface Services (AIS) & Orchestrator Studio Server (:7077 / :8080)
Backed by live Oracle 19c PDB JDEORCL (PRODDTA / PRODCTL) on jde-demo-db (10.118.0.41:1521/jdeorcl)
"""

import datetime
import json
import logging
import os
import secrets
import threading
import time
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
import oracledb
import uvicorn

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("jde-ais-orchestrator")

DB_HOST = os.environ.get("JDE_DB_HOST", "10.118.0.41")
DB_PORT = int(os.environ.get("JDE_DB_PORT", "1521"))
DB_SERVICE = os.environ.get("JDE_DB_SERVICE", "jdeorcl")
DB_USER = os.environ.get("JDE_DB_USER", "PRODDTA")
DB_PASSWORD = os.environ.get("JDE_DB_PASSWORD", "REPLACE_WITH_JDE_DB_PASSWORD")

app = FastAPI(
    title="JD Edwards EnterpriseOne AIS & Orchestrator Server",
    version="9.2.26.0",
    description="Oracle JD Edwards EnterpriseOne Application Interface Services (AIS) v2 & Orchestrator v3 REST API",
)

_db_pool: Optional[oracledb.ConnectionPool] = None
_pool_lock = threading.Lock()


def _reset_session_identifier(conn, requested_tag):
    try:
        with conn.cursor() as cur:
            cur.execute("BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;")
    except Exception:
        pass


def get_pool() -> oracledb.ConnectionPool:
    global _db_pool
    if _db_pool is None:
        with _pool_lock:
            if _db_pool is None:
                dsn = f"{DB_HOST}:{DB_PORT}/{DB_SERVICE}"
                _db_pool = oracledb.create_pool(
                    user=DB_USER,
                    password=DB_PASSWORD,
                    dsn=dsn,
                    min=1,
                    max=10,
                    increment=1,
                    session_callback=_reset_session_identifier,
                )
    return _db_pool


def iso_to_julian(iso_str: Optional[str] = None) -> int:
    if not iso_str:
        dt = datetime.date.today()
    else:
        try:
            dt = datetime.date.fromisoformat(iso_str[:10])
        except Exception:
            dt = datetime.date.today()
    century = (dt.year - 1900) // 100
    yy = dt.year % 100
    ddd = dt.timetuple().tm_yday
    return century * 100000 + yy * 1000 + ddd


def julian_to_iso(julian: Optional[int]) -> Optional[str]:
    if not julian or julian <= 0:
        return None
    year = 1900 + (julian // 1000)
    ddd = julian % 1000
    try:
        dt = datetime.date(year, 1, 1) + datetime.timedelta(days=ddd - 1)
        return dt.isoformat()
    except Exception:
        return str(julian)


def now_hhmmss() -> int:
    now = datetime.datetime.now()
    return now.hour * 10000 + now.minute * 100 + now.second


def next_number(cur, system_code: str) -> int:
    cur.execute(
        "SELECT NNDOCO FROM PRODDTA.F0002 WHERE TRIM(NNSY) = :sy FOR UPDATE",
        {"sy": system_code.strip()},
    )
    row = cur.fetchone()
    if not row:
        doco = 480100
        cur.execute(
            "INSERT INTO PRODDTA.F0002 (NNSY, NNDOCO) VALUES (:sy, :doco)",
            {"sy": system_code.ljust(4), "doco": doco + 1},
        )
        return doco
    doco = int(row[0])
    cur.execute(
        "UPDATE PRODDTA.F0002 SET NNDOCO = :next_doco WHERE TRIM(NNSY) = :sy",
        {"next_doco": doco + 1, "sy": system_code.strip()},
    )
    return doco


def resolve_jde_user(cur, payload: Optional[Dict[str, Any]] = None, headers: Optional[Any] = None) -> str:
    try:
        cur.execute("BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;")
    except Exception:
        pass
    candidate = None
    if isinstance(payload, dict):
        candidate = payload.get("userEmail") or payload.get("jdeUser") or payload.get("username")
    if not candidate and headers:
        candidate = headers.get("x-user-email") or headers.get("x-jde-user")
    if candidate and str(candidate).strip().upper() == "JDE":
        candidate = None
    jde_usr = "NGONZAL"
    try:
        cur.execute(
            "SELECT PRODDTA.GE_JDE_MCP_TOOLS.get_active_jde_user(:u) FROM DUAL",
            {"u": str(candidate).strip() if candidate else None},
        )
        row = cur.fetchone()
        if row and row[0]:
            jde_usr = str(row[0]).strip()
        cur.execute("BEGIN DBMS_SESSION.SET_IDENTIFIER(:id); END;", {"id": jde_usr[:64]})
    except Exception as exc:
        logger.debug("resolve_jde_user fallback: %s", exc)
    return jde_usr


def check_f00950_security(cur, jde_user: str, app_id: str, branch_plant: str) -> None:
    try:
        cur.execute(
            """
            SELECT FSOKAY, FSATN, FSCHNG
            FROM PRODCTL.F00950
            WHERE TRIM(FSUSER) IN (:u, '*PUBLIC')
              AND TRIM(FSOBNM) = :app
              AND TRIM(FSMCU)  = :mcu
            FETCH FIRST 1 ROWS ONLY
            """,
            {"u": jde_user.strip().upper(), "app": app_id.strip().upper(), "mcu": branch_plant.strip().upper()},
        )
        row = cur.fetchone()
        if row and (row[0] != "Y" or row[1] != "Y"):
            raise HTTPException(
                status_code=403,
                detail=f"JDE Security Workbench (F00950) denied action on {app_id} for user {jde_user} in Branch/Plant {branch_plant}",
            )
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("F00950 security check failed: %s", exc)
        raise HTTPException(
            status_code=500,
            detail="Internal security verification failure.",
        )


def log_audit(
    cur,
    tool_name: str,
    action_type: str,
    target_object: str,
    payload: Any,
    status: str = "SUCCESS",
    jde_user: str = "NGONZAL",
):
    try:
        wo_num = payload.get("WorkOrderNumber") if isinstance(payload, dict) else None
        cur.execute(
            """
            INSERT INTO PRODDTA.GGLTOOLBOX$MCP_LOG
              (TOOL_NAME, JDE_USER, WORK_ORDER_NUM, PARAMETERS, EXECUTION_MODE, STATUS)
            VALUES (:t, :usr, :wo, :p, :a, :s)
            """,
            {
                "t": f"{tool_name}:{target_object}"[:128],
                "usr": (jde_user or "NGONZAL").strip()[:30],
                "wo": int(wo_num) if wo_num else None,
                "p": json.dumps(payload, default=str)[:3900],
                "a": action_type[:32],
                "s": status[:32],
            },
        )
    except Exception as exc:
        logger.warning("Audit log warning: %s", exc)


# ============================================================================
# 1. AIS v2 Authentication & Discovery Endpoints
# ============================================================================

@app.get("/jderest/v2/defaultconfig")
@app.get("/jderest/defaultconfig")
def default_config():
    return {
        "jasHost": "http://jde-demo-web.c.jde-showcase.internal:8080",
        "jasPort": "8080",
        "jasProtocol": "http",
        "defaultEnvironment": "JPD920",
        "defaultRole": "*ALL",
        "displayEnvironment": True,
        "displayRole": True,
        "aisVersion": "EnterpriseOne 9.2.26.0",
        "capabilityList": [
            {"name": "dataservice", "shortDescription": "AIS Data Service", "asofRelease": "9.2.1"},
            {"name": "formservice", "shortDescription": "AIS Form Service", "asofRelease": "9.2.0"},
            {"name": "orchestrator", "shortDescription": "JDE Orchestrator v3", "asofRelease": "9.2.4"},
            {"name": "open-api-catalog", "shortDescription": "OpenAPI 3.0 Catalog", "asofRelease": "9.2.5"},
            {"name": "E1Menu", "shortDescription": "EnterpriseOne Web Client", "asofRelease": "9.2.0"},
        ],
    }


@app.post("/jderest/v2/tokenrequest")
@app.post("/jderest/tokenrequest")
def token_request(body: dict, request: Request):
    username = body.get("username", "NGONZAL")
    env = body.get("environment", "JPD920")
    role = body.get("role", "MFG_MGR")
    an8 = 80001
    alph = "Gonzalez, Nelson (VP Mfg Operations)"
    try:
        with get_pool().acquire() as conn:
            with conn.cursor() as cur:
                username = resolve_jde_user(cur, body, request.headers)
                cur.execute(
                    """
                    SELECT u.ULAN8, TRIM(a.ABALPH), TRIM(u.ULROLE), TRIM(u.ULENV)
                    FROM SY920.F0092 u
                    JOIN PRODDTA.F0101 a ON a.ABAN8 = u.ULAN8
                    WHERE TRIM(u.ULUSER) = :u
                    FETCH FIRST 1 ROWS ONLY
                    """,
                    {"u": username},
                )
                r = cur.fetchone()
                if r:
                    an8, alph, role, env = int(r[0]), str(r[1]), str(r[2]), str(r[3])
    except Exception as exc:
        logger.debug("Token request user lookup fallback: %s", exc)
    token = f"JDE_AIS_TOKEN_{secrets.token_hex(16)}"
    return {
        "username": username,
        "environment": env,
        "role": role,
        "jasserver": "http://jde-demo-web.c.jde-showcase.internal:8080",
        "userInfo": {
            "token": token,
            "langPref": "  ",
            "locale": "en",
            "dateFormat": "MDE",
            "dateSeperator": "/",
            "simpleDateFormat": "MM/dd/yyyy",
            "decimalFormat": ".",
            "addressNumber": an8,
            "alphaName": alph,
            "appsRelease": "E920",
            "country": " ",
            "username": username,
        },
        "userAuthorized": True,
        "version": "9.2.26.0",
    }


@app.post("/jderest/v2/tokenrequest/logout")
def token_logout():
    return {"status": "LOGGED_OUT"}


ORCHESTRATIONS_CATALOG = [
    {
        "name": "ORCH_CreateDiscreteWorkOrder",
        "Category": "Manufacturing - Discrete",
        "Version": "v3",
        "Description": "Creates a Discrete Manufacturing Work Order header in F4801 (P48013), explodes and attaches the standard Bill of Material into F3111 (P3111), attaches standard Routing operations into F3112 (P3112), commits inventory in F41021, and initializes F3102 production costing.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "BranchPlant", "type": "String", "required": True, "example": "M30"},
            {"name": "ItemNumber", "type": "String", "required": True, "example": "AS-5000-SERVO"},
            {"name": "OrderQuantity", "type": "Numeric", "required": True, "example": 15},
            {"name": "RequestedDate", "type": "String", "required": False, "example": "2026-10-20"},
            {"name": "StartDate", "type": "String", "required": False, "example": "2026-10-10"},
            {"name": "WorkOrderType", "type": "String", "required": False, "example": "WO"},
            {"name": "Priority", "type": "String", "required": False, "example": "1"},
            {"name": "AttachPartsListAndRouting", "type": "Boolean", "required": False, "example": True},
        ],
    },
    {
        "name": "ORCH_IssueMaterialToWorkOrder",
        "Category": "Manufacturing - Discrete",
        "Version": "v3",
        "Description": "Executes Work Order Inventory Issues (P31113) for a component against an active Discrete Work Order. Decrements F41021 on-hand/commitments, increments F3111 issued quantity, writes an IM transaction to F4111 Cardex, and updates F3102 actual material cost.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "WorkOrderNumber", "type": "Integer", "required": True, "example": 480010},
            {"name": "BranchPlant", "type": "String", "required": True, "example": "M30"},
            {"name": "ComponentItem", "type": "String", "required": True, "example": "CM-1010-STATOR"},
            {"name": "IssueQuantity", "type": "Numeric", "required": True, "example": 10},
            {"name": "FromLocation", "type": "String", "required": False, "example": "RM-B01"},
            {"name": "LotSerial", "type": "String", "required": False, "example": ""},
        ],
    },
    {
        "name": "ORCH_RecordRoutingHours",
        "Category": "Manufacturing - Discrete",
        "Version": "v3",
        "Description": "Executes Super Backflush / Routing Hours Entry (P311221) against a Work Order routing step in F3112 and updates B1/B3 actual costs in F3102.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "WorkOrderNumber", "type": "Integer", "required": True, "example": 480010},
            {"name": "OperationSequence", "type": "Numeric", "required": True, "example": 20},
            {"name": "ActualLaborHours", "type": "Numeric", "required": True, "example": 4.5},
            {"name": "ActualMachineHours", "type": "Numeric", "required": True, "example": 3.0},
            {"name": "CompletedQuantity", "type": "Numeric", "required": False, "example": 5},
        ],
    },
    {
        "name": "ORCH_CompleteWorkOrder",
        "Category": "Manufacturing - Discrete",
        "Version": "v3",
        "Description": "Executes Work Order Completions (P31114) into Finished Goods inventory. Updates F4801 completed/scrapped quantities and status, increments F41021 finished goods on-hand, writes an IC transaction to F4111 Cardex, and updates F3102 completed/scrap costs.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "WorkOrderNumber", "type": "Integer", "required": True, "example": 480010},
            {"name": "BranchPlant", "type": "String", "required": True, "example": "M30"},
            {"name": "CompletedQuantity", "type": "Numeric", "required": True, "example": 15},
            {"name": "ScrappedQuantity", "type": "Numeric", "required": False, "example": 0},
            {"name": "ToLocation", "type": "String", "required": False, "example": "FG-A01"},
            {"name": "NewStatusCode", "type": "String", "required": False, "example": "90"},
        ],
    },
    {
        "name": "ORCH_ExpediteShortagePO",
        "Category": "Supply Chain & Shop Floor",
        "Version": "v3",
        "Description": "Expedites an open Purchase Order line in F4311 (P4310) for a shortage component and updates promised delivery date.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "PurchaseOrderNumber", "type": "Integer", "required": True, "example": 430101},
            {"name": "PromisedDeliveryDate", "type": "String", "required": True, "example": "2026-10-10"},
        ],
    },
    {
        "name": "ORCH_EvaluateWatchlistAndPrecedent",
        "Category": "Watchlists & Operational Precedent",
        "Version": "v3",
        "Description": "Evaluates active JDE One View Watchlist alerts (SY920.F980051 / P980051), 14-day proactive shortage/capacity horizon risks, and historical resolution precedents (PRODDTA.F48019).",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "BranchPlant", "type": "String", "required": False, "example": "M30"},
            {"name": "WatchlistId", "type": "String", "required": False, "example": "WL-MFG-02"},
        ],
    },
    {
        "name": "ORCH_ResolveDMAAIException",
        "Category": "Manufacturing Accounting (P4095 / R31802A)",
        "Version": "v3",
        "Description": "Remediates a missing or invalid Distribution/Manufacturing Automatic Accounting Instruction (DMAAI) in PRODDTA.F4095 (P4095) against PRODDTA.F0901, enforces the $5,000 policy gate (autonomous execution < $5,000 vs. human A2UI approval >= $5,000), posts R31802A Manufacturing Accounting for the blocked Work Order, and updates PRODDTA.F48019 operational precedent.",
        "InputFormat": "JSON",
        "Inputs": [
            {"name": "DMAAITableNumber", "type": "Integer", "required": True, "example": 3120},
            {"name": "CompanyCode", "type": "String", "required": False, "example": "00030"},
            {"name": "DocumentType", "type": "String", "required": True, "example": "IH"},
            {"name": "GLClassCode", "type": "String", "required": True, "example": "IN30"},
            {"name": "CostType", "type": "String", "required": True, "example": "B3"},
            {"name": "TargetObjectAccount", "type": "String", "required": True, "example": "1340"},
            {"name": "TargetSubsidiary", "type": "String", "required": True, "example": "B3"},
            {"name": "BlockedWorkOrderNumber", "type": "Integer", "required": False, "example": 480015},
            {"name": "ApprovalConfirmed", "type": "Boolean", "required": False, "example": False},
        ],
    },
]


@app.get("/jderest/v2/open-api-catalog")
@app.get("/jderest/v3/orchestrator/discover")
def open_api_catalog():
    paths = {}
    for orch in ORCHESTRATIONS_CATALOG:
        paths[f"/jderest/v3/orchestrator/{orch['name']}"] = {
            "post": {
                "summary": orch["Description"],
                "tags": [orch["Category"]],
                "operationId": orch["name"],
            }
        }
    return {
        "openapi": "3.0.1",
        "info": {
            "title": "JD Edwards EnterpriseOne Orchestrator Studio Catalog (JPD920)",
            "version": "9.2.26.0",
            "description": "Live Orchestrations for Discrete Manufacturing (Branch/Plant M30)",
        },
        "orchestrations": ORCHESTRATIONS_CATALOG,
        "paths": paths,
    }


# ============================================================================
# 2. JDE Orchestrator v3 Execution Engine (/jderest/v3/orchestrator/{name})
# ============================================================================

@app.post("/jderest/v3/orchestrator/{orch_name}")
@app.post("/jderest/orchestrator/{orch_name}")
def execute_orchestration(orch_name: str, payload: dict, request: Request):
    pool = get_pool()

    if orch_name == "ORCH_CreateDiscreteWorkOrder":
        bp = str(payload.get("BranchPlant", "M30")).strip().rjust(12)
        item_str = str(payload.get("ItemNumber") or payload.get("ParentItem") or "AS-5000-SERVO").strip()
        qty_ea = float(payload.get("OrderQuantity") or payload.get("QuantityOrdered") or 10)
        qty_scaled = int(round(qty_ea * 10000))
        req_julian = iso_to_julian(payload.get("RequestedDate"))
        start_julian = iso_to_julian(payload.get("StartDate"))
        wo_type = str(payload.get("WorkOrderType", "WO")).strip()[:2].ljust(2)
        priority = str(payload.get("Priority", "1")).strip()[:1]
        attach_bom = bool(
            payload.get("AttachPartsListAndRouting")
            if "AttachPartsListAndRouting" in payload
            else payload.get("AttachPartsAndRouting", True)
        )
        custom_desc = payload.get("Description")

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                jde_user_pad = jde_user.ljust(10)[:10]
                check_f00950_security(cur, jde_user, "P48013", bp.strip())

                # Lookup item in F4101
                if item_str.isdigit():
                    cur.execute(
                        """
                        SELECT IMITM, TRIM(IMLITM), TRIM(IMAITM), IMDSC1, TRIM(IMUOM1)
                        FROM PRODDTA.F4101
                        WHERE IMITM = :item
                        """,
                        {"item": int(item_str)},
                    )
                else:
                    cur.execute(
                        """
                        SELECT IMITM, TRIM(IMLITM), TRIM(IMAITM), IMDSC1, TRIM(IMUOM1)
                        FROM PRODDTA.F4101
                        WHERE TRIM(IMLITM) = :item
                        """,
                        {"item": item_str},
                    )
                item_row = cur.fetchone()
                if not item_row:
                    raise HTTPException(status_code=404, detail=f"Item '{item_str}' not found in PRODDTA.F4101")
                itm, litm, aitm, dsc1, uom = item_row

                doco = next_number(cur, "48")
                init_status = "30" if attach_bom else "10"
                today_j = iso_to_julian()
                wo_desc = (custom_desc[:30] if custom_desc else f"WO: {dsc1[:25]}")

                cur.execute(
                    """
                    INSERT INTO PRODDTA.F4801
                      (WADOCO, WADCTO, WAMCU, WAITM, WALITM, WAAITM, WADSC1, WASRST,
                       WATYPS, WAPRTS, WAUORG, WASOQS, WASOCN, WAUOM, WATRDJ, WASTRT,
                       WADRQJ, WASTRX, WAAN8, WAANPA, WAWR01, WAUSER, WAPID, WAJOBN, WAUPMJ, WATDAY)
                    VALUES
                      (:doco, :dcto, :mcu, :itm, :litm, :aitm, :dsc1, :srst,
                       '1', :prts, :uorg, 0, 0, :uom, :trdj, :strt,
                       :drqj, 0, 80001, 80001, 'DISC', :usr, 'P48013    ', 'ORCH-V3   ', :upmj, :tday)
                    """,
                    {
                        "doco": doco,
                        "dcto": wo_type,
                        "mcu": bp,
                        "itm": itm,
                        "litm": litm.ljust(25),
                        "aitm": (aitm or litm).ljust(25),
                        "dsc1": wo_desc,
                        "srst": init_status,
                        "prts": priority,
                        "uorg": qty_scaled,
                        "uom": (uom or "EA").ljust(2),
                        "trdj": today_j,
                        "strt": start_julian,
                        "drqj": req_julian,
                        "usr": jde_user_pad,
                        "upmj": today_j,
                        "tday": now_hhmmss(),
                    },
                )

                attached_parts = []
                attached_routings = []
                if attach_bom:
                    # Explode BOM from F3002 into F3111
                    cur.execute(
                        """
                        SELECT b.IXCPNB, b.IXITM, TRIM(b.IXLITM), m.IMDSC1, b.IXQNTY, TRIM(b.IXUM), b.IXOPSQ
                        FROM PRODDTA.F3002 b
                        JOIN PRODDTA.F4101 m ON m.IMITM = b.IXITM
                        WHERE b.IXKIT = :kit AND TRIM(b.IXMMCU) = :mcu
                        ORDER BY b.IXCPNB
                        """,
                        {"kit": itm, "mcu": bp.strip()},
                    )
                    bom_rows = cur.fetchall()
                    for c_cpnb, c_itm, c_litm, c_dsc1, c_qnty, c_um, c_opsq in bom_rows:
                        req_comp_scaled = int(round((c_qnty / 10000.0) * qty_ea * 10000))
                        # Find primary bin in F41021
                        cur.execute(
                            """
                            SELECT LILOCN FROM PRODDTA.F41021
                            WHERE LIITM = :itm AND TRIM(LIMCU) = :mcu AND ROWNUM = 1
                            """,
                            {"itm": c_itm, "mcu": bp.strip()},
                        )
                        loc_row = cur.fetchone()
                        locn = loc_row[0] if loc_row else "RM-B01              "
                        cur.execute(
                            """
                            INSERT INTO PRODDTA.F3111
                              (WMDOCO, WMDCTO, WMCPNB, WMCMCU, WMITM, WMLITM, WMAITM, WMDSC1,
                               WMUORG, WMTRQT, WMSOCN, WMUM, WMOPSQ, WMLOCN, WMLOTN, WMUSER, WMPID, WMUPMJ)
                            VALUES
                              (:doco, :dcto, :cpnb, :mcu, :itm, :litm, :litm, :dsc1,
                               :uorg, 0, 0, :um, :opsq, :locn, '                              ', :usr, 'R31410    ', :upmj)
                            """,
                            {
                                "doco": doco,
                                "dcto": wo_type,
                                "cpnb": c_cpnb,
                                "mcu": bp,
                                "itm": c_itm,
                                "litm": c_litm.ljust(25),
                                "dsc1": c_dsc1,
                                "uorg": req_comp_scaled,
                                "um": (c_um or "EA").ljust(2),
                                "opsq": c_opsq,
                                "locn": locn,
                                "usr": jde_user_pad,
                                "upmj": today_j,
                            },
                        )
                        # Soft commit in F41021
                        cur.execute(
                            """
                            UPDATE PRODDTA.F41021
                            SET LIHCOM = NVL(LIHCOM, 0) + :req_qty
                            WHERE LIITM = :itm AND TRIM(LIMCU) = :mcu AND LILOCN = :locn
                            """,
                            {"req_qty": req_comp_scaled, "itm": c_itm, "mcu": bp.strip(), "locn": locn},
                        )
                        attached_parts.append(
                            {
                                "component_item_id": c_itm,
                                "component_item": c_litm,
                                "description": c_dsc1,
                                "required_qty": req_comp_scaled / 10000.0,
                                "uom": c_um,
                                "operation_seq": c_opsq / 100.0,
                            }
                        )

                    # Attach Routing from F3003 into F3112
                    cur.execute(
                        """
                        SELECT IROPSQ, IRMCU, IRDSC1, IRRUNL, IRRUNM, IRSETL
                        FROM PRODDTA.F3003
                        WHERE IRKIT = :kit AND TRIM(IRMMCU) = :mcu
                        ORDER BY IROPSQ
                        """,
                        {"kit": itm, "mcu": bp.strip()},
                    )
                    rtg_rows = cur.fetchall()
                    for r_opsq, r_wcmcu, r_dsc1, r_runl, r_runm, r_setl in rtg_rows:
                        std_run_l = int(round(r_runl * qty_ea))
                        std_run_m = int(round(r_runm * qty_ea))
                        cur.execute(
                            """
                            INSERT INTO PRODDTA.F3112
                              (WLDOCO, WLDCTO, WLOPSQ, WLOPST, WLMCU, WLMMCU, WLDSC1,
                               WLRUNL, WLRUNM, WLSETL, WLHRSO, WLHRSA, WLUORG, WLSOQS, WLSOCN,
                               WLSTRT, WLDRQJ, WLUSER, WLPID, WLUPMJ)
                            VALUES
                              (:doco, :dcto, :opsq, '10', :wcmcu, :mmcu, :dsc1,
                               :runl, :runm, :setl, 0, 0, :uorg, 0, 0,
                               :strt, :drqj, :usr, 'R31410    ', :upmj)
                            """,
                            {
                                "doco": doco,
                                "dcto": wo_type,
                                "opsq": r_opsq,
                                "wcmcu": r_wcmcu,
                                "mmcu": bp,
                                "dsc1": r_dsc1,
                                "runl": std_run_l,
                                "runm": std_run_m,
                                "setl": r_setl,
                                "uorg": qty_scaled,
                                "strt": start_julian,
                                "drqj": req_julian,
                                "usr": jde_user_pad,
                                "upmj": today_j,
                            },
                        )
                        attached_routings.append(
                            {
                                "operation_seq": r_opsq / 100.0,
                                "work_center": r_wcmcu.strip(),
                                "description": r_dsc1.strip(),
                                "std_run_labor_hrs": std_run_l / 100.0,
                                "std_run_machine_hrs": std_run_m / 100.0,
                                "std_setup_hrs": r_setl / 100.0,
                            }
                        )

                    # Seed standard cost rows in F3102
                    std_mat_cost = int(round(qty_ea * 14500 * 100))
                    std_lab_cost = int(round(qty_ea * 4200 * 100))
                    std_mac_cost = int(round(qty_ea * 5800 * 100))
                    for cost_code, std_amt in [("A1 ", std_mat_cost), ("B1 ", std_lab_cost), ("B3 ", std_mac_cost)]:
                        cur.execute(
                            """
                            INSERT INTO PRODDTA.F3102
                              (IGDOCO, IGDCTO, IGITM, IGLITM, IGMCU, IGCOST, IGPART, IGSTDC, IGPLNC, IGACTC, IGCSMT, IGSCRP, IGUPMJ)
                            VALUES
                              (:doco, :dcto, :itm, :litm, :mcu, :cost, ' ', :std, :std, 0, 0, 0, :upmj)
                            """,
                            {
                                "doco": doco,
                                "dcto": wo_type,
                                "itm": itm,
                                "litm": litm.ljust(25),
                                "mcu": bp,
                                "cost": cost_code,
                                "std": std_amt,
                                "upmj": today_j,
                            },
                        )

                log_audit(cur, orch_name, "ORCHESTRATOR_WRITE", f"F4801:{doco}", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "jdeEnvironment": "JPD920",
            "workOrderNumber": doco,
            "workOrderType": wo_type.strip(),
            "statusCode": init_status,
            "branchPlant": bp.strip(),
            "itemNumber": litm,
            "itemDescription": wo_desc,
            "orderQuantity": qty_ea,
            "uom": uom,
            "startDate": julian_to_iso(start_julian),
            "requestedDate": julian_to_iso(req_julian),
            "partsListAttachedCount": len(attached_parts),
            "partsList": attached_parts,
            "routingOperationsAttachedCount": len(attached_routings),
            "routingOperations": attached_routings,
        }

    elif orch_name == "ORCH_IssueMaterialToWorkOrder":
        wo_num = int(payload.get("WorkOrderNumber"))
        bp = str(payload.get("BranchPlant", "M30")).strip()
        comp_str = str(payload.get("ComponentItem")).strip()
        issue_qty = float(payload.get("IssueQuantity") or payload.get("QuantityIssued") or 0)
        issue_scaled = int(round(issue_qty * 10000))
        from_loc = str(payload.get("FromLocation") or payload.get("Location") or "RM-B01").strip().ljust(20)
        lot_n = str(payload.get("LotSerial", "")).strip().ljust(30)

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                jde_user_pad = jde_user.ljust(10)[:10]
                check_f00950_security(cur, jde_user, "P31113", bp)

                if comp_str.isdigit():
                    cur.execute(
                        """
                        SELECT WMITM, TRIM(WMLITM), WMDSC1, WMUORG, WMTRQT, TRIM(WMUM)
                        FROM PRODDTA.F3111
                        WHERE WMDOCO = :doco AND WMITM = :comp
                        """,
                        {"doco": wo_num, "comp": int(comp_str)},
                    )
                else:
                    cur.execute(
                        """
                        SELECT WMITM, TRIM(WMLITM), WMDSC1, WMUORG, WMTRQT, TRIM(WMUM)
                        FROM PRODDTA.F3111
                        WHERE WMDOCO = :doco AND TRIM(WMLITM) = :comp
                        """,
                        {"doco": wo_num, "comp": comp_str},
                    )
                part_row = cur.fetchone()
                if not part_row:
                    raise HTTPException(
                        status_code=404,
                        detail=f"Component '{comp_str}' not found on Parts List (F3111) for Work Order {wo_num}",
                    )
                c_itm, c_litm, c_dsc1, uorg_s, trqt_s, c_um = part_row

                # Update F3111 issued quantity
                new_trqt_s = int(trqt_s or 0) + issue_scaled
                cur.execute(
                    """
                    UPDATE PRODDTA.F3111
                    SET WMTRQT = :new_trqt, WMUSER = :usr, WMUPMJ = :upmj, WMPID = 'P31113    '
                    WHERE WMDOCO = :doco AND WMITM = :itm
                    """,
                    {"new_trqt": new_trqt_s, "usr": jde_user_pad, "upmj": iso_to_julian(), "doco": wo_num, "itm": c_itm},
                )

                # Decrement F41021 on-hand & commitment
                cur.execute(
                    """
                    UPDATE PRODDTA.F41021
                    SET LIPQOH = LIPQOH - :qty,
                        LIHCOM = GREATEST(0, NVL(LIHCOM, 0) - :qty)
                    WHERE LIITM = :itm AND TRIM(LIMCU) = :mcu AND LILOCN = :locn AND LILOTN = :lotn
                    """,
                    {"qty": issue_scaled, "itm": c_itm, "mcu": bp, "locn": from_loc, "lotn": lot_n},
                )

                # Get standard cost from F4105
                cur.execute(
                    """
                    SELECT COUNCS FROM PRODDTA.F4105
                    WHERE COITM = :itm AND TRIM(COMCU) = :mcu AND COLEDG = '07' AND ROWNUM = 1
                    """,
                    {"itm": c_itm, "mcu": bp},
                )
                cost_row = cur.fetchone()
                unit_cost_scaled = int(cost_row[0]) if cost_row else 2500000
                extended_cost_cents = int(round((unit_cost_scaled / 10000.0) * issue_qty * 100))

                # Insert IM document into F4111 Cardex
                im_doc = next_number(cur, "41")
                cur.execute("SELECT PRODDTA.SEQ_F4111_UKID.NEXTVAL FROM DUAL")
                ukid = int(cur.fetchone()[0])
                today_j = iso_to_julian()

                cur.execute(
                    """
                    INSERT INTO PRODDTA.F4111
                      (ILUKID, ILDOC, ILDCT, ILKCO, ILDOCO, ILDCTO, ILITM, ILLITM,
                       ILMCU, ILLOCN, ILLOTN, ILTRDJ, ILTRQT, ILTRUM, ILUNCS, ILPAID,
                       ILTREX, ILUSER, ILPID, ILCRDJ, ILTDAY)
                    VALUES
                      (:ukid, :doc, 'IM', '00200', :doco, 'WO', :itm, :litm,
                       :mcu, :locn, :lotn, :trdj, :trqt, :um, :uncs, :paid,
                       :trex, :usr, 'P31113    ', :trdj, :tday)
                    """,
                    {
                        "ukid": ukid,
                        "doc": im_doc,
                        "doco": wo_num,
                        "itm": c_itm,
                        "litm": c_litm.ljust(25),
                        "mcu": bp.rjust(12),
                        "locn": from_loc,
                        "lotn": lot_n,
                        "trdj": today_j,
                        "trqt": -issue_scaled,
                        "um": (c_um or "EA").ljust(2),
                        "uncs": unit_cost_scaled,
                        "paid": -extended_cost_cents,
                        "trex": f"IM Issue WO {wo_num}"[:30],
                        "usr": jde_user_pad,
                        "tday": now_hhmmss(),
                    },
                )

                # Advance F4801 status to '45' (Material Issued / WIP) if below 45
                cur.execute(
                    """
                    UPDATE PRODDTA.F4801
                    SET WASRST = CASE WHEN TRIM(WASRST) < '45' THEN '45' ELSE WASRST END,
                        WAUSER = :usr, WAUPMJ = :upmj, WATDAY = :tday
                    WHERE WADOCO = :doco
                    """,
                    {"usr": jde_user_pad, "upmj": today_j, "tday": now_hhmmss(), "doco": wo_num},
                )

                # Update F3102 actual material cost (A1)
                cur.execute(
                    """
                    UPDATE PRODDTA.F3102
                    SET IGACTC = NVL(IGACTC, 0) + :cost_cents, IGUPMJ = :upmj
                    WHERE IGDOCO = :doco AND TRIM(IGCOST) = 'A1'
                    """,
                    {"cost_cents": extended_cost_cents, "upmj": today_j, "doco": wo_num},
                )

                log_audit(cur, orch_name, "ORCHESTRATOR_WRITE", f"F3111:{wo_num}:{c_litm}", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "workOrderNumber": wo_num,
            "componentItem": c_litm,
            "componentDescription": c_dsc1,
            "issuedQuantityNow": issue_qty,
            "cumulativeIssuedQuantity": new_trqt_s / 10000.0,
            "requiredQuantity": (uorg_s or 0) / 10000.0,
            "remainingOpenQuantity": max(0.0, ((uorg_s or 0) - new_trqt_s) / 10000.0),
            "cardexDocumentNumber": im_doc,
            "cardexDocumentType": "IM",
            "cardexUniqueKeyID": ukid,
            "extendedMaterialCostUSD": extended_cost_cents / 100.0,
        }

    elif orch_name == "ORCH_RecordRoutingHours":
        wo_num = int(payload.get("WorkOrderNumber"))
        op_seq_user = float(payload.get("OperationSequence", 10))
        op_seq_db = int(round(op_seq_user * 100)) if op_seq_user < 100 else int(op_seq_user)
        labor_hrs = float(payload.get("ActualLaborHours", 0))
        mach_hrs = float(payload.get("ActualMachineHours", 0))
        comp_qty = float(payload.get("CompletedQuantity", 0))

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                jde_user_pad = jde_user.ljust(10)[:10]
                check_f00950_security(cur, jde_user, "P311221", "M30")

                cur.execute(
                    """
                    UPDATE PRODDTA.F3112
                    SET WLHRSO = NVL(WLHRSO, 0) + :lab,
                        WLHRSA = NVL(WLHRSA, 0) + :mac,
                        WLSOQS = NVL(WLSOQS, 0) + :qty,
                        WLOPST = '40',
                        WLUSER = :usr,
                        WLUPMJ = :upmj,
                        WLPID  = 'P311221   '
                    WHERE WLDOCO = :doco AND WLOPSQ = :opsq
                    """,
                    {
                        "lab": int(round(labor_hrs * 100)),
                        "mac": int(round(mach_hrs * 100)),
                        "qty": int(round(comp_qty * 10000)),
                        "usr": jde_user_pad,
                        "upmj": iso_to_julian(),
                        "doco": wo_num,
                        "opsq": op_seq_db,
                    },
                )
                labor_cost_cents = int(round(labor_hrs * 85.0 * 100))
                mach_cost_cents = int(round(mach_hrs * 125.0 * 100))
                cur.execute(
                    "UPDATE PRODDTA.F3102 SET IGACTC = NVL(IGACTC, 0) + :c WHERE IGDOCO = :d AND TRIM(IGCOST) = 'B1'",
                    {"c": labor_cost_cents, "d": wo_num},
                )
                cur.execute(
                    "UPDATE PRODDTA.F3102 SET IGACTC = NVL(IGACTC, 0) + :c WHERE IGDOCO = :d AND TRIM(IGCOST) = 'B3'",
                    {"c": mach_cost_cents, "d": wo_num},
                )
                log_audit(cur, orch_name, "ORCHESTRATOR_WRITE", f"F3112:{wo_num}:{op_seq_db}", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "workOrderNumber": wo_num,
            "operationSequence": op_seq_db / 100.0,
            "recordedLaborHours": labor_hrs,
            "recordedMachineHours": mach_hrs,
            "operationCompletedQuantity": comp_qty,
            "laborCostAddedUSD": labor_cost_cents / 100.0,
            "machineCostAddedUSD": mach_cost_cents / 100.0,
        }

    elif orch_name == "ORCH_CompleteWorkOrder":
        wo_num = int(payload.get("WorkOrderNumber"))
        bp = str(payload.get("BranchPlant", "M30")).strip()
        comp_qty = float(payload.get("CompletedQuantity") or payload.get("QuantityCompleted") or 0)
        scrap_qty = float(payload.get("ScrappedQuantity") or payload.get("QuantityScrapped") or 0)
        to_loc = str(payload.get("ToLocation", "FG-A01")).strip().ljust(20)
        new_status = str(payload.get("NewStatusCode", "90")).strip()[:2]

        comp_scaled = int(round(comp_qty * 10000))
        scrap_scaled = int(round(scrap_qty * 10000))
        today_j = iso_to_julian()

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                jde_user_pad = jde_user.ljust(10)[:10]
                check_f00950_security(cur, jde_user, "P31114", bp)

                cur.execute(
                    """
                    SELECT WAITM, TRIM(WALITM), WADSC1, WAUORG, WASOQS, WASOCN, TRIM(WAUOM)
                    FROM PRODDTA.F4801
                    WHERE WADOCO = :doco
                    """,
                    {"doco": wo_num},
                )
                wo_row = cur.fetchone()
                if not wo_row:
                    raise HTTPException(status_code=404, detail=f"Work Order {wo_num} not found in PRODDTA.F4801")
                itm, litm, dsc1, uorg_s, soqs_s, socn_s, uom = wo_row

                new_soqs_s = int(soqs_s or 0) + comp_scaled
                new_socn_s = int(socn_s or 0) + scrap_scaled
                final_status = new_status if (new_soqs_s + new_socn_s) >= int(uorg_s or 0) else "45"

                cur.execute(
                    """
                    UPDATE PRODDTA.F4801
                    SET WASOQS = :soqs,
                        WASOCN = :socn,
                        WASRST = :srst,
                        WASTRX = :strx,
                        WAUSER = :usr,
                        WAUPMJ = :upmj,
                        WATDAY = :tday,
                        WAPID  = 'P31114    '
                    WHERE WADOCO = :doco
                    """,
                    {
                        "soqs": new_soqs_s,
                        "socn": new_socn_s,
                        "srst": final_status,
                        "strx": today_j,
                        "usr": jde_user_pad,
                        "upmj": today_j,
                        "tday": now_hhmmss(),
                        "doco": wo_num,
                    },
                )

                # Increment finished goods inventory in F41021
                cur.execute(
                    """
                    UPDATE PRODDTA.F41021
                    SET LIPQOH = NVL(LIPQOH, 0) + :qty
                    WHERE LIITM = :itm AND TRIM(LIMCU) = :mcu AND LILOCN = :locn
                    """,
                    {"qty": comp_scaled, "itm": itm, "mcu": bp, "locn": to_loc},
                )

                # Lookup standard cost in F4105
                cur.execute(
                    """
                    SELECT COUNCS FROM PRODDTA.F4105
                    WHERE COITM = :itm AND TRIM(COMCU) = :mcu AND COLEDG = '07' AND ROWNUM = 1
                    """,
                    {"itm": itm, "mcu": bp},
                )
                c_row = cur.fetchone()
                unit_cost_s = int(c_row[0]) if c_row else 24500000
                receipt_val_cents = int(round((unit_cost_s / 10000.0) * comp_qty * 100))

                ic_doc = next_number(cur, "41")
                cur.execute("SELECT PRODDTA.SEQ_F4111_UKID.NEXTVAL FROM DUAL")
                ukid = int(cur.fetchone()[0])

                cur.execute(
                    """
                    INSERT INTO PRODDTA.F4111
                      (ILUKID, ILDOC, ILDCT, ILKCO, ILDOCO, ILDCTO, ILITM, ILLITM,
                       ILMCU, ILLOCN, ILLOTN, ILTRDJ, ILTRQT, ILTRUM, ILUNCS, ILPAID,
                       ILTREX, ILUSER, ILPID, ILCRDJ, ILTDAY)
                    VALUES
                      (:ukid, :doc, 'IC', '00200', :doco, 'WO', :itm, :litm,
                       :mcu, :locn, '                              ', :trdj, :trqt, :um, :uncs, :paid,
                       :trex, :usr, 'P31114    ', :trdj, :tday)
                    """,
                    {
                        "ukid": ukid,
                        "doc": ic_doc,
                        "doco": wo_num,
                        "itm": itm,
                        "litm": litm.ljust(25),
                        "mcu": bp.rjust(12),
                        "locn": to_loc,
                        "trdj": today_j,
                        "trqt": comp_scaled,
                        "um": (uom or "EA").ljust(2),
                        "uncs": unit_cost_s,
                        "paid": receipt_val_cents,
                        "trex": f"IC WO Completion {wo_num}"[:30],
                        "usr": jde_user_pad,
                        "tday": now_hhmmss(),
                    },
                )

                # Update F3102 completed & scrap cost columns
                cur.execute(
                    """
                    UPDATE PRODDTA.F3102
                    SET IGCSMT = IGSTDC,
                        IGSCRP = CASE WHEN :scrap_q > 0 THEN ROUND(IGSTDC * (:scrap_q / NULLIF(:ord_q, 0))) ELSE IGSCRP END,
                        IGUPMJ = :upmj
                    WHERE IGDOCO = :doco
                    """,
                    {
                        "scrap_q": scrap_qty,
                        "ord_q": max(1.0, (uorg_s or 10000) / 10000.0),
                        "upmj": today_j,
                        "doco": wo_num,
                    },
                )

                log_audit(cur, orch_name, "ORCHESTRATOR_WRITE", f"F4801:{wo_num}:IC", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "workOrderNumber": wo_num,
            "parentItem": litm,
            "description": dsc1,
            "completedQuantityNow": comp_qty,
            "scrappedQuantityNow": scrap_qty,
            "cumulativeCompletedQuantity": new_soqs_s / 10000.0,
            "cumulativeScrappedQuantity": new_socn_s / 10000.0,
            "orderedQuantity": (uorg_s or 0) / 10000.0,
            "newWorkOrderStatus": final_status,
            "completionDate": julian_to_iso(today_j),
            "inventoryReceiptLocation": to_loc.strip(),
            "cardexDocumentNumber": ic_doc,
            "cardexDocumentType": "IC",
            "inventoryReceiptValueUSD": receipt_val_cents / 100.0,
        }

    elif orch_name == "ORCH_ExpediteShortagePO":
        po_num = int(payload.get("PurchaseOrderNumber"))
        promised_iso = str(payload.get("PromisedDeliveryDate", "2026-10-10"))
        promised_j = iso_to_julian(promised_iso)

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                check_f00950_security(cur, jde_user, "P4310", "M30")
                cur.execute(
                    """
                    UPDATE PRODDTA.F4311
                    SET PDPDDJ = :pddj, PDNXTR = '400', PDLTTR = '280'
                    WHERE PDDOCO = :doco
                    """,
                    {"pddj": promised_j, "doco": po_num},
                )
                # Update Watchlist WL-MFG-03 and Precedent PREC-SHORT-ENC if PO 430101 expedited
                if po_num == 430101:
                    cur.execute(
                        """
                        UPDATE SY920.F980051
                        SET WATCHLIST_STATUS = 'EXPEDITED_BY_AGENT',
                            ACTIVE_RECORD_COUNT = 0,
                            FINANCIAL_EXPOSURE = 0,
                            LAST_EVALUATED_DTTM = TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
                        WHERE WATCHLIST_ID = 'WL-MFG-03'
                        """
                    )
                    cur.execute(
                        """
                        UPDATE PRODDTA.F48019
                        SET HISTORICAL_CASES_CNT = HISTORICAL_CASES_CNT + 1,
                            LAST_APPROVED_BY = :usr,
                            LAST_RESOLVED_DTTM = TO_CHAR(SYSDATE, 'YYYY-MM-DD')
                        WHERE PRECEDENT_ID = 'PREC-SHORT-ENC'
                        """,
                        {"usr": jde_user},
                    )
                log_audit(cur, orch_name, "ORCHESTRATOR_WRITE", f"F4311:{po_num}", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "purchaseOrderNumber": po_num,
            "newPromisedDeliveryDate": julian_to_iso(promised_j),
            "watchlistUpdated": "WL-MFG-03" if po_num == 430101 else None,
        }

    elif orch_name == "ORCH_EvaluateWatchlistAndPrecedent":
        bp = str(payload.get("BranchPlant", "M30")).strip()
        wl_id = payload.get("WatchlistId")
        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                check_f00950_security(cur, jde_user, "P980051", bp)
                cur.execute(
                    """
                    SELECT watchlist_id, watchlist_name, jde_program_id, detection_mode,
                           severity_level, branch_plant, active_record_count, stuck_days_avg,
                           financial_exposure, linked_work_orders, watchlist_status,
                           precedent_id, historical_cases_cnt, success_rate_pct,
                           recommended_orch, recommended_action, avg_manual_hours,
                           agent_cycle_minutes, est_financial_impact, policy_threshold_usd,
                           policy_gate_mode
                    FROM PRODDTA.VW_JDE_WATCHLIST_ALERTS
                    WHERE TRIM(branch_plant) = :bp
                      AND (:wl IS NULL OR watchlist_id = :wl)
                    ORDER BY watchlist_id
                    """,
                    {"bp": bp, "wl": wl_id},
                )
                cols = [d[0].lower() for d in cur.description]
                watchlists = [dict(zip(cols, r)) for r in cur.fetchall()]
                log_audit(cur, orch_name, "ORCHESTRATOR_READ", f"F980051:{bp}", payload, jde_user=jde_user)
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "jdeUser": jde_user,
            "branchPlant": bp,
            "watchlistAlertsCount": len(watchlists),
            "watchlistAlerts": watchlists,
        }

    elif orch_name == "ORCH_ResolveDMAAIException":
        dmaai_num = int(payload.get("DMAAITableNumber", 3120))
        co_code = str(payload.get("CompanyCode", "00030")).strip()
        doc_type = str(payload.get("DocumentType", "IH")).strip().upper()
        gl_class = str(payload.get("GLClassCode", "IN30")).strip().upper()
        cost_type = str(payload.get("CostType", "B3")).strip().upper()
        target_obj = str(payload.get("TargetObjectAccount", "1340")).strip()
        target_sub = str(payload.get("TargetSubsidiary", "B3")).strip()
        blocked_wo = payload.get("BlockedWorkOrderNumber")
        approval_confirmed = bool(payload.get("ApprovalConfirmed", False))
        bp = str(payload.get("BranchPlant", "M30")).strip()
        today_j = iso_to_julian()

        with pool.acquire() as conn:
            with conn.cursor() as cur:
                jde_user = resolve_jde_user(cur, payload, request.headers)
                jde_user_pad = jde_user.ljust(10)[:10]
                check_f00950_security(cur, jde_user, "P4095", bp)

                # Verify target GL account exists in F0901 Chart of Accounts
                cur.execute(
                    """
                    SELECT GMAID, TRIM(GMDL01)
                    FROM PRODDTA.F0901
                    WHERE TRIM(GMCO) = :co AND TRIM(GMMCU) = :mcu AND TRIM(GMOBJ) = :obj AND TRIM(GMSUB) = :sub
                    FETCH FIRST 1 ROWS ONLY
                    """,
                    {"co": co_code, "mcu": bp, "obj": target_obj, "sub": target_sub},
                )
                gl_row = cur.fetchone()
                gl_aid = gl_row[0] if gl_row else f"{co_code}{target_obj[:3]}"
                gl_desc = gl_row[1] if gl_row else f"{bp} GL {target_obj}.{target_sub}"

                # Lookup DMAAI exception & precedent impact
                cur.execute(
                    """
                    SELECT unposted_accounting_usd, policy_threshold_usd, policy_gate_mode,
                           precedent_id, blocked_work_order_number
                    FROM PRODDTA.VW_JDE_DMAAI_EXCEPTIONS
                    WHERE dmaai_table_number = :anid
                      AND document_type = :dcto
                      AND gl_class_code = :glpt
                      AND TRIM(cost_type) = :cost
                    FETCH FIRST 1 ROWS ONLY
                    """,
                    {"anid": dmaai_num, "dcto": doc_type, "glpt": gl_class, "cost": cost_type},
                )
                ex_row = cur.fetchone()
                impact_usd = float(ex_row[0] or 3420.0) if ex_row else 3420.0
                threshold_usd = float(ex_row[1] or 5000.0) if ex_row else 5000.0
                gate_mode = str(ex_row[2] or "AUTO_EXECUTE_UNDER_5K") if ex_row else "AUTO_EXECUTE_UNDER_5K"
                prec_id = str(ex_row[3] or f"PREC-DMAAI-{dmaai_num}") if ex_row else f"PREC-DMAAI-{dmaai_num}"
                wo_to_clear = int(blocked_wo or (ex_row[4] if ex_row and ex_row[4] else 480015))

                # Policy Gate enforcement: >= $5,000 requires human A2UI approval!
                if impact_usd >= threshold_usd and not approval_confirmed:
                    log_audit(
                        cur,
                        orch_name,
                        "POLICY_GATE_HOLD_A2UI",
                        f"F4095:{dmaai_num}:{doc_type}:{gl_class}:{cost_type}",
                        payload,
                        status="PENDING_APPROVAL",
                        jde_user=jde_user,
                    )
                    conn.commit()
                    return {
                        "orchestration": orch_name,
                        "status": "PENDING_HUMAN_APPROVAL",
                        "policyGateTriggered": True,
                        "policyGateMode": gate_mode,
                        "unpostedAccountingUSD": impact_usd,
                        "policyThresholdUSD": threshold_usd,
                        "message": (
                            f"DMAAI {dmaai_num} ({doc_type}/{gl_class}/{cost_type}) has unposted R31802A accounting impact "
                            f"of ${impact_usd:,.2f}, which exceeds the ${threshold_usd:,.2f} autonomous remediation limit. "
                            "Surface an A2UI approval card and re-invoke with ApprovalConfirmed=true."
                        ),
                        "proposedGLAccount": f"{bp}.{target_obj}.{target_sub}",
                        "proposedGLAccountID": gl_aid,
                        "blockedWorkOrderNumber": wo_to_clear,
                        "precedentId": prec_id,
                    }

                formatted_ani = f"{bp.rjust(12)}.{target_obj}.{target_sub}"
                cur.execute(
                    """
                    UPDATE PRODDTA.F4095
                    SET MLANI  = :ani,
                        MLOBJ  = :obj,
                        MLSUB  = :sub,
                        MLDL01 = :dl01,
                        MLSTAT = 'ACTIVE',
                        MLUSER = :usr,
                        MLPID  = 'P4095     ',
                        MLUPMJ = :upmj
                    WHERE MLANID = :anid
                      AND TRIM(MLCO) = :co
                      AND TRIM(MLDCTO) = :dcto
                      AND TRIM(MLGLPT) = :glpt
                      AND TRIM(MLCOST) = :cost
                    """,
                    {
                        "ani": formatted_ani,
                        "obj": target_obj,
                        "sub": target_sub,
                        "dl01": gl_desc[:30],
                        "usr": jde_user_pad,
                        "upmj": today_j,
                        "anid": dmaai_num,
                        "co": co_code,
                        "dcto": doc_type,
                        "glpt": gl_class,
                        "cost": cost_type,
                    },
                )

                # Clear R31802A accounting hold on the blocked Work Order in F4801
                cur.execute(
                    """
                    UPDATE PRODDTA.F4801
                    SET WASRST = '95',
                        WAWR01 = 'POST',
                        WAUSER = :usr,
                        WAPID  = 'R31802A   ',
                        WAUPMJ = :upmj,
                        WATDAY = :tday
                    WHERE WADOCO = :doco
                    """,
                    {"usr": jde_user_pad, "upmj": today_j, "tday": now_hhmmss(), "doco": wo_to_clear},
                )

                # Update Operational Precedent F48019
                cur.execute(
                    """
                    UPDATE PRODDTA.F48019
                    SET HISTORICAL_CASES_CNT = HISTORICAL_CASES_CNT + 1,
                        LAST_APPROVED_BY = :usr,
                        LAST_RESOLVED_DTTM = TO_CHAR(SYSDATE, 'YYYY-MM-DD')
                    WHERE PRECEDENT_ID = :pid
                    """,
                    {"usr": jde_user, "pid": prec_id},
                )

                # Re-count remaining DMAAI exceptions for Watchlist WL-MFG-02
                cur.execute("SELECT COUNT(*) FROM PRODDTA.F4095 WHERE MLSTAT = 'MISSING_GL_EXCEPTION'")
                rem_ex = int(cur.fetchone()[0])
                cur.execute(
                    """
                    UPDATE SY920.F980051
                    SET ACTIVE_RECORD_COUNT = :cnt,
                        FINANCIAL_EXPOSURE = CASE WHEN :cnt = 0 THEN 0 WHEN :cnt = 1 THEN 11850.00 ELSE 15270.00 END,
                        WATCHLIST_STATUS = CASE WHEN :cnt = 0 THEN 'RESOLVED' ELSE 'ALERT_ACTIVE' END,
                        LAST_EVALUATED_DTTM = TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
                    WHERE WATCHLIST_ID = 'WL-MFG-02'
                    """,
                    {"cnt": rem_ex},
                )

                exec_mode = "A2UI_HUMAN_APPROVED" if approval_confirmed else "AUTO_POLICY_UNDER_5K"
                log_audit(
                    cur,
                    orch_name,
                    exec_mode,
                    f"F4095:{dmaai_num}:{doc_type}:{gl_class}:{cost_type}->WO:{wo_to_clear}",
                    payload,
                    jde_user=jde_user,
                )
            conn.commit()
        return {
            "orchestration": orch_name,
            "status": "SUCCESS",
            "executionMode": exec_mode,
            "jdeUser": jde_user,
            "dmaaiTableNumber": dmaai_num,
            "companyCode": co_code,
            "documentType": doc_type,
            "glClassCode": gl_class,
            "costType": cost_type,
            "configuredGLAccount": f"{bp}.{target_obj}.{target_sub}",
            "glAccountID": gl_aid,
            "glAccountDescription": gl_desc,
            "r31802aBatchStatus": "POSTED",
            "unblockedWorkOrderNumber": wo_to_clear,
            "newWorkOrderStatus": "95 (R31802A Accounting Posted)",
            "postedAccountingAmountUSD": impact_usd,
            "precedentUpdated": prec_id,
            "remainingWatchlistWL_MFG_02Count": rem_ex,
        }

    else:
        raise HTTPException(status_code=404, detail=f"Orchestration '{orch_name}' not found in JPD920 catalog")


# ============================================================================
# 3. AIS v2 Form Service (/jderest/v2/formservice)
# ============================================================================

@app.post("/jderest/v2/formservice")
@app.post("/jderest/formservice")
def form_service(body: dict, request: Request):
    form_name = str(body.get("formName", "P48013_W48013A")).upper()
    pool = get_pool()
    rowset = []
    with pool.acquire() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;")
            except Exception:
                pass
            if "P48013" in form_name:
                cur.execute(
                    """
                    SELECT WORK_ORDER_NUMBER, ORDER_TYPE, BRANCH_PLANT, PARENT_ITEM_NUMBER,
                           ITEM_DESCRIPTION, STATUS_CODE, STATUS_MEANING,
                           QUANTITY_ORDERED, QUANTITY_COMPLETED, QUANTITY_SCRAPPED, START_DATE_ISO, REQUESTED_DATE_ISO
                    FROM PRODDTA.VW_JDE_MFG_WORK_ORDERS
                    ORDER BY WORK_ORDER_NUMBER DESC
                    """
                )
                cols = [d[0] for d in cur.description]
                for r in cur.fetchall():
                    rowset.append(dict(zip(cols, [str(v) if isinstance(v, datetime.datetime) else v for v in r])))
            elif "P4095" in form_name:
                cur.execute("SELECT * FROM PRODDTA.VW_JDE_DMAAI_EXCEPTIONS")
                cols = [d[0] for d in cur.description]
                for r in cur.fetchall():
                    rowset.append(dict(zip(cols, [str(v) if isinstance(v, datetime.datetime) else v for v in r])))
            elif "P41202" in form_name:
                cur.execute(
                    """
                    SELECT l.LIITM AS ITEM_ID, TRIM(m.IMLITM) AS ITEM_NUMBER, m.IMDSC1 AS DESCRIPTION,
                           TRIM(l.LIMCU) AS BRANCH_PLANT, TRIM(l.LILOCN) AS LOCATION,
                           ROUND(l.LIPQOH/10000.0, 2) AS QTY_ON_HAND,
                           ROUND((l.LIPCOM + l.LIHCOM)/10000.0, 2) AS QTY_COMMITTED,
                           ROUND((l.LIPQOH - l.LIPCOM - l.LIHCOM)/10000.0, 2) AS QTY_AVAILABLE,
                           ROUND(l.LIPREQ/10000.0, 2) AS QTY_ON_PO
                    FROM PRODDTA.F41021 l
                    JOIN PRODDTA.F4101 m ON m.IMITM = l.LIITM
                    ORDER BY l.LIITM
                    """
                )
                cols = [d[0] for d in cur.description]
                for r in cur.fetchall():
                    rowset.append(dict(zip(cols, r)))
            else:
                cur.execute("SELECT * FROM PRODDTA.VW_JDE_MFG_PARTS_SHORTAGES")
                cols = [d[0] for d in cur.description]
                for r in cur.fetchall():
                    rowset.append(dict(zip(cols, [str(v) if isinstance(v, datetime.datetime) else v for v in r])))
    return {
        f"fs_{form_name}": {
            "title": f"JD Edwards EnterpriseOne Form {form_name}",
            "data": {
                "gridData": {
                    "id": 1,
                    "fullGridId": "1",
                    "rowset": rowset,
                    "summary": {"records": len(rowset), "moreRecords": False},
                }
            },
            "errors": [],
            "warnings": [],
        }
    }


# ============================================================================
# 4. JDE EnterpriseOne 9.2 Web Client & Orchestrator Studio UI (:8080 / :7077)
# ============================================================================

@app.get("/", response_class=HTMLResponse)
@app.get("/jde/E1Menu.maf", response_class=HTMLResponse)
@app.get("/Studio", response_class=HTMLResponse)
def jde_web_portal():
    pool = get_pool()
    with pool.acquire() as conn:
        with conn.cursor() as cur:
            try:
                cur.execute("BEGIN DBMS_SESSION.CLEAR_IDENTIFIER; END;")
            except Exception:
                pass
            cur.execute(
                """
                SELECT WATCHLIST_ID, WATCHLIST_NAME, JDE_PROGRAM_ID, DETECTION_MODE,
                       SEVERITY_LEVEL, ACTIVE_RECORD_COUNT, FINANCIAL_EXPOSURE,
                       LINKED_WORK_ORDERS, WATCHLIST_STATUS, PRECEDENT_ID, SUCCESS_RATE_PCT
                FROM PRODDTA.VW_JDE_WATCHLIST_ALERTS
                ORDER BY WATCHLIST_ID
                """
            )
            watchlists = cur.fetchall()

            cur.execute(
                """
                SELECT DMAAI_TABLE_NUMBER, COMPANY_CODE, BRANCH_PLANT, DOCUMENT_TYPE,
                       GL_CLASS_CODE, COST_TYPE, CONFIGURED_GL_ACCOUNT, DMAAI_DESCRIPTION,
                       DMAAI_STATUS, BLOCKED_WORK_ORDER_NUMBER, RECOMMENDED_GL_ACCOUNT,
                       UNPOSTED_ACCOUNTING_USD, POLICY_GATE_MODE, PRECEDENT_ID
                FROM PRODDTA.VW_JDE_DMAAI_EXCEPTIONS
                ORDER BY CASE DMAAI_STATUS WHEN 'MISSING_GL_EXCEPTION' THEN 1 ELSE 2 END,
                         DMAAI_TABLE_NUMBER, COST_TYPE
                """
            )
            dmaais = cur.fetchall()

            cur.execute(
                """
                SELECT WORK_ORDER_NUMBER, PARENT_ITEM_NUMBER, ITEM_DESCRIPTION,
                       STATUS_CODE, STATUS_MEANING, QUANTITY_ORDERED, QUANTITY_COMPLETED,
                       REQUESTED_DATE_ISO, SCHEDULE_HEALTH
                FROM PRODDTA.VW_JDE_MFG_WORK_ORDERS
                ORDER BY WORK_ORDER_NUMBER DESC
                FETCH FIRST 10 ROWS ONLY
                """
            )
            wos = cur.fetchall()

            cur.execute(
                """
                SELECT LOG_ID, TO_CHAR(LOG_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS'),
                       JDE_USER, TOOL_NAME, WORK_ORDER_NUM, EXECUTION_MODE, STATUS
                FROM PRODDTA.GGLTOOLBOX$MCP_LOG
                ORDER BY LOG_ID DESC
                FETCH FIRST 6 ROWS ONLY
                """
            )
            logs = cur.fetchall()
    total_wl_alerts = sum(int(w[5] or 0) for w in watchlists)
    wl_cards_html = ""
    for w in watchlists:
        wid, wname, prog, dmode, sev, cnt, exp_usd, linked, wstat, pid, srate = w
        is_clear = int(cnt or 0) == 0 or wstat in ("RESOLVED", "EXPEDITED_BY_AGENT")
        pill_bg = "#dcfce7" if is_clear else ("#fee2e2" if sev == "CRITICAL" else "#fef3c7")
        pill_fg = "#166534" if is_clear else ("#991b1b" if sev == "CRITICAL" else "#92400e")
        mode_badge = "PROACTIVE 14-DAY RADAR" if dmode == "PROACTIVE_14D" else "ONE VIEW WATCHLIST"
        wl_cards_html += f"""
        <div class="wl-card" style="border-left: 4px solid {pill_fg};">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
            <span style="font-size:11px;font-weight:700;color:#475569;letter-spacing:0.4px;">{wid} &bull; {prog} &bull; {mode_badge}</span>
            <span style="background:{pill_bg};color:{pill_fg};padding:2px 8px;border-radius:999px;font-size:11px;font-weight:700;">{cnt} ACTIVE ({wstat})</span>
          </div>
          <div style="font-size:13.5px;font-weight:700;color:#0f172a;margin-bottom:4px;">{wname}</div>
          <div style="font-size:12px;color:#334155;margin-bottom:6px;"><b>Scope:</b> {linked}</div>
          <div style="display:flex;justify-content:space-between;font-size:11.5px;color:#64748b;border-top:1px solid #f1f5f9;padding-top:6px;">
            <span>Exposure: <b style="color:#0f172a;">${float(exp_usd or 0):,.2f}</b></span>
            <span>Precedent: <b style="color:#1d4ed8;">{pid} ({float(srate or 0):.1f}%)</b></span>
          </div>
        </div>
        """

    dmaai_rows_html = ""
    for d in dmaais:
        anid, co, bp, dcto, glpt, cost, gl_acct, desc, stat, b_wo, rec_gl, usd, gate, pid = d
        is_ex = stat == "MISSING_GL_EXCEPTION"
        row_bg = "#fff1f2" if is_ex else "#ffffff"
        acct_cell = (
            f"<span class='badge-err'>MISSING GL ACCOUNT (NULL)</span>"
            if is_ex
            else f"<code style='color:#166534;font-weight:700;'>{gl_acct}</code>"
        )
        stat_cell = (
            f"<span class='badge-err'>R31802A BLOCKED (WO {b_wo})</span>"
            if is_ex
            else "<span class='badge-ok'>ACTIVE &bull; POSTED</span>"
        )
        gate_cell = (
            f"<span class='badge-warn'>{gate} (${float(usd or 0):,.2f})</span>"
            if is_ex and usd
            else "<span style='color:#64748b;'>Standard Mapped</span>"
        )
        dmaai_rows_html += (
            f"<tr style='background:{row_bg};'>"
            f"<td><b>{anid}</b></td><td>{co}</td><td>{bp}</td><td><b>{dcto}</b></td><td><b>{glpt}</b></td><td><b>{cost}</b></td>"
            f"<td>{acct_cell}</td><td>{desc}</td><td>{stat_cell}</td>"
            f"<td><code>{rec_gl or gl_acct}</code></td><td>{gate_cell}</td></tr>"
        )

    wo_rows_html = ""
    for r in wos:
        wo_no, litm, dsc, s_code, s_mean, q_ord, q_comp, req_dt, health = r
        h_badge = "badge-err" if health in ("LATE", "AT_RISK_SHORTAGE") or str(s_code) == "45" else "badge-ok"
        wo_rows_html += (
            f"<tr><td><b>{wo_no}</b></td><td><code>{litm}</code></td><td>{dsc}</td>"
            f"<td><span class='badge'>{s_code} - {s_mean}</span></td>"
            f"<td>{q_ord}</td><td>{q_comp}</td><td>{req_dt}</td>"
            f"<td><span class='{h_badge}'>{health}</span></td></tr>"
        )

    log_rows_html = ""
    for l in logs:
        lid, ts, jusr, tname, wonum, emode, st = l
        log_rows_html += (
            f"<tr><td><b>#{lid}</b></td><td>{ts}</td><td><span class='badge'>{jusr}</span></td>"
            f"<td><code>{tname}</code></td><td>{wonum or '-'}</td><td><b>{emode}</b></td>"
            f"<td><span class='badge-ok'>{st}</span></td></tr>"
        )

    portal_style_html = (
        "<style>\n"
        "  * { box-sizing: border-box; }\n"
        "  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; background: #f1f5f9; color: #0f172a; }\n"
        "  header { background: #172554; color: #fff; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #3b82f6; }\n"
        "  .brand { display: flex; align-items: center; gap: 14px; font-size: 16px; font-weight: 700; }\n"
        "  .nav-pills { display: flex; align-items: center; gap: 12px; font-size: 12.5px; }\n"
        "  .wl-dropdown-pill { background: #dc2626; color: #fff; padding: 5px 12px; border-radius: 999px; font-weight: 700; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 6px rgba(220,38,38,0.35); }\n"
        "  .wl-dropdown-pill.clean { background: #16a34a; box-shadow: 0 2px 6px rgba(22,163,74,0.35); }\n"
        "  .sub { background: #1e3a8a; color: #e2e8f0; padding: 7px 24px; font-size: 12px; display: flex; justify-content: space-between; }\n"
        "  .container { padding: 16px 24px; max-width: 1860px; margin: auto; }\n"
        "  .wl-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 16px; }\n"
        "  .wl-card { background: #fff; border-radius: 8px; padding: 12px 14px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; }\n"
        "  .two-col { display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 16px; }\n"
        "  .card { background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); padding: 14px 18px; margin-bottom: 16px; border: 1px solid #e2e8f0; }\n"
        "  h2 { margin: 0 0 10px 0; font-size: 15px; color: #1e3a8a; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; display: flex; justify-content: space-between; align-items: center; }\n"
        "  table { width: 100%; border-collapse: collapse; font-size: 12px; }\n"
        "  th, td { text-align: left; padding: 7px 9px; border-bottom: 1px solid #e2e8f0; }\n"
        "  th { background: #f8fafc; color: #475569; font-weight: 700; font-size: 11.5px; text-transform: uppercase; }\n"
        "  .badge { background: #e0f2fe; color: #0369a1; padding: 2px 7px; border-radius: 4px; font-weight: 700; font-size: 11px; }\n"
        "  .badge-ok { background: #dcfce7; color: #166534; padding: 2px 7px; border-radius: 4px; font-weight: 700; font-size: 11px; }\n"
        "  .badge-warn { background: #fef3c7; color: #92400e; padding: 2px 7px; border-radius: 4px; font-weight: 700; font-size: 11px; }\n"
        "  .badge-err { background: #fee2e2; color: #b91c1c; padding: 2px 7px; border-radius: 4px; font-weight: 700; font-size: 11px; }\n"
        "</style>"
    )

    return f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Oracle JD Edwards EnterpriseOne 9.2.26 — Manufacturing Control Center, Watchlists & P4095 DMAAI Workbench</title>
  {portal_style_html}
</head>
<body>
  <header>
    <div class="brand">
      <span>Oracle JD Edwards EnterpriseOne 9.2.26.0</span>
      <span style="font-weight:400;font-size:13px;color:#93c5fd;">| Discrete Manufacturing &amp; Accounting Workbench (Branch/Plant M30)</span>
    </div>
    <div class="nav-pills">
      <div class="wl-dropdown-pill {'clean' if total_wl_alerts <= 4 else ''}">
        &#128276; One View Watchlists (SY920.F980051): {total_wl_alerts} Active Alerts
      </div>
      <span>Env: <b>JPD920</b></span>
      <span>User: <b>NGONZAL (AN8: 80001)</b></span>
      <span>Role: <b>MFG_MGR</b></span>
    </div>
  </header>
  <div class="sub">
    <span>AIS / Orchestrator v3: <code>http://10.118.0.43:7077/jderest/v3/orchestrator</code> (7 Active Orchestrations)</span>
    <span>Oracle 19c PDB: <code>10.118.0.41:1521/jdeorcl</code> &bull; JDE Identity Context (F01151 / F0092): <code>admin@negonzal.altostrat.com &rarr; NGONZAL</code></span>
  </div>
  <div class="container">
    <div class="wl-grid">
      {wl_cards_html}
    </div>
    <div class="card">
      <h2>
        <span>P4095 — Distribution/Manufacturing Automatic Accounting Instructions (PRODDTA.F4095 &amp; F0901) &bull; R31802A Exception Queue</span>
        <span style="font-size:12px;color:#475569;">Policy Gate: Auto-Execute &lt; $5,000 &nbsp;|&nbsp; Human A2UI Approval &ge; $5,000</span>
      </h2>
      <table>
        <thead>
          <tr>
            <th>DMAAI</th><th>Co</th><th>Plant</th><th>Doc</th><th>GL Class</th><th>Cost</th>
            <th>Configured GL Account (F4095.MLANI)</th><th>Description</th><th>R31802A Status</th>
            <th>Precedent Target GL (F0901)</th><th>Policy Gate &amp; Exposure</th>
          </tr>
        </thead>
        <tbody>{dmaai_rows_html}</tbody>
      </table>
    </div>
    <div class="two-col">
      <div class="card">
        <h2>
          <span>P48013 — Discrete Manufacturing Work Order Master Queue (PRODDTA.F4801)</span>
          <span style="font-size:11.5px;color:#64748b;">Branch/Plant M30</span>
        </h2>
        <table>
          <thead><tr><th>WO Number</th><th>Item Number</th><th>Description</th><th>Status (SRST)</th><th>Ord Qty</th><th>Comp Qty</th><th>Req Date</th><th>Health</th></tr></thead>
          <tbody>{wo_rows_html}</tbody>
        </table>
      </div>
      <div class="card">
        <h2>
          <span>PRODDTA.GGLTOOLBOX$MCP_LOG — Live JDE Orchestrator &amp; Security Audit Trail (F00950)</span>
          <span style="font-size:11.5px;color:#166534;">CLIENT_IDENTIFIER = NGONZAL</span>
        </h2>
        <table>
          <thead><tr><th>Log ID</th><th>Timestamp</th><th>JDE User</th><th>Orchestration / Tool</th><th>WO #</th><th>Execution Mode</th><th>Status</th></tr></thead>
          <tbody>{log_rows_html}</tbody>
        </table>
      </div>
    </div>
  </div>
</body>
</html>"""


if __name__ == "__main__":
    port = int(os.environ.get("JDE_AIS_PORT", "7077"))
    uvicorn.run(app, host="0.0.0.0", port=port)
