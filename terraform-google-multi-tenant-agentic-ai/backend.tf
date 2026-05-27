# backend.tf

# ==============================================================================
# GCS Backend Configuration
# ==============================================================================
# Uncomment and configure the block below to enable remote state storage 
# once the centralized Terraform state GCS bucket has been provisioned.
# ==============================================================================

/*
terraform {
  backend "gcs" {
    bucket  = "REPLACE_WITH_YOUR_STATE_BUCKET_NAME"
    prefix  = "terraform/state/core-infrastructure"
  }
}
*/