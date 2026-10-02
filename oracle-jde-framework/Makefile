# ===========================================================================
# Project defaults
# ===========================================================================

PROJECT_NAME := oracle-ebs-toolkit
PROJECT ?= $(PROJECT_NAME)

PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
PROJECT_ID_CLEAN := $(shell echo $(PROJECT_ID) | awk -F':' '{print $$NF}')

export TF_VAR_project_id := $(PROJECT_ID_CLEAN)

PROJECT_SA_EMAIL := jde-project-service-account@$(PROJECT_ID_CLEAN).iam.gserviceaccount.com

# ===========================================================================
# ExaScale GRID image settings for JDE on ExaScale
# ===========================================================================

GRID_LOCATION        ?= northamerica-northeast2
GRID_ZONE_ID         ?= northamerica-northeast2-a-r2
GRID_DESIRED_VERSION ?=

GRID_IMAGE_FILE      ?= .grid_image_id
GRID_VERSION_FILE    ?= .grid_version

# Terraform working directory
TF_DIR := .

# Required IAM roles for deployment
REQUIRED_ROLES = roles/storage.admin \
	roles/iam.serviceAccountUser \
	roles/iap.tunnelResourceAccessor \
	roles/compute.osAdminLogin \
	roles/compute.instanceAdmin.v1

.PHONY: help setup init format lint validate plan deploy destroy docs verify-gcp-access \
	jde_demo_plan jde_demo_deploy jde_demo_destroy jde_demo_deploy_soft \
	jde_cust_data_plan jde_cust_data_deploy jde_cust_data_destroy \
	prompt_grid_vars fetch_grid_image_id clean_grid_id \
	jde_cust_data_exa_plan jde_cust_data_exa_deploy jde_cust_data_exa_destroy \
	exascale_deploy_jde

# ===========================================================================
# General targets
# ===========================================================================

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | \
		awk 'BEGIN {FS = ":.*?##"}; {printf "  make %-24s %s\n", $$1, $$2}'

setup: ## Install required local tooling and dependencies
	@echo "Starting project setup..."
	bash scripts/install.sh
	@echo "Setup complete."
	@echo "Ensure gcloud is initialized with the target project, then run: make verify-gcp-access"

init: ## Initialize Terraform and configure the remote backend
	@if [ -z "$(PROJECT_ID)" ]; then \
		echo "PROJECT_ID is not set."; \
		exit 1; \
	fi
	@PROJECT_NUMBER=$$(gcloud projects describe $(PROJECT_ID) --format="value(projectNumber)"); \
	BUCKET_NAME="gs://$(PROJECT_ID_CLEAN)-$${PROJECT_NUMBER}-terraform-state"; \
	echo "Checking Terraform backend bucket: $$BUCKET_NAME"; \
	if ! gcloud storage ls -b $$BUCKET_NAME >/dev/null 2>&1; then \
		echo "Backend bucket not found. Creating bucket..."; \
		gcloud storage buckets create $$BUCKET_NAME \
			--location=US \
			--uniform-bucket-level-access; \
		echo "Waiting for bucket propagation..."; \
		sleep 10; \
	fi; \
	echo "Initializing Terraform in $(TF_DIR)..."; \
	terraform -chdir=$(TF_DIR) init -reconfigure \
		-backend-config="bucket=$(PROJECT_ID_CLEAN)-$${PROJECT_NUMBER}-terraform-state" \
		-backend-config="prefix=jde"
	@echo "Terraform initialization completed successfully."

format: ## Format Terraform configuration files
	terraform -chdir=$(TF_DIR) fmt

lint: ## Run pre-commit checks against all files
	pre-commit run --all-files

validate: ## Validate Terraform configuration
	terraform -chdir=$(TF_DIR) validate \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)"
	@echo "Terraform configuration is valid."

# ===========================================================================
# GCP access validation
# ===========================================================================

verify-gcp-access: ## Verify GCP authentication, project access, and required IAM roles
	@if [ -z "$(PROJECT_ID_CLEAN)" ]; then \
		echo "PROJECT_ID is not set and could not be detected from gcloud config."; \
		echo "Run: gcloud init"; \
		echo "Or pass PROJECT_ID explicitly, for example: make verify-gcp-access PROJECT_ID=<project-id>"; \
		exit 1; \
	fi
	@echo "Verifying access to GCP project: $(PROJECT_ID_CLEAN)"
	@if ! gcloud auth list --format="value(account)" 2>/dev/null | grep -q .; then \
		echo "No active gcloud authentication found. Run: gcloud init"; \
		exit 1; \
	fi
	@if ! gcloud projects describe "$(PROJECT_ID_CLEAN)" --quiet >/dev/null 2>&1; then \
		echo "Unable to access project: $(PROJECT_ID_CLEAN)"; \
		exit 1; \
	fi
	@echo "Project access confirmed: $(PROJECT_ID_CLEAN)"
	@CURRENT_ACCOUNT=$$(gcloud config get-value account 2>/dev/null); \
	echo "Checking IAM roles for account: $$CURRENT_ACCOUNT"; \
	USER_ROLES=$$(gcloud projects get-iam-policy "$(PROJECT_ID_CLEAN)" \
		--flatten="bindings[].members" \
		--format="table(bindings.role)" \
		--filter="bindings.members:user:$$CURRENT_ACCOUNT" | tail -n +2); \
	if echo "$$USER_ROLES" | grep -Eq "(roles/owner|roles/editor)"; then \
		echo "Account has Owner or Editor role. Skipping detailed role checks."; \
	else \
		MISSING=0; \
		for role in $(REQUIRED_ROLES); do \
			if echo "$$USER_ROLES" | grep -q $$role; then \
				echo "Role found: $$role"; \
			else \
				echo "Missing role: $$role"; \
				MISSING=1; \
			fi; \
		done; \
		if [ $$MISSING -ne 0 ]; then \
			echo "One or more required IAM roles are missing. Update permissions before continuing."; \
			exit 1; \
		fi; \
	fi; \
	echo ""; \
	echo "GCP access verification passed for project: $(PROJECT_ID_CLEAN)"

# ===========================================================================
# JDE demo deployment targets
# ===========================================================================

VISION ?= false

jde_demo_plan: ## Generate a Terraform plan for the JDE demo deployment
	terraform -chdir=$(TF_DIR) plan \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=true"

jde_demo_deploy: ## Deploy the JDE demo environment
	terraform -chdir=$(TF_DIR) apply -auto-approve \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=true"

jde_demo_destroy: ## Destroy the JDE demo environment
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=true"

jde_demo_deploy_soft: ## Install required JDE software on the provisioned instances
	@echo ""
	@echo "\033[1m>>> Retrieving JDE instance zone from Terraform output\033[0m"
	@jde_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw vision_instance_zone); \
	echo "Zone: $$jde_gce_zone"; \
	echo ""; \
	echo "\033[1m>>> Copying JDE helper functions to the provisioning instance\033[0m"; \
	gcloud compute scp --tunnel-through-iap --zone "$$jde_gce_zone" --project=$(PROJECT_ID_CLEAN) \
		scripts/jde/functions.sh jde-demo-prov:~; \
	echo ""; \
	echo "\033[1m>>> Running JDE software provisioning\033[0m"; \
	gcloud compute ssh --zone "$$jde_gce_zone" "jde-demo-prov" --tunnel-through-iap --project $(PROJECT_ID_CLEAN) \
		--command "source functions.sh; create_and_dist_opc_key; stage_jde_software; start_jde_provisioning_server; \
		stage_oracle_database; stage_weblogic; stage_deployment_server" \
		-- -o TCPKeepAlive=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=20; \
	echo ""; \
	echo "\033[1m>>> Fetching JDE OPC private key\033[0m"; \
	gcloud compute ssh --zone "$$jde_gce_zone" "jde-demo-prov" --tunnel-through-iap \
		--command="sudo cat /home/opc/.ssh/jde_oneclick_key" > ./jde_oneclick_key.openssh && \
		chmod 600 ./jde_oneclick_key.openssh

# ===========================================================================
# JDE customer-data deployment targets
# ===========================================================================

jde_cust_data_plan: ## Generate a Terraform plan for JDE customer-data deployment
	terraform -chdir=$(TF_DIR) plan \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=false"

jde_cust_data_deploy: ## Deploy JDE customer-data environment
	terraform -chdir=$(TF_DIR) apply -auto-approve \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=false"

jde_cust_data_destroy: ## Destroy JDE customer-data environment
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
		-var="project_id=$(PROJECT_ID_CLEAN)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_vision=false"

# ===========================================================================
# ExaScale GRID image helpers
# ===========================================================================

prompt_grid_vars:
	@if [ ! -f $(GRID_IMAGE_FILE) ] || [ ! -f $(GRID_VERSION_FILE) ]; then \
		echo "-----------------------------------------------------------------"; \
		echo "GRID image and version are not cached. Starting configuration..."; \
		echo "Examples:"; \
		echo "  Location: northamerica-northeast2, us-east4, europe-west3"; \
		echo "  Zone ID:  northamerica-northeast2-a-r2, us-east4-b-r2"; \
		echo "-----------------------------------------------------------------"; \
		read -p "Enter GCP location [$(GRID_LOCATION)]: " loc; \
		LOC=$${loc:-$(GRID_LOCATION)}; \
		read -p "Enter GCP Oracle Zone ID [$(GRID_ZONE_ID)]: " zone; \
		ZONE=$${zone:-$(GRID_ZONE_ID)}; \
		$(MAKE) fetch_grid_image_id GRID_LOCATION=$$LOC GRID_ZONE_ID=$$ZONE; \
	else \
		echo "Using cached GRID image $$(cat $(GRID_IMAGE_FILE)) with version $$(cat $(GRID_VERSION_FILE))"; \
	fi

fetch_grid_image_id:
	@echo "Querying available 19c GRID versions in $(GRID_ZONE_ID)..."
	@ACCESS_TOKEN=$$(gcloud auth print-access-token); \
	if [ -z "$$ACCESS_TOKEN" ]; then \
		echo "Error: unable to retrieve gcloud access token."; \
		exit 1; \
	fi; \
	RESULT=$$(curl -sG -X GET \
		-H "Authorization: Bearer $$ACCESS_TOKEN" \
		--data-urlencode 'filter=shape_family="EXADB_XS" AND gcp_oracle_zone_id="$(GRID_ZONE_ID)"' \
		"https://oracledatabase.googleapis.com/v1/projects/$(PROJECT_ID)/locations/$(GRID_LOCATION)/giVersions/19.0.0.0/minorVersions"); \
	if [ -z "$(GRID_DESIRED_VERSION)" ]; then \
		SELECTED=$$(echo "$$RESULT" | jq -c '.minorVersions | sort_by(.version | split(".") | map(tonumber)) | last'); \
	else \
		SELECTED=$$(echo "$$RESULT" | jq -c --arg v "$(GRID_DESIRED_VERSION)" '.minorVersions[] | select(.version == $$v)'); \
	fi; \
	ID=$$(echo "$$SELECTED" | jq -r '.gridImageId // empty'); \
	VER=$$(echo "$$SELECTED" | jq -r '.version // empty'); \
	if [ -z "$$ID" ] || [ -z "$$VER" ]; then \
		echo "Error: unable to determine GRID image/version."; \
		echo "Requested version: '$(GRID_DESIRED_VERSION)'"; \
		echo "An empty requested version means the latest version should be selected."; \
		echo "API response: $$RESULT"; \
		exit 1; \
	fi; \
	echo "$$ID" > $(GRID_IMAGE_FILE); \
	echo "$$VER" > $(GRID_VERSION_FILE); \
	echo "Selected GRID version: $$VER"; \
	echo "GRID image ID:         $$ID"

clean_grid_id:
	rm -f $(GRID_IMAGE_FILE) $(GRID_VERSION_FILE)

# ===========================================================================
# JDE customer-data deployment on ExaScale
# ===========================================================================

jde_cust_data_exa_plan: jde_cust_data_plan prompt_grid_vars
	@echo "Generating Terraform plan for JDE customer-data deployment on ExaScale..."
	@if [ -z "$(TF_DIR)" ] || [ -z "$(PROJECT_ID)" ] || [ -z "$(PROJECT_SA_EMAIL)" ] || [ -z "$(GRID_IMAGE_FILE)" ] || [ -z "$(GRID_VERSION_FILE)" ]; then \
		echo "Error: required variables are missing."; \
		echo "Ensure TF_DIR, PROJECT_ID, PROJECT_SA_EMAIL, GRID_IMAGE_FILE, and GRID_VERSION_FILE are set."; \
		exit 1; \
	fi
	terraform -chdir=$(TF_DIR) plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))"

jde_cust_data_exa_deploy: prompt_grid_vars
	terraform -chdir=$(TF_DIR) apply -auto-approve \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))"

jde_cust_data_exa_destroy:
	@if [ ! -f $(GRID_IMAGE_FILE) ]; then \
		echo "dummy-id" > $(GRID_IMAGE_FILE); \
	fi
	terraform -chdir=$(TF_DIR) destroy \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_jde_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))" \
		-var="exascale_deletion_protection=false"
	@if [ "$$(cat $(GRID_IMAGE_FILE))" = "dummy-id" ]; then \
		rm -f $(GRID_IMAGE_FILE); \
	fi
