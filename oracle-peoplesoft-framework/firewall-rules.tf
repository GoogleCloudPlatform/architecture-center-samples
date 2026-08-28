module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "18.1.2"
  project_id   = var.project_id
  network_name = module.network.network_name

  ingress_rules = [
    {
      name        = "ps-allow-icmp-in"
      description = "Allow ICMP traffic inbound"
      source_ranges = [
        var.iap_cidr
      ]
      allow = [
        {
          protocol = "icmp"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["icmp-access"]
    },
    {
      name          = "ps-allow-iap-in"
      description   = "Allow IAP traffic inbound"
      source_ranges = [var.iap_cidr]
      allow = [
        {
          protocol = "tcp"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["iap-access"]
    },
    {
      name          = "ps-allow-internal-access"
      description   = "Allow internal traffic within the VPC"
      source_ranges = [values(module.network.subnets)[0].ip_cidr_range]
      allow = [
        {
          protocol = "tcp"
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["internal-access"]
    },
    {
      name        = "ps-allow-nfs-internal"
      description = "Allow NFS (2049) only from internal VPC and ODB network CIDRs"
      source_ranges = [
        values(module.network.subnets)[0].ip_cidr_range,
        var.exascale_client_subnet_cidr,
        var.exascale_backup_subnet_cidr,
      ]
      allow = [
        {
          protocol = "tcp"
          ports    = ["2049"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["external-app-access"]
    }
  ]

  egress_rules = []
}
