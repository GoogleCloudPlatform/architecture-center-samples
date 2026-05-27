resource "google_cloud_run_v2_service" "frontend_portal" {
  name     = "frontend-portal"
  location = var.region
  project  = var.hub_project_id

  template {
    containers {
      image = local.frontend_container_image
    }
  }
}