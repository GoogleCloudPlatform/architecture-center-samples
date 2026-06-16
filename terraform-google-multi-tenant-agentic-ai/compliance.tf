# compliance.tf (Root Directory)

# Group all instantiated tenant project IDs into a single list
locals {
  tenant_project_ids = [
    module.tenant_marketing.project_id,
    module.tenant_hr.project_id
  ]
}

# Dynamically fetch the IAM policy for every tenant project in the list
data "google_project_iam_policy" "tenant_checks" {
  for_each = toset(local.tenant_project_ids)
  project  = each.value
}

# =============================================================================
# SECURITY GUARDRAIL: IAM Resource Isolation Enforcement
# Validates that sensitive service roles are scoped to specific resources 
# rather than the project level to maintain Multi-Tenant Hard Isolation.
# =============================================================================

check "iam_resource_scoped_enforcement" {
  assert {
    # Flattens all bindings from all projects into a single list and checks for the role
    condition = !anytrue(flatten([
      for policy in data.google_project_iam_policy.tenant_checks : [
        for binding in policy.bindings : binding.role == "roles/run.invoker"
      ]
    ]))

    error_message = <<EOT
      Access Control Violation: 'roles/run.invoker' detected at the Project level.
      This violates the Multi-Tenant Isolation Architecture. 
      All service invocation permissions must be scoped to specific Cloud Run 
      service resources in the tenant module.
    EOT
  }
}