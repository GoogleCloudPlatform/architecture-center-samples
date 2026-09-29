module "network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 18.1"
  project_id                             = var.project_id
  network_name                           = var.network_name
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  routing_mode                           = var.routing_mode
  auto_create_subnetworks                = var.auto_create_subnetworks

  subnets = var.subnets
}

module "nat_gateway_route" {
  source  = "terraform-google-modules/network/google//modules/routes"
  version = "~> 18.1"

  project_id   = var.project_id
  network_name = module.network.network_name

  routes = [
    {
      name              = "nat-jde-egress-internet"
      description       = "Public NAT GW - route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = ["egress-nat"]
      next_hop_internet = "true"
    }
  ]

  depends_on = [module.network]
}

locals {
  nat_ip_names = [for nat in var.nat_config : nat.name]
}

resource "google_compute_address" "nat_ip" {
  for_each = toset(local.nat_ip_names)

  name         = each.value
  region       = var.region
  address_type = "EXTERNAL"
}

locals {
  nat_config = [
    for nat in var.nat_config : merge(nat, {
      nat_ip_allocate_option = contains(keys(google_compute_address.nat_ip), nat.name) ? "MANUAL_ONLY" : nat.nat_ip_allocate_option,
      nat_ips                = contains(keys(google_compute_address.nat_ip), nat.name) ? [google_compute_address.nat_ip[nat.name].id] : []
    })
  ]
}

module "cloud_router" {
  source     = "terraform-google-modules/cloud-router/google"
  version    = "~> 9.0"
  project_id = var.project_id

  name    = "${var.network_name}-cloud-router"
  network = module.network.network_name
  region  = var.region

  nats = var.enable_nat_gateway ? local.nat_config : []

  depends_on = [module.network, google_compute_address.nat_ip]
}

# JDE DEMO
resource "google_compute_address" "jde_demo_prov_server_internal_ip" {
  count        = var.oracle_jde_vision ? 1 : 0
  name         = "jde-demo-prov-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_demo_prov_server_internal_ip
}

resource "google_compute_address" "jde_demo_db_server_internal_ip" {
  count        = var.oracle_jde_vision ? 1 : 0
  name         = "jde-demo-db-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_demo_db_server_internal_ip
}

resource "google_compute_address" "jde_demo_ent_server_internal_ip" {
  count        = var.oracle_jde_vision ? 1 : 0
  name         = "jde-demo-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_demo_ent_server_internal_ip
}

resource "google_compute_address" "jde_demo_web_server_internal_ip" {
  count        = var.oracle_jde_vision ? 1 : 0
  name         = "jde-demo-web-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_demo_web_server_internal_ip
}

resource "google_compute_address" "jde_demo_dep_server_internal_ip" {
  count        = var.oracle_jde_vision ? 1 : 0
  name         = "jde-demo-dep-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_demo_dep_server_internal_ip
}


# JDE Customer Data
resource "google_compute_address" "jde_prov_server_internal_ip" {
  count        = var.oracle_jde_vision ? 0 : 1
  name         = "jde-prov-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_prov_server_internal_ip
}

resource "google_compute_address" "jde_db_server_internal_ip" {
  count        = var.oracle_jde_vision ? 0 : (var.oracle_jde_exascale ? 0 : 1)
  name         = "jde-db-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_db_server_internal_ip
}

resource "google_compute_address" "jde_web_server_internal_ip" {
  count        = var.oracle_jde_vision ? 0 : 1
  name         = "jde-web-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_web_server_internal_ip
}

resource "google_compute_address" "jde_dep_server_internal_ip" {
  count        = var.oracle_jde_vision ? 0 : 1
  name         = "jde-dep-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.jde_dep_server_internal_ip
}

resource "google_compute_address" "jde_ent_server_internal_ip" {
  count        = var.oracle_jde_vision ? 0 : 1
  name         = "jde-ent-server-internal-ip"
  subnetwork   = values(module.network.subnets)[0].name
  address_type = "INTERNAL"
  region       = var.region
  address      = var.jde_ent_server_internal_ip
}
