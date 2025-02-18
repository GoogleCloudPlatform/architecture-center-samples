/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


## Minimum viable testing project creation. Borrowed from Cloud Foundation Toolkit

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6"
    }
  }
}

variable "org_id" {
  description = "The numeric organization id"
}

variable "folder_id" {
  description = "The folder to deploy in"
}

variable "billing_account" {
  description = "The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ"
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"

  name              = "ci-tf-acs"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account
}

output "project_id" {
  value = module.project.project_id
}
