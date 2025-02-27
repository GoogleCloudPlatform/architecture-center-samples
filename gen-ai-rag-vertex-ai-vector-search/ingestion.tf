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

### Bucket for ingested data
resource "google_storage_bucket" "ingest" {
  name = "ingest-${local.unique_str}"

  # Design consideration: Data availability
  location = var.region
}

### Pub/Sub to trigger ingestion job

# Pub/Sub Topic
resource "google_pubsub_topic" "ingest" {
  name = "ingest-${local.unique_str}"
}

# Link events on the Cloud Storage bucket to the Pub/Sub Topic
resource "google_storage_notification" "default" {
  bucket         = google_storage_bucket.ingest.name
  topic          = google_pubsub_topic.ingest.id
  event_types    = ["OBJECT_FINALIZE"]
  payload_format = "JSON_API_V1"

  depends_on = [google_pubsub_topic_iam_member.pubsub]
}

# Allow the Cloud Storage service account the ability to publish messages
resource "google_pubsub_topic_iam_member" "gcs" {
  topic  = google_pubsub_topic.ingest.id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${local.gcs_service_account}"

  depends_on = [module.project_services]
}

# Allow the Pub/Sub service account the ability to publish messages
resource "google_pubsub_topic_iam_member" "pubsub" {
  topic  = google_pubsub_topic.ingest.id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${local.pubsub_service_account}"
}

### Cloud Run Function code

# Take the Cloud Run Function code from the local function-source folder
data "archive_file" "default" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "function-source/"
}

# Create a bucket to store the Cloud Run Function code
resource "google_storage_bucket" "default" {
  name                        = "gcf-source-${local.unique_str}-${var.project_id}"
  location                    = "US"
  uniform_bucket_level_access = true
}

# Upload the function code
resource "google_storage_bucket_object" "default" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.default.name
  source = data.archive_file.default.output_path
}

### Ingestion function

resource "google_cloudfunctions2_function" "default" {
  name        = "ingestion-${local.unique_str}"
  location    = var.region
  description = "Function to process Cloud Storage events"

  build_config {
    runtime     = "python312"
    entry_point = "process_data"

    source {
      # From uploaded archive of local code folder
      storage_source {
        bucket = google_storage_bucket.default.name
        object = google_storage_bucket_object.default.name
      }
    }
  }

  # Note: Configure based on performance requirements for ingest function.
  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.gcf.email
  }

  # Creates a Pub/Sub Subscription based on the topic
  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.ingest.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [module.project_services, google_service_account.gcf]
}

# Dedicated service account for function.
# Note: grant any additional permissions to the function as required.
resource "google_service_account" "gcf" {
  account_id = "function-service-account-${local.unique_str}"
}
