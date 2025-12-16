resource "google_service_account" "project_sa" {
  account_id   = "project-service-account"
  display_name = "Project Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "project_sa_roles" {
  for_each = toset(var.project_service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.project_sa.email}"
}
