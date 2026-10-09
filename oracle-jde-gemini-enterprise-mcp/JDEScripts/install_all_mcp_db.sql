-- =============================================================================
-- Consolidated One-Step Installer for Oracle JD Edwards EnterpriseOne (JDE) 9.2
-- Discrete Manufacturing MCP Schema, Email-to-JDE Identity, Views & Precedents
-- Target PDB: JDEORCL (Schemas: PRODDTA, PRODCTL, SY920, JDE_AI)
-- =============================================================================
SET ECHO ON
SET FEEDBACK ON

PROMPT [1/4] Installing JDE 9.2 Discrete Manufacturing Core Schema & Seed Data (Branch/Plant M30)...
@@install_jde_920_discrete_mfg_schema.sql

PROMPT [2/4] Installing JDE EnterpriseOne Email-to-JDE Identity & F00950 Security Context...
@@install_jde_identity_and_context.sql

PROMPT [3/4] Installing Normalized Read-Only Discrete Manufacturing Views & Autonomous Audit Log...
@@install_jde_mfg_views_and_audit.sql

PROMPT [4/4] Installing JDE One View Watchlists (F980051), DMAAI Rules (F4095) & Operational Precedent Ledger (F48019)...
@@install_jde_watchlist_dmaai_precedent.sql

PROMPT =============================================================================
PROMPT Oracle JDE 9.2 Discrete Manufacturing MCP Database Installation Complete.
PROMPT =============================================================================
