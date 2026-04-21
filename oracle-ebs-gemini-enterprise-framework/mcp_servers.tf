resource "null_resource" "oracle_ebs_gemini_enterprise_mcp_server" {
  triggers = {
    deploy_script_hash = filemd5("${path.module}/MCPServers/mcp-toolbox-ebs/deploy.sh")
    env_template_hash  = filemd5("${path.module}/MCPServers/mcp-toolbox-ebs/.env.example")
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      echo "Generating .env file for MCP Server..."
      
      # Extract the service account name (everything before the @ symbol)
      SA_NAME=$(echo "${var.service_account_key}" | cut -d'@' -f1)

      # Navigate to the MCP directory
      cd MCPServers/mcp-toolbox-ebs/

      # Copy template
      cp .env.example .env
      
      # Inject Terraform variables into the .env file
      sed -i.bak "s|^PROJECT_ID=.*|PROJECT_ID=${var.project_id}|" .env
      sed -i.bak "s|^SERVICE_ACCOUNT_EMAIL=.*|SERVICE_ACCOUNT_EMAIL=${var.service_account_key}|" .env
      sed -i.bak "s|^SERVICE_ACCOUNT_NAME=.*|SERVICE_ACCOUNT_NAME=$SA_NAME|" .env
      sed -i.bak "s|^REGION=.*|REGION=${var.region}|" .env
      sed -i.bak "s|^VPC_NAME=.*|VPC_NAME=${var.vpc_name}|" .env
      sed -i.bak "s|^SUBNET_NAME=.*|SUBNET_NAME=${var.subnet_name}|" .env

      # Cleanup backup files
      rm -f *.bak

      echo ".env file created successfully."

      # Execute the deployment script
      ./deploy.sh
    EOT
  }
}