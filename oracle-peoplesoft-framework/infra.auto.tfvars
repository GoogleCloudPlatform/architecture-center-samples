# Set Region and Zone
terraform_version = "1.6.6"
region            = "northamerica-northeast2"
zone              = "northamerica-northeast2-a"

# Adjust subnet region and IP CIDR range
subnets = [{
  subnet_name           = "oracle-peoplesoft-toolkit-subnet-01"
  subnet_region         = "northamerica-northeast2"
  subnet_ip             = "10.115.0.0/20"
  subnet_private_access = true
  subnet_flow_logs      = true
}]


# peoplesoft Apps VM Configuration
peoplesoft_apps_server_internal_ip = "10.115.0.20"
apps_machine_type                  = "e2-highmem-8"
apps_boot_disk_type                = "pd-balanced"
apps_boot_disk_size                = 512
apps_boot_disk_auto_delete         = true

# ===========================================================================
# ExaScale (Oracle Database@Google Cloud) - added for PeopleSoft on ExaScale
# ===========================================================================

# --- ExaScale application VM (app tier only; DB lives on Exadata) ---
exascale_peoplesoft_server_internal_ip = "10.115.0.40"
exascale_apps_machine_type             = "e2-highmem-8"
exascale_apps_boot_disk_type           = "pd-balanced"
exascale_apps_boot_disk_size           = 512
exascale_apps_boot_disk_auto_delete    = true

# --- ExaScale / Oracle Database@Google Cloud ---
exascale_location           = "northamerica-northeast2"
exascale_client_subnet_cidr = "10.116.0.0/20"
exascale_backup_subnet_cidr = "10.116.128.0/20"
cdb_name                    = "PSFTCDB"
