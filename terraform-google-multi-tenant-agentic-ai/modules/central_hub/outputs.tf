# modules/central_hub/outputs.tf

output "gateway_url" {
  description = "The public IP address (URL) of the central routing hub's load balancer."
  # We format the raw IP address into a clickable HTTP URL
  value = "http://${google_compute_global_forwarding_rule.frontend_forwarding_rule.ip_address}"
}