locals {
  is_standard_ebs        = !var.oracle_ebs_vision && !var.oracle_ebs_exascale
  is_vision_gce          = var.oracle_ebs_vision && !var.oracle_ebs_exascale
  is_vision_exa          = var.oracle_ebs_exascale
  service_account_prefix = "project-service-account"
  ebs_apps_label         = "oracle-ebs-apps"
  ebs_db_label           = "oracle-ebs-db"
  vision_label           = "oracle-ebs-vision"
  exascale_label         = "oracle-exascale-db"
  vm_network_tags = {
    app = [
      "http-server",
      "https-server",
      "lb-health-check",
      "oracle-ebs-apps",
      "iap-access",
      "icmp-access",
      "egress-nat",
      "internal-access",
      "external-db-access"
    ]

    db = [
      "http-server",
      "https-server",
      "lb-health-check",
      "oracle-ebs-apps",
      "iap-access",
      "icmp-access",
      "egress-nat",
      "internal-access",
      "external-db-access"
    ]

    vision = [
      "http-server",
      "https-server",
      "lb-health-check",
      "oracle-ebs-apps",
      "iap-access",
      "icmp-access",
      "egress-nat",
      "internal-access",
      "external-db-access"
    ]

    exascale = [
      "http-server",
      "https-server",
      "lb-health-check",
      "oracle-ebs-apps",
      "iap-access",
      "icmp-access",
      "egress-nat",
      "internal-access",
      "external-db-access"
    ]
  }
}
