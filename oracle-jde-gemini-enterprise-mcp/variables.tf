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
  description = "The Python version to use for the virtual environment"
  type        = string
  default     = "3.11"
}

variable "service_account_key" {
  description = "Email of the GCP service account used for Cloud Run and Agent deployment"
  type        = string
}

variable "mcp_server_jde_url" {
  description = "Cloud Run URL of mcp-jde-orchestrator"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC to use for Direct VPC Egress to Oracle JD Edwards EnterpriseOne"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to use for Direct VPC Egress to Oracle JD Edwards EnterpriseOne"
  type        = string
}

variable "jde_ais_base_url" {
  description = "Oracle JDE AIS & Orchestrator v3 base URL (e.g., http://10.118.0.43:7077)"
  type        = string
  default     = "http://10.118.0.43:7077"
}

variable "jde_db_dsn" {
  description = "Oracle JD Edwards 19c Database connection string (e.g., 10.118.0.41:1521/jdeorcl)"
  type        = string
  default     = ""
}

variable "jde_db_user" {
  description = "Least-privilege Oracle JDE Database username (default: JDE_AI)"
  type        = string
  default     = "JDE_AI"
}

variable "jde_db_password" {
  description = "Oracle JDE Database password (stored in Google Cloud Secret Manager)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "jde_username" {
  description = "Default JDE EnterpriseOne service username for AIS/Orchestrator calls (default: NGONZAL)"
  type        = string
  default     = "NGONZAL"
}

variable "jde_password" {
  description = "Oracle JDE AIS/Orchestrator password (stored in Google Cloud Secret Manager)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "build_ar_image" {
  description = "Whether to build and push the pre-configured JDE Hybrid MCP container image to the project's Artifact Registry repository (jde-mcp-repo)"
  type        = bool
  default     = true
}
