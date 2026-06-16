# modules/tenant_project/run.tf

resource "google_service_account" "agent_sa" {
  project = google_project.tenant.project_id
  # Dynamically prefixes the service account ID with the tenant ID
  account_id = "${var.tenant_id}-agent-runtime-sa"
  # Adds the full tenant name to the display name for easier UI readability
  display_name = "Agent Runtime SA for ${var.tenant_name}"
}

resource "google_cloud_run_v2_service" "agent" {
  name     = "${var.tenant_name}-agent"
  location = var.region
  project  = google_project.tenant.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      # Leverages the dynamic local variable
      image = local.agent_container_image
      env {
        name  = "MODEL_ARMOR_TEMPLATE"
        value = google_model_armor_template.tenant_filter.id
      }
    }
  }
  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "mcp_server" {
  name     = "${var.tenant_name}-mcp-server"
  location = var.region
  project  = google_project.tenant.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.agent_sa.email
    containers {
      # Leverages the dynamic local variable
      image = local.mcp_server_container_image
      env {
        name  = "DATASET_ID"
        value = google_bigquery_dataset.rag_dataset.dataset_id
      }
    }
  }
  depends_on = [google_project_service.apis]
}