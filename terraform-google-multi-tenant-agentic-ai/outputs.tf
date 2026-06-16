# root outputs.tf

# --- 1. Hub & Gateway Info (For Connectivity Tracking) ---
output "hub_gateway_url" {
  description = "The External Load Balancer URL for the Central Routing Hub"
  value       = module.routing_hub.gateway_url
}

# --- 2. Tenant Project IDs (For DevRel Revenue Attribution) ---
output "tenant_projects" {
  description = "The Project IDs generated for each business unit"
  value = {
    marketing = module.tenant_marketing.project_id
    hr        = module.tenant_hr.project_id
  }
}

# --- 3. Security Identities (For Audit & PAB Verification) ---
output "agent_identities" {
  description = "The Service Accounts assigned to each Agent (used for PAB & ACLs)"
  value = {
    marketing_agent = module.tenant_marketing.agent_service_account_email
    hr_agent        = module.tenant_hr.agent_service_account_email
  }
}

# --- 4. Perimeter Status ---
output "vpc_sc_perimeter_name" {
  description = "The name of the Macro-Perimeter protecting the platform"
  value       = google_access_context_manager_service_perimeter.platform_macro_perimeter.name
}
