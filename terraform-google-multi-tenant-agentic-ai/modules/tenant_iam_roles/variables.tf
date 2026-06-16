# modules/tenant_iam_roles/variables.tf

variable "project_id" {
  type        = string
  description = "The GCP project ID where the custom roles will be created."
}