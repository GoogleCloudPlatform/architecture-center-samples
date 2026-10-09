# Default settings
PROJECT_NAME := oracle-jde-toolkit
PROJECT ?= $(PROJECT_NAME)
PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
REGION ?= us-central1
export TF_VAR_project_id := $(PROJECT_ID)
export TF_VAR_region := $(REGION)
export TF_VAR_mcp_server_jde_url := "pending"
PROJECT_SA_EMAIL ?= project-service-account@$(PROJECT_ID).iam.gserviceaccount.com

# Directory for Terraform
TF_DIR := .

# Required GCP IAM roles
REQUIRED_ROLES = roles/storage.admin roles/iam.serviceAccountUser roles/iap.tunnelResourceAccessor roles/compute.osAdminLogin roles/compute.instanceAdmin.v1

.PHONY: help setup init verify-gcp-access format lint set_config_mcp_servers reset_config plan_mcp_server deploy_mcp_server destroy_mcp_server plan_jde_agents deploy_jde_agents destroy_jde_agents

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf "  make %-20s %s\n", $$1, $$2}'

setup: ## Run setup script
	@bash scripts/install.sh
	@echo "Setup complete. Run 'gcloud init' if needed, then proceed to 'make verify-gcp-access'."

init: ## Initialize Terraform backend
	@if [ -z "$(PROJECT_ID)" ]; then echo "PROJECT_ID not set"; exit 1; fi
	@set -e; \
	PROJECT_NUMBER=$$(gcloud projects describe $(PROJECT_ID) --format="value(projectNumber)"); \
	BUCKET_NAME="gs://$(PROJECT_ID)-$${PROJECT_NUMBER}-terraform-state"; \
	if ! gcloud storage ls -b $$BUCKET_NAME >/dev/null 2>&1; then \
		gcloud storage buckets create $$BUCKET_NAME --location=US --uniform-bucket-level-access; \
		sleep 10; \
	fi; \
	terraform -chdir=$(TF_DIR) init -reconfigure \
		-backend-config="bucket=$(PROJECT_ID)-$${PROJECT_NUMBER}-terraform-state" \
		-backend-config="prefix=jde-gemini"

verify-gcp-access: ## Verify GCP access and permissions
	@if [ -z "$(PROJECT_ID)" ]; then echo "PROJECT_ID not set. Pass PROJECT_ID=<id> to make."; exit 1; fi
	@if ! gcloud auth list --format="value(account)" 2>/dev/null | grep -q .; then echo "No active gcloud auth. Run: gcloud init"; exit 1; fi
	@if ! gcloud projects describe "$(PROJECT_ID)" --quiet >/dev/null 2>&1; then echo "Cannot access project: $(PROJECT_ID)"; exit 1; fi
	@echo "GCP access and permissions verified for $(PROJECT_ID)."

format: ## Format Terraform files
	terraform -chdir=$(TF_DIR) fmt

lint: ## Run pre-commit linting
	pre-commit run --all-files

set_config_mcp_servers: ## Set configuration for JDE MCP Server (DB DSN, AIS URL, VPC, Subnet)
	@echo "Configuring JDE Hybrid Orchestrator + SQL MCP Server..."
	@cp MCPServers/mcp-jde-orchestrator/tools.yaml.example MCPServers/mcp-jde-orchestrator/tools.yaml
	@touch infra.auto.tfvars
	@if ! grep -q "jde_db_dsn" infra.auto.tfvars; then \
		read -p "Enter Oracle JDE 19c DB DSN (e.g., 10.118.0.41:1521/jdeorcl): " db_conn; \
		echo "jde_db_dsn = \"$$db_conn\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "jde_ais_base_url" infra.auto.tfvars; then \
		read -p "Enter Oracle JDE AIS/Orchestrator Base URL [http://10.118.0.43:7077]: " ais_url; \
		ais_url=$${ais_url:-http://10.118.0.43:7077}; \
		echo "jde_ais_base_url = \"$$ais_url\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "jde_db_user" infra.auto.tfvars; then \
		read -p "Enter Oracle JDE DB User [JDE_AI]: " db_user; \
		db_user=$${db_user:-JDE_AI}; \
		echo "jde_db_user = \"$$db_user\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "jde_db_password" infra.auto.tfvars; then \
		read -s -p "Enter Oracle JDE DB Password: " db_pass; echo ""; \
		echo "jde_db_password = \"$$db_pass\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "vpc_name" infra.auto.tfvars; then \
		read -p "Enter VPC Name: " vpc; echo "vpc_name = \"$$vpc\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "subnet_name" infra.auto.tfvars; then \
		read -p "Enter Subnet Name: " sub; echo "subnet_name = \"$$sub\"" >> infra.auto.tfvars; \
	fi
	@echo "Configuration saved to infra.auto.tfvars."

reset_config: ## Clear local configs to force re-prompting
	@echo "Resetting configurations..."
	@cp MCPServers/mcp-jde-orchestrator/tools.yaml.example MCPServers/mcp-jde-orchestrator/tools.yaml
	@rm -f infra.auto.tfvars MCPServers/mcp-jde-orchestrator/.env MCPServers/mcp-jde-orchestrator/*.bak *.bak
	@echo "Done. You can now run 'make set_config_mcp_servers' to enter new values."

plan_mcp_server: ## Plan Terraform for JDE MCP Server
	terraform -chdir=$(TF_DIR) plan -target="null_resource.oracle_jde_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

deploy_mcp_server: ## Deploy JDE MCP Server
	terraform -chdir=$(TF_DIR) apply -auto-approve -target="null_resource.oracle_jde_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

destroy_mcp_server: ## Destroy JDE MCP Server
	terraform -chdir=$(TF_DIR) destroy -auto-approve -target="null_resource.oracle_jde_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

plan_jde_agents: ## Plan Terraform for JDE Manufacturing AI Agent (JDE_Master)
	@touch infra.auto.tfvars
	@MCP_URL=$$(gcloud run services describe mcp-jde-orchestrator --project $(PROJECT_ID) --region $(REGION) --format 'value(status.url)' 2>/dev/null); \
	if [ -z "$$MCP_URL" ]; then \
		echo "Error: Could not find JDE MCP Server URL in region $(REGION). Is it deployed?"; \
		exit 1; \
	fi; \
	echo "Found JDE MCP URL: $$MCP_URL/mcp"; \
	if grep -q "mcp_server_jde_url" infra.auto.tfvars; then \
		sed -i.bak "s|^mcp_server_jde_url[[:space:]]*=.*|mcp_server_jde_url = \"$$MCP_URL/mcp\"|" infra.auto.tfvars && rm infra.auto.tfvars.bak; \
	else \
		echo "mcp_server_jde_url = \"$$MCP_URL/mcp\"" >> infra.auto.tfvars; \
	fi
	terraform -chdir=$(TF_DIR) plan -target="null_resource.oracle_jde_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

deploy_jde_agents: ## Deploy JDE Manufacturing AI Agent (JDE_Master)
	terraform -chdir=$(TF_DIR) apply -auto-approve -target="null_resource.oracle_jde_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

destroy_jde_agents: ## Destroy JDE Manufacturing AI Agent deployment
	terraform -chdir=$(TF_DIR) destroy -auto-approve -target="null_resource.oracle_jde_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="service_account_key=$(PROJECT_SA_EMAIL)"
