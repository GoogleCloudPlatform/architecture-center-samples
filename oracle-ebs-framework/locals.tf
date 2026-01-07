locals {
  ebs_apps_label = "oracle-ebs-apps"
  ebs_db_label   = "oracle-ebs-db"
  vision_label   = "oracle-ebs-vision"

  common_tags = toset([
    "lb-health-check",
    "iap-access",
    "icmp-access",
    "egress-nat",
    "internal-access",
  ])

  vm_network_tags = {
    app = toset(concat(tolist(local.common_tags), [
      "http-server",
      "https-server",
      local.ebs_apps_label,
      "external-app-access",
    ]))

    db = toset(concat(tolist(local.common_tags), [
      local.ebs_db_label,
      "external-db-access"
    ]))

    vision = toset(concat(tolist(local.common_tags), [
      "http-server",
      "https-server",
      local.ebs_apps_label,
      "external-app-access",
      "external-db-access"
    ]))
  }
}
