# root main.tf

# 1. The Shared Routing Hub (Centralized Security & Gateway)
module "routing_hub" {
  source             = "./modules/central_hub"
  hub_project_id     = var.hub_project_id
  hub_project_number = var.hub_project_number
  region             = var.region
  support_email      = var.support_email

  # NEW: Pass all tenants as a single map variable
  tenant_projects = {
    "marketing" = "mkt-${var.tenant_id_suffix}"
    "hr"        = "hr-${var.tenant_id_suffix}"
  }

  trusted_corporate_ip_ranges = var.trusted_corporate_ip_ranges
}

# 2. Tenant Spoke Instance: Marketing
module "tenant_marketing" {
  source      = "./modules/tenant_project"
  tenant_name = "marketing"
  tenant_id   = "mkt"
  project_id  = "mkt-${var.tenant_id_suffix}"
  # REMOVED: project_number input
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
  org_id          = var.org_id
}

# 3. Tenant Spoke Instance: HR
module "tenant_hr" {
  source      = "./modules/tenant_project"
  tenant_name = "hr"
  tenant_id   = "hr"
  project_id  = "hr-${var.tenant_id_suffix}"
  # REMOVED: project_number input
  folder_id       = var.folder_id
  billing_account = var.billing_account
  region          = var.region
  org_id          = var.org_id
}