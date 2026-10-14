# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
  default     = "us-central1"
}

variable "python_version" {
  description = "The Python version to use for the Conda environment"
  type        = string
  default     = "3.9"
}

variable "service_account_key" {
  description = "Email of the GCP service account used for Cloud Run and Agent deployment"
  type        = string
}

variable "mcp_server_ebs_url" {
  description = "Cloud Run URL of mcp-toolbox-ebs"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC to use for Direct VPC Egress to Oracle EBS"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to use for Direct VPC Egress to Oracle EBS"
  type        = string
}

variable "ebs_db_connection_string" {
  description = "Oracle EBS Database connection string (e.g., 10.0.0.10:1521/EBSDB)"
  type        = string
  default     = ""
}

variable "ebs_db_user" {
  description = "Least-privilege Oracle EBS Database username (default: apps_ai)"
  type        = string
  default     = "apps_ai"
}

variable "ebs_db_password" {
  description = "Oracle EBS Database password (stored in Google Cloud Secret Manager)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "build_ar_image" {
  description = "Whether to build and push the pre-configured EBS MCP container image to the project's Artifact Registry repository (ebs-mcp-repo)"
  type        = bool
  default     = true
}
