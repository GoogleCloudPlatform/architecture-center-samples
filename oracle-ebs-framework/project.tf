module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "18.2.0"

  project_id = var.project_id

  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  enable_apis                 = true
  disable_services_on_destroy = false
}
