resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "ebs_storage_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 8.0.1"

  name       = "${var.ebs_storage_bucket_name}-${random_id.bucket_suffix.hex}"
  project_id = var.project_id
  location   = var.region

  storage_class = "NEARLINE"
  versioning    = true
  labels        = var.labels
  force_destroy = var.force_destroy_bucket
}

resource "google_storage_bucket_iam_member" "bucket_object_admin" {
  bucket = module.ebs_storage_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.project_sa.email}"
}
