# modules/tenant_project/iam.tf

# =============================================================================
# 1. Principal Access Boundary (PAB)
# =============================================================================
resource "google_iam_principal_access_boundary_policy" "tenant_isolation" {
  organization  = var.org_id
  location      = "global"
  pab_policy_id = "${var.tenant_id}-isolation-policy"
  display_name  = "Isolation Policy for ${var.tenant_name}"

  rules {
    description = "Restrict ${var.tenant_name} Agent identity to its own project resources"
    effect      = "ALLOW"
    # Directly references the project resource created in this module
    resources = ["cloudresourcemanager.googleapis.com/projects/${google_project.tenant.number}"]
  }
}

resource "google_iam_principal_access_boundary_policy_binding" "agent_pab_binding" {
  organization = var.org_id
  location     = "global"
  pab_policy   = google_iam_principal_access_boundary_policy.tenant_isolation.id
  principal    = "serviceAccount:${google_service_account.agent_sa.email}"
}

# =============================================================================
# 2. Model Armor & SCC Roles (Dynamic Block)
# =============================================================================
resource "google_project_iam_member" "agent_sa_roles" {
  for_each = var.agent_sa_project_roles

  project = google_project.tenant.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}

# =============================================================================
# 3. Resource-Level User IAM (Dynamic Block)
# =============================================================================
resource "google_cloud_run_v2_service_iam_member" "cloud_run_users" {
  for_each = var.cloud_run_iam_bindings

  project  = google_project.tenant.project_id
  location = var.region
  name     = google_cloud_run_v2_service.agent.name
  role     = each.value.role
  member   = each.value.member
}