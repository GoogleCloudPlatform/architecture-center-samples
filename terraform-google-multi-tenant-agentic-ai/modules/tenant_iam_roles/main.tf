locals {
  tenant_custom_roles = {
    gemini_console_viewer = {
      role_id     = "GeminiConsoleViewer"
      title       = "Gemini Console Viewer"
      description = "Functional read-only dashboard access for monitoring agent health and logs."
      permissions = [
        "resourcemanager.projects.get",
        "serviceusage.services.list",
        "run.services.list",
        "run.services.get",
        "run.locations.list",
        "run.revisions.list",
        "logging.logEntries.list",
        "monitoring.dashboards.list",
        "monitoring.timeSeries.list"
      ]
    }
    gemini_data_steward = {
      role_id     = "GeminiDataSteward"
      title       = "Gemini Data Steward"
      description = "Access to BigQuery and GCS for managing tenant-specific RAG data."
      permissions = [
        "bigquery.datasets.get",
        "bigquery.tables.list",
        "bigquery.tables.getData",
        "storage.buckets.list",
        "storage.objects.list",
        "storage.objects.get"
      ]
    }
    gemini_agent_builder = {
      role_id     = "GeminiAgentBuilder"
      title       = "Gemini Agent Builder"
      description = "Deploy and manage Cloud Run services; blocked from IAM changes."
      permissions = [
        "run.services.create",
        "run.services.get",
        "run.services.list",
        "run.services.update",
        "run.services.delete",
        "run.configurations.get",
        "run.revisions.list"
      ]
    }
    gemini_app_user = {
      role_id     = "GeminiAppUser"
      title       = "Gemini App User"
      description = "Allows invoking the Cloud Run agent service."
      permissions = [
        "run.routes.invoke"
      ]
    }
  }
}

# Creates all custom roles defined in the locals map dynamically
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = local.tenant_custom_roles

  project     = var.project_id
  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
}