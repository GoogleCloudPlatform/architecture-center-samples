# modules/tenant_project/outputs.tf

# 1. Project ID (Used by the root compliance.tf for security auditing)
output "project_id" {
  description = "The GCP Project ID for the tenant spoke"
  value       = google_project.tenant.project_id
}

# 2. Agent Runtime URL (Used by the Hub/Load Balancer for routing)
output "agent_url" {
  description = "The URI of the Cloud Run Agent service"
  value       = google_cloud_run_v2_service.agent.uri
}

# 3. Security Identity (Used by root outputs for PAB & ACL verification)
output "agent_service_account_email" {
  description = "The email of the isolated Service Account for this tenant agent"
  value       = google_service_account.agent_sa.email
}

# 4. Model Armor Template (Used for verifying AI Safety configuration)
output "model_armor_template_id" {
  description = "The ID of the Model Armor security filter"
  value       = google_model_armor_template.tenant_filter.id
}

output "project_number" {
  description = "The numeric Google Cloud Project Number for the tenant."
  value       = google_project.tenant.number
}