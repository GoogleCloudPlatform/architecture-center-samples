#!/bin/bash
# run_tests.sh
# Script to run all automated tests for the Oracle EBS Agents project.

# Fail if any command errors that isn't explicitly handled
set -e

# Go to the script directory (root of the workspace)
cd "$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Oracle EBS Agents Test Suite${NC}\n"

# 1. Source .env file if it exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}Loading environment variables from .env file...${NC}"
    # set -a automatically exports all sourced variables
    set -a
    source .env
    set +a
else
    echo -e "${YELLOW}No .env file found in root. Proceeding with existing shell environment variables...${NC}"
fi

# 2. Ask the user for test credentials if they weren't exported through the .env file
if [ -z "$TEST_EBS_USERNAME" ]; then
    echo -e "${YELLOW}TEST_EBS_USERNAME is not set.${NC}"
    read -p "Enter test Oracle EBS username (or press enter to use 'testuser'): " input_user
    export TEST_EBS_USERNAME="${input_user:-testuser}"
fi

if [ -z "$TEST_EBS_PASSWORD" ]; then
    echo -e "${YELLOW}TEST_EBS_PASSWORD is not set.${NC}"
    read -s -p "Enter test Oracle EBS password (or press enter to use 'testpass'): " input_pass
    echo "" # Add a newline after silent password input
    export TEST_EBS_PASSWORD="${input_pass:-testpass}"
fi

echo ""

# 3. Environment Validations
if ! python -m pytest --version >/dev/null 2>&1; then
    echo -e "${RED}Error: pytest is not installed in the active Python environment.${NC}"
    echo -e "Please ensure you are in the correct virtualenv and run: ${YELLOW}pip install pytest pytest-asyncio${NC}"
    exit 1
fi

if ! python -m ruff --version >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: ruff is not installed. Skipping syntax checks...${NC}"
else
    echo -e "${GREEN}[1/3] Running Ruff Linter...${NC}"
    python -m ruff check .
    echo -e "${GREEN}Ruff checks passed!${NC}\n"
fi

# Disable strict failure catching so we can process all test suites explicitly
set +e
TEST_FAILURES=0

# 4. Run EBS Python Tests
echo -e "${GREEN}[2/3] Running Tests: MCP Oracle EBS Server...${NC}"
pushd MCPServers/mcp-oracle-ebs > /dev/null
python -m pytest test_main.py -v
if [ $? -ne 0 ]; then
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi
popd > /dev/null
echo ""

# 5. Run SQL Wrapper Python Tests
echo -e "${GREEN}[3/3] Running Tests: MCP Oracle SQL Server...${NC}"
pushd MCPServers/mcp-oracle-sql > /dev/null
python -m pytest test_main.py -v
if [ $? -ne 0 ]; then
    TEST_FAILURES=$((TEST_FAILURES + 1))
fi
popd > /dev/null
echo ""

# 6. Final Status
if [ "$TEST_FAILURES" -gt 0 ]; then
    echo -e "${RED}Test execution failed! ($TEST_FAILURES test suite(s) encountered errors)${NC}"
    exit 1
else
    echo -e "${GREEN}All test suites passed successfully! Ready for deployment.${NC}"
    exit 0
fi
