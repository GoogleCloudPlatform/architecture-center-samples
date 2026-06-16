# In your variables.tf (or equivalent file):

variable "support_email" {
  description = "The support email associated with the IAP brand."
  type        = string
}

# ----------------------------------------------------------------------

# In your main resources file:

resource "google_iap_brand" "project_brand" {
  project           = var.hub_project_id
  support_email     = var.support_email
  application_title = "Multi-Tenant AI Portal"
}

resource "google_iap_client" "project_client" {
  display_name = "Frontend Portal Client"
  brand        = google_iap_brand.project_brand.name
}