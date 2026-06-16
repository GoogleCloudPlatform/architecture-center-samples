resource "google_compute_global_address" "lb_ip" {
  name    = "central-hub-lb-ip"
  project = var.hub_project_id
}
