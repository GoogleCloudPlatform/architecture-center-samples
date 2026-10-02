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

variable "jde_storage_bucket" {
  description = "The name of the storage bucket to be created."
  type        = string
  default     = "oracle-jde-toolkit-storage-bucket"
}

variable "force_destroy_bucket" {
  description = "Whether to allow force deletion of the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "oracle_jde_vision" {
  description = "Whether to deploy Oracle JDE Demo environment"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to all resources in the deployment."
  type        = map(string)

  default = {
    "service"    = "oracle-jde-toolkit"
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
    "roles/storage.objectViewer",
    "roles/viewer",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/iap.tunnelResourceAccessor"
  ]
}

# Vars for VPC and NAT Gateway
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "oracle-jde-toolkit-network"
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
      subnet_name           = "oracle-jde-toolkit-subnet-01"
      subnet_region         = "us-central1"
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
      name                               = "oracle-jde-toolkit-nat-01"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetworks = [
        {
          name                    = "oracle-jde-toolkit-subnet-01"
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

# JDE DEMO env variables
variable "jde_demo_prov_server_internal_ip" {
  description = "The internal IP address for the JDE Provisioning DEMO VM instance"
  type        = string
  default     = "10.115.0.40"
}

variable "jde_demo_db_server_internal_ip" {
  description = "The internal IP address for the JDE DB DEMO VM instance"
  type        = string
  default     = "10.115.0.41"
}

variable "jde_demo_ent_server_internal_ip" {
  description = "The internal IP address for the JDE Enterprise DEMO VM instance"
  type        = string
  default     = "10.115.0.42"
}

variable "jde_demo_web_server_internal_ip" {
  description = "The internal IP address for the JDE Web DEMO VM instance"
  type        = string
  default     = "10.115.0.43"
}

variable "jde_demo_dep_server_internal_ip" {
  description = "The internal IP address for the JDE deployment DEMO VM instance"
  type        = string
  default     = "10.115.0.44"
}

variable "jde_demo_prov_family" {
  description = "Image family for the demo instance"
  default     = "oracle-linux-9"
}

variable "jde_demo_prov_project" {
  description = "Project where the demo image family resides"
  default     = "oracle-linux-cloud"
}

variable "jde_demo_prov_family_win" {
  description = "Image family for the demo instance Win "
  default     = "windows-2016"
}

variable "jde_demo_prov_project_win" {
  description = "Project where the demo image family resides"
  default     = "windows-cloud"
}

variable "jde_demo_prov_vm_name" {
  description = "The machine name for the JDE Provisioning DEMO instance"
  type        = string
  default     = "demo_prov"
}

variable "jde_demo_prov_machine_type" {
  description = "The machine type for the JDE Provisioning DEMO instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_demo_prov_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_demo_prov_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_demo_prov_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_demo_db_vm_name" {
  description = "The machine name for the JDE DB DEMO instance"
  type        = string
  default     = "demo_db"
}

variable "jde_demo_db_machine_type" {
  description = "The machine type for the JDE Database DEMO instance"
  type        = string
  default     = "e2-highmem-4"
}

variable "jde_demo_db_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_demo_db_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_demo_db_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_demo_ent_vm_name" {
  description = "The machine name for the JDE ENT DEMO instance"
  type        = string
  default     = "demo_ent"
}

variable "jde_demo_ent_machine_type" {
  description = "The machine type for the JDE Enterprise DEMO instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_demo_ent_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_demo_ent_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_demo_ent_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_demo_web_vm_name" {
  description = "The machine name for the JDE Web DEMO instance"
  type        = string
  default     = "demo_web"
}

variable "jde_demo_web_machine_type" {
  description = "The machine type for the JDE WEB DEMO instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_demo_web_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_demo_web_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_demo_web_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_demo_dep_vm_name" {
  description = "The machine name for the JDE Deployment DEMO instance"
  type        = string
  default     = "demo_dep"
}

variable "jde_demo_dep_machine_type" {
  description = "The machine type for the JDE deployment DEMO instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_demo_dep_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 300
}

variable "jde_demo_dep_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_demo_dep_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}


# JDE Customer Data env variables
variable "jde_prov_server_internal_ip" {
  description = "The internal IP address for the JDE Provisioning Customer Data VM instance"
  type        = string
  default     = "10.115.1.40"
}

variable "jde_db_server_internal_ip" {
  description = "The internal IP address for the JDE DB Customer Data VM instance"
  type        = string
  default     = "10.115.1.41"
}

variable "jde_ent_server_internal_ip" {
  description = "The internal IP address for the JDE Enterprise Customer Data VM instance"
  type        = string
  default     = "10.115.1.42"
}

variable "jde_web_server_internal_ip" {
  description = "The internal IP address for the JDE Web Customer Data VM instance"
  type        = string
  default     = "10.115.1.43"
}

variable "jde_dep_server_internal_ip" {
  description = "The internal IP address for the JDE deployment Customer Data VM instance"
  type        = string
  default     = "10.115.1.44"
}

variable "trusted_ip_ranges" {
  description = "List of trusted IP ranges allowed to access the firewall rules"
  type        = list(string)
  default     = []
}

variable "jde_prov_family" {
  description = "Image family for the Customer Data instance"
  default     = "oracle-linux-9"
}

variable "jde_prov_project" {
  description = "Project where the Customer Data image family resides"
  default     = "oracle-linux-cloud"
}

variable "jde_prov_family_win" {
  description = "Image family for the Customer Data instance Win "
  default     = "windows-2016"
}

variable "jde_prov_project_win" {
  description = "Project where the Customer Data image family resides"
  default     = "windows-cloud"
}

variable "jde_prov_vm_name" {
  description = "The machine name for the JDE Provisioning Customer Data instance"
  type        = string
  default     = "jde_prov"
}

variable "jde_prov_machine_type" {
  description = "The machine type for the JDE Provisioning Customer Data instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_prov_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_prov_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_prov_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_db_vm_name" {
  description = "The machine name for the JDE DB Customer Data instance"
  type        = string
  default     = "jde_db"
}

variable "jde_db_machine_type" {
  description = "The machine type for the JDE Database Customer Data instance"
  type        = string
  default     = "e2-highmem-4"
}

variable "jde_db_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_db_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_db_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_ent_vm_name" {
  description = "The machine name for the JDE ENT Customer Data instance"
  type        = string
  default     = "jde_ent"
}

variable "jde_ent_machine_type" {
  description = "The machine type for the JDE Enterprise Customer Data instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_ent_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_ent_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_ent_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_web_vm_name" {
  description = "The machine name for the JDE Web Customer Data instance"
  type        = string
  default     = "jde_web"
}

variable "jde_web_machine_type" {
  description = "The machine type for the JDE WEB Customer Data instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_web_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 200
}

variable "jde_web_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_web_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

variable "jde_dep_vm_name" {
  description = "The machine name for the JDE Deployment Customer Data instance"
  type        = string
  default     = "jde_dep"
}

variable "jde_dep_machine_type" {
  description = "The machine type for the JDE deployment Customer Data instance"
  type        = string
  default     = "e2-highmem-2"
}

variable "jde_dep_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 300
}

variable "jde_dep_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "jde_dep_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}
