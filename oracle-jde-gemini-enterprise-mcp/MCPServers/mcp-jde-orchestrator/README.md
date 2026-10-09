# Oracle JD Edwards EnterpriseOne (JDE) 9.2 Hybrid Orchestrator v3 + SQL MCP Server (`MCPServers/mcp-jde-orchestrator/`)

This directory contains the containerized **18-tool Hybrid Model Context Protocol (`FastMCP`) Server** connecting **Gemini Enterprise** and the **Discrete Manufacturing AI Agent (`JDE_Master`)** to:
1. **Oracle JD Edwards EnterpriseOne Orchestrator Studio v3 & AIS REST APIs (`/jderest/v3/orchestrator/*` and `/jderest/v2/*`)** for transactional Discrete Manufacturing operations (`P48013` Work Orders, `P31113` Material Issues, `P311221` Time Entry, `P31114` Completions, `P4310` PO Expedites, `P980051` Watchlists, and `P4095` DMAAI Auto-Remediation) so all JDE Master Business Functions (MBFs), Next Numbers (`F0002`), Inventory Commitments (`F41021`), Item Ledger Cardex (`F4111`), and Application Security (`PRODCTL.F00950`) are strictly enforced.
2. **Direct Oracle 19c Database SQL (`JDEORCL` / `PRODDTA`)** over 7 normalized read-only analytical views (`VW_JDE_MFG_*`, `VW_JDE_WATCHLIST_ALERTS`, `VW_JDE_DMAAI_EXCEPTIONS`, `VW_JDE_OPERATIONAL_PRECEDENTS`) with automatic 6-digit JDE Julian date (`CYYDDD` <-> `YYYY-MM-DD`) and 4-decimal implied scaling conversion.

## Files

| File | Description |
| :--- | :--- |
| **`server.py`** | 18-tool Python `FastMCP` server (`streamable-http` transport on `/mcp`) implementing JDE Email-to-JDE identity resolution, read-only SQL analytics, JDE Orchestrator v3 calls, DMAAI `< $5,000` policy auto-remediation, and Google A2UI `v0.9` approval surface generation. |
| **`Dockerfile`** | Builds the lightweight `python:3.12-slim` container image with `mcp[cli]`, `oracledb`, `httpx`, `uvicorn`, and `pydantic`. |
| **`deploy.sh`** | Automated deployment script that creates the `jde-mcp-repo` Docker repository in Google Artifact Registry, stores credentials in Secret Manager, builds the image via Cloud Build, and deploys `mcp-jde-orchestrator` to Cloud Run with Direct VPC Egress. |
| **`.env.example`** | Environment template for `deploy.sh` (zero plaintext passwords). |
| **`tools.yaml.example`** | Optional GenAI Toolbox for Databases YAML definition for pure SQL read-only deployments. |
