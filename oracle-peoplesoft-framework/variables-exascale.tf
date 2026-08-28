# ---------------------------------------------------------------------------
# Vars for ExaScale (PeopleSoft)
# Ported from oracle-ebs-framework/variables.tf, EBS names -> PeopleSoft.
# "ps-" prefixes avoid collisions because PeopleSoft shares the EBS GCP project.
# ---------------------------------------------------------------------------

variable "oracle_peoplesoft_exascale" {
  description = "Whether to deploy the Oracle PeopleSoft ExaScale environment"
  type        = bool
  default     = false
}

variable "odb_subnet_id" {
  description = "The name of the subnet to be used for the ODB network"
  type        = string
  default     = "oracle-peoplesoft-toolkit-odb-subnet"
}

variable "odb_subnet_cidr" {
  description = "The CIDR range for the ODB subnet"
  type        = string
  default     = "10.116.0.0/20"
}

variable "exascale_location" {
  description = "Region for the ExaScale environment. Must be a region where Oracle Database@Google Cloud is available."
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
  default     = "ps-exadb-vm-cluster-01"
}

variable "exadb_display_name" {
  description = "Display name of the Exadata VM Cluster"
  type        = string
  default     = "PeopleSoft Exadata VM Cluster"
}

variable "exadata_infrastructure_id" {
  description = "ID of the Exadata infrastructure to use for the VM cluster"
  type        = string
  default     = "ps-exadata-infrastructure-01"
}

variable "exascale_time_zone" {
  description = "Time zone for the VM cluster"
  type        = string
  default     = "UTC"
}

variable "exascale_grid_image_id" {
  description = "Grid image ID for the VM cluster (supplied by the Makefile via fetch_grid_image_id)"
  type        = string
  default     = ""
}

variable "exascale_grid_version" {
  description = "GI/grid version string, e.g. 19.32.0.0.0, supplied by the Makefile. The dbHome dbVersion is derived from this so no version is hardcoded."
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
  default     = "psft-node"
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
  description = "Cluster name for the VM cluster (max 11 characters)"
  type        = string
  default     = "psftcl1"
  validation {
    condition     = length(var.exascale_cluster_name) >= 1 && length(var.exascale_cluster_name) <= 11
    error_message = "The cluster name must be between 1 and 11 characters."
  }
}

variable "exascale_storage_vault_id" {
  description = "ID of the ExaScale DB Storage Vault"
  type        = string
  default     = "ps-exascale-db-storage-vault"
}

variable "exascale_storage_vault_display_name" {
  description = "Display name of the ExaScale DB Storage Vault"
  type        = string
  default     = "PeopleSoft Exascale DB Storage Vault"
}

variable "exascale_storage_vault_size_gb" {
  description = "Total size of the ExaScale DB Storage Vault in GB"
  type        = number
  default     = 1000
}

variable "exascale_shape_attribute" {
  description = "Shape attribute for the VM cluster"
  type        = string
  default     = "BLOCK_STORAGE"
}

variable "cdb_name" {
  description = "Name of the Exadata container database to be provisioned"
  type        = string
  default     = "PSFTCDB"
}

variable "oci_api_version" {
  description = "OCI REST API version used by the local-exec provisioners"
  type        = string
  default     = "20160918"
}

variable "exascale_deletion_protection" {
  description = "Whether to enable deletion protection for the ExaScale VM cluster"
  type        = bool
  default     = true
}

# --- ExaScale application VM (app tier only; DB lives on Exadata) ---

variable "exascale_peoplesoft_server_internal_ip" {
  description = "Reserved internal IP for the ExaScale PeopleSoft application VM"
  type        = string
  default     = "10.115.0.40"
}

variable "exascale_apps_machine_type" {
  description = "Machine type for the ExaScale PeopleSoft application VM"
  type        = string
  default     = "e2-highmem-8"
}

variable "exascale_apps_boot_disk_size" {
  description = "Boot disk size (GB) for the ExaScale PeopleSoft application VM"
  type        = number
  default     = 512
}

variable "exascale_apps_boot_disk_type" {
  description = "Boot disk type for the ExaScale PeopleSoft application VM"
  type        = string
  default     = "pd-balanced"
}

variable "exascale_apps_boot_disk_auto_delete" {
  description = "Whether the ExaScale application VM boot disk is auto-deleted"
  type        = bool
  default     = true
}
