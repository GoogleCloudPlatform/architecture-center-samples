resource "google_service_account" "hub_sa" {
  project      = var.hub_project_id
  account_id   = "central-hub-sa"
  display_name = "Central Hub Service Account"
}

# Dynamically grants Hub access to ALL tenant Cloud Run services passed into the module
resource "google_cloud_run_v2_service_iam_member" "tenant_agent_invoker" {
  for_each = var.tenant_projects

  project  = each.value
  location = var.region

  # Constructs the service name dynamically (e.g., "marketing-agent", "hr-agent")
  # using the key from the map
  name = "${each.key}-agent"
  role = "roles/run.invoker"

  member = "serviceAccount:${google_service_account.hub_sa.email}"
}