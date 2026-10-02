# Set Region and Zone
terraform_version    = "1.6.6"
region               = "northamerica-northeast2"
zone                 = "northamerica-northeast2-a"
force_destroy_bucket = true

# Adjust subnet region and IP CIDR range
subnets = [{
  subnet_name           = "oracle-jde-toolkit-subnet-01"
  subnet_region         = "northamerica-northeast2"
  subnet_ip             = "10.115.0.0/20"
  subnet_private_access = true
  subnet_flow_logs      = true
}]

## JDE DEMO config
# JD Edwards EnterpriseOne DEMO Provisioning Server jde_demo_prov
jde_demo_prov_vm_name               = "jde-demo-prov"
jde_demo_prov_server_internal_ip    = "10.115.0.40"
jde_demo_prov_machine_type          = "e2-highmem-2"
jde_demo_prov_boot_disk_size        = 200
jde_demo_prov_boot_disk_type        = "pd-ssd"
jde_demo_prov_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne DEMO Database Server Configuration jde_demo_db
jde_demo_db_vm_name               = "jde-demo-db"
jde_demo_db_server_internal_ip    = "10.115.0.41"
jde_demo_db_machine_type          = "e2-highmem-4"
jde_demo_db_boot_disk_size        = 200
jde_demo_db_boot_disk_type        = "pd-ssd"
jde_demo_db_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne DEMO Enterprise Server Configuration jde_demo_ent
jde_demo_ent_vm_name               = "jde-demo-ent"
jde_demo_ent_server_internal_ip    = "10.115.0.42"
jde_demo_ent_machine_type          = "e2-highmem-2"
jde_demo_ent_boot_disk_size        = 200
jde_demo_ent_boot_disk_type        = "pd-ssd"
jde_demo_ent_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne DEMO Web Server Configuration jde_demo_web
jde_demo_web_vm_name               = "jde-demo-web"
jde_demo_web_server_internal_ip    = "10.115.0.43"
jde_demo_web_machine_type          = "e2-highmem-2"
jde_demo_web_boot_disk_size        = 200
jde_demo_web_boot_disk_type        = "pd-ssd"
jde_demo_web_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne DEMO Deployment Server Configuration jde_demo_dep
jde_demo_dep_vm_name               = "jde-demo-dep"
jde_demo_dep_server_internal_ip    = "10.115.0.44"
jde_demo_dep_machine_type          = "e2-highmem-2"
jde_demo_dep_boot_disk_size        = 300
jde_demo_dep_boot_disk_type        = "pd-ssd"
jde_demo_dep_boot_disk_auto_delete = true

## JDE Customer Data config
#
# JD Edwards EnterpriseOne Provisioning Server jde_prov - customer data
jde_prov_vm_name               = "jde-prov"
jde_prov_server_internal_ip    = "10.115.1.40"
jde_prov_machine_type          = "e2-highmem-2"
jde_prov_boot_disk_size        = 200
jde_prov_boot_disk_type        = "pd-ssd"
jde_prov_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne Database Server Configuration jde_db - customer data
jde_db_vm_name               = "jde-db"
jde_db_server_internal_ip    = "10.115.1.41"
jde_db_machine_type          = "e2-highmem-4"
jde_db_boot_disk_size        = 1000
jde_db_boot_disk_type        = "pd-ssd"
jde_db_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne Enterprise Server Configuration jde_ent - customer data
jde_ent_vm_name               = "jde-ent"
jde_ent_server_internal_ip    = "10.115.1.42"
jde_ent_machine_type          = "e2-highmem-2"
jde_ent_boot_disk_size        = 200
jde_ent_boot_disk_type        = "pd-ssd"
jde_ent_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne Web Server Configuration jde_web - customer data
jde_web_vm_name               = "jde-web"
jde_web_server_internal_ip    = "10.115.1.43"
jde_web_machine_type          = "e2-highmem-2"
jde_web_boot_disk_size        = 200
jde_web_boot_disk_type        = "pd-ssd"
jde_web_boot_disk_auto_delete = true

# JD Edwards EnterpriseOne Deployment Server Configuration jde_dep - customer data
jde_dep_vm_name               = "jde-dep"
jde_dep_server_internal_ip    = "10.115.1.44"
jde_dep_machine_type          = "e2-highmem-2"
jde_dep_boot_disk_size        = 300
jde_dep_boot_disk_type        = "pd-ssd"
jde_dep_boot_disk_auto_delete = true

# Trusted IP Ranges for External access
trusted_ip_ranges = [] # Please provide your own trusted IP ranges. Example -   trusted_ip_ranges = ["203.0.113.0/24", "198.51.100.0/24"]

# ===========================================================================
# ExaScale (Oracle Database@Google Cloud) - added for JDE on ExaScale
# ===========================================================================

# --- ExaScale application VM (app tier only; DB lives on Exadata) ---
exascale_jde_server_internal_ip    = "10.115.0.50"
exascale_jde_machine_type          = "e2-highmem-8"
exascale_jde_boot_disk_type        = "pd-balanced"
exascale_jde_boot_disk_size        = 512
exascale_jde_boot_disk_auto_delete = true

# --- ExaScale / Oracle Database@Google Cloud ---
exascale_location           = "northamerica-northeast2"
exascale_client_subnet_cidr = "10.116.0.0/20"
exascale_backup_subnet_cidr = "10.116.128.0/20"
cdb_name                    = "JDECDB"
