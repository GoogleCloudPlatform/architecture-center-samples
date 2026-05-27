# modules/tenant_project/main.tf

# 1. Create the Project
resource "google_project" "tenant" {
  name            = "Tenant-${var.tenant_name}"
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

# 2. Inject the Security Roles (Calls your other module)
module "tenant_roles" {
  source     = "../tenant_iam_roles"
  project_id = google_project.tenant.project_id
}
