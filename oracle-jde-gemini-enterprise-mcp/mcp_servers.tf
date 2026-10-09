# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "null_resource" "oracle_jde_gemini_enterprise_mcp_server" {
  triggers = {
    deploy_script_hash = filemd5("${path.module}/MCPServers/mcp-jde-orchestrator/deploy.sh")
    env_template_hash  = filemd5("${path.module}/MCPServers/mcp-jde-orchestrator/.env.example")
    server_py_hash     = filemd5("${path.module}/MCPServers/mcp-jde-orchestrator/server.py")
  }

  provisioner "local-exec" {
    environment = {
      JDE_DB_PASSWORD = var.jde_db_password
      JDE_PASSWORD    = var.jde_password
    }
    command = <<EOT
      set -e

      echo "Generating .env file for JDE Hybrid Orchestrator + SQL MCP Server..."

      SA_NAME=$(echo "${var.service_account_key}" | cut -d'@' -f1)

      cd MCPServers/mcp-jde-orchestrator/

      cat <<EOF > .env
PROJECT_ID=${var.project_id}
SERVICE_ACCOUNT_EMAIL=${var.service_account_key}
SERVICE_ACCOUNT_NAME=$SA_NAME
REGION=${var.region}
VPC_NAME=${var.vpc_name}
SUBNET_NAME=${var.subnet_name}
BUILD_AR_IMAGE=${var.build_ar_image}
JDE_AIS_BASE_URL=${var.jde_ais_base_url}
JDE_DB_DSN=${var.jde_db_dsn}
JDE_DB_USER=${var.jde_db_user}
JDE_USERNAME=${var.jde_username}
EOF

      echo ".env file created successfully."

      ./deploy.sh
    EOT
  }
}
