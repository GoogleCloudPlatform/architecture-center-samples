module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "9.3.0"
  project_id   = var.project_id
  network_name = module.network.network_name

  ingress_rules = [
    {
      name          = "allow-http-in"
      description   = "Allow HTTP traffic inbound"
      source_ranges = var.trusted_ip_ranges
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["http-server"]
    },
    {
      name          = "allow-https-in"
      description   = "Allow HTTPS traffic inbound"
      source_ranges = var.trusted_ip_ranges
      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["https-server"]
    },
    {
      name        = "allow-icmp-in"
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
      name          = "allow-iap-in"
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
      name          = "allow-internal-access"
      description   = "Allow internal HTTP traffic within the VPC"
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
      name          = "allow-external-app-access"
      description   = "Allow external access to Oracle EBS Apps"
      source_ranges = var.trusted_ip_ranges
      allow = [
        {
          protocol = "tcp"
          ports    = ["8000", "4443"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["external-app-access"]
    },
    {
      name          = "allow-external-db-access"
      description   = "Allow external access to Oracle EBS DB"
      source_ranges = var.trusted_ip_ranges
      allow = [
        {
          protocol = "tcp"
          ports    = ["1521"]
        }
      ]
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      target_tags = ["external-db-access"]
    }
  ]

  egress_rules = []
}
