# Default settings
PROJECT_NAME := oracle-ebs-toolkit
PROJECT ?= $(PROJECT_NAME)
PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
export TF_VAR_project_id := $(PROJECT_ID)
PROJECT_SA_EMAIL := project-service-account@$(PROJECT_ID).iam.gserviceaccount.com

# Directory for Terraform
TF_DIR := .

# Required GCP IAM roles
REQUIRED_ROLES = roles/storage.admin roles/iam.serviceAccountUser roles/iap.tunnelResourceAccessor roles/compute.osAdminLogin  roles/compute.instanceAdmin.v1

.PHONY: help setup init format lint validate plan deploy destroy docs verify-gcp-access vision_plan vision_deploy vision_destroy

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | awk 'BEGIN {FS = ":.*?##"}; {printf "  make %-20s %s\n", $$1, $$2}'

setup: ## Run initial setup for the project
	@echo "Running setup..."
	bash scripts/install.sh
	@echo "Setup complete."
	@echo "Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'."

init: ## Initialize Terraform configuration
	@if [ -z "$(PROJECT_ID)" ]; then \
		echo "PROJECT_ID not set"; exit 1; \
	fi
	@PROJECT_NUMBER=$$(gcloud projects describe $(PROJECT_ID) --format="value(projectNumber)"); \
	BUCKET_NAME="gs://$(PROJECT_ID)-$${PROJECT_NUMBER}-terraform-state"; \
	echo "Checking if backend bucket $$BUCKET_NAME exists..."; \
	if ! gcloud storage ls -b $$BUCKET_NAME >/dev/null 2>&1; then \
		echo "Bucket does not exist. Creating..."; \
		gcloud storage buckets create $$BUCKET_NAME \
			--location=US --uniform-bucket-level-access; \
		echo "Waiting 10s for bucket propagation..."; \
		sleep 10; \
	fi; \
	echo "Initializing Terraform in $(TF_DIR)..."; \
	terraform -chdir=$(TF_DIR) init -reconfigure \
		-backend-config="bucket=$(PROJECT_ID)-$${PROJECT_NUMBER}-terraform-state" \
		-backend-config="prefix=$(PROJECT_ID)"
	@echo "Terraform initialized successfully."

format: ## Format Terraform files
	terraform -chdir=$(TF_DIR) fmt

lint: ## Lint Terraform files
	pre-commit run --all-files

validate: ## Validate Terraform configuration
    @echo "Validating Terraform configuration..."
	terraform -chdir=$(TF_DIR) validate \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"
	@echo "Terraform configuration is valid."

plan: ## Validate Terraform configuration
	terraform -chdir=$(TF_DIR) plan \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"
	@echo "Terraform plan generated."

deploy: ## Apply Terraform configuration
	terraform -chdir=$(TF_DIR) apply -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"

deploy_oracle_ebs_scripts: ## Deploy Oracle EBS scripts to instances
	@echo ""
	@echo "\033[1m>>> Getting EBS instance zone from Terraform output \033[0m"
	@ebs_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	echo "Zone: $$ebs_gce_zone"; \
	echo ""; \
	echo "\033[1m>>> Creating /scripts on oracle-ebs-db \033[0m"; \
	gcloud compute ssh --zone "$$ebs_gce_zone" "oracle-ebs-db" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"; \
	echo ""; \
	echo "\033[1m>>> Copying /scripts/* to oracle-ebs-db \033[0m"; \
	gcloud compute scp --tunnel-through-iap --zone "$$ebs_gce_zone" --project=$(PROJECT_ID) \
	scripts/ebs/* oracle-ebs-db:/scripts; \
	echo ""; \
	echo "\033[1m>>> Creating /scripts on oracle-ebs-apps \033[0m"; \
	gcloud compute ssh --zone "$$ebs_gce_zone" "oracle-ebs-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"; \
	echo ""; \
	echo "\033[1m>>> Copying /scripts/* to oracle-ebs-apps \033[0m"; \
	gcloud compute scp --tunnel-through-iap --zone "$$ebs_gce_zone" --project=$(PROJECT_ID) \
	scripts/ebs/* oracle-ebs-apps:/scripts

VISION ?= false

vision_plan: ## Plan Terraform configuration with Oracle EBS Vision
	terraform -chdir=$(TF_DIR) plan \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
	  -var="oracle_ebs_vision=true"

vision_deploy: ## Apply Terraform configuration with Oracle EBS Vision
	terraform -chdir=$(TF_DIR) apply -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
	  -var="oracle_ebs_vision=true"

vision_destroy: ## Destroy Terraform configuration with Oracle EBS Vision
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
	  -var="oracle_ebs_vision=true"

destroy: ## Destroy Terraform-managed infrastructure
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"

verify-gcp-access: ## Verify GCP access and required IAM roles
	@if [ -z "$(PROJECT_ID)" ]; then \
		echo " PROJECT_ID is not set and could not be auto-detected from gcloud config."; \
		echo "Please run: gcloud init OR pass PROJECT_ID=<id> to make."; \
		exit 1; \
	fi
	@echo " Verifying GCP access for project: $(PROJECT_ID)"
	@if ! gcloud auth list --format="value(account)" 2>/dev/null | grep -q .; then \
		echo "⚠ No active gcloud authentication found. Please run: gcloud init"; \
		exit 1; \
	fi
	@if ! gcloud projects describe "$(PROJECT_ID)" --quiet >/dev/null 2>&1; then \
		echo " Cannot access project: $(PROJECT_ID)"; \
		exit 1; \
	fi
	@echo "Access to project $(PROJECT_ID) confirmed."
	@CURRENT_ACCOUNT=$$(gcloud config get-value account 2>/dev/null); \
	echo " Checking IAM roles for $$CURRENT_ACCOUNT..."; \
	USER_ROLES=$$(gcloud projects get-iam-policy "$(PROJECT_ID)" \
		--flatten="bindings[].members" \
		--format="table(bindings.role)" \
		--filter="bindings.members:user:$$CURRENT_ACCOUNT" | tail -n +2); \
	if echo "$$USER_ROLES" | grep -Eq "(roles/owner|roles/editor)"; then \
		echo " User has Owner/Editor role → skipping fine-grained permission checks."; \
	else \
		MISSING=0; \
		for role in $(REQUIRED_ROLES); do \
			if echo "$$USER_ROLES" | grep -q $$role; then \
				echo "Has role: $$role"; \
			else \
				echo " Missing role: $$role"; \
				MISSING=1; \
			fi; \
		done; \
		if [ $$MISSING -ne 0 ]; then \
			echo " Missing required IAM roles. Please update permissions before proceeding."; \
			exit 1; \
		fi; \
	fi; \
	echo ""; \
	echo " GCP access check passed for project: $(PROJECT_ID)"

vision_deploy_oracle_ebs: ## Deploy Oracle EBS Vision application
	@echo ""
	@echo "\033[1m>>> Getting Vision instance zone from Terraform output \033[0m"
	@vision_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw vision_instance_zone); \
	echo "Zone: $$vision_gce_zone"; \
	echo ""; \
	echo "\033[1m>>> Creating /scripts on oracle-vision \033[0m"; \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"; \
	echo ""; \
	echo "\033[1m>>> Copying /scripts/* to oracle-vision \033[0m"; \
	gcloud compute scp --tunnel-through-iap --zone "$$vision_gce_zone" --project=$(PROJECT_ID) \
	scripts/vision/* oracle-vision:/scripts; \
	echo ""; \
	echo "\033[1m>>> Ownership updates /scripts/ on oracle-vision \033[0m"; \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo chown -Rfv root:root /scripts && sudo chmod -Rfv 777 /scripts/*"; \
	echo ""; \
	echo "\033[1m>>> Deploying Oracle EBS vision: Runtime ~ 50-60 minutes \033[0m"; \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo /scripts/vision_apps_fs_prepare.sh | tee -a /scripts/vision_apps_fs_prepare.sh.\$$(date +%Y%m%d_%H%M%S).log"

vision_ebs_troubleshoot: ## Troubleshoot Oracle EBS Vision deployment
	@echo ""
	@echo "\033[1m>>>Troubleshooting - printing deployment Oracle EBS details \033[0m"
	@vision_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw vision_instance_zone); \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo bash -c '/scripts/vision_apps_troubleshoot.sh | tee -a /scripts/vision_apps_troubleshoot.sh.\$$(date +%Y%m%d_%H%M%S).log'"

vision_ebs_start: ## Start Oracle EBS Vision application
	@echo ""
	@echo "\033[1m>>>Oracle Vision EBS: Startup \033[0m"
	@vision_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw vision_instance_zone); \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo -u oracle bash -c '/scripts/vision_apps_startup.sh | tee -a /scripts/vision_apps_startup.sh.log'"

vision_ebs_stop: ## Stop Oracle EBS Vision application
	@echo ""
	@echo "\033[1m>>>Oracle Vision EBS: Stop \033[0m"
	@vision_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw vision_instance_zone); \
	gcloud compute ssh --zone "$$vision_gce_zone" "oracle-vision" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo -u oracle bash -c 'kill -9 -1; sleep 5; ps -fea | grep oracle'"
