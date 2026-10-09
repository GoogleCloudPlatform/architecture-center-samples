#!/bin/bash
# run_tests.sh
# Script to run all automated tests for the Oracle PeopleSoft 9.2 MCP & Agents project.

set -e
cd "$(dirname "$0")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting Oracle PeopleSoft 9.2 MCP & Agents Test Suite${NC}\n"

if [ -f ".env" ]; then
    echo -e "${YELLOW}Loading environment variables from .env file...${NC}"
    set -a
    source .env
    set +a
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}Error: python3 is not installed in the active environment.${NC}"
    exit 1
fi

set +e
TEST_FAILURES=0

if [ -f "MCPServers/mcp-toolbox-peoplesoft/tools.yaml.example" ]; then
    echo -e "${GREEN}[1/2] Validating MCP Toolbox PeopleSoft configuration (tools.yaml.example)...${NC}"
    python3 -c '
import yaml, sys
with open("MCPServers/mcp-toolbox-peoplesoft/tools.yaml.example", "r", encoding="utf-8") as f:
    cfg = yaml.safe_load(f)
tools = cfg.get("tools", {})
assert len(tools) >= 20, f"Expected at least 20 tools, found {len(tools)}"
print(f"Verified {len(tools)} PeopleSoft MCP tools in tools.yaml.example")
' || TEST_FAILURES=$((TEST_FAILURES + 1))
else
    echo -e "${RED}Error: MCPServers/mcp-toolbox-peoplesoft/tools.yaml.example not found.${NC}"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

if [ -d "Agents/PSFT_Master" ]; then
    echo -e "${GREEN}[2/2] Validating PeopleSoft Master & Sub-Agent Python modules...${NC}"
    find Agents utils -name "*.py" -print0 | xargs -0 python3 -m py_compile || TEST_FAILURES=$((TEST_FAILURES + 1))
else
    echo -e "${RED}Error: Agents/PSFT_Master directory not found.${NC}"
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi

if [ "$TEST_FAILURES" -gt 0 ]; then
    echo -e "${RED}Test execution failed! ($TEST_FAILURES test suite(s) encountered errors)${NC}"
    exit 1
else
    echo -e "${GREEN}All test suites passed successfully! Ready for deployment.${NC}"
    exit 0
fi
