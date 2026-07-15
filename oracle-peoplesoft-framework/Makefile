# Default settings
PROJECT_NAME := oracle-ebs-toolkit
PROJECT ?= $(PROJECT_NAME)
PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
export TF_VAR_project_id := $(PROJECT_ID)
PROJECT_SA_EMAIL := ps-project-service-account@$(PROJECT_ID).iam.gserviceaccount.com


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