# Default settings
PROJECT_NAME := oracle-ebs-toolkit
PROJECT ?= $(PROJECT_NAME)
PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
export TF_VAR_project_id := $(PROJECT_ID)
PROJECT_SA_EMAIL := ps-project-service-account@$(PROJECT_ID).iam.gserviceaccount.com

# --- ExaScale grid image settings (added for PeopleSoft on ExaScale) ---
GRID_LOCATION        ?= northamerica-northeast2
GRID_ZONE_ID         ?= northamerica-northeast2-a-r2
GRID_DESIRED_VERSION ?=
GRID_IMAGE_FILE      ?= .grid_image_id
GRID_VERSION_FILE    ?= .grid_version


# Directory for Terraform
TF_DIR := .

# Required GCP IAM roles
REQUIRED_ROLES = roles/storage.admin roles/iam.serviceAccountUser roles/iap.tunnelResourceAccessor roles/compute.osAdminLogin  roles/compute.instanceAdmin.v1

.PHONY: help setup init format lint validate plan deploy destroy docs list-projects verify-gcp-access vision_plan vision_deploy vision_destroy 

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | awk 'BEGIN {FS = ":.*?##"}; {printf "  make %-20s %s\n", $$1, $$2}'

setup:
	@echo "Running setup..."
	bash scripts/install.sh
	@echo "Setup complete."
	@echo "Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'."


format:
	terraform -chdir=$(TF_DIR) fmt

list-projects:
	@echo "Available projects:"
	@ls -1 projects

verify-gcp-access:
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

init:
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
		-backend-config="prefix=peoplesoft"
	@echo "Terraform initialized successfully."

plan:
	terraform -chdir=$(TF_DIR) plan \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"

deploy:
	terraform -chdir=$(TF_DIR) apply -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"

destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve \
	  -var="project_id=$(PROJECT_ID)" \
	  -var="project_service_account_email=$(PROJECT_SA_EMAIL)"

deploy_peoplesoft:
	@echo ""
	@echo "\033[1m >>>Oracle Peoplesoft PUM (DEMO) Setup \033[0m"
	@peoplesoft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	gcloud compute ssh --zone "$$peoplesoft_gce_zone" "oracle-peoplesoft-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo su - oracle -c 'date; stage_poeplesoft_media; install_poeplesoft '"

deploy_customer_peoplesoft:
	@echo ""
	@echo "\033[1m >>>Oracle Peoplesoft Customer Setup \033[0m"
	@peoplesoft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	gcloud compute ssh --zone "$$peoplesoft_gce_zone" "oracle-peoplesoft-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo su - oracle -c 'date; stage_cust_data; rdbms_stage_oh; rdbms_rman_restore; setup_cust_app '"

peoplesoft_stop:
	@echo ""
	@echo "\033[1m >>>Oracle Peoplesoft PUM (DEMO) stop procedure \033[0m"
	@peoplesoft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	gcloud compute ssh --zone "$$peoplesoft_gce_zone" "oracle-peoplesoft-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo su - oracle -c 'date; stop_poeplesoft '"

peoplesoft_start:
	@echo ""
	@echo "\033[1m >>>Oracle Peoplesoft PUM (DEMO) start procedure \033[0m"
	@peoplesoft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	gcloud compute ssh --zone "$$peoplesoft_gce_zone" "oracle-peoplesoft-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo su - oracle -c 'date; start_poeplesoft '"

deploy_oracle_peoplesoft_scripts:
	@echo ""
	@echo "\033[1m>>> Getting peoplesoft instance zone from Terraform output \033[0m"
	@peoplesoft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	echo "Zone: $$peoplesoft_gce_zone"; \
	echo ""; \
	echo "\033[1m>>> Creating /scripts on oracle-peoplesoft-apps \033[0m"; \
	gcloud compute ssh --zone "$$peoplesoft_gce_zone" "oracle-peoplesoft-apps" --tunnel-through-iap --project $(PROJECT_ID) \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 755 /scripts"; \
	echo ""; \
	echo "\033[1m>>> Copying /scripts/* to oracle-peoplesoft-apps \033[0m"; \
	gcloud compute scp --tunnel-through-iap --zone "$$peoplesoft_gce_zone" --project=$(PROJECT_ID) \
	scripts/peoplesoft/* oracle-peoplesoft-apps:/scripts; 

# ===========================================================================
# ExaScale targets (added for PeopleSoft on ExaScale)
# ===========================================================================

prompt_grid_vars:
	@if [ ! -f $(GRID_IMAGE_FILE) ] || [ ! -f $(GRID_VERSION_FILE) ]; then \
		echo "-----------------------------------------------------------------"; \
		echo "Grid image/version not cached. Starting configuration..."; \
		echo "Examples:"; \
		echo "  Location: northamerica-northeast2, us-east4, europe-west3"; \
		echo "  Zone ID:  northamerica-northeast2-a-r2, us-east4-b-r2"; \
		echo "-----------------------------------------------------------------"; \
		read -p "Enter GCP Location [$(GRID_LOCATION)]: " loc; \
		LOC=$${loc:-$(GRID_LOCATION)}; \
		read -p "Enter GCP Oracle Zone ID [$(GRID_ZONE_ID)]: " zone; \
		ZONE=$${zone:-$(GRID_ZONE_ID)}; \
		$(MAKE) fetch_grid_image_id GRID_LOCATION=$$LOC GRID_ZONE_ID=$$ZONE; \
	else \
		echo "Using cached grid image $$(cat $(GRID_IMAGE_FILE)) (version $$(cat $(GRID_VERSION_FILE)))"; \
	fi

fetch_grid_image_id:
	@echo "Querying available 19c GRID versions in $(GRID_ZONE_ID)..."
	@ACCESS_TOKEN=$$(gcloud auth print-access-token); \
	if [ -z "$$ACCESS_TOKEN" ]; then echo "Error: Failed to get gcloud token"; exit 1; fi; \
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
		echo "Error: could not determine grid image/version (wanted: '$(GRID_DESIRED_VERSION)', empty = latest)."; \
		echo "API Response: $$RESULT"; \
		exit 1; \
	fi; \
	echo "$$ID"  > $(GRID_IMAGE_FILE); \
	echo "$$VER" > $(GRID_VERSION_FILE); \
	echo "Selected GRID version : $$VER"; \
	echo "Grid image ID         : $$ID"

clean_grid_id:
	rm -f $(GRID_IMAGE_FILE) $(GRID_VERSION_FILE)

exascale_plan: prompt_grid_vars
	terraform -chdir=$(TF_DIR) plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_peoplesoft_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))"

exascale_deploy: prompt_grid_vars
	terraform -chdir=$(TF_DIR) apply -auto-approve \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_peoplesoft_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))"

exascale_destroy:
	@if [ ! -f $(GRID_IMAGE_FILE) ]; then \
		echo "dummy-id" > $(GRID_IMAGE_FILE); \
	fi
	terraform -chdir=$(TF_DIR) destroy \
		-var="project_id=$(PROJECT_ID)" \
		-var="project_service_account_email=$(PROJECT_SA_EMAIL)" \
		-var="oracle_peoplesoft_exascale=true" \
		-var="exascale_grid_image_id=$$(cat $(GRID_IMAGE_FILE))" \
		-var="exascale_grid_version=$$(cat $(GRID_VERSION_FILE))" \
		-var="exascale_deletion_protection=false"
	@if [ "$$(cat $(GRID_IMAGE_FILE))" = "dummy-id" ]; then \
		rm -f $(GRID_IMAGE_FILE); \
	fi

exascale_deploy_peoplesoft:
	@echo "" ; \
	echo "\033[1m>>> Getting ExaScale app instance zone from Terraform output \033[0m"; \
	psft_gce_zone=$$(terraform -chdir=$(TF_DIR) output -raw apps_instance_zone); \
	echo "Zone: $$psft_gce_zone"; \
	export CLOUDSDK_CORE_LOG_HTTP=false ; \
	export CLOUDSDK_PYTHON_SITEPACKAGES=1 ; \
	echo ""; \
	echo "\033[1m>>> Creating /scripts on oracle-exascale-peoplesoft-app \033[0m"; \
	gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo mkdir -vp /scripts/logs && sudo chown -R oracle:oinstall /scripts" 2>/dev/null; \
	echo ""; \
	echo "\033[1m>>> Copying /scripts/* to oracle-exascale-peoplesoft-app \033[0m"; \
	tar czf - -C ./scripts/exascale . | gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo -u oracle tar xzf - -C /scripts/ && sudo -u oracle chmod +x /scripts/*.sh" 2>/dev/null; \
	echo ""; \
	echo "\033[1m>>> Setting up nfs share @GCP \033[0m"; \
	gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo bash -c '/scripts/setup_nfs_share.sh'" 2>/dev/null; \
	echo ""; \
	echo "\033[1m>>> Staging Customer data @GCP \033[0m"; \
	gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo -u oracle bash -c '/scripts/stage_customer_data.sh'" 2>/dev/null; \
	echo ""; \
	echo "\033[1m>>> Setting up Peoplesoft database on Exascale@GCP \033[0m"; \
	gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo -u oracle bash -c '/scripts/start_db_setup.sh'" 2>/dev/null; \
	echo ""; \
	echo "\033[1m>>> Setting up Peoplesoft applications @GCP \033[0m"; \
	gcloud compute ssh --zone "$$psft_gce_zone" "oracle-exascale-peoplesoft-app" --tunnel-through-iap --project $(PROJECT_ID) \
	  --quiet --ssh-flag="-o LogLevel=ERROR" --command "sudo -u oracle bash -c '/scripts/setup_ps_apps.sh'" 2>/dev/null;
