locals {
  # ===========================================================================
  # 1. Container Images
  # ===========================================================================
  # Concatenates the image names and tags dynamically
  agent_container_image      = "${var.agent_image_name}:${var.agent_image_tag}"
  mcp_server_container_image = "${var.mcp_server_image_name}:${var.mcp_server_image_tag}"
  frontend_container_image   = "${var.frontend_image_name}:${var.frontend_image_tag}"

  # ===========================================================================
  # 2. Custom IAM Roles
  # ===========================================================================
  # A map of objects defining the custom IAM roles to be created
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

  # ===========================================================================
  # 3. WAF & Threat Intelligence Rules
  # ===========================================================================
  # Grouping WAF and Threat Intelligence rules to keep the code DRY
  waf_expression_rules = {
    bot-protection = {
      action      = "deny(403)"
      priority    = 500
      expression  = "evaluatePreconfiguredExpr('botman-stable')"
      description = "WAF: Block known botnets and scanners"
    }
    sqli-protection = {
      action      = "deny(403)"
      priority    = 1000
      expression  = "evaluatePreconfiguredWaf('sqli-stable', {'sensitivity': 1})"
      description = "WAF: Block SQL Injection"
    }
    xss-protection = {
      action      = "deny(403)"
      priority    = 1010
      expression  = "evaluatePreconfiguredWaf('xss-stable', {'sensitivity': 1})"
      description = "WAF: Block XSS"
    }
    # Future rules (like LFI, RCE, etc.) can simply be added to this map
  }
}