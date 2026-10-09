# Oracle JD Edwards EnterpriseOne (JDE) 9.2 Discrete Manufacturing AI Agent (`Agents/JDE_Master/`)

This directory contains the Google Agent Development Kit (ADK) multi-agent system (**`JDE_Master`**) deployed to **Vertex AI Reasoning Engine** and registered in **Gemini Enterprise** for **Oracle JD Edwards EnterpriseOne 9.2 Discrete Manufacturing (`Branch/Plant M30`)**.

## Multi-Agent Hierarchy

1. **`JDE_Master` (Root Orchestrator Agent):**
   - Extracts the signed-in user's Gemini Enterprise identity (`user_email`) and routes Discrete Manufacturing, Watchlist, DMAAI Accounting, and Executive Charting requests to specialist sub-agents.
2. **`JDE_Mfg_Agent` (`sub-agents/JDE_Mfg_Agent/`):**
   - Connects over OIDC-authenticated Streamable HTTP (`/mcp`) to the 18-tool Cloud Run **`mcp-jde-orchestrator`** server.
   - Grounded by `jde_discrete_mfg_semantic_map.json` covering JDE 9.2 Discrete Manufacturing tables (`F4801`, `F3111`, `F3112`, `F3102`, `F4101`, `F41021`, `F4111`, `F4311`, `F980051`, `F4095`, `F48019`, `F0101`, `F01151`, `F0092`, `F95921`, `F00950`), 7 read-only `PRODDTA.VW_JDE_*` analytical views, and 7 JDE Orchestrator Studio v3 orchestrations.
3. **`JDE_Graphs_Agent` (`sub-agents/JDE_Graphs_Agent/`):**
   - Publication-grade **180 DPI (`12.0" x 6.6"` widescreen)** executive charting engine rendering horizontal bar, grouped/stacked bar, donut, and multi-series line charts inline in Gemini Enterprise.
4. **`MrGoogle` (`sub-agents/MrGoogle/`):**
   - External web search specialist sub-agent for supplier and market intelligence.
