# Set Region and Zone
terraform_version = "1.6.6"
region            = "us-central1"

# Python version for the environment
python_version = "3.11"

# URLs & VPC for JDE Hybrid Orchestrator + SQL MCP server
vpc_name           = "oracle-jde-toolkit-network"
subnet_name        = "oracle-jde-toolkit-subnet-01"
jde_ais_base_url   = "http://10.118.0.43:7077"
mcp_server_jde_url = "https://mcp-jde-orchestrator-801681953257.us-central1.run.app/mcp"
