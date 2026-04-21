# Default settings
PROJECT_NAME := oracle-ebs-toolkit
PROJECT ?= $(PROJECT_NAME)
PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
export TF_VAR_project_id := $(PROJECT_ID)
# Added this to stop the prompt during MCP deployment
export TF_VAR_mcp_server_ebs_url := "pending"
PROJECT_SA_EMAIL := project-service-account@$(PROJECT_ID).iam.gserviceaccount.com

# Directory for Terraform
TF_DIR := .

# Required GCP IAM roles
REQUIRED_ROLES = roles/storage.admin roles/iam.serviceAccountUser roles/iap.tunnelResourceAccessor roles/compute.osAdminLogin roles/compute.instanceAdmin.v1

.PHONY: help setup init verify-gcp-access format lint set_config_mcp_servers plan_mcp_server deploy_mcp_server destroy_mcp_server plan_ebs_agents deploy_ebs_agents destroy_ebs_agents

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
		-backend-config="prefix=ebs-gemini"

verify-gcp-access: ## Verify GCP access and permissions
	@if [ -z "$(PROJECT_ID)" ]; then echo "PROJECT_ID not set. Pass PROJECT_ID=<id> to make."; exit 1; fi
	@if ! gcloud auth list --format="value(account)" 2>/dev/null | grep -q .; then echo "No active gcloud auth. Run: gcloud init"; exit 1; fi
	@if ! gcloud projects describe "$(PROJECT_ID)" --quiet >/dev/null 2>&1; then echo "Cannot access project: $(PROJECT_ID)"; exit 1; fi
	@set -e; \
	CURRENT_ACCOUNT=$$(gcloud config get-value account 2>/dev/null); \
	USER_ROLES=$$(gcloud projects get-iam-policy "$(PROJECT_ID)" --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:user:$$CURRENT_ACCOUNT" | tail -n +2); \
	if ! echo "$$USER_ROLES" | grep -Eq "(roles/owner|roles/editor)"; then \
		for role in $(REQUIRED_ROLES); do \
			if ! echo "$$USER_ROLES" | grep -q $$role; then echo "Missing required role: $$role"; exit 1; fi; \
		done; \
	fi
	@echo "GCP access and permissions verified for $(PROJECT_ID)."

format: ## Format Terraform files
	terraform -chdir=$(TF_DIR) fmt

lint: ## Run pre-commit linting
	pre-commit run --all-files

set_config_mcp_servers: ## Prompt for DB and Network configs and save to tfvars/tools.yaml
	@echo "Configuring MCP Server..."
	@touch infra.auto.tfvars
	@if grep -qE "apps.example.com:1521/EBSDB|connectionString:[[:space:]]*\"\"|connectionString:[[:space:]]*$$" MCPServers/mcp-toolbox-ebs/tools.yaml; then \
		read -p "Enter Oracle DB Connection String: " db_conn; \
		read -p "Enter Oracle DB User: " db_user; \
		read -p "Enter Oracle DB Password: " db_pass; \
		sed -i.bak -E "s|^([[:space:]]*)connectionString:.*|\1connectionString: \"$$db_conn\"|" MCPServers/mcp-toolbox-ebs/tools.yaml; \
		sed -i.bak -E "s|^([[:space:]]*)user:.*|\1user: $$db_user|" MCPServers/mcp-toolbox-ebs/tools.yaml; \
		sed -i.bak -E "s|^([[:space:]]*)password:.*|\1password: $$db_pass|" MCPServers/mcp-toolbox-ebs/tools.yaml; \
		rm -f MCPServers/mcp-toolbox-ebs/*.bak; \
		echo "tools.yaml updated successfully!"; \
	else \
		echo "tools.yaml is already configured."; \
	fi
	@if ! grep -q "vpc_name" infra.auto.tfvars; then \
		read -p "Enter VPC Name: " vpc_name; \
		echo "vpc_name = \"$$vpc_name\"" >> infra.auto.tfvars; \
	fi
	@if ! grep -q "subnet_name" infra.auto.tfvars; then \
		read -p "Enter Subnet Name: " subnet_name; \
		echo "subnet_name = \"$$subnet_name\"" >> infra.auto.tfvars; \
	fi
	@echo "MCP Server configuration complete and saved to infra.auto.tfvars."

plan_mcp_server: ## Plan Terraform for MCP Server
	terraform -chdir=$(TF_DIR) plan -target="null_resource.oracle_ebs_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

deploy_mcp_server: ## Deploy MCP Server
	terraform -chdir=$(TF_DIR) apply -auto-approve -target="null_resource.oracle_ebs_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

destroy_mcp_server: ## Destroy MCP Server
	terraform -chdir=$(TF_DIR) destroy -auto-approve -target="null_resource.oracle_ebs_gemini_enterprise_mcp_server" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

plan_ebs_agents: ## Plan Terraform for EBS agents
	@touch infra.auto.tfvars
	@read -p "Enter MCP Server EBS URL: " ebs_url; \
	if grep -q "mcp_server_ebs_url" infra.auto.tfvars; then \
		sed -i.bak "s|^mcp_server_ebs_url[[:space:]]*=.*|mcp_server_ebs_url = \"$$ebs_url\"|" infra.auto.tfvars && rm infra.auto.tfvars.bak; \
	else \
		echo "mcp_server_ebs_url = \"$$ebs_url\"" >> infra.auto.tfvars; \
	fi
	terraform -chdir=$(TF_DIR) plan -target="null_resource.oracle_ebs_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

deploy_ebs_agents: ## Deploy EBS Agent
	terraform -chdir=$(TF_DIR) apply -auto-approve -target="null_resource.oracle_ebs_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"

destroy_ebs_agents: ## Destroy EBS Agent deployment
	terraform -chdir=$(TF_DIR) destroy -auto-approve -target="null_resource.oracle_ebs_gemini_enterprise_framework" -var="project_id=$(PROJECT_ID)" -var="service_account_key=$(PROJECT_SA_EMAIL)"