# modules/tenant_project/variables.tf

variable "project_id" {
  description = "The GCP project ID for the tenant project."
  type        = string
}

variable "tenant_name" {
  description = "The full descriptive name of the tenant."
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to associate with the tenant project."
  type        = string
}

variable "folder_id" {
  description = "The folder ID where the tenant project will be created."
  type        = string
}

variable "region" {
  description = "The default Google Cloud region for deploying tenant resources."
  type        = string
  default     = "us-central1"
}

variable "org_id" {
  description = "The Google Cloud Organization ID."
  type        = string
}

variable "tenant_id" {
  description = "Short identifier for the tenant (e.g., 'mkt', 'hr') used for resource naming."
  type        = string
}

variable "enabled_apis" {
  description = "List of Google Cloud APIs to enable for the tenant project."
  type        = list(string)
  default = [
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "modelarmor.googleapis.com",
    "securitycenter.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "discoveryengine.googleapis.com"
  ]
}

variable "agent_sa_project_roles" {
  description = "A set of IAM roles to assign to the Agent Service Account at the project level."
  type        = set(string)
  default = [
    "roles/modelarmor.user",
    "roles/securitycenter.admin"
  ]
}

variable "cloud_run_iam_bindings" {
  description = "An object defining the IAM bindings for the Cloud Run agent service. Must be explicitly provided."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}

variable "agent_image_name" {
  description = "The base name/URL of the container image for the Agent runtime."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "agent_image_tag" {
  description = "The specific tag or version of the Agent container image to deploy. WARNING: The default 'latest' should only be used for dev/testing. For production, always override this with a specific immutable tag (e.g., 'v1.2.3' or a Git SHA)."
  type        = string
  default     = "latest"
}

variable "mcp_server_image_name" {
  description = "The base name/URL of the container image for the MCP server."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "mcp_server_image_tag" {
  description = "The specific tag or version of the MCP server container image to deploy. WARNING: The default 'latest' should only be used for dev/testing. For production, always override this with a specific immutable tag (e.g., 'v1.2.3' or a Git SHA)."
  type        = string
  default     = "latest"
}

variable "rag_bucket_retention_days" {
  description = "The number of days to keep objects in the RAG bucket before deleting them."
  type        = number
  default     = 365
}