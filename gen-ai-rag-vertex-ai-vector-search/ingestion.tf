# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Ingest bucket

resource "google_storage_bucket" "ingest" {
  name     = "ingest-${local.unique_str}"

  # Design consideration: Data availability
  location = var.region
}

## Pub/Sub to trigger ingestion job

resource "google_pubsub_topic" "ingest" {
  name = "ingest-${local.unique_str}"

  ingestion_data_source_settings {
    cloud_storage {
      bucket = google_storage_bucket.ingest.name
    }
  }
}

# Allow the Pub/Sub service account the ability to publish messages
resource "google_project_iam_member" "pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"

  depends_on = [module.project_services]
}

# Allow the Pub/Sub service account permissions to access the bucket
resource "google_storage_bucket_iam_member" "pubsub" {
  bucket = google_storage_bucket.ingest.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"

  depends_on = [module.project_services]
}

resource "google_pubsub_subscription" "ingest-processing" {
  name  = "ingest-processing-${local.unique_str}"
  topic = google_pubsub_topic.ingest.name

  push_config {
    # Trigger a Cloud Run job via the Cloud Run REST API
    # https://cloud.google.com/run/docs/execute/jobs#rest-api
    push_endpoint = "https://run.googleapis.com/v2/projects/${google_cloud_run_v2_job.ingest_job.project}/locations/${google_cloud_run_v2_job.ingest_job.location}/jobs/${google_cloud_run_v2_job.ingest_job.name}:run"

    oidc_token {
      service_account_email = "${data.google_project.default.project_id}-compute@developer.gserviceaccount.com"
    }
  }

  # Design Consideration: Failure handling
  retry_policy {
    minimum_backoff = "10s"
  }

  depends_on = [google_storage_bucket_iam_member.pubsub]
}

## Ingest Job

resource "google_cloud_run_v2_job" "ingest_job" {
  name     = "ingest-job"
  location = "us-central1"

  template {
    template {
      containers {
        # Note: Replace with ingestion job container
        image = "us-docker.pkg.dev/cloudrun/container/job"
      }
    }
  }

  deletion_protection = false
  depends_on          = [module.project_services]
}
