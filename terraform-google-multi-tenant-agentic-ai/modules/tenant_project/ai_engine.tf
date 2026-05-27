# modules/tenant_project/ai_engine.tf

# 1. Vertex AI Data Store (for RAG)
resource "google_discovery_engine_data_store" "tenant_ds" {
  project           = google_project.tenant.project_id
  location          = "global"
  data_store_id     = "${var.tenant_name}-knowledge-base"
  display_name      = "Knowledge Base for ${var.tenant_name}"
  industry_vertical = "GENERIC"
  content_config    = "CONTENT_REQUIRED"
  solution_types    = ["SOLUTION_TYPE_SEARCH"]
}

# 2. Vertex AI Search Engine
resource "google_discovery_engine_search_engine" "tenant_engine" {
  project        = google_project.tenant.project_id
  location       = google_discovery_engine_data_store.tenant_ds.location
  engine_id      = "${var.tenant_name}-search-engine"
  collection_id  = "default_collection"
  data_store_ids = [google_discovery_engine_data_store.tenant_ds.data_store_id]
  display_name   = "Search Engine for ${var.tenant_name}"

  common_config {
    company_name = var.tenant_name
  }
}

# 3. Agent Access to Data Store
resource "google_project_iam_member" "agent_search_user" {
  project = google_project.tenant.project_id
  role    = "roles/discoveryengine.viewer"
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}
