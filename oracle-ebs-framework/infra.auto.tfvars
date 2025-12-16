# Set Region and Zone
terraform_version = "1.6.6"
region            = "us-central1"
zone              = "us-central1-a"

# Adjust subnet region and IP CIDR range
subnets = [{
  subnet_name           = "oracle-ebs-toolkit-subnet-01"
  subnet_region         = "us-central1"
  subnet_ip             = "10.115.0.0/20"
  subnet_private_access = true
  subnet_flow_logs      = true
}]

# EBS Apps VM Configuration
ebs_apps_server_internal_ip = "10.115.0.20"
apps_machine_type           = "e2-standard-4"
apps_boot_disk_type         = "pd-balanced"
apps_boot_disk_size         = 512
apps_boot_disk_auto_delete  = true

# EBS DB VM Configuration
ebs_db_server_internal_ip = "10.115.0.25"
dbs_machine_type          = "e2-standard-8"
dbs_boot_disk_type        = "pd-balanced"
dbs_boot_disk_size        = 1024
dbs_boot_disk_auto_delete = true

# Vision VM Configuration
vision_server_internal_ip    = "10.115.0.30"
vision_machine_type          = "e2-standard-8"
vision_boot_disk_size        = 1024
vision_boot_disk_type        = "pd-balanced"
vision_boot_disk_auto_delete = true

# Trusted IP Ranges for External access | Replace with actual trusted IP ranges
trusted_ip_ranges = ["203.0.113.0/24", "198.51.100.0/24"]
