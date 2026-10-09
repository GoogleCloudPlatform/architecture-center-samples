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

locals {
  psft_sa_name = split("@", var.service_account_key)[0]
}

resource "local_file" "mcp_toolbox_peoplesoft_env" {
  filename        = "${path.module}/MCPServers/mcp-toolbox-peoplesoft/.env"
  file_permission = "0600"
  content         = <<-EOT
    PROJECT_ID=${var.project_id}
    SERVICE_ACCOUNT_EMAIL=${var.service_account_key}
    SERVICE_ACCOUNT_NAME=${local.psft_sa_name}
    REGION=${var.region}
    VPC_NAME=${var.vpc_name}
    SUBNET_NAME=${var.subnet_name}
    BUILD_AR_IMAGE=${var.build_ar_image}
    PSFT_DB_CONNECTION_STRING=${var.psft_db_connection_string}
    PSFT_DB_USER=${var.psft_db_user}
  EOT
}

resource "null_resource" "oracle_peoplesoft_gemini_enterprise_mcp_server" {
  depends_on = [local_file.mcp_toolbox_peoplesoft_env]

  triggers = {
    deploy_script_hash = filemd5("${path.module}/MCPServers/mcp-toolbox-peoplesoft/deploy.sh")
    env_content_hash   = md5(local_file.mcp_toolbox_peoplesoft_env.content)
    tools_yaml_hash    = filemd5("${path.module}/MCPServers/mcp-toolbox-peoplesoft/tools.yaml.example")
    dockerfile_hash    = filemd5("${path.module}/MCPServers/mcp-toolbox-peoplesoft/Dockerfile")
  }

  provisioner "local-exec" {
    environment = {
      PSFT_DB_PASSWORD = var.psft_db_password
    }
    command = <<EOT
      set -e
      cd MCPServers/mcp-toolbox-peoplesoft/
      ./deploy.sh
    EOT
  }
}
