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

variable "zone" {
  description = "The default zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "peoplesoft_storage_bucket_name" {
  description = "The name of the storage bucket to be created."
  type        = string
  default     = "oracle-peoplesoft-toolkit-storage-bucket"
}

variable "oracle_peoplesoft_vision" {
  description = "Whether to deploy Oracle peoplesoft Vision environment"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to all resources in the deployment."
  type        = map(string)

  default = {
    "service"    = "oracle-peoplesoft-toolkit"
    "managed-by" = "terraform"
  }
}

variable "project_service_account_email" {
  description = "The email of the service account for the project"
  type        = string
}

variable "project_service_account_roles" {
  description = "The roles to assign to the project service account"
  type        = list(string)
  default = [
    "roles/compute.instanceAdmin.v1",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/iap.tunnelResourceAccessor"
  ]
}

# Vars for VPC and NAT Gateway
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "oracle-peoplesoft-toolkit-network"
}

variable "auto_create_subnetworks" {
  description = "Whether to auto create subnetworks"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets"
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = string
    subnet_private_access            = optional(bool, false)
    subnet_private_ipv6_access       = optional(string, "DISABLE_GOOGLE_ACCESS")
    subnet_flow_logs                 = optional(bool, false)
    subnet_flow_logs_interval        = optional(string, "INTERVAL_5_SEC")
    subnet_flow_logs_sampling        = optional(number, 0.5)
    subnet_flow_logs_metadata        = optional(string, "INCLUDE_ALL_METADATA")
    subnet_flow_logs_filter          = optional(bool, true)
    subnet_flow_logs_metadata_fields = optional(list(string), [])
    description                      = optional(string, null)
    purpose                          = optional(string, null)
    role                             = optional(string, null)
    stack_type                       = optional(string, null)
    ipv6_access_type                 = optional(string, null)
  }))
  default = [
    {
      subnet_name           = "oracle-peoplesoft-toolkit-subnet-01"
      subnet_region         = "northamerica-northeast2"
      subnet_ip             = "10.115.0.0/20"
      subnet_private_access = true
      subnet_flow_logs      = true
    }
  ]
}

variable "delete_default_internet_gateway_routes" {
  description = "Whether to delete the default internet gateway routes"
  type        = bool
  default     = true
}

variable "routing_mode" {
  description = "The routing mode for the VPC network"
  type        = string
  default     = "REGIONAL"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for internet egress"
  type        = bool
  default     = true
}

variable "iap_cidr" {
  description = "CIDR address of the IAP source network."
  type        = string
  default     = "35.235.240.0/20"
}

variable "nat_config" {
  description = "NAT configuration for the cloud router"
  type = list(object({
    name                               = string
    nat_ip_allocate_option             = optional(string)
    source_subnetwork_ip_ranges_to_nat = optional(string)
    nat_ips                            = optional(list(string), [])
    log_config = optional(object({
      enable = optional(bool, true)
      filter = optional(string, "ALL")
    }), {})
    subnetworks = optional(list(object({
      name                     = string
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = optional(list(string))
    })), [])
  }))
  default = [
    {
      name                               = "oracle-peoplesoft-toolkit-nat-01"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetworks = [
        {
          name                    = "oracle-peoplesoft-toolkit-subnet-01"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
        }
      ]
      log_config = {
        enable = true
        filter = "ALL"
      }
    }
  ]
}

variable "peoplesoft_apps_server_internal_ip" {
  description = "The internal IP address for the oracle peoplesoft VM instance"
  type        = string
  default     = "10.115.0.10"
}

variable "trusted_ip_ranges" {
  description = "List of trusted IP ranges allowed to access the firewall rules"
  type        = list(string)
  default     = []
}

variable "apps_image_family" {
  description = "Image family for the apps instance"
  default     = "oracle-linux-8"
}

variable "apps_image_project" {
  description = "Project where the apps image family resides"
  default     = "oracle-linux-cloud"
}

# Vars for peoplesoft Apps VM
variable "apps_machine_type" {
  description = "The machine type for the peoplesoft Apps VM instance"
  type        = string
  default     = "e2-standard-8"
}

variable "apps_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "apps_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 1024
}

variable "apps_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}
