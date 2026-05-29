# variables.tf

variable "hub_project_id" {
  type        = string
  description = "Project ID for the central routing hub."
}

variable "billing_account" {
  type        = string
  description = "Billing account to associate with all projects."
}

variable "folder_id" {
  type        = string
  description = "Folder ID where tenant projects will be created."
}

variable "tenant_id_suffix" {
  type        = string
  description = "A unique suffix for project IDs to ensure global uniqueness."
}

variable "region" {
  type    = string
  default = "us-central1"
}

# --- VPC-SC & PAB Infrastructure Variables ---

variable "org_id" {
  type        = string
  description = "The 12-digit Google Cloud Organization ID (required for PAB policies)."
}

variable "access_policy_id" {
  type        = string
  description = "The ID of the Access Context Manager Policy for VPC-SC."
}

# --- Project Numbers (Required for Macro-Perimeter & PAB) ---

variable "hub_project_number" {
  type        = string
  description = "The numeric Project Number of the Hub."
}

variable "mkt_project_number" {
  type        = string
  description = "The numeric Project Number of the Marketing Spoke."
}

variable "hr_project_number" {
  type        = string
  description = "The numeric Project Number of the HR Spoke."
}

# --- Security & Governance ---

variable "trusted_corporate_ip_ranges" {
  type        = list(string)
  description = "List of corporate IP ranges for Internal-Only mode. Leave as [] for Public mode."
  default     = []
}

variable "tenant_project_numbers" {
  description = "A list of numeric Project Numbers for all Tenant Spokes to be included in the Macro-Perimeter."
  type        = list(string)
  default     = [] # Optional, but good practice
}

variable "support_email" {
  type        = string
  description = "The support email associated with the IAP brand."
}