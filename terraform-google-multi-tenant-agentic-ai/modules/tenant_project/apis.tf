# modules/tenant_project/apis.tf

resource "google_project_service" "apis" {
  for_each = toset(var.enabled_apis)

  project            = google_project.tenant.project_id
  service            = each.key
  disable_on_destroy = false
}