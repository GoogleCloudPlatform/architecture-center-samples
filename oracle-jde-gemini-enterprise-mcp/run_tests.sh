#!/bin/bash
# run_tests.sh
# Script to run syntax and tool verification checks for the Oracle JD Edwards 9.2 MCP & Discrete Manufacturing AI Agent project.

set -e
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting Oracle JD Edwards EnterpriseOne 9.2 Discrete Manufacturing MCP Test Suite${NC}\n"

python3 -m py_compile MCPServers/mcp-jde-orchestrator/server.py
python3 -m py_compile JDEScripts/jde_ais_orchestrator_server.py
python3 -m py_compile Agents/JDE_Master/agent.py
python3 -m py_compile Agents/JDE_Master/sub_agents/JDE_Mfg_Agent/agent.py
python3 -m py_compile Agents/JDE_Master/sub_agents/JDE_Graphs_Agent/agent.py

echo -e "${GREEN}All Python modules compiled cleanly! Ready for deployment.${NC}"
