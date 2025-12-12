locals {
  service_account_prefix = "project-service-account"
  ebs_apps_label         = "oracle-ebs-apps"
  ebs_db_label           = "oracle-ebs-db"
  vision_label           = "oracle-ebs-vision"
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
  }
}
