variable "terraform_version" {
  type        = string
  description = "The version of Terraform to use for the deployment"
  default     = "1.6.6"
}

variable "project_id" {
  description = "The GCP Project ID to deploy into"
  type        = string
}

variable "region" {
  description = "The default region for resources"
  type        = string
  default     = "northamerica-northeast2"
}

variable "python_version" {
  description = "The Python version to use for the Conda environment"
  type        = string
  default     = "3.9"
}

variable "service_account_key" {
  description = "Path to the GCP service account key file"
  type        = string
}

variable "mcp_server_ebs_url" {
  description = "Cloud Run URL of mcp-oracle-ebs"
  type        = string
  default = ""
}

variable "vpc_name" {
  description = "Name of the VPC to use for the deployment"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to use for the deployment"
  type        = string
}
