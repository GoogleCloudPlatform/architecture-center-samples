resource "google_cloud_run_v2_service" "frontend_portal" {
  name     = "frontend-portal"
  location = var.region
  project  = var.hub_project_id

  template {
    service_account = google_service_account.hub_sa.email
    containers {
      image = "${var.frontend_image_name}:${var.frontend_image_tag}"
    }
  }
}