# modules/tenant_iam_roles/main.tf

# Creates all custom roles defined in the locals map dynamically
resource "google_project_iam_custom_role" "custom_roles" {
  for_each    = local.tenant_custom_roles
  
  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
}