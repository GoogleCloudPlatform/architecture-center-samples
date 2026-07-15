locals {
  service_account_prefix = "ps-project-service-account"
  ebs_apps_label         = "oracle-ebs-apps"
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
  }
}
