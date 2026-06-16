# modules/central_hub/variables.tf

variable "hub_project_id" {
  description = "The project ID for the Central Hub."
  type        = string
}

variable "hub_project_number" {
  description = "The numerical project number of the Hub (used for the LB Service Agent)."
  type        = string
}

variable "region" {
  description = "The default Google Cloud region for deploying Hub resources."
  type        = string
  # REMOVED: default = "us-central1" to enforce explicit assignment from root
}

# --- Tenant Project IDs (Required for the IAM Bridge) ---

variable "tenant_projects" {
  description = "A map of tenant names to their respective Project IDs."
  type        = map(string)
}

# --- Flexible Security Variables ---

variable "trusted_corporate_ip_ranges" {
  description = "List of public IP ranges (CIDR) for Internal-Only access."
  type        = list(string)
  default     = []
}

variable "enforce_edge_lockdown" {
  description = "Toggle to switch between Default Allow (Public) and Default Deny (Internal-Only)."
  type        = bool
  default     = false
}

variable "frontend_image_name" {
  description = "The base name/URL of the container image for the frontend portal."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "frontend_image_tag" {
  description = "The specific tag or version of the container image to deploy. WARNING: The default 'latest' should only be used for dev/testing. For production, always override this with a specific immutable tag (e.g., 'v1.2.3' or a Git SHA)."
  type        = string
  default     = "latest"
}

variable "support_email" {
  description = "The support email associated with the IAP brand."
  type        = string
}