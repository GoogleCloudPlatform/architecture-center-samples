# modules/tenant_project/ai_security.tf

# Define the Model Armor Template for the Tenant
resource "google_model_armor_template" "tenant_filter" {
  provider    = google-beta
  project     = google_project.tenant.project_id
  location    = var.region
  template_id = "${var.tenant_id}-security-filter"

  content_filter_config {
    # Filters out PII and Malicious prompts before they reach the LLM
    pii_config {
      pii_entities = ["EMAIL_ADDRESS", "PHONE_NUMBER", "STREET_ADDRESS"]
      mode         = "BLOCK"
    }

    jailbreak_config {
      mode = "BLOCK"
    }
  }

  depends_on = [google_project_service.apis]
}