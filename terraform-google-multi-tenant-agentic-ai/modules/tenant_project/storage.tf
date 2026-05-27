# modules/tenant_project/storage.tf

resource "google_storage_bucket" "rag_bucket" {
  project                     = google_project.tenant.project_id
  name                        = "${google_project.tenant.project_id}-rag-data"
  location                    = var.region
  uniform_bucket_level_access = true

  # Prevents accidental deletion of the bucket
  lifecycle {
    prevent_destroy = true
  }

  # (Your existing lifecycle_rules would stay here)
}

resource "google_bigquery_dataset" "rag_dataset" {
  project    = google_project.tenant.project_id
  dataset_id = "rag_dataset"
  location   = var.region

  # Prevents accidental deletion of the dataset
  lifecycle {
    prevent_destroy = true
  }
}