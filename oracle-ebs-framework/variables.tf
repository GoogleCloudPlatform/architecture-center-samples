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

variable "zone" {
  description = "The default zone for resources"
  type        = string
  default     = "northamerica-northeast2-a"
}

variable "ebs_storage_bucket_name" {
  description = "The name of the storage bucket to be created."
  type        = string
  default     = "oracle-ebs-toolkit-storage-bucket"
}

variable "oracle_ebs_vision" {
  description = "Whether to deploy Oracle EBS Vision environment"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to all resources in the deployment."
  type        = map(string)

  default = {
    "service"    = "oracle-ebs-toolkit"
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
  default     = "oracle-ebs-toolkit-network"
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
      subnet_name           = "oracle-ebs-toolkit-subnet-01"
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
      name                               = "oracle-ebs-toolkit-nat-01"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetworks = [
        {
          name                    = "oracle-ebs-toolkit-subnet-01"
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

variable "ebs_apps_server_internal_ip" {
  description = "The internal IP address for the oracle EBS VM instance"
  type        = string
  default     = "10.115.0.10"
}

variable "ebs_db_server_internal_ip" {
  description = "The internal IP address for the oracle EBS VM instance"
  type        = string
  default     = "10.115.0.20"
}

variable "vision_server_internal_ip" {
  description = "The internal IP address for the Vision VM instance"
  type        = string
  default     = "10.115.0.30"

}

variable "exascale_vision_server_internal_ip" {
  description = "The internal IP address for the Exascale Vision VM instance"
  type        = string
  default     = "10.115.0.40"
}

variable "apps_image_family" {
  description = "Image family for the apps instance"
  default     = "oracle-linux-8"
}

variable "apps_image_project" {
  description = "Project where the apps image family resides"
  default     = "oracle-linux-cloud"
}

variable "dbs_image_family" {
  description = "Image family for the dbs instance"
  default     = "oracle-linux-8"
}

variable "dbs_image_project" {
  description = "Project where the dbs image family resides"
  default     = "oracle-linux-cloud"
}

variable "vision_image_family" {
  description = "Image family for the vision instance"
  default     = "oracle-linux-8"
}

variable "vision_image_project" {
  description = "Project where the vision image family resides"
  default     = "oracle-linux-cloud"
}

# Vars for EBS Apps VM
variable "apps_machine_type" {
  description = "The machine type for the EBS Apps VM instance"
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

# Vars for EBS DB VM
variable "dbs_machine_type" {
  description = "The machine type for the EBS DB VM instance"
  type        = string
  default     = "e2-standard-8"
}

variable "dbs_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "dbs_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 1024

}
variable "dbs_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

# Vars for Vision VM
variable "vision_machine_type" {
  description = "The machine type for the Vision VM instance"
  type        = string
  default     = "e2-standard-8"
}

variable "vision_boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 1024
}

variable "vision_boot_disk_type" {
  description = "The type of the boot disk (e.g., pd-ssd, pd-standard)"
  type        = string
  default     = "pd-ssd"
}

variable "vision_boot_disk_auto_delete" {
  description = "Whether the boot disk should be auto-deleted when the instance is deleted"
  type        = bool
  default     = false
}

# Vars for Exascale

variable "oracle_ebs_exascale" {
  description = "Whether to deploy Oracle Exascale environment"
  type        = bool
  default     = false

}

variable "odb_subnet_id" {
  description = "The name of the subnet to be used for ODB network"
  type        = string
  default     = "oracle-ebs-toolkit-odb-subnet"
}

variable "odb_subnet_cidr" {
  description = "The CIDR range for the ODB subnet"
  type        = string
  default     = "10.116.0.0/20"
}

variable "exascale_location" {
  description = "The region for the Exascale environment"
  type        = string
  default     = "northamerica-northeast2"
}

variable "exascale_client_subnet_cidr" {
  description = "The CIDR range for the client subnet"
  type        = string
  default     = "10.116.0.0/20"
}

variable "exascale_backup_subnet_cidr" {
  description = "The CIDR range for the backup subnet"
  type        = string
  default     = "10.116.128.0/20"
}

variable "exadb_vm_cluster_id" {
  description = "ID of the Exadata VM Cluster"
  type        = string
  default     = "exadb-vm-cluster-01"
}

variable "exadb_display_name" {
  description = "Display name of the Exadata VM Cluster"
  type        = string
  default     = "Exadata VM Cluster"
}

variable "exadata_infrastructure_id" {
  description = "ID of the Exadata infrastructure to use for the VM cluster"
  type        = string
  default     = "exadata-infrastructure-01"
}

variable "exascale_time_zone" {
  description = "Time zone for the VM cluster"
  type        = string
  default     = "UTC"
}

variable "exascale_grid_image_id" {
  description = "Grid image ID for the VM cluster"
  type        = string
  default     = ""
}

variable "exascale_node_count" {
  description = "Number of nodes in the VM cluster"
  type        = number
  default     = 1
}

variable "exascale_enabled_ecpu_count_per_node" {
  description = "Number of enabled eCPUs per node"
  type        = number
  default     = 8
}

variable "exascale_vm_file_system_storage_size_gb" {
  description = "Size of the VM file system storage per node in GB"
  type        = number
  default     = 260
  validation {
    condition     = var.exascale_vm_file_system_storage_size_gb >= 260
    error_message = "The VM file system storage size per node must be at least 260 GB."
  }
}

variable "exascale_hostname_prefix" {
  description = "Hostname prefix for the VM cluster"
  type        = string
  default     = "exadb-node"
}

variable "exascale_license_model" {
  description = "License model for the VM cluster"
  type        = string
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "exascale_scan_listener_port_tcp" {
  description = "TCP port for the scan listener"
  type        = number
  default     = 1521
}

variable "exascale_cluster_name" {
  description = "Cluster name for the VM cluster"
  type        = string
  default     = "exadb-cl1"
  validation {
    condition     = length(var.exascale_cluster_name) >= 1 && length(var.exascale_cluster_name) <= 11
    error_message = "The cluster name must be between 1 and 11 characters."
  }
}

variable "exascale_storage_vault_id" {
  description = "ID of the Exascale DB Storage Vault"
  type        = string
  default     = "exascale-db-storage-vault"
}

variable "exascale_storage_vault_display_name" {
  description = "Display name of the Exascale DB Storage Vault"
  type        = string
  default     = "Exascale DB Storage Vault"
}

variable "exascale_storage_vault_size_gb" {
  description = "Total size of the Exascale DB Storage Vault in GB"
  type        = number
  default     = 1000
}

variable "exascale_shape_attribute" {
  description = "Shape attribute for the VM cluster"
  type        = string
  default     = "BLOCK_STORAGE"
}

variable "cdb_name" {
  description = "Name of the Exadata database to be provisioned"
  type        = string
  default     = "EBSCDB"
}

variable "oci_api_version" {
  type    = string
  default = "20160918"
}

variable "exascale_deletion_protection" {
  description = "Whether to enable deletion protection for the Exascale VM cluster"
  type        = bool
  default     = true
}
