# providers.tf

provider "google" {
  # You can default to the hub project, or remove this and explicitly pass it in resources
  project = var.hub_project_id
  region  = var.region
}

provider "google-beta" {
  project = var.hub_project_id
  region  = var.region
}