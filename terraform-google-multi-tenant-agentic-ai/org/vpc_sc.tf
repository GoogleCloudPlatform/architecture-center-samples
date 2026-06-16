# Create one single Macro-Perimeter for the entire platform (Hub + All Spokes)
resource "google_access_context_manager_service_perimeter" "platform_macro_perimeter" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/agent_factory_macro_boundary"
  title  = "Agent Factory Macro Perimeter"

  status {
    # Combine the Hub project and all Tenant Spoke project numbers
    resources = concat(
      ["projects/${var.hub_project_number}"],
      [for p_num in var.tenant_project_numbers : "projects/${p_num}"]
    )

    # These are the services we are protecting from data exfiltration
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com",
      "aiplatform.googleapis.com",      # Vertex AI
      "discoveryengine.googleapis.com", # Vertex AI Search
      "logging.googleapis.com"
    ]

    # IMPORTANT: We no longer need "Bridges" or "VPC-SC Peerings" 
    # because every project is now inside the same perimeter.
  }
}
