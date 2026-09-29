# JDE DEMO
resource "google_dns_managed_zone" "jde_demo_dns" {
  count      = var.oracle_jde_vision ? 1 : 0
  name       = "jde-demo-dns"
  dns_name   = "${var.project_id}.internal."
  visibility = "private"
  private_visibility_config {
    networks { network_url = module.network.network_self_link }
  }
}

locals {
  raw_jde_demo_dns_records = var.oracle_jde_vision ? {
    (var.jde_demo_prov_vm_name) = one(google_compute_address.jde_demo_prov_server_internal_ip[*].address)
    (var.jde_demo_db_vm_name)   = one(google_compute_address.jde_demo_db_server_internal_ip[*].address)
    (var.jde_demo_ent_vm_name)  = one(google_compute_address.jde_demo_ent_server_internal_ip[*].address)
    (var.jde_demo_web_vm_name)  = one(google_compute_address.jde_demo_web_server_internal_ip[*].address)
    (var.jde_demo_dep_vm_name)  = one(google_compute_address.jde_demo_dep_server_internal_ip[*].address)
  } : {}

  jde_demo_dns_records = {
    for k, v in local.raw_jde_demo_dns_records : k => v if v != null && v != ""
  }
}

# 1. Global DNS Records (Demo)
resource "google_dns_record_set" "jde_demo_server_global" {
  for_each     = local.jde_demo_dns_records
  name         = "${each.key}.c.${var.project_id}.internal."
  managed_zone = one(google_dns_managed_zone.jde_demo_dns[*].name)
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value]
}

# 2. Zonal DNS Records (Demo)
resource "google_dns_record_set" "jde_demo_server_zonal" {
  for_each     = local.jde_demo_dns_records
  name         = "${each.key}.${var.zone}.c.${var.project_id}.internal."
  managed_zone = one(google_dns_managed_zone.jde_demo_dns[*].name)
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value]
}

# JDE Customer Data
resource "google_dns_managed_zone" "jde_dns" {
  count      = var.oracle_jde_vision ? 0 : 1
  name       = "jde-dns"
  dns_name   = "${var.project_id}.internal."
  visibility = "private"
  private_visibility_config {
    networks { network_url = module.network.network_self_link }
  }
}

locals {
  raw_jde_dns_records = merge(
    (var.oracle_jde_vision ? {} : {
      (var.jde_prov_vm_name) = one(google_compute_address.jde_prov_server_internal_ip[*].address)
      (var.jde_db_vm_name)   = one(google_compute_address.jde_db_server_internal_ip[*].address)
      (var.jde_ent_vm_name)  = one(google_compute_address.jde_ent_server_internal_ip[*].address)
      (var.jde_web_vm_name)  = one(google_compute_address.jde_web_server_internal_ip[*].address)
      (var.jde_dep_vm_name)  = one(google_compute_address.jde_dep_server_internal_ip[*].address)
    }),
    (var.oracle_jde_exascale ? {
      "oracle-exascale-jde-app" = one(google_compute_address.exascale_jde_server_internal_ip[*].address)
    } : {})
  )
  jde_dns_records = {
    for k, v in local.raw_jde_dns_records : k => v if v != null && v != ""
  }
}

# 1. Global DNS Records (Customer Data)
resource "google_dns_record_set" "jde_server_global" {
  for_each     = local.jde_dns_records
  name         = "${each.key}.c.${var.project_id}.internal."
  managed_zone = one(google_dns_managed_zone.jde_dns[*].name)
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value]
}

# 2. Zonal DNS Records (Customer Data)
resource "google_dns_record_set" "jde_server_zonal" {
  for_each     = local.jde_dns_records
  name         = "${each.key}.${var.zone}.c.${var.project_id}.internal."
  managed_zone = one(google_dns_managed_zone.jde_dns[*].name)
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value]
}
