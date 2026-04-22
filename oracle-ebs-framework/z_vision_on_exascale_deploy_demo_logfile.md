# Oracle EBS Toolkit on GCP | Oracle EBS Vision on Oracle Database@GCP Demo logfile output example

This file shows example of exeucing Oracle EBS Vision on Oracle Database@GCP  deployment log and outputs as well as timings and expected resutls

! Fill this up with actual logs and outputs once it's compelte - must follow readme's from a-z

### Setup Environment

```bash
 
[user@desktop] mkdir Code
[user@desktop] cd Code
[user@desktop] Code % git clone https://github.com/company/ebs-infra-framework
[user@desktop] Code % cd ebs-infra-framework

[user@desktop] ebs-infra-framework % ls -lart
drwxr-xr-x@ 41 user  group    1312 Mar 24 11:00 ..
-rw-r--r--@  1 user  group     615 Mar 24 11:00 .pre-commit-config.yaml
-rw-r--r--@  1 user  group    8650 Mar 24 11:00 README-customer-data.md
-rw-r--r--@  1 user  group     149 Mar 24 11:00 provider.tf
-rw-r--r--@  1 user  group     407 Mar 24 11:00 service-accounts.tf
-rw-r--r--@  1 user  group  394818 Mar 24 11:00 z_customer_deploy_demo_logfile.md
-rw-r--r--@  1 user  group  196588 Mar 24 11:00 z_vision_deploy_demo_logfile.md
-rw-r--r--@  1 user  group     408 Mar 24 11:00 backend.tf
-rw-r--r--@  1 user  group     663 Mar 24 11:00 buckets.tf
drwxr-xr-x@  5 user  group     160 Mar 24 11:18 images
-rw-r--r--@  1 user  group    1549 Apr  7 10:33 .gitignore
-rw-r--r--@  1 user  group    7897 Apr  7 10:33 README-exascale-vision.md
-rw-r--r--@  1 user  group    7468 Apr  7 10:33 README.md
-rw-r--r--@  1 user  group    1104 Apr  7 10:33 infra.auto.tfvars
-rw-r--r--@  1 user  group    6602 Apr  7 17:28 .terraform.lock.hcl
-rw-r--r--@  1 user  group      92 Apr  7 17:29 .grid_image_id
drwxr-xr-x@  5 user  group     160 Apr  7 20:13 .terraform
-rw-r--r--@  1 user  group    2739 Apr  8 09:25 firewall-rules.tf
-rw-r--r--@  1 user  group    1385 Apr  8 09:25 locals.tf
-rw-r--r--@  1 user  group    1398 Apr  8 09:25 odb-network.tf
-rw-r--r--@  1 user  group    5373 Apr  8 09:25 output.tf
-rw-r--r--@  1 user  group     434 Apr  8 09:25 project.tf
drwxr-xr-x@  8 user  group     256 Apr  8 09:25 scripts
-rw-r--r--@  1 user  group     906 Apr  8 09:25 secrets.tf
-rw-r--r--@  1 user  group   12446 Apr  8 09:25 variables.tf
-rw-r--r--@  1 user  group    6298 Apr  8 09:25 vm.tf
-rw-r--r--@  1 user  group    3287 Apr  8 09:25 vpc.tf
-rw-r--r--@  1 user  group   13652 Apr  8 20:36 Makefile
-rw-r--r--@  1 user  group  138232 Apr  8 22:07 z_vision_on_exasclae_deploy_demo_logfile.md
drwxr-xr-x@ 32 user  group    1024 Apr  9 15:43 .
-rw-r--r--@  1 user  group   17294 Apr  9 15:43 exadb.tf
drwxr-xr-x@ 15 user  group     480 Apr  9 15:47 .git

[user@desktop] ebs-infra-framework % git pull
Current branch develop is up to date.

[user@desktop] make setup
Running setup...
bash scripts/install.sh
gcloud already exists.
✔ Terraform already installed: 1.13.0
✔ terraform-docs already installed: 0.20.0
All tools installed and configured.
Setup complete.
Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'.

[user@desktop]  gcloud config list
[core]
account = user@pythian.com
disable_usage_reporting = False
project = oracle-ebs-toolkit-demo

Your active configuration is: [default]
[environment: untagged] Read more to tag: g.co/cloud/project-env-tag.

[user@desktop]  make verify-gcp-access
 Verifying GCP access for project: oracle-ebs-toolkit-demo
Access to project oracle-ebs-toolkit-demo confirmed.
 Checking IAM roles for user@pythian.com...
 User has Owner/Editor role → skipping fine-grained permission checks.

 GCP access check passed for project: oracle-ebs-toolkit-demo

```

### 2. Authenticate with GCP and configure Application Default Credentials:

Terraform uses Application Default Credentials (ADC) to interact with GCP. Run the following command before initializing Terraform:

```bash
user@desktop]  gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=...


Credentials saved to file: [/Users/user/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).


Quota project "oracle-ebs-toolkit-demo" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
[user@desktop] 
```

### 3. Deploy EBS Vision Infrastructure on GCP and OCI (~2 hours)

```
[user@desktop]  make init
Checking if backend bucket gs://oracle-ebs-toolkit-demo-119724395047-terraform-state exists...
Initializing Terraform in ....
Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/tls from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Reusing previous version of hashicorp/google from the dependency lock file
- Reusing previous version of hashicorp/google-beta from the dependency lock file
- Reusing previous version of hashicorp/null from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/random v3.8.1
- Using previously-installed hashicorp/tls v4.2.1
- Using previously-installed hashicorp/local v2.8.0
- Using previously-installed hashicorp/google v6.50.0
- Using previously-installed hashicorp/google-beta v7.26.0
- Using previously-installed hashicorp/null v3.2.4

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Terraform initialized successfully.

[user@desktop]  make exascale_plan
Using existing Grid Image ID from .grid_image_id: ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq
terraform -chdir=. plan \
		-var="project_id=oracle-ebs-toolkit-demo" \
		-var="project_service_account_email=project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" \
		-var="oracle_ebs_exascale=true" \
		-var="oracle_ebs_vision=false" \
		-var="exascale_grid_image_id=$(cat .grid_image_id)"
Acquiring state lock. This may take a few moments...
data.google_compute_image.vision_image: Reading...
data.google_compute_image.apps_image: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.dbs_image: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
data.google_compute_image.dbs_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
data.google_compute_image.vision_image: Read complete after 2s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.exascale_vision_server_internal_ip[0] will be created
  + resource "google_compute_address" "exascale_vision_server_internal_ip" {
      + address            = "10.115.0.40"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "exascale-vision-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-ebs-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_instance.exascale_vision[0] will be created
  + resource "google_compute_instance" "exascale_vision" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application"                = "oracle-exascale-vision"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-exascale-vision"
          + "managed-by"  = "terraform"
        }
      + machine_type         = "e2-standard-8"
      + metadata             = (known after apply)
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-exascale-vision-app"
      + project              = "oracle-ebs-toolkit-demo"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-db-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-ebs-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "application"                = "oracle-exascale-vision"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + zone                 = "northamerica-northeast2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + guest_os_features          = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + architecture           = (known after apply)
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 1024
              + snapshot               = (known after apply)
              + type                   = "pd-balanced"
            }
        }

      + confidential_instance_config (known after apply)

      + guest_accelerator (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_attachment          = (known after apply)
          + network_ip                  = "10.115.0.40"
          + stack_type                  = (known after apply)
          + subnetwork                  = (known after apply)
          + subnetwork_project          = (known after apply)
        }

      + reservation_affinity {
          + type = "ANY_RESERVATION"
        }

      + scheduling {
          + automatic_restart   = true
          + on_host_maintenance = "MIGRATE"
          + preemptible         = false
          + provisioning_model  = "STANDARD"
        }

      + service_account {
          + email  = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = true
          + enable_vtpm                 = true
        }
    }

  # google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0] will be created
  + resource "google_oracle_database_exadb_vm_cluster" "exadb_vm_cluster" {
      + backup_odb_subnet   = (known after apply)
      + create_time         = (known after apply)
      + deletion_protection = false
      + display_name        = "Exadata VM Cluster"
      + effective_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id      = (known after apply)
      + exadb_vm_cluster_id = "exadb-vm-cluster-01"
      + gcp_oracle_zone     = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "deployment" = "demo"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_network         = (known after apply)
      + odb_subnet          = (known after apply)
      + project             = "oracle-ebs-toolkit-demo"
      + terraform_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_ecpu_count_per_node = (known after apply)
          + cluster_name                   = "exadb-cl1"
          + enabled_ecpu_count_per_node    = 8
          + exascale_db_storage_vault      = (known after apply)
          + gi_version                     = (known after apply)
          + grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq"
          + hostname                       = (known after apply)
          + hostname_prefix                = "exadb-node"
          + license_model                  = "BRING_YOUR_OWN_LICENSE"
          + lifecycle_state                = (known after apply)
          + memory_size_gb                 = (known after apply)
          + node_count                     = 1
          + oci_uri                        = (known after apply)
          + scan_listener_port_tcp         = 1521
          + shape_attribute                = "BLOCK_STORAGE"
          + ssh_public_keys                = (known after apply)

          + data_collection_options {
              + is_diagnostics_events_enabled = true
              + is_health_monitoring_enabled  = true
              + is_incident_logs_enabled      = true
            }

          + time_zone {
              + id = "UTC"
            }

          + vm_file_system_storage {
              + size_in_gbs_per_node = 260
            }
        }

      + timeouts {
          + create = "180m"
          + delete = "180m"
          + update = "180m"
        }
    }

  # google_oracle_database_exascale_db_storage_vault.exascale_vault[0] will be created
  + resource "google_oracle_database_exascale_db_storage_vault" "exascale_vault" {
      + create_time                  = (known after apply)
      + deletion_protection          = false
      + display_name                 = "Exascale DB Storage Vault"
      + effective_labels             = {
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id               = (known after apply)
      + exascale_db_storage_vault_id = "exascale-db-storage-vault"
      + gcp_oracle_zone              = (known after apply)
      + id                           = (known after apply)
      + location                     = "northamerica-northeast2"
      + name                         = (known after apply)
      + project                      = "oracle-ebs-toolkit-demo"
      + terraform_labels             = {
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_flash_cache_percent = (known after apply)
          + attached_shape_attributes      = (known after apply)
          + available_shape_attributes     = (known after apply)
          + oci_uri                        = (known after apply)
          + ocid                           = (known after apply)
          + state                          = (known after apply)
          + vm_cluster_count               = (known after apply)
          + vm_cluster_ids                 = (known after apply)

          + exascale_db_storage_details {
              + available_size_gbs = (known after apply)
              + total_size_gbs     = 1000
            }

          + time_zone (known after apply)
        }
    }

  # google_oracle_database_odb_network.odb_network[0] will be created
  + resource "google_oracle_database_odb_network" "odb_network" {
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + entitlement_id      = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + network             = "projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network"
      + odb_network_id      = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_oracle_database_odb_subnet.backup_subnet[0] will be created
  + resource "google_oracle_database_odb_subnet" "backup_subnet" {
      + cidr_range          = "10.116.128.0/20"
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_subnet_id       = "oracle-ebs-toolkit-network-backup-subnet"
      + odbnetwork          = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + purpose             = "BACKUP_SUBNET"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_oracle_database_odb_subnet.client_subnet[0] will be created
  + resource "google_oracle_database_odb_subnet" "client_subnet" {
      + cidr_range          = "10.116.0.0/20"
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_subnet_id       = "oracle-ebs-toolkit-network-client-subnet"
      + odbnetwork          = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + purpose             = "CLIENT_SUBNET"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/storage.admin"
    }

  # google_secret_manager_secret.exadb_private_key_secret[0] will be created
  + resource "google_secret_manager_secret" "exadb_private_key_secret" {
      + create_time           = (known after apply)
      + deletion_protection   = false
      + effective_annotations = (known after apply)
      + effective_labels      = {
          + "goog-terraform-provisioned" = "true"
        }
      + expire_time           = (known after apply)
      + id                    = (known after apply)
      + name                  = (known after apply)
      + project               = "oracle-ebs-toolkit-demo"
      + secret_id             = (known after apply)
      + terraform_labels      = {
          + "goog-terraform-provisioned" = "true"
        }

      + replication {
          + auto {
            }
        }
    }

  # google_secret_manager_secret_version.exadb_private_key_secret_version[0] will be created
  + resource "google_secret_manager_secret_version" "exadb_private_key_secret_version" {
      + create_time            = (known after apply)
      + deletion_policy        = "DELETE"
      + destroy_time           = (known after apply)
      + enabled                = true
      + id                     = (known after apply)
      + is_secret_data_base64  = false
      + name                   = (known after apply)
      + secret                 = (known after apply)
      + secret_data            = (sensitive value)
      + secret_data_wo         = (write-only attribute)
      + secret_data_wo_version = 0
      + version                = (known after apply)
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "oracle-ebs-toolkit-demo"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + role   = "roles/storage.objectAdmin"
    }

  # local_file.exadb_private_key[0] will be created
  + resource "local_file" "exadb_private_key" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0600"
      + filename             = "./exadb_private_key.pem"
      + id                   = (known after apply)
    }

  # local_file.exadb_public_key[0] will be created
  + resource "local_file" "exadb_public_key" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0644"
      + filename             = "./exadb_public_key.pub"
      + id                   = (known after apply)
    }

  # null_resource.exascale_configure_and_upload[0] will be created
  + resource "null_resource" "exascale_configure_and_upload" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "EBSCDB"
          + "oci_api_version" = "20160918"
          + "password"        = (known after apply)
          + "vm_id"           = (known after apply)
        }
    }

  # null_resource.exascale_db_provisioning[0] will be created
  + resource "null_resource" "exascale_db_provisioning" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "EBSCDB"
          + "cluster_uri"     = (known after apply)
          + "oci_api_version" = "20160918"
        }
    }

  # null_resource.exascale_ingress_rules[0] will be created
  + resource "null_resource" "exascale_ingress_rules" {
      + id       = (known after apply)
      + triggers = {
          + "cluster_uri"     = (known after apply)
          + "oci_api_version" = "20160918"
          + "vpc_cidr"        = "10.115.0.0/20"
        }
    }

  # random_id.bucket_suffix will be created
  + resource "random_id" "bucket_suffix" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # random_id.secret_suffix[0] will be created
  + resource "random_id" "secret_suffix" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # random_password.admin_password[0] will be created
  + resource "random_password" "admin_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + length           = 16
      + lower            = true
      + min_lower        = 2
      + min_numeric      = 2
      + min_special      = 2
      + min_upper        = 2
      + number           = true
      + numeric          = true
      + override_special = "_-"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

  # tls_private_key.exadb_ssh_key[0] will be created
  + resource "tls_private_key" "exadb_ssh_key" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 4096
    }

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-ebs-toolkit-network-cloud-router"
      + network            = "oracle-ebs-toolkit-network"
      + project            = "oracle-ebs-toolkit-demo"
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-ebs-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-ebs-toolkit-demo"
      + region                              = "northamerica-northeast2"
      + router                              = "oracle-ebs-toolkit-network-cloud-router"
      + source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
      + tcp_established_idle_timeout_sec    = 1200
      + tcp_time_wait_timeout_sec           = 120
      + tcp_transitory_idle_timeout_sec     = 30
      + type                                = "PUBLIC"
      + udp_idle_timeout_sec                = 30

      + log_config {
          + enable = true
          + filter = "ALL"
        }

      + subnetwork {
          + name                     = "oracle-ebs-toolkit-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
    }

  # module.ebs_storage_bucket.google_storage_bucket.bucket will be created
  + resource "google_storage_bucket" "bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-ebs-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + location                    = "NORTHAMERICA-NORTHEAST2"
      + name                        = (known after apply)
      + project                     = "oracle-ebs-toolkit-demo"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-ebs-toolkit"
        }
      + time_created                = (known after apply)
      + uniform_bucket_level_access = true
      + updated                     = (known after apply)
      + url                         = (known after apply)

      + autoclass {
          + enabled                = false
          + terminal_storage_class = (known after apply)
        }

      + hierarchical_namespace {
          + enabled = false
        }

      + soft_delete_policy {
          + effective_time             = (known after apply)
          + retention_duration_seconds = 604800
        }

      + versioning {
          + enabled = true
        }

      + website (known after apply)
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle EBS Apps"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-external-app-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "external-app-access",
        ]

      + allow {
          + ports    = [
              + "8000",
              + "4443",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle EBS DB"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-external-db-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "external-db-access",
        ]

      + allow {
          + ports    = [
              + "1521",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-http-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "http-server",
        ]

      + allow {
          + ports    = [
              + "80",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTPS traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-https-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "https-server",
        ]

      + allow {
          + ports    = [
              + "443",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow IAP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-iap-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "35.235.240.0/20",
        ]
      + target_tags        = [
          + "iap-access",
        ]

      + allow {
          + ports    = []
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow ICMP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-icmp-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "35.235.240.0/20",
        ]
      + target_tags        = [
          + "icmp-access",
        ]

      + allow {
          + ports    = []
          + protocol = "icmp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow internal HTTP traffic within the VPC"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-internal-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "10.115.0.0/20",
        ]
      + target_tags        = [
          + "internal-access",
        ]

      + allow {
          + ports    = []
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.nat_gateway_route.google_compute_route.route["nat-egress-internet"] will be created
  + resource "google_compute_route" "route" {
      + as_paths                   = (known after apply)
      + creation_timestamp         = (known after apply)
      + description                = "Public NAT GW - route through IGW to access internet"
      + dest_range                 = "0.0.0.0/0"
      + id                         = (known after apply)
      + name                       = "nat-egress-internet"
      + network                    = "oracle-ebs-toolkit-network"
      + next_hop_gateway           = "default-internet-gateway"
      + next_hop_hub               = (known after apply)
      + next_hop_instance_zone     = (known after apply)
      + next_hop_inter_region_cost = (known after apply)
      + next_hop_ip                = (known after apply)
      + next_hop_med               = (known after apply)
      + next_hop_network           = (known after apply)
      + next_hop_origin            = (known after apply)
      + next_hop_peering           = (known after apply)
      + priority                   = 1000
      + project                    = "oracle-ebs-toolkit-demo"
      + route_status               = (known after apply)
      + route_type                 = (known after apply)
      + self_link                  = (known after apply)
      + tags                       = [
          + "egress-nat",
        ]
      + warnings                   = (known after apply)
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"] will be created
  + resource "google_compute_subnetwork" "subnetwork" {
      + creation_timestamp         = (known after apply)
      + enable_flow_logs           = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + internal_ipv6_prefix       = (known after apply)
      + ip_cidr_range              = "10.115.0.0/20"
      + ipv6_cidr_range            = (known after apply)
      + ipv6_gce_endpoint          = (known after apply)
      + name                       = "oracle-ebs-toolkit-subnet-01"
      + network                    = "oracle-ebs-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-ebs-toolkit-demo"
      + purpose                    = (known after apply)
      + region                     = "northamerica-northeast2"
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)
      + state                      = (known after apply)
      + subnetwork_id              = (known after apply)

      + log_config {
          + aggregation_interval = "INTERVAL_5_SEC"
          + filter_expr          = "true"
          + flow_sampling        = 0.5
          + metadata             = "INCLUDE_ALL_METADATA"
        }

      + secondary_ip_range (known after apply)
    }

  # module.network.module.vpc.google_compute_network.network will be created
  + resource "google_compute_network" "network" {
      + auto_create_subnetworks                   = false
      + bgp_always_compare_med                    = (known after apply)
      + bgp_best_path_selection_mode              = "LEGACY"
      + bgp_inter_region_cost                     = (known after apply)
      + delete_bgp_always_compare_med             = false
      + delete_default_routes_on_create           = true
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "oracle-ebs-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-ebs-toolkit-demo"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 46 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + admin_password                = (sensitive value)
  + apps_instance_zone            = ""
  + dbs_instance_zone             = ""
  + deployment_summary            = (known after apply)
  + exascale_vision_instance_zone = (known after apply)
  + vision_instance_zone          = ""

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
[user@desktop] 
[user@desktop] 
[user@desktop] 
[user@desktop]  date; make exascale_deploy ; date
Thu Apr  9 15:56:01 EEST 2026
Using existing Grid Image ID from .grid_image_id: ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq
terraform -chdir=. apply -auto-approve \
		-var="project_id=oracle-ebs-toolkit-demo" \
		-var="project_service_account_email=project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" \
		-var="oracle_ebs_exascale=true" \
		-var="oracle_ebs_vision=false" \
		-var="exascale_grid_image_id=$(cat .grid_image_id)"
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.vision_image: Reading...
data.google_compute_image.apps_image: Reading...
data.google_compute_image.dbs_image: Reading...
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
data.google_compute_image.dbs_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
data.google_compute_image.vision_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.exascale_vision_server_internal_ip[0] will be created
  + resource "google_compute_address" "exascale_vision_server_internal_ip" {
      + address            = "10.115.0.40"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "exascale-vision-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-ebs-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_instance.exascale_vision[0] will be created
  + resource "google_compute_instance" "exascale_vision" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application"                = "oracle-exascale-vision"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-exascale-vision"
          + "managed-by"  = "terraform"
        }
      + machine_type         = "e2-standard-8"
      + metadata             = (known after apply)
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-exascale-vision-app"
      + project              = "oracle-ebs-toolkit-demo"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-db-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-ebs-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "application"                = "oracle-exascale-vision"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + zone                 = "northamerica-northeast2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + guest_os_features          = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + architecture           = (known after apply)
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 1024
              + snapshot               = (known after apply)
              + type                   = "pd-balanced"
            }
        }

      + confidential_instance_config (known after apply)

      + guest_accelerator (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_attachment          = (known after apply)
          + network_ip                  = "10.115.0.40"
          + stack_type                  = (known after apply)
          + subnetwork                  = (known after apply)
          + subnetwork_project          = (known after apply)
        }

      + reservation_affinity {
          + type = "ANY_RESERVATION"
        }

      + scheduling {
          + automatic_restart   = true
          + on_host_maintenance = "MIGRATE"
          + preemptible         = false
          + provisioning_model  = "STANDARD"
        }

      + service_account {
          + email  = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = true
          + enable_vtpm                 = true
        }
    }

  # google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0] will be created
  + resource "google_oracle_database_exadb_vm_cluster" "exadb_vm_cluster" {
      + backup_odb_subnet   = (known after apply)
      + create_time         = (known after apply)
      + deletion_protection = false
      + display_name        = "Exadata VM Cluster"
      + effective_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id      = (known after apply)
      + exadb_vm_cluster_id = "exadb-vm-cluster-01"
      + gcp_oracle_zone     = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "deployment" = "demo"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_network         = (known after apply)
      + odb_subnet          = (known after apply)
      + project             = "oracle-ebs-toolkit-demo"
      + terraform_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_ecpu_count_per_node = (known after apply)
          + cluster_name                   = "exadb-cl1"
          + enabled_ecpu_count_per_node    = 8
          + exascale_db_storage_vault      = (known after apply)
          + gi_version                     = (known after apply)
          + grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq"
          + hostname                       = (known after apply)
          + hostname_prefix                = "exadb-node"
          + license_model                  = "BRING_YOUR_OWN_LICENSE"
          + lifecycle_state                = (known after apply)
          + memory_size_gb                 = (known after apply)
          + node_count                     = 1
          + oci_uri                        = (known after apply)
          + scan_listener_port_tcp         = 1521
          + shape_attribute                = "BLOCK_STORAGE"
          + ssh_public_keys                = (known after apply)

          + data_collection_options {
              + is_diagnostics_events_enabled = true
              + is_health_monitoring_enabled  = true
              + is_incident_logs_enabled      = true
            }

          + time_zone {
              + id = "UTC"
            }

          + vm_file_system_storage {
              + size_in_gbs_per_node = 260
            }
        }

      + timeouts {
          + create = "180m"
          + delete = "180m"
          + update = "180m"
        }
    }

  # google_oracle_database_exascale_db_storage_vault.exascale_vault[0] will be created
  + resource "google_oracle_database_exascale_db_storage_vault" "exascale_vault" {
      + create_time                  = (known after apply)
      + deletion_protection          = false
      + display_name                 = "Exascale DB Storage Vault"
      + effective_labels             = {
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id               = (known after apply)
      + exascale_db_storage_vault_id = "exascale-db-storage-vault"
      + gcp_oracle_zone              = (known after apply)
      + id                           = (known after apply)
      + location                     = "northamerica-northeast2"
      + name                         = (known after apply)
      + project                      = "oracle-ebs-toolkit-demo"
      + terraform_labels             = {
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_flash_cache_percent = (known after apply)
          + attached_shape_attributes      = (known after apply)
          + available_shape_attributes     = (known after apply)
          + oci_uri                        = (known after apply)
          + ocid                           = (known after apply)
          + state                          = (known after apply)
          + vm_cluster_count               = (known after apply)
          + vm_cluster_ids                 = (known after apply)

          + exascale_db_storage_details {
              + available_size_gbs = (known after apply)
              + total_size_gbs     = 1000
            }

          + time_zone (known after apply)
        }
    }

  # google_oracle_database_odb_network.odb_network[0] will be created
  + resource "google_oracle_database_odb_network" "odb_network" {
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + entitlement_id      = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + network             = "projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network"
      + odb_network_id      = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_oracle_database_odb_subnet.backup_subnet[0] will be created
  + resource "google_oracle_database_odb_subnet" "backup_subnet" {
      + cidr_range          = "10.116.128.0/20"
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_subnet_id       = "oracle-ebs-toolkit-network-backup-subnet"
      + odbnetwork          = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + purpose             = "BACKUP_SUBNET"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_oracle_database_odb_subnet.client_subnet[0] will be created
  + resource "google_oracle_database_odb_subnet" "client_subnet" {
      + cidr_range          = "10.116.0.0/20"
      + create_time         = (known after apply)
      + deletion_protection = false
      + effective_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
      + id                  = (known after apply)
      + labels              = {
          + "terraform_created" = "true"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_subnet_id       = "oracle-ebs-toolkit-network-client-subnet"
      + odbnetwork          = "oracle-ebs-toolkit-network-odb-network"
      + project             = "oracle-ebs-toolkit-demo"
      + purpose             = "CLIENT_SUBNET"
      + state               = (known after apply)
      + terraform_labels    = {
          + "goog-terraform-provisioned" = "true"
          + "terraform_created"          = "true"
        }
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-ebs-toolkit-demo"
      + role    = "roles/storage.admin"
    }

  # google_secret_manager_secret.exadb_private_key_secret[0] will be created
  + resource "google_secret_manager_secret" "exadb_private_key_secret" {
      + create_time           = (known after apply)
      + deletion_protection   = false
      + effective_annotations = (known after apply)
      + effective_labels      = {
          + "goog-terraform-provisioned" = "true"
        }
      + expire_time           = (known after apply)
      + id                    = (known after apply)
      + name                  = (known after apply)
      + project               = "oracle-ebs-toolkit-demo"
      + secret_id             = (known after apply)
      + terraform_labels      = {
          + "goog-terraform-provisioned" = "true"
        }

      + replication {
          + auto {
            }
        }
    }

  # google_secret_manager_secret_version.exadb_private_key_secret_version[0] will be created
  + resource "google_secret_manager_secret_version" "exadb_private_key_secret_version" {
      + create_time            = (known after apply)
      + deletion_policy        = "DELETE"
      + destroy_time           = (known after apply)
      + enabled                = true
      + id                     = (known after apply)
      + is_secret_data_base64  = false
      + name                   = (known after apply)
      + secret                 = (known after apply)
      + secret_data            = (sensitive value)
      + secret_data_wo         = (write-only attribute)
      + secret_data_wo_version = 0
      + version                = (known after apply)
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "oracle-ebs-toolkit-demo"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
      + role   = "roles/storage.objectAdmin"
    }

  # local_file.exadb_private_key[0] will be created
  + resource "local_file" "exadb_private_key" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0600"
      + filename             = "./exadb_private_key.pem"
      + id                   = (known after apply)
    }

  # local_file.exadb_public_key[0] will be created
  + resource "local_file" "exadb_public_key" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0644"
      + filename             = "./exadb_public_key.pub"
      + id                   = (known after apply)
    }

  # null_resource.exascale_configure_and_upload[0] will be created
  + resource "null_resource" "exascale_configure_and_upload" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "EBSCDB"
          + "oci_api_version" = "20160918"
          + "password"        = (known after apply)
          + "vm_id"           = (known after apply)
        }
    }

  # null_resource.exascale_db_provisioning[0] will be created
  + resource "null_resource" "exascale_db_provisioning" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "EBSCDB"
          + "cluster_uri"     = (known after apply)
          + "oci_api_version" = "20160918"
        }
    }

  # null_resource.exascale_ingress_rules[0] will be created
  + resource "null_resource" "exascale_ingress_rules" {
      + id       = (known after apply)
      + triggers = {
          + "cluster_uri"     = (known after apply)
          + "oci_api_version" = "20160918"
          + "vpc_cidr"        = "10.115.0.0/20"
        }
    }

  # random_id.bucket_suffix will be created
  + resource "random_id" "bucket_suffix" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # random_id.secret_suffix[0] will be created
  + resource "random_id" "secret_suffix" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # random_password.admin_password[0] will be created
  + resource "random_password" "admin_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + length           = 16
      + lower            = true
      + min_lower        = 2
      + min_numeric      = 2
      + min_special      = 2
      + min_upper        = 2
      + number           = true
      + numeric          = true
      + override_special = "_-"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

  # tls_private_key.exadb_ssh_key[0] will be created
  + resource "tls_private_key" "exadb_ssh_key" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 4096
    }

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-ebs-toolkit-network-cloud-router"
      + network            = "oracle-ebs-toolkit-network"
      + project            = "oracle-ebs-toolkit-demo"
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-ebs-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-ebs-toolkit-demo"
      + region                              = "northamerica-northeast2"
      + router                              = "oracle-ebs-toolkit-network-cloud-router"
      + source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
      + tcp_established_idle_timeout_sec    = 1200
      + tcp_time_wait_timeout_sec           = 120
      + tcp_transitory_idle_timeout_sec     = 30
      + type                                = "PUBLIC"
      + udp_idle_timeout_sec                = 30

      + log_config {
          + enable = true
          + filter = "ALL"
        }

      + subnetwork {
          + name                     = "oracle-ebs-toolkit-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
    }

  # module.ebs_storage_bucket.google_storage_bucket.bucket will be created
  + resource "google_storage_bucket" "bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-ebs-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + location                    = "NORTHAMERICA-NORTHEAST2"
      + name                        = (known after apply)
      + project                     = "oracle-ebs-toolkit-demo"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-ebs-toolkit"
        }
      + time_created                = (known after apply)
      + uniform_bucket_level_access = true
      + updated                     = (known after apply)
      + url                         = (known after apply)

      + autoclass {
          + enabled                = false
          + terminal_storage_class = (known after apply)
        }

      + hierarchical_namespace {
          + enabled = false
        }

      + soft_delete_policy {
          + effective_time             = (known after apply)
          + retention_duration_seconds = 604800
        }

      + versioning {
          + enabled = true
        }

      + website (known after apply)
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle EBS Apps"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-external-app-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "external-app-access",
        ]

      + allow {
          + ports    = [
              + "8000",
              + "4443",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle EBS DB"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-external-db-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "external-db-access",
        ]

      + allow {
          + ports    = [
              + "1521",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-http-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "http-server",
        ]

      + allow {
          + ports    = [
              + "80",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTPS traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-https-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "https-server",
        ]

      + allow {
          + ports    = [
              + "443",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow IAP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-iap-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "35.235.240.0/20",
        ]
      + target_tags        = [
          + "iap-access",
        ]

      + allow {
          + ports    = []
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow ICMP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-icmp-in"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "35.235.240.0/20",
        ]
      + target_tags        = [
          + "icmp-access",
        ]

      + allow {
          + ports    = []
          + protocol = "icmp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow internal HTTP traffic within the VPC"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "allow-internal-access"
      + network            = "oracle-ebs-toolkit-network"
      + priority           = 1000
      + project            = "oracle-ebs-toolkit-demo"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "10.115.0.0/20",
        ]
      + target_tags        = [
          + "internal-access",
        ]

      + allow {
          + ports    = []
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.nat_gateway_route.google_compute_route.route["nat-egress-internet"] will be created
  + resource "google_compute_route" "route" {
      + as_paths                   = (known after apply)
      + creation_timestamp         = (known after apply)
      + description                = "Public NAT GW - route through IGW to access internet"
      + dest_range                 = "0.0.0.0/0"
      + id                         = (known after apply)
      + name                       = "nat-egress-internet"
      + network                    = "oracle-ebs-toolkit-network"
      + next_hop_gateway           = "default-internet-gateway"
      + next_hop_hub               = (known after apply)
      + next_hop_instance_zone     = (known after apply)
      + next_hop_inter_region_cost = (known after apply)
      + next_hop_ip                = (known after apply)
      + next_hop_med               = (known after apply)
      + next_hop_network           = (known after apply)
      + next_hop_origin            = (known after apply)
      + next_hop_peering           = (known after apply)
      + priority                   = 1000
      + project                    = "oracle-ebs-toolkit-demo"
      + route_status               = (known after apply)
      + route_type                 = (known after apply)
      + self_link                  = (known after apply)
      + tags                       = [
          + "egress-nat",
        ]
      + warnings                   = (known after apply)
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit-demo"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"] will be created
  + resource "google_compute_subnetwork" "subnetwork" {
      + creation_timestamp         = (known after apply)
      + enable_flow_logs           = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + internal_ipv6_prefix       = (known after apply)
      + ip_cidr_range              = "10.115.0.0/20"
      + ipv6_cidr_range            = (known after apply)
      + ipv6_gce_endpoint          = (known after apply)
      + name                       = "oracle-ebs-toolkit-subnet-01"
      + network                    = "oracle-ebs-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-ebs-toolkit-demo"
      + purpose                    = (known after apply)
      + region                     = "northamerica-northeast2"
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)
      + state                      = (known after apply)
      + subnetwork_id              = (known after apply)

      + log_config {
          + aggregation_interval = "INTERVAL_5_SEC"
          + filter_expr          = "true"
          + flow_sampling        = 0.5
          + metadata             = "INCLUDE_ALL_METADATA"
        }

      + secondary_ip_range (known after apply)
    }

  # module.network.module.vpc.google_compute_network.network will be created
  + resource "google_compute_network" "network" {
      + auto_create_subnetworks                   = false
      + bgp_always_compare_med                    = (known after apply)
      + bgp_best_path_selection_mode              = "LEGACY"
      + bgp_inter_region_cost                     = (known after apply)
      + delete_bgp_always_compare_med             = false
      + delete_default_routes_on_create           = true
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "oracle-ebs-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-ebs-toolkit-demo"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 46 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + admin_password                = (sensitive value)
  + apps_instance_zone            = ""
  + dbs_instance_zone             = ""
  + deployment_summary            = (known after apply)
  + exascale_vision_instance_zone = (known after apply)
  + vision_instance_zone          = ""
tls_private_key.exadb_ssh_key[0]: Creating...
random_id.secret_suffix[0]: Creating...
random_id.bucket_suffix: Creating...
random_id.secret_suffix[0]: Creation complete after 0s [id=kf9mfQ]
random_password.admin_password[0]: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=fJ46cQ]
random_password.admin_password[0]: Creation complete after 0s [id=none]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Creating...
module.network.module.vpc.google_compute_network.network: Creating...
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creating...
google_service_account.project_sa: Creating...
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creating...
google_secret_manager_secret.exadb_private_key_secret[0]: Creating...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creating...
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creating...
google_secret_manager_secret.exadb_private_key_secret[0]: Creation complete after 1s [id=projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-91ff667d]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creating...
tls_private_key.exadb_ssh_key[0]: Creation complete after 1s [id=1582b616c1f2123a7b3ecb640f5e732089c0fd49]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Creating...
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Creation complete after 3s [id=projects/119724395047/secrets/exadb-ssh-private-key-91ff667d/versions/1]
local_file.exadb_private_key[0]: Creating...
local_file.exadb_private_key[0]: Creation complete after 0s [id=35fbf72a27330f2913aecf6de311421e457b058b]
local_file.exadb_public_key[0]: Creating...
local_file.exadb_public_key[0]: Creation complete after 0s [id=3bc81e4cd412ab52837a66a6b32ca3fffc8bc101]
module.ebs_storage_bucket.google_storage_bucket.bucket: Creating...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit-demo/storage.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit-demo/compute.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit-demo/secretmanager.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creation complete after 3s [id=oracle-ebs-toolkit-demo/iam.googleapis.com]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creation complete after 5s [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01]
module.ebs_storage_bucket.google_storage_bucket.bucket: Creation complete after 2s [id=oracle-ebs-toolkit-storage-bucket-7c9e3a71]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m10s elapsed]
google_service_account.project_sa: Still creating... [00m10s elapsed]
google_service_account.project_sa: Creation complete after 14s [id=projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creating...
google_storage_bucket_iam_member.bucket_object_admin: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creating...
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creating...
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creating...
google_storage_bucket_iam_member.bucket_object_admin: Creation complete after 5s [id=b/oracle-ebs-toolkit-storage-bucket-7c9e3a71/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creation complete after 9s [id=oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creation complete after 9s [id=oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creation complete after 10s [id=oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creation complete after 10s [id=oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creation complete after 10s [id=oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creation complete after 11s [id=oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creation complete after 11s [id=oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Still creating... [00m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m30s elapsed]
module.network.module.vpc.google_compute_network.network: Creation complete after 37s [id=projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network]
google_oracle_database_odb_network.odb_network[0]: Creating...
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Creating...
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m40s elapsed]
google_oracle_database_odb_network.odb_network[0]: Creation complete after 4s [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network]
google_oracle_database_odb_subnet.backup_subnet[0]: Creating...
google_oracle_database_odb_subnet.client_subnet[0]: Creating...
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Still creating... [00m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m50s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01]
google_compute_address.exascale_vision_server_internal_ip[0]: Creating...
module.cloud_router.google_compute_router.router: Creating...
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creating...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m10s elapsed]
google_compute_address.exascale_vision_server_internal_ip[0]: Creation complete after 4s [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/exascale-vision-server-internal-ip]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creating...
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m00s elapsed]
module.cloud_router.google_compute_router.router: Still creating... [00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still creating... [00m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m20s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creating...
module.cloud_router.google_compute_router.router: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router]
google_compute_instance.exascale_vision[0]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creation complete after 14s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creation complete after 14s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m30s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still creating... [00m10s elapsed]
google_compute_instance.exascale_vision[0]: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creation complete after 13s [id=oracle-ebs-toolkit-demo/northamerica-northeast2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m40s elapsed]
google_compute_instance.exascale_vision[0]: Still creating... [00m20s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m50s elapsed]
google_compute_instance.exascale_vision[0]: Still creating... [00m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m00s elapsed]
google_compute_instance.exascale_vision[0]: Still creating... [00m40s elapsed]
google_compute_instance.exascale_vision[0]: Creation complete after 43s [id=projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m20s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m40s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Creation complete after 2m27s [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Creation complete after 4m16s [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [05m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [05m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Creation complete after 5m17s [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Creating...
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [01m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [02m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [02m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [02m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [02m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [02m40s elapsed]
...
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [65m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [65m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Creation complete after 1h6m38s [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01]
null_resource.exascale_db_provisioning[0]: Creating...
null_resource.exascale_db_provisioning[0]: Provisioning with 'local-exec'...
null_resource.exascale_db_provisioning[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_db_provisioning[0]: Still creating... [00m10s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [00m20s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [00m30s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [00m40s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [00m50s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [01m00s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [01m10s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [01m20s elapsed]
...
null_resource.exascale_db_provisioning[0]: Still creating... [35m00s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [35m10s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [35m20s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [35m30s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [35m40s elapsed]
null_resource.exascale_db_provisioning[0]: Creation complete after 35m40s [id=5666121952533079172]
null_resource.exascale_ingress_rules[0]: Creating...
null_resource.exascale_configure_and_upload[0]: Creating...
null_resource.exascale_ingress_rules[0]: Provisioning with 'local-exec'...
null_resource.exascale_ingress_rules[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 1\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaie66fjrlgz3hw7ebklk3hrtwkrg3u636s24r7vzpr32a?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      if [ -z \"$CLUSTER_OCID\" ] || [ -z \"$OCI_REGION\" ]; then\n        exit 1\n      fi\n\n      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/exadbVmClusters/$CLUSTER_OCID\" | grep -v \"ServiceError\")\n      SUBNET_OCID=$(echo \"$CLUSTER_JSON\" | jq -r '.data.subnetId // empty')\n\n      if [ -z \"$SUBNET_OCID\" ]; then\n        exit 1\n      fi\n\n      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri \"https://iaas.${OCI_REGION}.oraclecloud.com/20160918/subnets/$SUBNET_OCID\" | grep -v \"ServiceError\")\n      VCN_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.vcnId // empty')\n      COMPARTMENT_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.compartmentId // empty')\n\n      TARGET_NSG_OCID=$(oci network nsg list \\\n        --compartment-id \"$COMPARTMENT_OCID\" \\\n        --vcn-id \"$VCN_OCID\" \\\n        --all | jq -r '\n          .data[] \n          | select(.[\"display-name\"] | endswith(\"_NSG\")) \n          | select(.[\"display-name\"] | contains(\"BCKP\") | not) \n          | .id\n        ' | head -n 1)\n\n      if [ -z \"$TARGET_NSG_OCID\" ]; then\n        exit 1\n      fi\n\n      oci network nsg rules add \\\n        --nsg-id \"$TARGET_NSG_OCID\" \\\n        --region \"$OCI_REGION\" \\\n        --security-rules '[\n          {\n            \"direction\": \"INGRESS\",\n            \"protocol\": \"6\",\n            \"source\": \"10.115.0.0/20\",\n            \"sourceType\": \"CIDR_BLOCK\",\n            \"tcpOptions\": {\n              \"destinationPortRange\": {\"max\": 1521, \"min\": 1521}\n            }\n          },\n          {\n            \"direction\": \"INGRESS\",\n            \"protocol\": \"6\",\n            \"source\": \"10.115.0.0/20\",\n            \"sourceType\": \"CIDR_BLOCK\",\n            \"tcpOptions\": {\n              \"destinationPortRange\": {\"max\": 22, \"min\": 22}\n            }\n          }\n        ]' > /dev/null\n"]
null_resource.exascale_configure_and_upload[0]: Provisioning with 'local-exec'...
null_resource.exascale_configure_and_upload[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 1\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaie66fjrlgz3hw7ebklk3hrtwkrg3u636s24r7vzpr32a?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      COMPARTMENT_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'compartmentId=[^&]+' | cut -d'=' -f2)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n      \n      CDB_NAME_CLEAN=$(echo \"EBSCDB\" | sed 's/[-_]//g')\n\n      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/exadbVmClusters/$CLUSTER_OCID\" 2>&1)\n      CLUSTER_NAME=$(echo \"$CLUSTER_JSON\" | jq -r '.data.clusterName // .data.displayName // \"null\"')\n      SCAN_DNS=$(echo \"$CLUSTER_JSON\" | jq -r '.data.scanDnsName // \"null\"')\n\n      DB_LIST=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases?compartmentId=$COMPARTMENT_OCID&systemId=$CLUSTER_OCID\" 2>&1)\n      DB_OCID=$(echo \"$DB_LIST\" | jq -r --arg dbname \"$CDB_NAME_CLEAN\" '.data[] | select((.dbName | ascii_downcase) == ($dbname | ascii_downcase)) | .id' | head -1)\n\n      if [ -z \"$DB_OCID\" ]; then\n        exit 1\n      fi\n\n      DB_DETAILS=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases/$DB_OCID\" 2>&1)\n      TNS_DATA=$(echo \"$DB_DETAILS\" | jq -c '.data.connectionStrings // {}')\n\n      DB_NODES_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbNodes?compartmentId=$COMPARTMENT_OCID&exadbVmClusterId=$CLUSTER_OCID\" 2>/dev/null || true)\n      \n      HOST_IP_OCID=$(echo \"$DB_NODES_JSON\" | jq -r '.data[]? | .hostIpId' 2>/dev/null | head -1 || true)\n\n      if [ -z \"$HOST_IP_OCID\" ]; then\n        DB_NODES_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbNodes?compartmentId=$COMPARTMENT_OCID&vmClusterId=$CLUSTER_OCID\" 2>/dev/null || true)\n        HOST_IP_OCID=$(echo \"$DB_NODES_JSON\" | jq -r '.data[]? | .hostIpId' 2>/dev/null | head -1 || true)\n      fi\n\n      NODE_IP=\"\"\n      if [ -n \"$HOST_IP_OCID\" ]; then\n        IP_JSON=$(oci raw-request --http-method GET --target-uri \"https://iaas.${OCI_REGION}.oraclecloud.com/20160918/privateIps/$HOST_IP_OCID\" 2>/dev/null || true)\n        NODE_IP=$(echo \"$IP_JSON\" | jq -r '.data.ipAddress // empty')\n      fi\n\n      if [ -z \"$NODE_IP\" ]; then\n        NODE_IP=$(echo \"$DB_DETAILS\" | grep -o 'HOST=[0-9.]*' | head -1 | cut -d= -f2)\n      fi\n\n      cat <<EOF > ./exascale_outputs.yaml\ncluster_name: \"$CLUSTER_NAME\"\nscan_dns: \"$SCAN_DNS\"\nnode_ip: \"$NODE_IP\"\nconnection_strings: $TNS_DATA\nEOF\n\n      max_retries=10\n      retry_count=0\n      \n      while ! gcloud compute scp ./exascale_outputs.yaml \\\n        oracle-exascale-vision-app:/tmp/exascale_outputs.yaml \\\n        --zone=\"northamerica-northeast2-a\" \\\n        --project=\"oracle-ebs-toolkit-demo\" \\\n        --tunnel-through-iap \\\n        --quiet; do\n        \n        retry_count=$((retry_count + 1))\n        if [ $retry_count -ge $max_retries ]; then\n          exit 1\n        fi\n        sleep 15\n      done\n"]
null_resource.exascale_configure_and_upload[0]: Still creating... [00m10s elapsed]
null_resource.exascale_ingress_rules[0]: Still creating... [00m10s elapsed]
null_resource.exascale_ingress_rules[0] (local-exec): /opt/homebrew/Cellar/oci-cli/3.76.1/libexec/lib/python3.14/site-packages/services/core/src/oci_cli_compute/compute_cli_extended.py:25: SyntaxWarning: "\." is an invalid escape sequence. Such sequences will not work in the future. Did you mean "\\."? A raw string is also an option.
null_resource.exascale_ingress_rules[0] (local-exec):   INSTANCE_CONSOLE_CONNECTION_STRING_INTERMEDIATE_HOST_REGEX = "(instance-console\.[a-z0-9-]+\.(oraclecloud|oracleiaas)\.com)"  # noqa: W605
null_resource.exascale_configure_and_upload[0] (local-exec): WARNING:

null_resource.exascale_configure_and_upload[0] (local-exec): To increase the performance of the tunnel, consider installing NumPy. For instructions,
null_resource.exascale_configure_and_upload[0] (local-exec): please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

null_resource.exascale_ingress_rules[0]: Creation complete after 17s [id=8606833282455637145]
null_resource.exascale_configure_and_upload[0] (local-exec): ** WARNING: connection is not using a post-quantum key exchange algorithm.
null_resource.exascale_configure_and_upload[0] (local-exec): ** This session may be vulnerable to "store now, decrypt later" attacks.
null_resource.exascale_configure_and_upload[0] (local-exec): ** The server may need to be upgraded. See https://openssh.com/pq.html
null_resource.exascale_configure_and_upload[0]: Still creating... [00m20s elapsed]
null_resource.exascale_configure_and_upload[0]: Creation complete after 20s [id=8527093559834533813]

Apply complete! Resources: 46 added, 0 changed, 0 destroyed.

Outputs:

admin_password = <sensitive>
apps_instance_zone = ""
dbs_instance_zone = ""
deployment_summary = <<EOT
=========================================
        Oracle Vision VM Deployment
=========================================
 Project ID         : oracle-ebs-toolkit-demo
 Region             : northamerica-northeast2
 Zone               : northamerica-northeast2-a
 VPC Network        : oracle-ebs-toolkit-network

-----------------------------------------
 Vision Instance
-----------------------------------------
   • Name           : oracle-exascale-vision-app
   • Internal IP    : 10.115.0.40
   • SSH Command    :
       gcloud compute ssh --zone "northamerica-northeast2-a" "oracle-exascale-vision-app" --tunnel-through-iap --project "oracle-ebs-toolkit-demo"

-----------------------------------------
 Database Tier
-----------------------------------------
   • Type           : Oracle Database@Google Cloud (Exascale)
   • Cluster Name   : Exadata VM Cluster
   • SSH Key        : ./exadb_private_key.pem
   • Connection Info: Saved securely to ./exascale_outputs.yaml (TNS, SCAN DNS)
   • Connection String: Pending generation (Available after apply)

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : oracle-ebs-toolkit-storage-bucket-7c9e3a71
   • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71

-----------------------------------------
 User Credentials
-----------------------------------------
   • Username       : admin
   • Admin Password : Run this command to retrieve the admin password securely:

       terraform output admin_password

=========================================
 Summary
-----------------------------------------
   • Total Instances: 1 Exascale Vision VM + 1 Exascale Cluster
   • Storage Bucket : oracle-ebs-toolkit-storage-bucket-7c9e3a71
   • Admin Password : Run "terraform output admin_password" to retrieve securely
   • Generated At   : 2026-04-09T14:08:47Z
=========================================

EOT
exascale_vision_instance_zone = "northamerica-northeast2-a"
vision_instance_zone = ""
Thu Apr  9 17:44:50 EEST 2026

```

### 4. Stage Vision Media files

```

[user@desktop]  gcloud storage ls
gs://oracle-ebs-toolkit-demo-119724395047-terraform-state/
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/
gs://oracle-media/
[user@desktop]  gcloud storage cp gs://oracle-media/"*.zip" gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/
Copying gs://oracle-media/V1034613-01.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034613-01.zip
Copying gs://oracle-media/V1034614-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_1of2.zip
Copying gs://oracle-media/V1034614-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_2of2.zip
Copying gs://oracle-media/V1034637-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_1of2.zip
Copying gs://oracle-media/V1034637-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_2of2.zip
Copying gs://oracle-media/V1034645-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_1of2.zip
Copying gs://oracle-media/V1034645-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_2of2.zip
Copying gs://oracle-media/V1034652-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_1of2.zip
Copying gs://oracle-media/V1034652-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_2of2.zip
Copying gs://oracle-media/V1034656-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_1of2.zip
Copying gs://oracle-media/V1034656-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_2of2.zip
Copying gs://oracle-media/V1034663-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_1of2.zip
Copying gs://oracle-media/V1034663-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_2of2.zip
Copying gs://oracle-media/V1034669-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_1of2.zip
Copying gs://oracle-media/V1034669-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_2of2.zip
Copying gs://oracle-media/V1034670-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_1of2.zip
Copying gs://oracle-media/V1034670-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_2of2.zip
Copying gs://oracle-media/V1034671-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_1of2.zip
Copying gs://oracle-media/V1034671-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_2of2.zip
Copying gs://oracle-media/V1035290-01.zip to gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1035290-01.zip
  Completed files 20/20 | 68.0GiB/68.0GiB | 534.7MiB/s

Average throughput: 832.7MiB/s
[user@desktop] 

[user@desktop]  gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034613-01.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1035290-01.zip
[user@desktop] 

```

### 5. Deploy Oracle EBS Vision environment

```
[user@desktop]   gcloud compute instances list
NAME                        ZONE                       MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
oracle-exascale-vision-app  northamerica-northeast2-a  e2-standard-8               10.115.0.40               RUNNING
[user@desktop]

[user@desktop]  gcloud oracle-database exadb-vm-clusters list --location=northamerica-northeast2
---
backupOdbSubnet: projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet
createTime: '2026-04-09T13:02:12.226688649Z'
displayName: Exadata VM Cluster
entitlementId: e9ba70fb-1d6d-4539-8f05-e4a61819531e
gcpOracleZone: northamerica-northeast2-a-r2
labels:
  deployment: demo
  goog-terraform-provisioned: 'true'
name: projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01
odbNetwork: projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network
odbSubnet: projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet
properties:
  clusterName: exadb-cl1
  dataCollectionOptions:
    isDiagnosticsEventsEnabled: true
    isHealthMonitoringEnabled: true
    isIncidentLogsEnabled: true
  enabledEcpuCountPerNode: 8
  exascaleDbStorageVault: projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault
  giVersion: 19.30.0.0.0
  gridImageId: ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq
  hostname: exadb-node
  licenseModel: BRING_YOUR_OWN_LICENSE
  lifecycleState: AVAILABLE
  memorySizeGb: 22
  nodeCount: 1
  scanListenerPortTcp: 1521
  shapeAttribute: BLOCK_STORAGE
  sshPublicKeys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnIn3ojGgXqcYfMKIm00pI+up5RR0USV1iJO/YyGFtswzDwmW2WyvE/HcYlmgmIUSIsei2WlUOAfix6AucnGvg1ZFuy1tjTpAkaXejfbNgAh52esRj6EcDwKCxIVCxF4y9DFnnYTkfdMClzPje76aE1AzrT2olbEuz83WgePiKNgGa3FNgUj2Lxyu1K9frjXbmp/GN5VjBUYMbFsBvqHEldCSy1bUQfVNjkx9ED0PEV2ZAJOHWf8DbhlrT9IdJQ9Vf7Tj7tXRerZhDyv5Yyp4sbX6ZI8BaP2NPjAuG5Eeamw05saShqmeoY9ApQsoxg843bPpsR2et8osjkqcNNrfwo69d4cTdBZx6YQiZ+kSI18ObtPYcHeU1L79vO45VAKxf/SatLIDwJtD1Tcmsz4kJ7yynBj+0yJaM3cH+GORN1nzuSzpl0F537YqlH4AY9PDrGTmYp1k204x+XqWE4RkNaZ72a1kjN/4Gohm3yqBaTnm1HeoCYOyfLtYn30ubQifNw+jXdN3Ifr50otGc8enDhuZmFwM+08JuhB9rzCVtzlJ+dZDm5hPyM2N8hOWhKSO4nN1yc6FAb67P7XCfW60AgxWMfG0EZ+qMuEIIah4APL1HR9gOHMKefe+63IerdXcbrbWgaG4tZGzlTqcoUzzi0xkqkV0meYYgOIxspsI02Q==
  timeZone:
    id: UTC
  vmFileSystemStorage:
    sizeInGbsPerNode: 260
[user@desktop]  gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034613-01.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034614-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034637-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034645-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034652-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034656-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034663-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034669-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034670-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1034671-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-7c9e3a71/V1035290-01.zip
[user@desktop] 
[user@desktop] date; make exascale_oracle_vision_deploy ; date
Mon Apr 13 13:16:01 EEST 2026

>>> Getting Vision instance zone from Terraform output
Zone: northamerica-northeast2-a

>>> Creating /scripts on oracle-exascale-vision-app
mkdir: created directory '/scripts'
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

>>> Copying /scripts/* to oracle-exascale-vision-app
7zz                                                                                                                                                                                                                                                                                                                                       100% 2811KB   2.2MB/s   00:01
exa_post_dup.sh                                                                                                                                                                                                                                                                                                                           100% 4884    36.5KB/s   00:00
gcp_to_exa_db_sync_functions.sh                                                                                                                                                                                                                                                                                                           100%   19KB 127.9KB/s   00:00
gcp_to_exa_db_sync.sh                                                                                                                                                                                                                                                                                                                     100%  364     2.8KB/s   00:00
vision_apps_env.sh                                                                                                                                                                                                                                                                                                                        100%  305     2.2KB/s   00:00
vision_apps_fs_mount.sh                                                                                                                                                                                                                                                                                                                   100% 1144     8.6KB/s   00:00
vision_apps_fs_prepare.sh                                                                                                                                                                                                                                                                                                                 100% 4629    34.2KB/s   00:00
vision_apps_startup_exa.sh                                                                                                                                                                                                                                                                                                                100% 4026    30.1KB/s   00:00
vision_apps_startup.sh                                                                                                                                                                                                                                                                                                                    100% 3661    27.0KB/s   00:00

>>> Ownership updates /scripts/ on oracle-exascale-vision-app
changed ownership of '/scripts/7zz' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/exa_post_dup.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/gcp_to_exa_db_sync_functions.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/gcp_to_exa_db_sync.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/vision_apps_env.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/vision_apps_fs_mount.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/vision_apps_fs_prepare.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/vision_apps_startup_exa.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
changed ownership of '/scripts/vision_apps_startup.sh' from saldabols_pythian_com:saldabols_pythian_com to root:root
ownership of '/scripts' retained as root:root
mode of '/scripts/7zz' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)
mode of '/scripts/exa_post_dup.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/gcp_to_exa_db_sync_functions.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/gcp_to_exa_db_sync.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_env.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_fs_mount.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_fs_prepare.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_startup_exa.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_startup.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)

>>> Deploying Oracle EBS vision : Runtime ~ 50-60 minutes

### step: creating dir on server: /VMDK

### step: File Checksums of GCP BUCKET:
a1a6e2a3f6535fb94685bcdf28b44797 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034613-01.zip
2d7834065fb916e7d9dfde5fc0876f86 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034614-01_1of2.zip
d6f505bd6120c2092984b7a0d0e03d18 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034614-01_2of2.zip
61f98ec913c1e06173b647b4aed90f40 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034637-01_1of2.zip
16dc47697b582b43367377617594e13a gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034637-01_2of2.zip
ef50ef02a5cbb2652ecd19f22f915c12 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034645-01_1of2.zip
e3c829b09be160daf2381a2237600766 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034645-01_2of2.zip
e1eed5ba79a5247d890a3fe87a4eb265 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034652-01_1of2.zip
6586b4309e0f8a0567272df1dc393f88 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034652-01_2of2.zip
178f2361b6c5f1cd45b09f23851ce09e gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034656-01_1of2.zip
56c79886941d663e79713565c2331d55 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034656-01_2of2.zip
65a219465cf523243c5f6257469e6299 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034663-01_1of2.zip
8377da190700baa293f99ea16f58b08f gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034663-01_2of2.zip
e72a3471a03bd3733d0cbfa396f45ce1 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034669-01_1of2.zip
7c0152b9d30dd2221474afd84c471584 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034669-01_2of2.zip
0d153b95e3d9b730592d6b31c3fc9250 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034670-01_1of2.zip
bc4704750ab746a0012845f08cd8bf48 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034670-01_2of2.zip
245c8caa50ba0107ea40c1e10e7f89fe gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034671-01_1of2.zip
6ad9977ef8535a253ca1b05af71850a6 gs://oracle-ebs-toolkit-storage-bucket-086024db/V1034671-01_2of2.zip
8b75682b0fadeaeb86a2cd7333a1281f gs://oracle-ebs-toolkit-storage-bucket-086024db/V1035290-01.zip

### step: transfering Vision zip files to server

### step: File Checksums after local copy at /VMDK
a1a6e2a3f6535fb94685bcdf28b44797  /VMDK/V1034613-01.zip
2d7834065fb916e7d9dfde5fc0876f86  /VMDK/V1034614-01_1of2.zip
d6f505bd6120c2092984b7a0d0e03d18  /VMDK/V1034614-01_2of2.zip
61f98ec913c1e06173b647b4aed90f40  /VMDK/V1034637-01_1of2.zip
16dc47697b582b43367377617594e13a  /VMDK/V1034637-01_2of2.zip
ef50ef02a5cbb2652ecd19f22f915c12  /VMDK/V1034645-01_1of2.zip
e3c829b09be160daf2381a2237600766  /VMDK/V1034645-01_2of2.zip
e1eed5ba79a5247d890a3fe87a4eb265  /VMDK/V1034652-01_1of2.zip
6586b4309e0f8a0567272df1dc393f88  /VMDK/V1034652-01_2of2.zip
178f2361b6c5f1cd45b09f23851ce09e  /VMDK/V1034656-01_1of2.zip
56c79886941d663e79713565c2331d55  /VMDK/V1034656-01_2of2.zip
65a219465cf523243c5f6257469e6299  /VMDK/V1034663-01_1of2.zip
8377da190700baa293f99ea16f58b08f  /VMDK/V1034663-01_2of2.zip
e72a3471a03bd3733d0cbfa396f45ce1  /VMDK/V1034669-01_1of2.zip
7c0152b9d30dd2221474afd84c471584  /VMDK/V1034669-01_2of2.zip
0d153b95e3d9b730592d6b31c3fc9250  /VMDK/V1034670-01_1of2.zip
bc4704750ab746a0012845f08cd8bf48  /VMDK/V1034670-01_2of2.zip
245c8caa50ba0107ea40c1e10e7f89fe  /VMDK/V1034671-01_1of2.zip
6ad9977ef8535a253ca1b05af71850a6  /VMDK/V1034671-01_2of2.zip
8b75682b0fadeaeb86a2cd7333a1281f  /VMDK/V1035290-01.zip

### step: Extract zip files
Archive:  V1034613-01.zip
   creating: V1034613-01/
 extracting: V1034613-01/assemble_12212.zip
  inflating: V1034613-01/README.txt
   creating: V1034613-01/Documents/
  inflating: V1034613-01/Documents/vb12212_4.gif
  inflating: V1034613-01/Documents/sqlconnection2.gif
  inflating: V1034613-01/Documents/Doc2933812.1_Oracle VM Virtual Appliance for Oracle E-Business Suite Deployment Guide_Release 12.2.12.html
  inflating: V1034613-01/Documents/vb12212_1.gif
  inflating: V1034613-01/Documents/createvm12212_1.gif
  inflating: V1034613-01/Documents/createvm12212_3.gif
  inflating: V1034613-01/Documents/vb12212_3.gif
  inflating: V1034613-01/Documents/vb12212_2.gif
  inflating: V1034613-01/Documents/createvm12212_2.gif
  inflating: V1034613-01/Documents/vision12212_2.gif
  inflating: V1034613-01/Documents/vm12212_4.gif
  inflating: V1034613-01/Documents/vm12212_5.gif
  inflating: V1034613-01/Documents/vision12212_1.gif
  inflating: V1034613-01/Documents/sqlconnection.gif
  inflating: V1034613-01/Documents/vm12212_2.gif
  inflating: V1034613-01/Documents/vm12212_3.gif
  inflating: V1034613-01/Documents/vm12212_1.gif
  inflating: V1034613-01/Documents/vmgr.gif
Archive:  V1034614-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.00
Archive:  V1034614-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.01
Archive:  V1034637-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.02
Archive:  V1034637-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.03
Archive:  V1034645-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.04
Archive:  V1034645-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.05
Archive:  V1034652-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.06
Archive:  V1034652-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.07
Archive:  V1034656-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.08
Archive:  V1034656-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.09
Archive:  V1034663-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.10
Archive:  V1034663-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.11
Archive:  V1034669-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.12
Archive:  V1034669-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.13
Archive:  V1034670-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.14
Archive:  V1034670-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.15
Archive:  V1034671-01_1of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.16
Archive:  V1034671-01_2of2.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.17
Archive:  V1035290-01.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.18
removed '/VMDK/V1034613-01.zip'
removed '/VMDK/V1034614-01_1of2.zip'
removed '/VMDK/V1034614-01_2of2.zip'
removed '/VMDK/V1034637-01_1of2.zip'
removed '/VMDK/V1034637-01_2of2.zip'
removed '/VMDK/V1034645-01_1of2.zip'
removed '/VMDK/V1034645-01_2of2.zip'
removed '/VMDK/V1034652-01_1of2.zip'
removed '/VMDK/V1034652-01_2of2.zip'
removed '/VMDK/V1034656-01_1of2.zip'
removed '/VMDK/V1034656-01_2of2.zip'
removed '/VMDK/V1034663-01_1of2.zip'
removed '/VMDK/V1034663-01_2of2.zip'
removed '/VMDK/V1034669-01_1of2.zip'
removed '/VMDK/V1034669-01_2of2.zip'
removed '/VMDK/V1034670-01_1of2.zip'
removed '/VMDK/V1034670-01_2of2.zip'
removed '/VMDK/V1034671-01_1of2.zip'
removed '/VMDK/V1034671-01_2of2.zip'
removed '/VMDK/V1035290-01.zip'

### step: Merge OVA's
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.00'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.01'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.02'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.03'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.04'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.05'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.06'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.07'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.08'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.09'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.10'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.11'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.12'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.13'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.14'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.15'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.16'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.17'
removed '/VMDK/Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.18'

### step: Extract OVA
Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ovf
Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
removed 'VISION_INSTALL.ova'

### step: Extract VMDK (using 7zz) - this takes time ~25 min

7-Zip (z) 25.01 (x64) : Copyright (c) 1999-2025 Igor Pavlov : 2025-08-03
 64-bit locale=en_US.UTF-8 Threads:8 OPEN_MAX:1024, ASM

Scanning the drive for archives:
1 file, 76394591232 bytes (72 GiB)

Extracting archive: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
--
Path = Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
Type = VMDK
Physical Size = 76394591232
Total Physical Size = 76394591232
Method = "streamOptimized" zlib Marker
Cluster Size = 65536
Headers Size = 65536
ID = 9b2f2b79
Name = Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
Comment =
{
# Disk DescriptorFile
version=1
CID=9b2f2b79
parentCID=ffffffff
createType="streamOptimized"

# Extent description
RDONLY 838860800 SPARSE "Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk"

# The disk Data Base
#DDB

ddb.virtualHWVersion = "4"
ddb.adapterType="ide"
ddb.geometry.cylinders="16383"
ddb.geometry.heads="16"
ddb.geometry.sectors="63"
ddb.geometry.biosCylinders="1024"
ddb.geometry.biosHeads="255"
ddb.geometry.biosSectors="63"
ddb.uuid.image="4405b9d5-698b-46fa-b146-3529dd0aa368"
ddb.uuid.parent="00000000-0000-0000-0000-000000000000"
ddb.uuid.modification="00000000-0000-0000-0000-000000000000"
ddb.uuid.parentmodification="00000000-0000-0000-0000-000000000000"
ddb.comment=""
}
----
Size = 429496729600
Packed Size = 76394525696
--
Path = Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.mbr
Type = MBR
Physical Size = 429496729600
Sector Size = 512
ID = 81223

Everything is Ok

Files: 2
Size:       429495681024
Compressed: 76394591232

### step: Get and Attach LVM
1.lvm
/dev/loop0: [2050]:2197820934 (/VMDK/1.lvm)
  Found volume group "ol" using metadata type lvm2
  3 logical volume(s) in volume group "ol" now active
  --- Logical volume ---
  LV Path                /dev/ol/swap
  LV Name                swap
  VG Name                ol
  LV UUID                hgEVZN-8vWp-Tvb1-lDrY-bOW0-Ard5-8ZgmG0
  LV Write Access        read/write
  LV Creation host, time localhost, 2019-11-19 04:25:59 +0000
  LV Status              available
  # open                 0
  LV Size                <7.88 GiB
  Current LE             2016
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           252:0

  --- Logical volume ---
  LV Path                /dev/ol/home
  LV Name                home
  VG Name                ol
  LV UUID                oVEq9K-mxLr-5gG9-nUd0-YvoI-eT8I-SrNJMy
  LV Write Access        read/write
  LV Creation host, time localhost, 2019-11-19 04:26:00 +0000
  LV Status              available
  # open                 0
  LV Size                <341.12 GiB
  Current LE             87326
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           252:1

  --- Logical volume ---
  LV Path                /dev/ol/root
  LV Name                root
  VG Name                ol
  LV UUID                qml0lx-1Z79-hPnA-JKSD-EweX-3QdB-yDL82f
  LV Write Access        read/write
  LV Creation host, time localhost, 2019-11-19 04:26:02 +0000
  LV Status              available
  # open                 0
  LV Size                50.00 GiB
  Current LE             12800
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           252:2

Mounting /dev/ol/home

### step: /etc/hosts update
renamed '/etc/hosts' -> '/etc/hosts.org'
renamed '/etc/hosts.new' -> '/etc/hosts'
Checking crontab for FS mount on startup
Add crontab: mount FS on startup

### step: hostname update to apps
apps
Checking crontab for hostname set on startup
Add crontab: set hostname on startup

### step: Oracle EBS Vision startup
Directory /u01/install/APPS is available.

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 13 11:00:46 2026
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORACLE instance shut down.
SQL> Disconnected
Logfile: /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt

You are running addlnctl.sh version 120.4


Starting listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 13-APR-2026 11:00:51

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Starting /u01/install/APPS/19.0.0/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u01/install/APPS/19.0.0/network/admin/listener.ora
Log messages written to /u01/install/APPS/19.0.0/log/diag/tnslsnr/apps/ebscdb/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=apps.example.com)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=apps.example.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                13-APR-2026 11:00:51
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/install/APPS/19.0.0/network/admin/listener.ora
Listener Log File         /u01/install/APPS/19.0.0/log/diag/tnslsnr/apps/ebscdb/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=apps.example.com)(PORT=1521)))
The listener supports no services
The command completed successfully

addlnctl.sh: exiting with status 0

addlnctl.sh: check the logfile /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt for more information ...


SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 13 11:00:51 2026
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORA-32004: obsolete or deprecated parameter(s) specified for RDBMS instance
ORACLE instance started.

Total System Global Area 2147482520 bytes
Fixed Size		    9165720 bytes
Variable Size		 1392508928 bytes
Database Buffers	  721420288 bytes
Redo Buffers		   24387584 bytes
Database mounted.
Database opened.
SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 13 11:01:17 2026
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0

SQL>
System altered.

SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0
Logfile: /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt

You are running addlnctl.sh version 120.4


Finding status of listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 13-APR-2026 11:01:17

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=apps.example.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                13-APR-2026 11:00:51
Uptime                    0 days 0 hr. 0 min. 26 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/install/APPS/19.0.0/network/admin/listener.ora
Listener Log File         /u01/install/APPS/19.0.0/log/diag/tnslsnr/apps/ebscdb/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=apps.example.com)(PORT=1521)))
Services Summary...
Service "2809223196ec2af8e053a740d20a4db6" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
Service "EBSCDB" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
Service "EBSCDBXDB" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
Service "EBSDB_ebs_patch" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
Service "ebs_EBSDB" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
Service "ebsdb" has 1 instance(s).
  Instance "EBSCDB", status READY, has 1 handler(s) for this service...
The command completed successfully

addlnctl.sh: exiting with status 0

addlnctl.sh: check the logfile /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt for more information ...


>>> Deploying Oracle EBS vision on Oracle Exascale @GCP: Runtime ~ 30 minutes
Mon Apr 13 11:01:26 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: create_exainfo
         ====================================================================
         Function Fetches Exascale connection details and admin PWD
         --------------------------------------------------------------------

### Fetching ExaScale details to GCP
File /tmp/exascale_outputs.yaml exists. Creating EXAINFO file.

log: /scripts/logs/20260413_110126_create_exainfo.log
Mon Apr 13 11:01:26 UTC 2026
Mon Apr 13 11:01:26 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: test_exa_connection
         ====================================================================
         Function Tests connectivity to Exascale using details from EXAINFO file
         --------------------------------------------------------------------

### Testing Oracle Exascale @GCP connection
Exadata connection as sys user validated successfully.
Exadata tns connection string is : (DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.7.222)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.1.42)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.3.66)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=EBSCDB_qh2_yyz.bpuarntviv.v63b7f69c.oraclevcn.com)))

log: /scripts/logs/20260413_110126_test_exa_connection.log
Mon Apr 13 11:01:26 UTC 2026
Mon Apr 13 11:01:26 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: update_pass
         ====================================================================
         Function updates passwords for SYS and creates password file for Exascale duplicate operation into Exascale
         --------------------------------------------------------------------

### Updating SYS passwords for Database duplicate opeation into Exascale
Updating system and ebs_system password in Gcp Vision Database
'Updating SYS and SYSTEM passwords'

User altered.


User altered.


Session altered.

'Updating EBS_SYSTEM password'

User altered.


log: /scripts/logs/20260413_110126_update_pass.log
Mon Apr 13 11:01:27 UTC 2026
Mon Apr 13 11:01:27 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: enable_gcp_archivelog
         ====================================================================
         Function Enable archivelog mode in GCP Vision Database, this is a pre-requisite for rman duplicate operation into Exascale
         --------------------------------------------------------------------

### Checking ARCHIVELOG mode...
'Setting DB_RECOVERY_FILE_DEST to /u01/install/APPS/data/archive'

System altered.


System altered.


### Database is in NOARCHIVELOG mode. Enabling ARCHIVELOG mode...
Database closed.
Database dismounted.
ORACLE instance shut down.
ORA-32004: obsolete or deprecated parameter(s) specified for RDBMS instance
ORACLE instance started.

Total System Global Area 2147482520 bytes
Fixed Size		    9165720 bytes
Variable Size		 1392508928 bytes
Database Buffers	  721420288 bytes
Redo Buffers		   24387584 bytes
Database mounted.

Database altered.


Database altered.


### ARCHIVELOG mode enabled.
'Current log mode:'

ARCHIVELOG


log: /scripts/logs/20260413_110127_enable_gcp_archivelog.log
Mon Apr 13 11:02:44 UTC 2026
Mon Apr 13 11:02:44 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: find_drop_exa_pdbs
         ====================================================================
         Function to drop preexisting PDB1 on CDB creation
         --------------------------------------------------------------------

### Drop PDBs if exists

### PDBS present in Exadata Database: PDB1

### Dropping pdb PDB1
'Setting REMOTE_RECOVERY_FILE_DEST to +RECOEBSCDB'

System altered.

'Setting SEC_CASE_SENSITIVE_LOGON to FALSE'

System altered.

'PDBS BEFORE DROP'

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 PDB1 			  READ WRITE NO
'Closing PDB PDB1'

Pluggable database altered.

'Dropping PDB PDB1, this process can take a few minutes to complete...'

Pluggable database dropped.

'PDBS AFTER DROP'

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO

log: /scripts/logs/20260413_110244_find_drop_exa_pdbs.log
Mon Apr 13 11:02:46 UTC 2026
Mon Apr 13 11:02:46 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: transfer_files
         ====================================================================
         Function transfers required files for Exascale Database setup
         --------------------------------------------------------------------

### Transferring files to Exascale Database Server

### Setting up ssh connection for file transfer and remote command execution
Warning: Permanently added '10.116.0.12' (ECDSA) to the list of known hosts.
SSH connection to Exascale Server is working
mode of '/tmp/exa_post_dup.sh' changed from 0775 (rwxrwxr-x) to 0755 (rwxr-xr-x)
mode of '/tmp/appsutil.zip' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)
mode of '/tmp/EXAINFO' retained as 0755 (rwxr-xr-x)
mode of '/tmp/9idata.zip' changed from 0644 (rw-r--r--) to 0755 (rwxr-xr-x)

log: /scripts/logs/20260413_110246_transfer_files.log
Mon Apr 13 11:03:24 UTC 2026
Mon Apr 13 11:03:24 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: exa_rman_dup
         ====================================================================
         Function Clone Vision Database PDB into Exascale using RMAN duplicate pluggable database from active database command
         --------------------------------------------------------------------

### Duplicating database verbose

### Running rman duplicate to clone PDB from apps to EXACS

Recovery Manager: Release 19.0.0.0.0 - Production on Mon Apr 13 11:03:24 2026
Version 19.18.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: EBSCDB (DBID=1034752545)
connected to auxiliary database: EBSCDB (DBID=1136368628)

RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13> 14> 15> 16> 17> 18> 19> 20> 21> 22>
using target database control file instead of recovery catalog
allocated channel: c1
channel c1: SID=206 device type=DISK

allocated channel: c2
channel c2: SID=613 device type=DISK

allocated channel: c3
channel c3: SID=109 device type=DISK

allocated channel: c4
channel c4: SID=207 device type=DISK

allocated channel: c5
channel c5: SID=312 device type=DISK

allocated channel: c6
channel c6: SID=711 device type=DISK

allocated channel: c7
channel c7: SID=412 device type=DISK

allocated channel: c8
channel c8: SID=514 device type=DISK

allocated channel: a1
channel a1: SID=68 instance=EBSCDB1 device type=DISK

allocated channel: a2
channel a2: SID=2374 instance=EBSCDB1 device type=DISK

allocated channel: a3
channel a3: SID=2389 instance=EBSCDB1 device type=DISK

allocated channel: a4
channel a4: SID=2390 instance=EBSCDB1 device type=DISK

allocated channel: a5
channel a5: SID=2391 instance=EBSCDB1 device type=DISK

allocated channel: a6
channel a6: SID=2392 instance=EBSCDB1 device type=DISK

allocated channel: a7
channel a7: SID=2393 instance=EBSCDB1 device type=DISK

allocated channel: a8
channel a8: SID=69 instance=EBSCDB1 device type=DISK

Starting Duplicate PDB at 13-APR-26
current log archived
duplicating Online logs to Oracle Managed File (OMF) location
duplicating Datafiles to Oracle Managed File (OMF) location
current log archived

contents of Memory Script:
{
   sql clone 'alter database flashback off';
   set newname for clone datafile  9 to new;
   set newname for clone datafile  10 to new;
   set newname for clone datafile  11 to new;
   set newname for clone datafile  12 to new;
   set newname for clone datafile  13 to new;
   set newname for clone datafile  14 to new;
   set newname for clone datafile  15 to new;
   set newname for clone datafile  16 to new;
   set newname for clone datafile  17 to new;
   set newname for clone datafile  18 to new;
   set newname for clone datafile  19 to new;
   set newname for clone datafile  20 to new;
   set newname for clone datafile  21 to new;
   set newname for clone datafile  22 to new;
   set newname for clone datafile  23 to new;
   set newname for clone datafile  24 to new;
   set newname for clone datafile  25 to new;
   set newname for clone datafile  26 to new;
   set newname for clone datafile  27 to new;
   set newname for clone datafile  28 to new;
   set newname for clone datafile  29 to new;
   set newname for clone datafile  30 to new;
   set newname for clone datafile  31 to new;
   set newname for clone datafile  32 to new;
   set newname for clone datafile  33 to new;
   set newname for clone datafile  34 to new;
   set newname for clone datafile  35 to new;
   set newname for clone datafile  36 to new;
   set newname for clone datafile  37 to new;
   set newname for clone datafile  38 to new;
   set newname for clone datafile  39 to new;
   set newname for clone datafile  40 to new;
   set newname for clone datafile  41 to new;
   set newname for clone datafile  42 to new;
   set newname for clone datafile  43 to new;
   set newname for clone datafile  44 to new;
   set newname for clone datafile  45 to new;
   set newname for clone datafile  46 to new;
   set newname for clone datafile  47 to new;
   set newname for clone datafile  48 to new;
   set newname for clone datafile  49 to new;
   set newname for clone datafile  50 to new;
   set newname for clone datafile  51 to new;
   set newname for clone datafile  52 to new;
   set newname for clone datafile  53 to new;
   set newname for clone datafile  54 to new;
   set newname for clone datafile  55 to new;
   set newname for clone datafile  56 to new;
   set newname for clone datafile  57 to new;
   set newname for clone datafile  58 to new;
   set newname for clone datafile  59 to new;
   set newname for clone datafile  60 to new;
   set newname for clone datafile  61 to new;
   set newname for clone datafile  62 to new;
   set newname for clone datafile  63 to new;
   set newname for clone datafile  64 to new;
   set newname for clone datafile  65 to new;
   set newname for clone datafile  66 to new;
   set newname for clone datafile  67 to new;
   set newname for clone datafile  68 to new;
   set newname for clone datafile  69 to new;
   set newname for clone datafile  70 to new;
   set newname for clone datafile  71 to new;
   set newname for clone datafile  72 to new;
   set newname for clone datafile  73 to new;
   set newname for clone datafile  74 to new;
   set newname for clone datafile  75 to new;
   set newname for clone datafile  76 to new;
   set newname for clone datafile  77 to new;
   set newname for clone datafile  78 to new;
   set newname for clone datafile  79 to new;
   set newname for clone datafile  80 to new;
   set newname for clone datafile  81 to new;
   set newname for clone datafile  82 to new;
   set newname for clone datafile  83 to new;
   set newname for clone datafile  84 to new;
   set newname for clone datafile  85 to new;
   set newname for clone datafile  86 to new;
   set newname for clone datafile  87 to new;
   set newname for clone datafile  88 to new;
   set newname for clone datafile  89 to new;
   set newname for clone datafile  90 to new;
   set newname for clone datafile  91 to new;
   set newname for clone datafile  92 to new;
   set newname for clone datafile  93 to new;
   set newname for clone datafile  94 to new;
   set newname for clone datafile  95 to new;
   set newname for clone datafile  96 to new;
   set newname for clone datafile  97 to new;
   set newname for clone datafile  98 to new;
   set newname for clone datafile  99 to new;
   set newname for clone datafile  100 to new;
   set newname for clone datafile  101 to new;
   set newname for clone datafile  102 to new;
   set newname for clone datafile  103 to new;
   set newname for clone datafile  104 to new;
   set newname for clone datafile  105 to new;
   set newname for clone datafile  106 to new;
   set newname for clone datafile  107 to new;
   set newname for clone datafile  108 to new;
   set newname for clone datafile  109 to new;
   set newname for clone datafile  110 to new;
   set newname for clone datafile  111 to new;
   set newname for clone datafile  112 to new;
   set newname for clone datafile  113 to new;
   set newname for clone datafile  114 to new;
   set newname for clone datafile  115 to new;
   set newname for clone datafile  116 to new;
   set newname for clone datafile  117 to new;
   set newname for clone datafile  118 to new;
   set newname for clone datafile  119 to new;
   set newname for clone datafile  120 to new;
   set newname for clone datafile  121 to new;
   set newname for clone datafile  122 to new;
   set newname for clone datafile  123 to new;
   set newname for clone datafile  124 to new;
   set newname for clone datafile  125 to new;
   set newname for clone datafile  126 to new;
   restore
   from  nonsparse   clone foreign pluggable database
    "EBSDB"
   from service  '(DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))'   ;
}
executing Memory Script

sql statement: alter database flashback off

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

Starting restore at 13-APR-26

channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 9 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.272.1230462247
channel a1: restore complete, elapsed time: 00:00:33
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 10 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.267.1230462247
channel a2: restore complete, elapsed time: 00:00:34
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 11 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.268.1230462247
channel a3: restore complete, elapsed time: 00:00:34
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 12 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.270.1230462247
channel a4: restore complete, elapsed time: 00:00:35
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 16 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.274.1230462251
channel a8: restore complete, elapsed time: 00:00:32
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 13 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.271.1230462249
channel a5: restore complete, elapsed time: 00:00:35
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 14 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.269.1230462251
channel a6: restore complete, elapsed time: 00:00:35
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 15 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.273.1230462251
channel a7: restore complete, elapsed time: 00:00:35
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 20 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.278.1230462283
channel a4: restore complete, elapsed time: 00:00:19
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 22 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.280.1230462285
channel a5: restore complete, elapsed time: 00:00:18
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 21 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.279.1230462283
channel a8: restore complete, elapsed time: 00:00:20
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 23 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.281.1230462287
channel a6: restore complete, elapsed time: 00:00:19
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 24 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.282.1230462287
channel a7: restore complete, elapsed time: 00:00:19
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 17 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.275.1230462281
channel a1: restore complete, elapsed time: 00:00:25
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 18 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.276.1230462281
channel a2: restore complete, elapsed time: 00:00:25
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 19 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.277.1230462281
channel a3: restore complete, elapsed time: 00:00:26
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 31 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_omo.289.1230462309
channel a2: restore complete, elapsed time: 00:00:06
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 32 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_omo.290.1230462309
channel a3: restore complete, elapsed time: 00:00:06
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 25 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.283.1230462301
channel a4: restore complete, elapsed time: 00:00:16
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 29 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/sysaux.287.1230462307
channel a7: restore complete, elapsed time: 00:00:15
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 33 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_archive.291.1230462315
channel a2: restore complete, elapsed time: 00:00:07
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 34 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_archive.292.1230462315
channel a3: restore complete, elapsed time: 00:00:06
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 30 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/sysaux.288.1230462307
channel a1: restore complete, elapsed time: 00:00:15
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 26 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.284.1230462303
channel a5: restore complete, elapsed time: 00:00:18
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 28 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.286.1230462305
channel a6: restore complete, elapsed time: 00:00:18
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 27 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/system.285.1230462303
channel a8: restore complete, elapsed time: 00:00:20
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 40 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_nologging.298.1230462321
channel a5: restore complete, elapsed time: 00:00:06
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 42 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_queues.300.1230462323
channel a8: restore complete, elapsed time: 00:00:05
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 39 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_media.297.1230462321
channel a1: restore complete, elapsed time: 00:00:08
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 41 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_nologging.299.1230462323
channel a6: restore complete, elapsed time: 00:00:08
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 35 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_interface.293.1230462317
channel a4: restore complete, elapsed time: 00:00:13
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 36 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_media.294.1230462319
channel a7: restore complete, elapsed time: 00:00:13
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 43 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_queues.301.1230462327
channel a5: restore complete, elapsed time: 00:00:09
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 37 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_media.295.1230462319
channel a2: restore complete, elapsed time: 00:00:19
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 38 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_media.296.1230462321
channel a3: restore complete, elapsed time: 00:00:34
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 47 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_seed.305.1230462333
channel a4: restore complete, elapsed time: 00:00:24
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 46 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_seed.304.1230462331
channel a6: restore complete, elapsed time: 00:00:25
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 44 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_seed.302.1230462329
channel a8: restore complete, elapsed time: 00:00:27
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 45 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_seed.303.1230462329
channel a1: restore complete, elapsed time: 00:00:28
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 50 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.308.1230462339
channel a2: restore complete, elapsed time: 00:00:18
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 49 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.307.1230462337
channel a5: restore complete, elapsed time: 00:00:21
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 48 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_seed.306.1230462333
channel a7: restore complete, elapsed time: 00:00:25
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 55 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.313.1230462355
channel a1: restore complete, elapsed time: 00:00:16
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 56 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.314.1230462355
channel a2: restore complete, elapsed time: 00:00:16
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 51 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.309.1230462353
channel a3: restore complete, elapsed time: 00:00:20
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 52 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.310.1230462355
channel a4: restore complete, elapsed time: 00:00:20
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 53 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.311.1230462355
channel a6: restore complete, elapsed time: 00:00:20
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 54 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_summary.312.1230462355
channel a8: restore complete, elapsed time: 00:00:21
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 57 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.315.1230462357
channel a5: restore complete, elapsed time: 00:00:20
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 58 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.316.1230462357
channel a7: restore complete, elapsed time: 00:00:22
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 59 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.317.1230462373
channel a1: restore complete, elapsed time: 00:00:33
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 60 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.318.1230462373
channel a2: restore complete, elapsed time: 00:00:34
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 62 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.320.1230462375
channel a4: restore complete, elapsed time: 00:00:33
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 63 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.321.1230462377
channel a6: restore complete, elapsed time: 00:00:34
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 64 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.322.1230462377
channel a8: restore complete, elapsed time: 00:00:34
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 65 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.323.1230462379
channel a5: restore complete, elapsed time: 00:00:34
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 66 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.324.1230462381
channel a7: restore complete, elapsed time: 00:00:33
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 61 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.319.1230462375
channel a3: restore complete, elapsed time: 00:00:39
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 67 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.325.1230462407
channel a1: restore complete, elapsed time: 00:00:34
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 68 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.326.1230462407
channel a2: restore complete, elapsed time: 00:00:34
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 69 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.327.1230462409
channel a4: restore complete, elapsed time: 00:00:35
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 70 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.328.1230462409
channel a6: restore complete, elapsed time: 00:00:35
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 71 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.329.1230462411
channel a8: restore complete, elapsed time: 00:00:36
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 72 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.330.1230462413
channel a5: restore complete, elapsed time: 00:00:36
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 73 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.331.1230462415
channel a7: restore complete, elapsed time: 00:00:37
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 74 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.332.1230462415
channel a3: restore complete, elapsed time: 00:00:37
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 75 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.333.1230462441
channel a1: restore complete, elapsed time: 00:00:37
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 76 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.334.1230462443
channel a2: restore complete, elapsed time: 00:00:37
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 77 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.335.1230462445
channel a4: restore complete, elapsed time: 00:00:36
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 78 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.336.1230462445
channel a6: restore complete, elapsed time: 00:00:36
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 79 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.337.1230462447
channel a8: restore complete, elapsed time: 00:00:35
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 80 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.338.1230462449
channel a5: restore complete, elapsed time: 00:00:36
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 81 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.339.1230462451
channel a7: restore complete, elapsed time: 00:00:35
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 82 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.340.1230462451
channel a3: restore complete, elapsed time: 00:00:34
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 83 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.341.1230462477
channel a1: restore complete, elapsed time: 00:00:15
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 84 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.342.1230462479
channel a2: restore complete, elapsed time: 00:00:15
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 85 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.343.1230462481
channel a4: restore complete, elapsed time: 00:00:15
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 88 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.346.1230462483
channel a5: restore complete, elapsed time: 00:00:11
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 86 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.344.1230462481
channel a6: restore complete, elapsed time: 00:00:15
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 87 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_data.345.1230462483
channel a8: restore complete, elapsed time: 00:00:16
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 89 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.347.1230462483
channel a7: restore complete, elapsed time: 00:00:22
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 90 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.348.1230462485
channel a3: restore complete, elapsed time: 00:00:25
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 91 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.349.1230462493
channel a1: restore complete, elapsed time: 00:00:35
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 92 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.350.1230462493
channel a2: restore complete, elapsed time: 00:00:34
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 93 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.351.1230462493
channel a4: restore complete, elapsed time: 00:00:34
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 94 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.352.1230462495
channel a5: restore complete, elapsed time: 00:00:34
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 95 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.353.1230462497
channel a6: restore complete, elapsed time: 00:00:34
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 96 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.354.1230462499
channel a8: restore complete, elapsed time: 00:00:33
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 98 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.356.1230462511
channel a3: restore complete, elapsed time: 00:00:21
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 97 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.355.1230462507
channel a7: restore complete, elapsed time: 00:00:26
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 99 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.357.1230462525
channel a1: restore complete, elapsed time: 00:00:32
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 100 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.358.1230462527
channel a2: restore complete, elapsed time: 00:00:32
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 105 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.363.1230462533
channel a3: restore complete, elapsed time: 00:00:29
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 101 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.359.1230462527
channel a4: restore complete, elapsed time: 00:00:32
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 102 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.360.1230462529
channel a5: restore complete, elapsed time: 00:00:33
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 103 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.361.1230462529
channel a6: restore complete, elapsed time: 00:00:32
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 106 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.364.1230462535
channel a7: restore complete, elapsed time: 00:00:30
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 104 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.362.1230462531
channel a8: restore complete, elapsed time: 00:00:33
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 114 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/ctxsys.372.1230462563
channel a8: restore complete, elapsed time: 00:00:04
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 109 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.367.1230462559
channel a3: restore complete, elapsed time: 00:00:10
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 116 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/dm_archive.374.1230462569
channel a3: restore complete, elapsed time: 00:00:01
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 115 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/dcm.373.1230462565
channel a8: restore complete, elapsed time: 00:00:05
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a4: restoring foreign file 110 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.368.1230462561
channel a4: restore complete, elapsed time: 00:00:13
channel a4: starting datafile backup set restore
channel a4: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a4: specifying datafile(s) to restore from backup set
channel a1: restoring foreign file 107 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.365.1230462557
channel a1: restore complete, elapsed time: 00:00:15
channel a1: starting datafile backup set restore
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 108 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.366.1230462559
channel a2: restore complete, elapsed time: 00:00:15
channel a2: starting datafile backup set restore
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: specifying datafile(s) to restore from backup set
channel a3: restoring foreign file 117 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/mtr.375.1230462571
channel a3: restore complete, elapsed time: 00:00:04
channel a3: starting datafile backup set restore
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: specifying datafile(s) to restore from backup set
channel a5: restoring foreign file 111 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.369.1230462561
channel a5: restore complete, elapsed time: 00:00:14
channel a5: starting datafile backup set restore
channel a5: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a5: specifying datafile(s) to restore from backup set
channel a6: restoring foreign file 112 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.370.1230462561
channel a6: restore complete, elapsed time: 00:00:14
channel a6: starting datafile backup set restore
channel a6: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a6: specifying datafile(s) to restore from backup set
channel a7: restoring foreign file 113 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_ts_tx_idx.371.1230462563
channel a7: restore complete, elapsed time: 00:00:13
channel a7: starting datafile backup set restore
channel a7: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a7: specifying datafile(s) to restore from backup set
channel a8: restoring foreign file 118 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/odm_data.376.1230462571
channel a8: restore complete, elapsed time: 00:00:04
channel a8: starting datafile backup set restore
channel a8: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a8: specifying datafile(s) to restore from backup set
channel a2: restoring foreign file 121 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/xdb.379.1230462573
channel a2: restore complete, elapsed time: 00:00:02
channel a4: restoring foreign file 119 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/owb.377.1230462571
channel a4: restore complete, elapsed time: 00:00:03
channel a1: restoring foreign file 120 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/owb.378.1230462573
channel a1: restore complete, elapsed time: 00:00:09
channel a3: restoring foreign file 122 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_undots1.380.1230462573
channel a3: restore complete, elapsed time: 00:00:08
channel a5: restoring foreign file 123 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_undots1.381.1230462573
channel a5: restore complete, elapsed time: 00:00:16
channel a6: restoring foreign file 124 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_undots1.382.1230462573
channel a6: restore complete, elapsed time: 00:00:16
channel a7: restoring foreign file 125 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_undots1.383.1230462575
channel a7: restore complete, elapsed time: 00:00:16
channel a8: restoring foreign file 126 to +DATAEBSCDB/EBSCDB_QH2_YYZ/2809223196EC2AF8E053A740D20A4DB6/DATAFILE/apps_undots1.384.1230462575
channel a8: restore complete, elapsed time: 00:00:15
Finished restore at 13-APR-26

contents of Memory Script:
{
   set archivelog destination to  '+RECOEBSCDB';
   restore clone force from service  '(DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))'
           foreign archivelog from scn  12204632166475;
}
executing Memory Script

executing command: SET ARCHIVELOG DESTINATION

Starting restore at 13-APR-26

channel a1: starting archived log restore to user-specified destination
archived log destination=+RECOEBSCDB
channel a1: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a1: restoring archived log
archived log thread=1 sequence=689
channel a2: starting archived log restore to user-specified destination
archived log destination=+RECOEBSCDB
channel a2: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a2: restoring archived log
archived log thread=1 sequence=690
channel a3: starting archived log restore to user-specified destination
archived log destination=+RECOEBSCDB
channel a3: using network backup set from service (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=EBSCDB))(ADDRESS=(PROTOCOL=tcp)(HOST=10.115.0.40)(PORT=1521)))
channel a3: restoring archived log
archived log thread=1 sequence=691
channel a1: restore complete, elapsed time: 00:00:01
channel a2: restore complete, elapsed time: 00:00:01
channel a3: restore complete, elapsed time: 00:00:01
Finished restore at 13-APR-26

Performing import of metadata...
Finished Duplicate PDB at 13-APR-26
released channel: c1
released channel: c2
released channel: c3
released channel: c4
released channel: c5
released channel: c6
released channel: c7
released channel: c8
released channel: a1
released channel: a2
released channel: a3
released channel: a4
released channel: a5
released channel: a6
released channel: a7
released channel: a8

RMAN>

Recovery Manager complete.

log: /scripts/logs/20260413_110324_exa_rman_dup.log
Mon Apr 13 11:10:25 UTC 2026
Mon Apr 13 11:10:25 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: post_config_exa_db
         ====================================================================
         Function Post configuration steps after database duplication into Exascale
         --------------------------------------------------------------------

### Running post configuration steps after database duplication into Exascale
Copy over appsutil to ORACLE HOME
'/tmp/appsutil.zip' -> '/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil.zip'
Copy over 9idata to ORACLE HOME
'/tmp/9idata.zip' -> '/u02/app/oracle/product/19.0.0.0/dbhome_1/9idata.zip'
Starting function run_datapatch at 130426111031
Restarting database EBSCDB_qh2_yyz in upgrade mode

System altered.

Database closed.
Database dismounted.
ORACLE instance shut down.
ORA-32004: obsolete or deprecated parameter(s) specified for RDBMS instance
ORACLE instance started.

Total System Global Area 3977102704 bytes
Fixed Size		    9188720 bytes
Variable Size		 1006632960 bytes
Database Buffers	 2684354560 bytes
Redo Buffers		  276926464 bytes
Database mounted.
Database opened.

Pluggable database altered.

Running datapatch
SQL Patching tool version 19.30.0.0.0 Production on Mon Apr 13 11:11:23 2026
Copyright (c) 2012, 2026, Oracle.  All rights reserved.

Log file for this invocation: /u02/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_371398_2026_04_13_11_11_23/sqlpatch_invocation.log

Connecting to database...OK
Gathering database info...done

Note:  Datapatch will only apply or rollback SQL fixes for PDBs
       that are in an open state, no patches will be applied to closed PDBs.
       Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
       (Doc ID 1585822.1)

Bootstrapping registry and package to current versions...done
Determining current state...done

Current state of interim SQL patches:
Interim patch 34411846 (OJVM RELEASE UPDATE: 19.17.0.0.221018 (34411846)):
  Binary registry: Not installed
  PDB CDB$ROOT: Not installed
  PDB EBSDB: Rolled back successfully on 06-MAR-23 04.18.50.736693 AM
  PDB PDB$SEED: Not installed
Interim patch 34786990 (OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990)):
  Binary registry: Not installed
  PDB CDB$ROOT: Not installed
  PDB EBSDB: Applied successfully on 06-MAR-23 04.18.50.743465 AM
  PDB PDB$SEED: Not installed
Interim patch 38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609)):
  Binary registry: Installed
  PDB CDB$ROOT: Applied successfully on 02-FEB-26 01.03.39.807800 PM
  PDB EBSDB: Not installed
  PDB PDB$SEED: Applied successfully on 02-FEB-26 01.17.07.143507 PM

Current state of release update SQL patches:
  Binary registry:
    19.30.0.0.0 Release_Update 260126024251: Installed
  PDB CDB$ROOT:
    Applied 19.30.0.0.0 Release_Update 260126024251 successfully on 02-FEB-26 01.16.20.382997 PM
  PDB EBSDB:
    Applied 19.18.0.0.0 Release_Update 230127005551 successfully on 06-MAR-23 09.32.50.881695 AM
  PDB PDB$SEED:
    Applied 19.30.0.0.0 Release_Update 260126024251 successfully on 02-FEB-26 01.27.08.639847 PM

Adding patches to installation queue and performing prereq checks...done
Installation queue:
  For the following PDBs: CDB$ROOT PDB$SEED
    No interim patches need to be rolled back
    No release update patches need to be installed
    No interim patches need to be applied
  For the following PDBs: EBSDB
    The following interim patches will be rolled back:
      34786990 (OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990))
    Patch 38632161 (Database Release Update : 19.30.0.0.260120(REL-JAN260130) (38632161)):
      Apply from 19.18.0.0.0 Release_Update 230127005551 to 19.30.0.0.0 Release_Update 260126024251
    The following interim patches will be applied:
      38523609 (OJVM RELEASE UPDATE: 19.30.0.0.260120 (38523609))

Installing patches...
Patch installation complete.  Total patches installed: 3

Validating logfiles...done
Patch 34786990 rollback (pdb EBSDB): SUCCESS
  logfile: /u02/app/oracle/cfgtoollogs/sqlpatch/34786990/25032666/34786990_rollback_EBSCDB_EBSDB_2026Apr13_11_12_03.log (no errors)
Patch 38632161 apply (pdb EBSDB): SUCCESS
  logfile: /u02/app/oracle/cfgtoollogs/sqlpatch/38632161/28482211/38632161_apply_EBSCDB_EBSDB_2026Apr13_11_12_28.log (no errors)
Patch 38523609 apply (pdb EBSDB): SUCCESS
  logfile: /u02/app/oracle/cfgtoollogs/sqlpatch/38523609/28341036/38523609_apply_EBSCDB_EBSDB_2026Apr13_11_12_22.log (no errors)
SQL Patching tool complete on Mon Apr 13 11:15:56 2026

real	4m33.315s
user	0m16.109s
sys	0m1.450s
Restarting database EBSCDB_qh2_yyz

System altered.

Database closed.
Database dismounted.
ORACLE instance shut down.
Showing pdb status after restart

Pluggable database altered.


Pluggable database altered.


    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO
Completed function run_datapatch at 130426111640
Recompiling invalid objects...
catcon::set_log_file_base_path: ALL catcon-related output will be written to [/u02/app/oracle/product/19.0.0.0/dbhome_1/rdbms/admin/utlrp_catcon_392142.lst]

catcon::set_log_file_base_path: catcon: See [/u02/app/oracle/product/19.0.0.0/dbhome_1/rdbms/admin/utlrp*.log] files for output generated by scripts

catcon::set_log_file_base_path: catcon: See [/u02/app/oracle/product/19.0.0.0/dbhome_1/rdbms/admin/utlrp_*.lst] files for spool files, if any

catcon.pl: completed successfully

real	7m44.398s
user	0m0.497s
sys	0m0.513s
Running adgrants.sql

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 13 11:24:24 2026
Version 19.30.0.0.0

Copyright (c) 1982, 2025, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.30.0.0.0

Current user is SYS


---------------------------------------------------
--- adgrants.sql started at 2026-04-13 11:24:24 ---
---------------------------------------------------
Removing logs from prior runs of adgrants.sql
-
Start granting from SYS to EBS_SYSTEM
-
End granting from SYS to EBS_SYSTEM


Completed granting and checking privileges


Generating list of ERRORS and WARNINGS to print out

CURRENT_USER
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SYS user ERRORS and WARNINGS will report at end of script


Creating PL/SQL profiler objects.



---------------------------------------------------
--- profload.sql started at 2026-04-13 11:24:25 ---



In 12.2c and beyond, the Oracle-supplied profload.sql script is a verification script, not an installation script.
Testing for correct installation
SYS.DBMS_PROFILER successfully loaded.


-----------------------------------------------------
--- profload.sql completed at 2026-04-13 11:24:27 ---


--------------------------------------------------
--- proftab.sql started at 2026-04-13 11:24:27 ---


-----------------------------------------------------
--- profltab.sql completed at 2026-04-13 11:24:27 ---

Installing Hierarchical Profiler.

-
Loading Stylesheets if missing

Begin creating the APPS_NE.ADGRANTS_VER_PKG package


End creating the APPS_NE.ADGRANTS_VER_PKG package


Executing PURGE DBA_RECYCLEBIN.


The following ERRORS and WARNINGS have been encountered during this adgrants session:


Grants given by this script have been written to the ad_zd_logs table.
You can run $AD_TOP/sql/ADZDSHOWLOG.sql to produce a report showing these grants.

Disconnected from Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.30.0.0.0
Starting function setup_autocfg at 130426112429
Running txkGenCDBTnsAdmin.pl...

Oracle Home being passed: /u02/app/oracle/product/19.0.0.0/dbhome_1


Script Name    : txkGenCDBTnsAdmin.pl
Script Version : 120.0.12020000.11
Started        : Mon Apr 13 11:24:29 UTC 2026

Log File       : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_CDB_TNS_ADMIN_Mon_Apr_13_11_24_29_2026/txkGenCDBTnsAdmin.log


-----------
Values used
-----------
Database Oracle Home    : /u02/app/oracle/product/19.0.0.0/dbhome_1
CDB NAME                : EBSCDB
CDB SID                 : EBSCDB1
Database port           :
OUT Directory           : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log
Is RAC?                 : No
Virtual Hostname        :
Logical Hostname        :
Script execution mode   : validate




=========================
Validating oracle home...
=========================
Oracle Home: /u02/app/oracle/product/19.0.0.0/dbhome_1 exists.


===========================
Validating out directory...
===========================
Out directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log exists.


===================================
Validating script execution mode...
===================================


Script execution mode: validate
Script execution mode is valid.


============================
Inside getDBHostDetails()...
============================
DB Hostname : exadb-node1-xkdgj
DB Domain   : bpuarntviv.v63b7f69c.oraclevcn.com
Logical hostname is not passed, hence using physical hostname details.
Logical Hostname : exadb-node1-xkdgj
Logical Domain   : bpuarntviv.v63b7f69c.oraclevcn.com


=====================
Inside getDBPort()...
=====================
DB Port not passed as an argument, hence using the default port.
DB Port: 1521


========================================
Inside setAllowedLogonVersionNumber()...
========================================


Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_CDB_TNS_ADMIN_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_bkp


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/sqlnet.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_CDB_TNS_ADMIN_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_bkp/sqlnet.ora


Add the ALLOWED_LOGON_VERSION_SERVER entry...





Exiting from the script.
Ended: Mon Apr 13 11:24:29 UTC 2026


Running txkPostPDBCreationTasks.pl...
stty: 'standard input': Inappropriate ioctl for device
Enter the APPS Password:
stty: 'standard input': Inappropriate ioctl for device

stty: 'standard input': Inappropriate ioctl for device
Enter the CDB SYSTEM Password:
stty: 'standard input': Inappropriate ioctl for device



Script Name    : txkPostPDBCreationTasks.pl
Script Version : 120.0.12020000.68
Started        : Mon Apr 13 11:24:29 UTC 2026

Log File       : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/txkPostPDBCreationTasks.log


-----------
Values used
-----------
Database Oracle Home    : /u02/app/oracle/product/19.0.0.0/dbhome_1
CDB NAME                : EBSCDB
CDB SID                 : EBSCDB1
DB Unique Name          : EBSCDB_qh2_yyz
PDB SID                 : EBSDB
Database port           : 1521
OUT Directory           : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log
APPS Schema Username    : APPS
Service Type            : exadatadbsystem
Is RAC?                 : yes
Virtual Hostname        : exadb-node1-xkdgj
Logical Hostname        :
Scan Hostname           : exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com
Scan Port               : 1521
Ignore scan details     : No
Generate UTL_FILE_DIR   : No




=========================
Validating oracle home...
=========================
Oracle Home: /u02/app/oracle/product/19.0.0.0/dbhome_1 exists.


===========================
Validating out directory...
===========================
Out directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log exists.


=============================
Validating DB service type...
=============================
Service Type: exadatadbsystem
Service type is valid.


============================
Inside getDBHostDetails()...
============================
DB Hostname : exadb-node1-xkdgj
DB Domain   : bpuarntviv.v63b7f69c.oraclevcn.com
Logical hostname is not passed, hence using physical hostname details.
Logical Hostname : exadb-node1-xkdgj
Logical Domain   : bpuarntviv.v63b7f69c.oraclevcn.com


==========================
Inside setContextName()...
==========================
CONTEXT_NAME: EBSDB_exadb-node1-xkdgj


=====================
Inside getDBPort()...
=====================
DB Port passed as an argument, using the same.
DB Port: 1521


============================
Inside setFileLocations()...
============================
SYSTEM_PWD_REUSE_FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/EBSCDB1_pwd_reuse_prf.txt


========================
Inside getDBVersion()...
========================
DB_VERSION = db190



=================================
Inside getVirtualHostDetails()...
=================================
RAC configuration, virtual hostname is read from script arguments.
Virtual Hostname : exadb-node1-xkdgj


============================
Inside checkScanDetails()...
============================
Scan Hostname : exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com
Scan Port     : 1521


**** Setting ORACLE_UNQNAME to EBSCDB_qh2_yyz
**** Setting ORACLE_SID to EBSCDB1
**** Setting TNS_ADMIN to /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin




===========================
Inside setListenerFlag()...
===========================
Before: START_STOP_LISTENER_FLAG: 0
After: START_STOP_LISTENER_FLAG: 0


======================================
Inside generateCDBTNSAdminContent()...
======================================
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_bkp
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_temp
Changing the listener template...
listener_template: listener_ora_cdb_db19_rac.tmp


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/listener_ora_cdb_db19_rac.tmp
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_temp/listener.ora


===================================
Inside replaceContextVariables()...
===================================
File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/listener.ora does not exist.


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_temp/listener.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/listener.ora


Skipping instantiation of tnsnames.ora.


================================
Inside generateCDBSqlNetOra()...
================================
Directory /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_bkp already exists.
Directory /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_temp already exists.


File already exists. Skipping instantiation of sqlnet.ora.
Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/sqlnet.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_cdb_bkp/sqlnet.ora


==============================
Inside updateCDBSqlNetOra()...
==============================




======================================
Inside generatePDBTNSAdminContent()...
======================================
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_bkp
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_temp


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/adlsnr10RAC.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_temp/listener.ora


===================================
Inside replaceContextVariables()...
===================================
File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/listener.ora does not exist.


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_temp/listener.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/listener.ora




Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/ad8itns.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_temp/tnsnames.ora


===================================
Inside replaceContextVariables()...
===================================
File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/tnsnames.ora does not exist.


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_temp/tnsnames.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/tnsnames.ora




================================
Inside generatePDBSqlNetOra()...
================================
Directory /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/tns_admin_pdb_bkp already exists.


File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/sqlnet.ora does not exist.


Copying the file
----------------
SOURCE : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/sqlnet.ora
TARGET : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/sqlnet.ora




File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj/sqlnet_ifile.ora does not exist.


File /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/sqlnet_ifile.ora does not exist.




==============================
Inside updatePDBSqlNetOra()...
==============================


=============================
Shutting down the database...
=============================
Shutdown mode       : IMMEDIATE
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
SQL execution went through successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out.


========================
Starting the database...
========================
Startup mode        : NONE
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
SQL execution went through successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out.


================================
Inside setDbDomainParameter()...
================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Updating DB_DOMAIN parameter.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.out.


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.out
pattern: NOT-EMPTY
================
Pattern found...
================
DB_DOMAIN parameter set. Checking for the parameter file.


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_domain.out
pattern: SPFILE
================
Pattern found...
================
SPFILE is being used. Executing ALTER command.


===============================
Inside setDbDomainInSPFILE()...
===============================
File /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/spfileEBSCDB1.ora does not exist.
File /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/spfileEBSCDB1.ora does not exist.
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/alter_db_domain.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/alter_db_domain.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/alter_db_domain.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/alter_db_domain.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
DB_DOMAIN set successfully in SPFILE.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/alter_db_domain.out.


=============================
Shutting down the database...
=============================
Shutdown mode       : IMMEDIATE
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
SQL execution went through successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/shutdown_IMMEDIATE.out.


========================
Starting the database...
========================
Startup mode        : NONE
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
SQL execution went through successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/startup_NONE.out.


========================
Inside copyNLSFiles()...
========================
Executing SYSTEM command: perl /u02/app/oracle/product/19.0.0.0/dbhome_1/nls/data/old/cr9idata.pl

Directory /u02/app/oracle/product/19.0.0.0/dbhome_1/nls/data/9idata already exist. Overwriting...
Copying files to /u02/app/oracle/product/19.0.0.0/dbhome_1/nls/data/9idata...
Copy finished.
Please reset environment variable ORA_NLS10 to /u02/app/oracle/product/19.0.0.0/dbhome_1/nls/data/9idata!
Script cr9idata.pl executed successfully.
=================================
Inside createOPatchDBObjects()...
=================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_opatch_db_objects.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_opatch_db_objects.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_opatch_db_objects.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_opatch_db_objects.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
OPATCH directories created successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_opatch_db_objects.out.


**** Setting TNS_ADMIN to /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj for PDB Connectivity.




===========================
Inside waitForListener()...
===========================
cmd: lsnrctl status | tr '[:lower:]' '[:upper:]' | awk '/\"EBSDB\"/{print;getline;print;}' | grep EBSCDB1 | grep -i READY

  INSTANCE "EBSCDB1", STATUS READY, HAS 1 HANDLER(S) FOR THIS SERVICE...


=============================
Inside checkDBConnection()...
=============================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_db_connection.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_db_connection.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_db_connection.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_db_connection.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_db_connection.log
pattern: ORA-12514
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Connection successful.


=====================================
Validating APPS schema credentials...
=====================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_apps_password.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_apps_password.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_apps_password.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_apps_password.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_apps_password.log
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Validated APPS credentials.


=======================================
Validating SYSTEM schema credentials...
=======================================


======================================
Inside checkSecCaseSensitiveLogon()...
======================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_sec_case_sensitive_logon.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_sec_case_sensitive_logon.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_sec_case_sensitive_logon.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_sec_case_sensitive_logon.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Getting the parameter SEC_CASE_SENSITIVE_LOGON.

Parameter SEC_CASE_SENSITIVE_LOGON is set to FALSE.

sec_case_sensitive_logon_flag: FALSE

Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_system_password.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_system_password.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_system_password.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_system_password.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/validate_system_password.log
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Validated SYSTEM credentials.


=============================
Inside getADTXKCodeLevel()...
=============================


===============================
Inside getProductCodeLevel()...
===============================
product_code: ad

Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ad.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ad.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ad.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ad.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ad.sql

EXIT STATUS: 0
Getting the code level...
code_level: C.14



===============================
Inside getProductCodeLevel()...
===============================
product_code: txk

Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_txk.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_txk.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_txk.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_txk.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_txk.sql

EXIT STATUS: 0
Getting the code level...
code_level: C.14

numeric_code_level: 14

**** AD_TXK_CODE_LEVEL = 14 ****


====================================
Inside getCompletionPatchStatus()...
====================================


===============================
Inside getProductCodeLevel()...
===============================
product_code: ebssys

Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ebssys.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ebssys.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ebssys.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ebssys.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_code_level_ebssys.sql

EXIT STATUS: 0
Getting the code level...
code_level: C.2

AD EBSSYS code level: C.2

numeric_code_level: 2

**** EBSSYS_CODE_LEVEL = 2 ****


**** Setting TNS_ADMIN to /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin




==================================
Inside compileEBSLOGONTrigger()...
==================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/compile_ebs_logon_trigger.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/compile_ebs_logon_trigger.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/compile_ebs_logon_trigger.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/compile_ebs_logon_trigger.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
EBS_LOGON trigger compiled successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/compile_ebs_logon_trigger.out.


======================
Inside setASMFlag()...
======================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_datafile_location.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_datafile_location.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_datafile_location.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_datafile_location.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0


Getting the datafile location...
ASM_CDB_DATAFILE_LOC: +DATAEBSCDB/EBSCDB_QH2_YYZ/DATAFILE
first_char: +
ASM_FLAG: 1


===================================
Inside generateSystemOraPasswd()...
===================================
File +DATAEBSCDB/EBSCDB_QH2_YYZ/DATAFILE/orapwEBSCDB1 does not exist.
File +DATAEBSCDB/EBSCDB_QH2_YYZ/DATAFILE/orapwEBSCDB1 does not exist.

Executing SYSTEM command: orapwd file=+DATAEBSCDB/EBSCDB_QH2_YYZ/DATAFILE/orapwEBSCDB1 force=y dbuniquename=EBSCDB_qh2_yyz


Enter password for SYS:
EXIT STATUS: 0
Password file creation went through successfully.


======================================
Inside getSystemPwdReuseMaxFromDB()...
======================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_max.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_max.out
Spool File          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/spool_get_system_pwd_reuse_max.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_max.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_max.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_max.sql

EXIT STATUS: 0
Getting the value of Password Reuse Max Limit...
system_pwd_reuse_max: UNLIMITED



=======================================
Inside getSystemPwdReuseTimeFromDB()...
=======================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_time.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_time.out
Spool File          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/spool_get_system_pwd_reuse_time.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_time.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_time.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_system_pwd_reuse_time.sql

EXIT STATUS: 0
Getting the value of Password Reuse Time Limit...
system_pwd_reuse_time: UNLIMITED



=====================================
Inside generateSystemPwdReusePrf()...
=====================================
File /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/EBSCDB1_pwd_reuse_prf.txt generated successfully.


================================
Inside setSystemCredentials()...
================================


======================================
Inside getSystemPwdReuseMaxFromFS()...
======================================
Reading the SYSTEM user reuse max limit from file /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/EBSCDB1_pwd_reuse_prf.txt
================
Pattern found...
================
SYSTEM_PWD_REUSE_MAX_PRF : UNLIMITED


=======================================
Inside getSystemPwdReuseTimeFromFS()...
=======================================
Reading the SYSTEM user reuse time limit from file /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/EBSCDB1_pwd_reuse_prf.txt
================
Pattern found...
================
SYSTEM_PWD_REUSE_TIME_PRF: UNLIMITED
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.sql



==============================
Inside removeUnwantedInfo()...
==============================
input_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.out
pattern: SYSTEM


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
SYSTEM credentials set successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/set_system_credentials.out.
**** Required AD/TXK Code Level (Delta 13 or above) is present. Checking COMPLETION patch status.

**** COMPLETION patch is applied. Skipping setting of EBS_SYSTEM credentials.



**** Setting TNS_ADMIN to /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj for PDB Connectivity.




==============================
Inside getEBSCustomTables()...
==============================


Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_user_table.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_user_table.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_user_table.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_user_table.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_user_table.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Getting the user tables.

Creating EBS custom views...


================================
Inside createEBSCustomViews()...
================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_utl_file_views.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_utl_file_views.out


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param
Table exists.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param_bk
Table does not exist.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param
Table exists.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param_bk
Table exists.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param2
Table exists.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param2_bk
Table does not exist.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param2
Table exists.


============================
Inside checkTableExists()...
============================
check_table_name = ebs_utlfile_param2_bk
Table exists.
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_utl_file_views.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_utl_file_views.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/create_utl_file_views.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Table and view created succussfully.


=============================
Inside generateDBCtxFile()...
=============================
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/ctx_bkp


==========================
Inside setADBldXMLEnv()...
==========================
Environment set
ORACLE_HOME     : /u02/app/oracle/product/19.0.0.0/dbhome_1
TNS_ADMIN       : /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin/EBSDB_exadb-node1-xkdgj
ORACLE_SID      : EBSDB
PATH            : /u02/app/oracle/product/19.0.0.0/dbhome_1/perl/bin:/u02/app/oracle/product/19.0.0.0/dbhome_1/bin:/usr/bin:/usr/sbin:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/jre/bin:/usr/ccs/bin:/bin:/usr/bin/X11:/usr/local/bin:/u02/app/oracle/product/19.0.0.0/dbhome_1/bin:/u02/app/oracle/product/19.0.0.0/dbhome_1/OPatch:/u02/app/oracle/product/19.0.0.0/dbhome_1/bin:/u02/app/oracle/product/19.0.0.0/dbhome_1/OPatch:/u02/app/oracle/product/19.0.0.0/dbhome_1/bin:/u02/app/oracle/product/19.0.0.0/dbhome_1/OPatch:/sbin:/bin:/usr/sbin:/usr/bin
LD_LIBRARY_PATH : /u02/app/oracle/product/19.0.0.0/dbhome_1/lib:/usr/X11R6/lib:/usr/openwin/lib:/usr/dt/lib:/u02/app/oracle/product/19.0.0.0/dbhome_1/ctx/lib
DB_LISTENER     : EBSCDB
DISPLAY         : localhost:10.0
Executing SYSTEM command: perl /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/adbldxml.pl appsuser=APPS servername=exadb-node1-xkdgj.bpuarntviv.v63b7f69c.oraclevcn.com virtualhost=exadb-node1-xkdgj enablescan=Y scanname=exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com scanport=1521


Starting context file generation for db tier..


Using CLASSPATH from /u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/orai18n.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt19.jar to execute java programs..


Using JVM from /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/jre/bin/java to execute java programs..


java_cmd = /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/jre/bin/java -classpath /u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/orai18n.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt19.jar

APPS Password: APPS Password:
The log file for this adbldxml session is located at:
/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/adbldxml_04131126.log

Could not Connect to the Database with the above parameters, Please answer the Questions below


Enter Hostname of Database server[EXADB-NODE1-XKDGJ]:
Enter Port of Database server[1521]:
Enter SID of Database server[EBSDB]:s_pluggable_database : true
s_pdb_name : EBSDB

The context file has been created at:
/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml
/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/adbldxml.pl is executed successfully.


**** Setting ORACLE_SID to EBSCDB1




=====================
Inside getDBName()...
=====================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_name.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_name.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_name.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_name.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_db_name.sql

EXIT STATUS: 0
Getting the value of DB Name...
db_name: EBSDB



================================
Inside getApplsysSchemaUser()...
================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_applsys_schema_user_name.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_applsys_schema_user_name.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_applsys_schema_user_name.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_applsys_schema_user_name.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_applsys_schema_user_name.sql

EXIT STATUS: 0
Getting the value of APPLSYS Schema User Name...
applsys_schema_user_name: APPLSYS



========================
Inside updateCtxVar()...
========================
NAME  : s_cdb_unique_name
VALUE : EBSCDB_qh2_yyz

update_status: 1
Update successful



========================
Inside updateCtxVar()...
========================
NAME  : s_update_scan
VALUE : TRUE

update_status: 1
Update successful

Updating s_ecx_log_dir and s_bis_debug_log_dir...


==============================
Inside updateECXBISCtxVar()...
==============================


===========================
Inside checkPrivileges()...
===========================
Checking whether below directory has READ/WRITE access:
/u02/app/oracle/product/19.0.0.0

read_access_chk = 1
write_access_chk = 1
create_access_chk = 1
Privileges check PASSED.

ORACLE BASE DIR /u02/app/oracle/product/19.0.0.0 is writable.



========================
Inside updateCtxVar()...
========================
NAME  : s_ecx_log_dir
VALUE : /u02/app/oracle/product/19.0.0.0/temp/EBSDB

update_status: 1
Update successful



========================
Inside updateCtxVar()...
========================
NAME  : s_bis_debug_log_dir
VALUE : /u02/app/oracle/product/19.0.0.0/temp/EBSDB

update_status: 1
Update successful



========================
Inside updateCtxVar()...
========================
NAME  : s_db_util_filedir
VALUE : /u02/app/oracle/product/19.0.0.0/temp/EBSDB

update_status: 1
Update successful



========================
Inside updateCtxVar()...
========================
NAME  : s_outbound_dir
VALUE : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/outbound/EBSDB_exadb-node1-xkdgj

update_status: 1
Update successful



================================
Inside instantiateTemplates()...
================================
Creating the directory: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/actual_files_bkp


File /u02/app/oracle/product/19.0.0.0/dbhome_1/EBSCDB1_exadb-node1-xkdgj.env does not exist.




===========================
Inside instantiateFile()...
===========================
**************************************************************
File Instantiation:
-------------------
Template: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/adcdb_ux_env.tmp
Instantiated location: /u02/app/oracle/product/19.0.0.0/dbhome_1/EBSCDB1_exadb-node1-xkdgj.env
**************************************************************
Executing SYSTEM command: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/jre/bin/java -classpath :/u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt12.jar oracle.apps.ad.autoconfig.InstantiateFile -e /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml -tmpl /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/adcdb_ux_env.tmp -out /u02/app/oracle/product/19.0.0.0/dbhome_1/EBSCDB1_exadb-node1-xkdgj.env -promptmsg hide

File instantiation successful.




File /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/scripts/EBSDB_exadb-node1-xkdgj/adcdblnctl.sh does not exist.




===========================
Inside instantiateFile()...
===========================
**************************************************************
File Instantiation:
-------------------
Template: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/adcdblnctl_sh.tmp
Instantiated location: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/scripts/EBSDB_exadb-node1-xkdgj/adcdblnctl.sh
**************************************************************
Executing SYSTEM command: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/jre/bin/java -classpath :/u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt12.jar oracle.apps.ad.autoconfig.InstantiateFile -e /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml -tmpl /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/template/adcdblnctl_sh.tmp -out /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/scripts/EBSDB_exadb-node1-xkdgj/adcdblnctl.sh -promptmsg hide

File instantiation successful.




===========================
Inside cleanupDBTables()...
===========================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.log
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
DB tables cleaned successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/cleanup_db_tables.log.

################# BEGIN AUTOCONFIG RUN #################


Executing SYSTEM command: /u02/app/oracle/product/19.0.0.0/dbhome_1/perl/bin/perl /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/adconfig.pl -contextfile=/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml -log=/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/acfg_log_Mon_Apr_13_11_24_29_2026.log


Log file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/acfg_log_Mon_Apr_13_11_24_29_2026.log

stty: 'standard input': Inappropriate ioctl for device
Enter the APPS user password:
stty: 'standard input': Inappropriate ioctl for device

The log file for this session is located at: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/acfg_log_Mon_Apr_13_11_24_29_2026.log

AutoConfig is configuring the Database environment...

AutoConfig will consider the custom templates if present.
	Using ORACLE_HOME location : /u02/app/oracle/product/19.0.0.0/dbhome_1

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.
	Classpath                   : :/u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt19.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/orai18n.jar

	Using Context file          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml

Context Value Management will now update the Context file

	Updating Context file...COMPLETED

	Attempting upload of Context file and templates to database...COMPLETED

Updating rdbms version in Context file to db19
Updating rdbms type in Context file to 64 bits
Configuring templates from ORACLE_HOME ...

AutoConfig completed with errors.
Failed to execute /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/adconfig.pl.
AutoConfig did not run successfully.
Please check the log file /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/acfg_log_Mon_Apr_13_11_24_29_2026.log to resolve any errors and re-run AutoConfig.

################## END AUTOCONFIG RUN ##################



=================================
Inside getServiceNameFromCtx()...
=================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_patch_service_name.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_patch_service_name.out
Spool File          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/spool_get_patch_service_name.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_patch_service_name.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_patch_service_name.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_patch_service_name.sql

EXIT STATUS: 0
Getting the value of s_patch_service_name...
patch_service_name: EBSDB_ebs_patch



**** Setting TNS_ADMIN to /u02/app/oracle/product/19.0.0.0/dbhome_1/network/admin




================================
Inside startEBSPatchService()...
================================


=========================================
Inside getServiceNameFromDBAServices()...
=========================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_dba_services.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_dba_services.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_dba_services.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_dba_services.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Getting the service name from dba_services...
=====================
Service name found...
=====================
db_patch_service_name = EBSDB_ebs_patch




====================================
Inside checkPatchServiceRunning()...
====================================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_patch_service_status.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_patch_service_status.out
Spool File          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/spool_check_patch_service_status.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_patch_service_status.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/check_patch_service_status.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Checking service is active or not.
patch_service_active: 1

Patch service already running. Do nothing.



**** Setting ORACLE_PDB_SID to EBSDB




===========================
Inside executeADGrants()...
===========================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/execute_adgrants.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/execute_adgrants.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/execute_adgrants.sql


AD/TXK code level is Delta 13 or above.
Parsing log generated by adgrants.sql to removing unwanted message related to AD_ZD_SYS.


====================================
Inside extractArrayElementIndex()...
====================================
search_element: Creating PL/SQL Package AD_ZD_SYS.
Element not found.
start_index_ad_zd_sys: -1


====================================
Inside extractArrayElementIndex()...
====================================
search_element: End of Creating PL/SQL Package AD_ZD_SYS.
Element not found.
end_index_ad_zd_sys: -1


Required error message is not found in log. Do nothing.


Searching for ERROR...
error_array_length: 3


Searching for "ERRORS and WARNINGS"...
error_warning_array_length: 3


Standard message from ADGRANTS.SQL, hence ignoring it.
ADGRANTS.SQL executed successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/execute_adgrants.out.
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/dbs/EBSCDB1_pwd_reuse_prf.txt



**** Resetting ORACLE_PDB_SID to NULL




======================================
Inside checkPDBCaseSensitiveParam()...
======================================


Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_case_sensitive_param.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_case_sensitive_param.out
Spool File          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/spool_get_case_sensitive_param.log
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_case_sensitive_param.sql
Removing the file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_case_sensitive_param.sql



==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/get_case_sensitive_param.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
Getting the parameter value.

Parameter _PDB_NAME_CASE_SENSITIVE is set to FALSE.



=======================
Saving the PDB state...
=======================
Generating SQL file : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/save_PDB_state.sql
SQL output file     : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/save_PDB_state.out
==========================
Inside executeSQLFile()...
==========================
Executing the SQL...

Execute SYSTEM command : sqlplus -s /nolog @/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/save_PDB_state.sql


==============================
Inside searchFileContents()...
==============================
log_file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/save_PDB_state.out
pattern: ERROR
=============================
Could not find the pattern...
=============================
EXIT STATUS: 0
PDB state saved successfully.
LOG FILE: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_POST_PDB_Mon_Apr_13_11_24_29_2026/save_PDB_state.out.




Exiting from the script.
Ended: Mon Apr 13 11:27:31 UTC 2026


Setting ORA_NLS10 env for database...
EBSCDB_qh2_yyz:
ORA_NLS10=/u02/app/oracle/product/19.0.0.0/dbhome_1/nls/data/9idata
Restarting Database
Setting up utl file...
Enter the full path of Context File: stty: 'standard input': Inappropriate ioctl for device
Enter the APPS Password:
stty: 'standard input': Inappropriate ioctl for device



Completed        : Mon Apr 13 11:28:16 UTC 2026


ERROR DESCRIPTION:
(*******FATAL ERROR*******
PROGRAM : (/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/txkCfgUtlfileDir.pl)
TIME    : Mon Apr 13 11:28:16 2026
FUNCTION: TXK::XML::load_doc [ Level 1 ]
MESSAGES:
error = Cannot open XML file for load
errorno = No such file or directory
file = APPS

STACK TRACE
 at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/perl/TXK/Error.pm line 168, <STDIN> line 1.
	TXK::Error::abort("TXK::Error", HASH(0x4036b00)) called at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/perl/TXK/XML.pm line 283
	TXK::XML::load_doc(TXK::XML=HASH(0x4036ab8), HASH(0x4036ae8)) called at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/perl/TXK/XML.pm line 266
	TXK::XML::loadDocument(TXK::XML=HASH(0x4036ab8), HASH(0x4036ae8)) called at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/txkCfgUtlfileDir.pl line 3363
	main::getCtxValue("s_db_oh", "d", 1) called at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/txkCfgUtlfileDir.pl line 456
	eval {...} called at /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/bin/txkCfgUtlfileDir.pl line 448
)
ERRORCODE = 1 ERRORCODE_END
100c100
<          <APPS_DATA_FILE_DIR oa_var="s_db_data_file_dir">/u02/app/oracle/product/19.0.0.0/temp/EBSDB</APPS_DATA_FILE_DIR>
---
>          <APPS_DATA_FILE_DIR oa_var="s_db_data_file_dir">/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/outbound/EBSDB_exadb-node1-xkdgj</APPS_DATA_FILE_DIR>
198c198
<          <OUTBOUND_DIR oa_var="s_outbound_dir">/u02/app/oracle/product/19.0.0.0/temp/EBSDB</OUTBOUND_DIR>
---
>          <OUTBOUND_DIR oa_var="s_outbound_dir">/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/outbound/EBSDB_exadb-node1-xkdgj</OUTBOUND_DIR>
stty: 'standard input': Inappropriate ioctl for device
Enter the APPS Password:
stty: 'standard input': Inappropriate ioctl for device


Script Name    : txkCfgUtlfileDir.pl
Script Version : 120.0.12020000.29
Started        : Mon Apr 13 11:28:16 UTC 2026

Log File       : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/TXK_UTIL_DIR_Mon_Apr_13_11_28_16_2026/txkCfgUtlfileDir.log

Context file: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml exists.


stty: 'standard input': Inappropriate ioctl for device
Enter the ebs_system Password:
stty: 'standard input': Inappropriate ioctl for device



Completed        : Mon Apr 13 11:28:22 UTC 2026


Successfully Completed the script
ERRORCODE = 0 ERRORCODE_END
Running autoconfig...
stty: 'standard input': Inappropriate ioctl for device
Enter the APPS user password:stty: 'standard input': Inappropriate ioctl for device

The log file for this session is located at: /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/log/EBSDB_exadb-node1-xkdgj/04131128/adconfig.log

AutoConfig is configuring the Database environment...

AutoConfig will consider the custom templates if present.
	Using ORACLE_HOME location : /u02/app/oracle/product/19.0.0.0/dbhome_1

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.
	Classpath                   : :/u02/app/oracle/product/19.0.0.0/dbhome_1/jdbc/lib/ojdbc8.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java/xmlparserv2.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/java:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/netcfg.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/ldapjclnt19.jar:/u02/app/oracle/product/19.0.0.0/dbhome_1/jlib/orai18n.jar

	Using Context file          : /u02/app/oracle/product/19.0.0.0/dbhome_1/appsutil/EBSDB_exadb-node1-xkdgj.xml

Context Value Management will now update the Context file

	Updating Context file...COMPLETED

	Attempting upload of Context file and templates to database...COMPLETED

Updating rdbms version in Context file to db19
Updating rdbms type in Context file to 64 bits
Configuring templates from ORACLE_HOME ...

AutoConfig completed successfully.
Completed function setup_autocfg at 130426112842

log: /scripts/logs/20260413_111025_post_config_exa_db.log
Mon Apr 13 11:28:42 UTC 2026
Mon Apr 13 11:28:42 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: shut_gcp_vision_db
         ====================================================================
         Function shutsdown GCP Vision EBS Database
         --------------------------------------------------------------------

### Shutting down Vision Database in GCP
Database closed.
Database dismounted.
ORACLE instance shut down.

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 13-APR-2026 11:29:13

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
The command completed successfully

log: /scripts/logs/20260413_112842_shut_gcp_vision_db.log
Mon Apr 13 11:29:13 UTC 2026
Mon Apr 13 11:29:13 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: apps_configure
         ====================================================================
         Function to update EBS context with Exascale details
         --------------------------------------------------------------------

### Updating Context file

  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: apps.example.com  Service/SID: EBSDB


  Sourcing the RUN File System ...


### Show Context file diff after update
102,103c102,103
<          <dbhost oa_var="s_dbhost">exadb-node-scan-vedvk</dbhost>
<          <domain oa_var="s_dbdomain">bpuarntviv.v63b7f69c.oraclevcn.com</domain>
---
>          <dbhost oa_var="s_dbhost">apps</dbhost>
>          <domain oa_var="s_dbdomain">example.com</domain>
271,272c271,272
<          <jdbc_url oa_var="s_apps_jdbc_connect_descriptor">jdbc:oracle:thin:@(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.1.42)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.7.222)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.3.66)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ebs_EBSDB)))</jdbc_url>
<          <jdbc_url_generation_check oa_var="s_jdbc_connect_descriptor_generation">false</jdbc_url_generation_check>
---
>          <jdbc_url oa_var="s_apps_jdbc_connect_descriptor">jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(LOAD_BALANCE=YES)(FAILOVER=YES)(ADDRESS=(PROTOCOL=tcp)(HOST=apps.example.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ebs_EBSDB)))</jdbc_url>
>          <jdbc_url_generation_check oa_var="s_jdbc_connect_descriptor_generation">true</jdbc_url_generation_check>
275c275
<          <patch_jdbc_url oa_var="s_apps_jdbc_patch_connect_descriptor">jdbc:oracle:thin:@(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.1.42)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.7.222)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.3.66)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=EBSDB_ebs_patch)))</patch_jdbc_url>
---
>          <patch_jdbc_url oa_var="s_apps_jdbc_patch_connect_descriptor">jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=apps.example.com)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=EBSDB_ebs_patch)(INSTANCE_NAME=EBSCDB)))</patch_jdbc_url>
573c573
<          <APPLPTMP oa_var="s_applptmp" osd="UNIX">/usr/tmp</APPLPTMP>
---
>          <APPLPTMP oa_var="s_applptmp" osd="UNIX">/u01/install/APPS/temp/EBSDB</APPLPTMP>
### Run Autoconfig

The log file for this session is located at: /u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/log/04131133/adconfig.log


wlsDomainName: EBS_domain
WLS Domain Name is VALID.
AutoConfig is configuring the Applications environment...

AutoConfig will consider the custom templates if present.
  Using CONFIG_HOME location     : /u01/install/APPS/fs1/inst/apps/EBSDB_apps
  Classpath                   : /u01/install/APPS/fs1/FMW_Home/Oracle_EBS-app1/shared-libs/ebs-appsborg/WEB-INF/lib/ebsAppsborgManifest.jar:/u01/install/APPS/fs1/EBSapps/comn/java/classes

  Using Context file          : /u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml

Context Value Management will now update the Context file

  Updating Context file...COMPLETED

  Attempting upload of Context file and templates to database...COMPLETED

Configuring templates from all of the product tops...
  Configuring AD_TOP........COMPLETED
  Configuring FND_TOP.......COMPLETED
  Configuring ICX_TOP.......COMPLETED
  Configuring MSC_TOP.......COMPLETED
  Configuring IEO_TOP.......COMPLETED
  Configuring BIS_TOP.......COMPLETED
  Configuring CZ_TOP........COMPLETED
  Configuring SHT_TOP.......COMPLETED
  Configuring AMS_TOP.......COMPLETED
  Configuring CCT_TOP.......COMPLETED
  Configuring WSH_TOP.......COMPLETED
  Configuring CLN_TOP.......COMPLETED
  Configuring OKE_TOP.......COMPLETED
  Configuring OKL_TOP.......COMPLETED
  Configuring OKS_TOP.......COMPLETED
  Configuring CSF_TOP.......COMPLETED
  Configuring IBY_TOP.......COMPLETED
  Configuring JTF_TOP.......COMPLETED
  Configuring MWA_TOP.......COMPLETED
  Configuring CN_TOP........COMPLETED
  Configuring CSI_TOP.......COMPLETED
  Configuring WIP_TOP.......COMPLETED
  Configuring CSE_TOP.......COMPLETED
  Configuring EAM_TOP.......COMPLETED
  Configuring GMF_TOP.......COMPLETED
  Configuring PON_TOP.......COMPLETED
  Configuring FTE_TOP.......COMPLETED
  Configuring ONT_TOP.......COMPLETED
  Configuring AR_TOP........COMPLETED
  Configuring AHL_TOP.......COMPLETED
  Configuring IES_TOP.......COMPLETED
  Configuring OZF_TOP.......COMPLETED
  Configuring CSD_TOP.......COMPLETED
  Configuring IGC_TOP.......COMPLETED

AutoConfig completed successfully.

### Start EBS
Directory /u01/install/APPS is available.

  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com  Service/SID: EBSDB


  Sourcing the RUN File System ...


You are running adstrtal.sh version 120.24.12020000.11

stty: 'standard input': Inappropriate ioctl for device

Enter the WebLogic Server password: stty: 'standard input': Inappropriate ioctl for device

The logfile for this session is located at /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adstrtal.log

Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/jtffmctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running jtffmctl.sh version 120.3.12020000.4

Validating Fulfillment patch level via /u01/install/APPS/fs1/EBSapps/comn/java/classes
Fulfillment patch level validated.
Starting Fulfillment Server for EBSDB on port 9300 ...

jtffmctl.sh: exiting with status 0


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adopmnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adopmnctl.sh version 120.0.12020000.2

Starting Oracle Process Manager (OPMN) ...

adopmnctl.sh: exiting with status 0

adopmnctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adopmnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adapcctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adapcctl.sh version 120.0.12020000.6

Starting OPMN managed Oracle HTTP Server (OHS) instance ...

adapcctl.sh: exiting with status 0

adapcctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adapcctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adnodemgrctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adnodemgrctl.sh version 120.11.12020000.12


Calling txkChkEBSDependecies.pl to perform dependency checks for ALL MANAGED SERVERS
Perl script txkChkEBSDependecies.pl got executed successfully


Starting the Node Manager...
Refer /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adnodemgrctl.txt for details

NodeManager log is located at /u01/install/APPS/fs1/FMW_Home/wlserver_10.3/common/nodemanager/nmHome1

adnodemgrctl.sh: exiting with status 0

adnodemgrctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adnodemgrctl.txt for more information ...


.end std out.
*** ALL THE FOLLOWING FILES ARE REQUIRED FOR RESOLVING RUNTIME ERRORS
*** Log File = /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/rgf/TXK/txkChkEBSDependecies_Mon_Apr_13_11_36_58_2026/txkChkEBSDependecies_Mon_Apr_13_11_36_58_2026.log

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adalnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

adalnctl.sh version 120.3.12020000.4

Checking for FNDFS executable.
Starting listener process APPS_EBSDB.

adalnctl.sh: exiting with status 0


adalnctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adalnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adcmctl.sh start
Timeout specified in context file: 1000 second(s)

script returned:
****************************************************

You are running adcmctl.sh version 120.19.12020000.7

Starting concurrent manager for EBSDB ...
Starting EBSDB_0413@EBSDB Internal Concurrent Manager
Default printer is noprint

adcmctl.sh: exiting with status 0


adcmctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adcmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adadminsrvctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adadminsrvctl.sh version 120.10.12020000.11

Starting WLS Admin Server...
Refer /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adadminsrvctl.txt for details

AdminServer logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/AdminServer/logs

adadminsrvctl.sh: exiting with status 0

adadminsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adadminsrvctl.txt for more information ...


.end std out.

.end err out.

****************************************************





Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start forms_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting forms_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/forms_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adformsctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start oafm_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oafm_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oafm_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adoafmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start oacore_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oacore_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oacore_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adoacorectl.txt for more information ...


.end std out.

.end err out.

****************************************************



All enabled services for this node are started.

adstrtal.sh: Exiting with status 0

adstrtal.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adstrtal.log for more information ...

Log filename : L7623484.log


Report filename : O7623484.out
Checking crontab for ebs apps auto startup
no crontab for oracle
Add crontab: set ebs startup script

>>> ########## SUMMARY: ##########
 > SYSADMIN PASSWORD: XXX (case sensitive)
 > Applicaiton URL: http://apps.example.com:8000

Use command to port forward port 8000 from GCP: >
gcloud compute ssh --zone <zone> oracle-vision --tunnel-through-iap --project <gcp_project> -- -L 8000:localhost:8000

add line to local machine hosts file: 127.0.0.1 apps.example.com apps


         =========================================
                 Oracle Vision Deployment
         =========================================
          URL                : http://apps.example.com:8000
          User               : SYSADMIN
          Password           : XXX (case sensitive)

          hosts file entry   : 127.0.0.1 apps.example.com apps
          IAP tunneling      :
            gcloud compute ssh oracle-vision --tunnel-through-iap --project oracle-ebs-toolkit-demo -- -L 8000:localhost:8000
         -----------------------------------------

Checking crontab for ebs apps auto startup
Add crontab: set ebs startup script

log: /scripts/logs/20260413_113332_apps_configure.log
Mon Apr 13 11:40:12 UTC 2026
[oracle@apps scripts]$ crontab  -l
@reboot sleep 5 && /scripts/vision_apps_startup_exa.sh | tee -a /scripts/vision_apps_startup_exa.sh.log 2>&1
[oracle@apps scripts]$ cat /scripts/logs/20260413_113332_apps_configure.log
Mon Apr 13 11:33:32 UTC 2026

         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: apps_configure
         ====================================================================
         Function to update EBS context with Exascale details
         --------------------------------------------------------------------

### Updating Context file

  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com  Service/SID: EBSDB


  Sourcing the RUN File System ...


### Show Context file diff after update

### Run Autoconfig

The log file for this session is located at: /u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/log/04131133/adconfig.log


wlsDomainName: EBS_domain
WLS Domain Name is VALID.
AutoConfig is configuring the Applications environment...

AutoConfig will consider the custom templates if present.
  Using CONFIG_HOME location     : /u01/install/APPS/fs1/inst/apps/EBSDB_apps
  Classpath                   : /u01/install/APPS/fs1/FMW_Home/Oracle_EBS-app1/shared-libs/ebs-appsborg/WEB-INF/lib/ebsAppsborgManifest.jar:/u01/install/APPS/fs1/EBSapps/comn/java/classes

  Using Context file          : /u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml

Context Value Management will now update the Context file

  Updating Context file...COMPLETED

  Attempting upload of Context file and templates to database...COMPLETED

Configuring templates from all of the product tops...
  Configuring AD_TOP........COMPLETED
  Configuring FND_TOP.......COMPLETED
  Configuring ICX_TOP.......COMPLETED
  Configuring MSC_TOP.......COMPLETED
  Configuring IEO_TOP.......COMPLETED
  Configuring BIS_TOP.......COMPLETED
  Configuring CZ_TOP........COMPLETED
  Configuring SHT_TOP.......COMPLETED
  Configuring AMS_TOP.......COMPLETED
  Configuring CCT_TOP.......COMPLETED
  Configuring WSH_TOP.......COMPLETED
  Configuring CLN_TOP.......COMPLETED
  Configuring OKE_TOP.......COMPLETED
  Configuring OKL_TOP.......COMPLETED
  Configuring OKS_TOP.......COMPLETED
  Configuring CSF_TOP.......COMPLETED
  Configuring IBY_TOP.......COMPLETED
  Configuring JTF_TOP.......COMPLETED
  Configuring MWA_TOP.......COMPLETED
  Configuring CN_TOP........COMPLETED
  Configuring CSI_TOP.......COMPLETED
  Configuring WIP_TOP.......COMPLETED
  Configuring CSE_TOP.......COMPLETED
  Configuring EAM_TOP.......COMPLETED
  Configuring GMF_TOP.......COMPLETED
  Configuring PON_TOP.......COMPLETED
  Configuring FTE_TOP.......COMPLETED
  Configuring ONT_TOP.......COMPLETED
  Configuring AR_TOP........COMPLETED
  Configuring AHL_TOP.......COMPLETED
  Configuring IES_TOP.......COMPLETED
  Configuring OZF_TOP.......COMPLETED
  Configuring CSD_TOP.......COMPLETED
  Configuring IGC_TOP.......COMPLETED

AutoConfig completed successfully.

### Start EBS
Directory /u01/install/APPS is available.

  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: exadb-node-scan-vedvk.bpuarntviv.v63b7f69c.oraclevcn.com  Service/SID: EBSDB


  Sourcing the RUN File System ...


You are running adstrtal.sh version 120.24.12020000.11

stty: 'standard input': Inappropriate ioctl for device

Enter the WebLogic Server password: stty: 'standard input': Inappropriate ioctl for device

The logfile for this session is located at /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adstrtal.log

Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/jtffmctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running jtffmctl.sh version 120.3.12020000.4

Validating Fulfillment patch level via /u01/install/APPS/fs1/EBSapps/comn/java/classes
Fulfillment patch level validated.
Starting Fulfillment Server for EBSDB on port 9300 ...

jtffmctl.sh: exiting with status 0


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adopmnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adopmnctl.sh version 120.0.12020000.2

Starting Oracle Process Manager (OPMN) ...

adopmnctl.sh: exiting with status 0

adopmnctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adopmnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adapcctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adapcctl.sh version 120.0.12020000.6

Starting OPMN managed Oracle HTTP Server (OHS) instance ...

adapcctl.sh: exiting with status 0

adapcctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adapcctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adnodemgrctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adnodemgrctl.sh version 120.11.12020000.12


Calling txkChkEBSDependecies.pl to perform dependency checks for ALL MANAGED SERVERS
Perl script txkChkEBSDependecies.pl got executed successfully


Starting the Node Manager...
Refer /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adnodemgrctl.txt for details

NodeManager log is located at /u01/install/APPS/fs1/FMW_Home/wlserver_10.3/common/nodemanager/nmHome1

adnodemgrctl.sh: exiting with status 0

adnodemgrctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adnodemgrctl.txt for more information ...


.end std out.
*** ALL THE FOLLOWING FILES ARE REQUIRED FOR RESOLVING RUNTIME ERRORS
*** Log File = /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/rgf/TXK/txkChkEBSDependecies_Mon_Apr_13_11_36_58_2026/txkChkEBSDependecies_Mon_Apr_13_11_36_58_2026.log

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adalnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

adalnctl.sh version 120.3.12020000.4

Checking for FNDFS executable.
Starting listener process APPS_EBSDB.

adalnctl.sh: exiting with status 0


adalnctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adalnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adcmctl.sh start
Timeout specified in context file: 1000 second(s)

script returned:
****************************************************

You are running adcmctl.sh version 120.19.12020000.7

Starting concurrent manager for EBSDB ...
Starting EBSDB_0413@EBSDB Internal Concurrent Manager
Default printer is noprint

adcmctl.sh: exiting with status 0


adcmctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adcmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/adadminsrvctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adadminsrvctl.sh version 120.10.12020000.11

Starting WLS Admin Server...
Refer /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adadminsrvctl.txt for details

AdminServer logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/AdminServer/logs

adadminsrvctl.sh: exiting with status 0

adadminsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adadminsrvctl.txt for more information ...


.end std out.

.end err out.

****************************************************





Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start forms_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting forms_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/forms_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adformsctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start oafm_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oafm_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oafm_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adoafmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/scripts/admanagedsrvctl.sh start oacore_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oacore_server1...

Server specific logs are located at /u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oacore_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adoacorectl.txt for more information ...


.end std out.

.end err out.

****************************************************



All enabled services for this node are started.

adstrtal.sh: Exiting with status 0

adstrtal.sh: check the logfile /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/admin/log/adstrtal.log for more information ...

Log filename : L7623484.log


Report filename : O7623484.out
Checking crontab for ebs apps auto startup
no crontab for oracle
Add crontab: set ebs startup script

>>> ########## SUMMARY: ##########
 > SYSADMIN PASSWORD: *** (case sensitive)
 > Applicaiton URL: http://apps.example.com:8000

Use command to port forward port 8000 from GCP: >
gcloud compute ssh --zone <zone> oracle-exascale-vision-app --tunnel-through-iap --project <gcp_project> -- -L 8000:localhost:8000

add line to local machine hosts file: 127.0.0.1 apps.example.com apps


         =========================================
                 Oracle Vision Deployment
         =========================================
          URL                : http://apps.example.com:8000
          User               : SYSADMIN
          Password           : *** (case sensitive)

          hosts file entry   : 127.0.0.1 apps.example.com apps
          IAP tunneling      :
            gcloud compute ssh oracle-exascale-vision-app --tunnel-through-iap --project oracle-ebs-toolkit-demo -- -L 8000:localhost:8000
         -----------------------------------------

Checking crontab for ebs apps auto startup
Add crontab: set ebs startup script

log: /scripts/logs/20260413_113332_apps_configure.log
Mon Apr 13 11:40:12 UTC 2026
[oracle@apps scripts]$

```
### ### 6. Destroy Exascale infrastructure

Note: this process will ask confirm destory process

```bash
 
[user@desktop] make exascale_destroy
terraform -chdir=. destroy \
		-var="project_id=oracle-ebs-toolkit-demo" \
		-var="project_service_account_email=project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" \
		-var="oracle_ebs_exascale=true" \
		-var="oracle_ebs_vision=false" \
		-var="exascale_grid_image_id=$(cat .grid_image_id)" \
		-var="exascale_deletion_protection=false"
random_id.secret_suffix[0]: Refreshing state... [id=27_LvA]
random_id.bucket_suffix: Refreshing state... [id=CGAk2w]
random_password.admin_password[0]: Refreshing state... [id=none]
tls_private_key.exadb_ssh_key[0]: Refreshing state... [id=011e78a02a77b2f1b2abcdfb0e749551d788643c]
local_file.exadb_public_key[0]: Refreshing state... [id=68b5445e4399079402ed4a9470154e7493600eea]
local_file.exadb_private_key[0]: Refreshing state... [id=22c4bd9970490ba9b182c2616f323137cecba340]
data.google_compute_image.vision_image: Reading...
data.google_compute_image.apps_image: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
google_service_account.project_sa: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
data.google_compute_image.dbs_image: Reading...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/iam.googleapis.com]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01]
google_secret_manager_secret.exadb_private_key_secret[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-dbbfcbbc]
module.network.module.vpc.google_compute_network.network: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault]
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/secretmanager.googleapis.com]
data.google_compute_image.dbs_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/storage.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/compute.googleapis.com]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Refreshing state... [id=projects/119724395047/secrets/exadb-ssh-private-key-dbbfcbbc/versions/1]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
data.google_compute_image.vision_image: Read complete after 2s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01]
google_oracle_database_odb_network.odb_network[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network]
module.ebs_storage_bucket.google_storage_bucket.bucket: Refreshing state... [id=oracle-ebs-toolkit-storage-bucket-086024db]
google_compute_address.exascale_vision_server_internal_ip[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/exascale-vision-server-internal-ip]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access]
module.cloud_router.google_compute_router.router: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet]
google_oracle_database_odb_subnet.client_subnet[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet]
google_oracle_database_odb_subnet.backup_subnet[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet]
google_storage_bucket_iam_member.bucket_object_admin: Refreshing state... [id=b/oracle-ebs-toolkit-storage-bucket-086024db/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_compute_instance.exascale_vision[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=oracle-ebs-toolkit-demo/northamerica-northeast2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01]
null_resource.exascale_db_provisioning[0]: Refreshing state... [id=9184041753248778086]
null_resource.exascale_ingress_rules[0]: Refreshing state... [id=176744551146596870]
null_resource.exascale_configure_and_upload[0]: Refreshing state... [id=797419597963081016]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_address.exascale_vision_server_internal_ip[0] will be destroyed
  - resource "google_compute_address" "exascale_vision_server_internal_ip" {
      - address            = "10.115.0.40" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2026-04-13T00:58:37.615-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/exascale-vision-server-internal-ip" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "exascale-vision-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit-demo" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "northamerica-northeast2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/exascale-vision-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be destroyed
  - resource "google_compute_address" "nat_ip" {
      - address            = "34.130.41.239" -> null
      - address_type       = "EXTERNAL" -> null
      - creation_timestamp = "2026-04-13T00:57:56.480-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "oracle-ebs-toolkit-nat-01" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit-demo" -> null
      - region             = "northamerica-northeast2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router",
        ] -> null
        # (6 unchanged attributes hidden)
    }

  # google_compute_instance.exascale_vision[0] will be destroyed
  - resource "google_compute_instance" "exascale_vision" {
      - can_ip_forward             = false -> null
      - cpu_platform               = "AMD Rome" -> null
      - creation_timestamp         = "2026-04-13T00:58:54.681-07:00" -> null
      - current_status             = "RUNNING" -> null
      - deletion_protection        = false -> null
      - effective_labels           = {
          - "application"                = "oracle-exascale-vision"
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
        } -> null
      - enable_display             = false -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app" -> null
      - instance_id                = "4890289151153347794" -> null
      - label_fingerprint          = "nWjutqQmnxg=" -> null
      - labels                     = {
          - "application" = "oracle-exascale-vision"
          - "managed-by"  = "terraform"
        } -> null
      - machine_type               = "e2-standard-8" -> null
      - metadata                   = {
          - "enable-oslogin"              = "TRUE"
          - "exadb_private_key_secret_id" = "projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-dbbfcbbc"
          - "exadb_public_key"            = <<-EOT
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYFE8md/TXQlR6D1J92CLsi92Das5k0vyG4CDi6f5fdnK5kisi+bde8r/MRyqiQSXh2pIV2rKkVgv5Lgf/V67US2o1B5Nwth+RUYOEeCutebahvL922wual9iGAnfQzjse/FkimBEePVOQLoZyUgfF0ljIP/XXhgl6moGeySgpe6JVea5vMcpjT3T1Vqb6D2G4dJotTpa2JUix9WuGHrtRk0jRxus9EDVLnP/IdkVomO6p/kzrRqCgq+klw1yugL6nUX//+lPGDXU7OTuJglT9wQmrGIFiuTFHUBbWrViP6QzsEewEmgkZeijT3+O3g3P6D+cKXihHe/1nn+UpqHmpuUSYYagdNkis7HaYD2RJi0HBVyhpzJsFEy7pj2K4VWr1xY1LHq0B4ChljqaRMlm9Q4oDW2/lbVUSOQ09mH7MvKmWSQmJ8BPAaTdYCqLJPy5yWNsr1v/WLhqs5YgnqxHlU5yIbO2wYcOFE2mbUIrJal32j5lZv46ObaTNlkqGxBnTeWDoUCfen670ifXJXz6TLPWJgM7lu83Gsf2p5tj1M7cF7UVp1YTOEdgLCVeRtyV8JCf2lOfwYvPdmdZwUaATNc4FzUeetBzEQ8ugJaZlhy5CC+YFIfNjGe22eML39IQ5RKsOf9zAjXSzD8V9oDJHsKvS6JlIrIREovOSTOZ/yQ==
            EOT
          - "startup-script"              = <<-EOT
                #!/bin/bash
                set -e

                # NOTE: This is EBS server boot script - all the updates add here

                # Update packages - skipping due to this is time consuming
                # dnf update -y

                # Enable Google Cloud repo
                tee /etc/yum.repos.d/google-cloud-sdk.repo << 'EOF'
                [google-cloud-cli]
                name=Google Cloud CLI
                baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
                enabled=1
                gpgcheck=1
                repo_gpgcheck=0
                gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
                EOF

                # Install Cloud SDK
                dnf install -y google-cloud-cli

                # Verify installation
                gcloud --version
                gcloud storage ls

                # disable SE LINUx
                sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

                # disable IPV6
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
                sysctl -p

                # dnf oracle packages
                dnf config-manager --set-enabled ol8_addons
                dnf install oracle-ebs-server-R12-preinstall -y
                dnf install oracle-database-preinstall-19c -y
                dnf install tmux gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                if [ ! -f /swapfile ]; then
                    fallocate -l 20G /swapfile
                    chmod 600 /swapfile
                    mkswap /swapfile
                    swapon /swapfile
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi

                # dir precreate and ownerships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # separate tasks for vision vs non-vision
                # vision requires hostname change
                # customer env requires tmux install to have long runnings sessions to attach
                if [ "$(hostname)" != "apps" ]; then
                    hostnamectl set-hostname apps
                fi

                [ -f /etc/profile.d/modules.sh ] && mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                [ -f /etc/profile.d/scl-init.sh ] && mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                [ -f /etc/profile.d/which2.sh ] && mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                [ ! -L /usr/lib/libXm.so.2 ] && ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset which for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

                echo "Configuring Exascale Cluster Access for Oracle user..."

                mkdir -p /home/oracle/.ssh
                chown oracle:oinstall /home/oracle/.ssh
                chmod 700 /home/oracle/.ssh

                SECRET_ID=$(curl -s -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/exadb_private_key_secret_id" || true)

                SECRET_NAME=$(basename "$SECRET_ID")

                EXA_KEY=""
                if [ -n "$SECRET_NAME" ]; then
                    for i in {1..6}; do
                        EXA_KEY=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null || true)
                        if [ -n "$EXA_KEY" ]; then
                            break
                        fi
                        sleep 10
                    done
                fi

                if [ -n "$EXA_KEY" ]; then
                    SKEL_SSH="/etc/skel/.ssh"
                    mkdir -p "$SKEL_SSH"
                    echo "$EXA_KEY" > "$SKEL_SSH/exadb_private_key.pem"
                    chmod 700 "$SKEL_SSH"
                    chmod 400 "$SKEL_SSH/exadb_private_key.pem"

                    USER_LIST=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
                    USER_LIST="$USER_LIST oracle"

                    for USERNAME in $USER_LIST; do
                        USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
                        if [ -d "$USER_HOME" ]; then
                            USER_SSH="$USER_HOME/.ssh"
                            mkdir -p "$USER_SSH"
                            printf "%s" "$EXA_KEY" > "$USER_SSH/exadb_private_key.pem"
                            chown -R "$USERNAME" "$USER_SSH"
                            chmod 700 "$USER_SSH"
                            chmod 400 "$USER_SSH/exadb_private_key.pem"
                        fi
                    done
                fi

                echo "EBS Startup Script Complete!"
            EOT
        } -> null
      - metadata_fingerprint       = "w15NpQylq_s=" -> null
      - name                       = "oracle-exascale-vision-app" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - resource_policies          = [] -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app" -> null
      - tags                       = [
          - "egress-nat",
          - "external-db-access",
          - "http-server",
          - "https-server",
          - "iap-access",
          - "icmp-access",
          - "internal-access",
          - "lb-health-check",
          - "oracle-ebs-apps",
        ] -> null
      - tags_fingerprint           = "Z67z3FXcE1U=" -> null
      - terraform_labels           = {
          - "application"                = "oracle-exascale-vision"
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
        } -> null
      - zone                       = "northamerica-northeast2-a" -> null
        # (4 unchanged attributes hidden)

      - boot_disk {
          - auto_delete                     = true -> null
          - device_name                     = "persistent-disk-0" -> null
          - force_attach                    = false -> null
          - guest_os_features               = [
              - "UEFI_COMPATIBLE",
              - "VIRTIO_SCSI_MULTIQUEUE",
              - "SEV_CAPABLE",
              - "SECURE_BOOT",
              - "GVNIC",
            ] -> null
          - mode                            = "READ_WRITE" -> null
          - source                          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/disks/oracle-exascale-vision-app" -> null
            # (6 unchanged attributes hidden)

          - initialize_params {
              - architecture                = "X86_64" -> null
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260126" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - resource_policies           = [] -> null
              - size                        = 1024 -> null
              - type                        = "pd-balanced" -> null
                # (2 unchanged attributes hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
          - network_ip                  = "10.115.0.40" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
          - subnetwork_project          = "oracle-ebs-toolkit-demo" -> null
            # (4 unchanged attributes hidden)
        }

      - reservation_affinity {
          - type = "ANY_RESERVATION" -> null
        }

      - scheduling {
          - automatic_restart           = true -> null
          - availability_domain         = 0 -> null
          - min_node_cpus               = 0 -> null
          - on_host_maintenance         = "MIGRATE" -> null
          - preemptible                 = false -> null
          - provisioning_model          = "STANDARD" -> null
            # (2 unchanged attributes hidden)
        }

      - service_account {
          - email  = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
          - scopes = [
              - "https://www.googleapis.com/auth/cloud-platform",
            ] -> null
        }

      - shielded_instance_config {
          - enable_integrity_monitoring = true -> null
          - enable_secure_boot          = true -> null
          - enable_vtpm                 = true -> null
        }
    }

  # google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0] will be destroyed
  - resource "google_oracle_database_exadb_vm_cluster" "exadb_vm_cluster" {
      - backup_odb_subnet   = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet" -> null
      - create_time         = "2026-04-13T08:03:38.556622280Z" -> null
      - deletion_protection = false -> null
      - display_name        = "Exadata VM Cluster" -> null
      - effective_labels    = {
          - "deployment"                 = "demo"
          - "goog-terraform-provisioned" = "true"
        } -> null
      - entitlement_id      = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - exadb_vm_cluster_id = "exadb-vm-cluster-01" -> null
      - gcp_oracle_zone     = "northamerica-northeast2-a-r2" -> null
      - id                  = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01" -> null
      - labels              = {
          - "deployment" = "demo"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01" -> null
      - odb_network         = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network" -> null
      - odb_subnet          = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet" -> null
      - project             = "oracle-ebs-toolkit-demo" -> null
      - terraform_labels    = {
          - "deployment"                 = "demo"
          - "goog-terraform-provisioned" = "true"
        } -> null

      - properties {
          - additional_ecpu_count_per_node = 0 -> null
          - cluster_name                   = "exadb-cl1" -> null
          - enabled_ecpu_count_per_node    = 8 -> null
          - exascale_db_storage_vault      = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault" -> null
          - gi_version                     = "19.30.0.0.0" -> null
          - grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqagp4ifksgm2fm5i6zmp66syuyubmygc7umcaf3chmxvsq" -> null
          - hostname                       = "exadb-node" -> null
          - hostname_prefix                = "exadb-node" -> null
          - license_model                  = "BRING_YOUR_OWN_LICENSE" -> null
          - lifecycle_state                = "AVAILABLE" -> null
          - memory_size_gb                 = 22 -> null
          - node_count                     = 1 -> null
          - oci_uri                        = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja" -> null
          - scan_listener_port_tcp         = 1521 -> null
          - shape_attribute                = "BLOCK_STORAGE" -> null
          - ssh_public_keys                = [
              - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYFE8md/TXQlR6D1J92CLsi92Das5k0vyG4CDi6f5fdnK5kisi+bde8r/MRyqiQSXh2pIV2rKkVgv5Lgf/V67US2o1B5Nwth+RUYOEeCutebahvL922wual9iGAnfQzjse/FkimBEePVOQLoZyUgfF0ljIP/XXhgl6moGeySgpe6JVea5vMcpjT3T1Vqb6D2G4dJotTpa2JUix9WuGHrtRk0jRxus9EDVLnP/IdkVomO6p/kzrRqCgq+klw1yugL6nUX//+lPGDXU7OTuJglT9wQmrGIFiuTFHUBbWrViP6QzsEewEmgkZeijT3+O3g3P6D+cKXihHe/1nn+UpqHmpuUSYYagdNkis7HaYD2RJi0HBVyhpzJsFEy7pj2K4VWr1xY1LHq0B4ChljqaRMlm9Q4oDW2/lbVUSOQ09mH7MvKmWSQmJ8BPAaTdYCqLJPy5yWNsr1v/WLhqs5YgnqxHlU5yIbO2wYcOFE2mbUIrJal32j5lZv46ObaTNlkqGxBnTeWDoUCfen670ifXJXz6TLPWJgM7lu83Gsf2p5tj1M7cF7UVp1YTOEdgLCVeRtyV8JCf2lOfwYvPdmdZwUaATNc4FzUeetBzEQ8ugJaZlhy5CC+YFIfNjGe22eML39IQ5RKsOf9zAjXSzD8V9oDJHsKvS6JlIrIREovOSTOZ/yQ==",
            ] -> null

          - data_collection_options {
              - is_diagnostics_events_enabled = true -> null
              - is_health_monitoring_enabled  = true -> null
              - is_incident_logs_enabled      = true -> null
            }

          - time_zone {
              - id      = "UTC" -> null
                # (1 unchanged attribute hidden)
            }

          - vm_file_system_storage {
              - size_in_gbs_per_node = 260 -> null
            }
        }

      - timeouts {
          - create = "180m" -> null
          - delete = "180m" -> null
          - update = "180m" -> null
        }
    }

  # google_oracle_database_exascale_db_storage_vault.exascale_vault[0] will be destroyed
  - resource "google_oracle_database_exascale_db_storage_vault" "exascale_vault" {
      - create_time                  = "2026-04-13T07:57:57.451338664Z" -> null
      - deletion_protection          = false -> null
      - display_name                 = "Exascale DB Storage Vault" -> null
      - effective_labels             = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - entitlement_id               = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - exascale_db_storage_vault_id = "exascale-db-storage-vault" -> null
      - gcp_oracle_zone              = "northamerica-northeast2-a-r2" -> null
      - id                           = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault" -> null
      - labels                       = {} -> null
      - location                     = "northamerica-northeast2" -> null
      - name                         = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exascaleDbStorageVaults/exascale-db-storage-vault" -> null
      - project                      = "oracle-ebs-toolkit-demo" -> null
      - terraform_labels             = {
          - "goog-terraform-provisioned" = "true"
        } -> null

      - properties {
          - additional_flash_cache_percent = 0 -> null
          - attached_shape_attributes      = [
              - "BLOCK_STORAGE",
            ] -> null
          - available_shape_attributes     = [
              - "BLOCK_STORAGE",
            ] -> null
          - oci_uri                        = "https://cloud.oracle.com/dbaas/exadb-xs/exascaleStorageVaults/ocid1.exascaledbstoragevault.oc1.ca-toronto-1.an2g6ljr33xv2ayahtbvcg4erwvtuqsg6llbczwxtxdzx4q3weaqxqfwqdka?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja" -> null
          - ocid                           = "ocid1.exascaledbstoragevault.oc1.ca-toronto-1.an2g6ljr33xv2ayahtbvcg4erwvtuqsg6llbczwxtxdzx4q3weaqxqfwqdka" -> null
          - state                          = "AVAILABLE" -> null
          - vm_cluster_count               = 1 -> null
          - vm_cluster_ids                 = [
              - "ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq",
            ] -> null

          - exascale_db_storage_details {
              - available_size_gbs = 129 -> null
              - total_size_gbs     = 1000 -> null
            }

          - time_zone {
              - id      = "UTC" -> null
                # (1 unchanged attribute hidden)
            }
        }
    }

  # google_oracle_database_odb_network.odb_network[0] will be destroyed
  - resource "google_oracle_database_odb_network" "odb_network" {
      - create_time         = "2026-04-13T07:58:25.742454118Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - entitlement_id      = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - id                  = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network" -> null
      - network             = "projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - odb_network_id      = "oracle-ebs-toolkit-network-odb-network" -> null
      - project             = "oracle-ebs-toolkit-demo" -> null
      - state               = "AVAILABLE" -> null
      - terraform_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
    }

  # google_oracle_database_odb_subnet.backup_subnet[0] will be destroyed
  - resource "google_oracle_database_odb_subnet" "backup_subnet" {
      - cidr_range          = "10.116.128.0/20" -> null
      - create_time         = "2026-04-13T07:58:27.607793069Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - id                  = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-backup-subnet" -> null
      - odb_subnet_id       = "oracle-ebs-toolkit-network-backup-subnet" -> null
      - odbnetwork          = "oracle-ebs-toolkit-network-odb-network" -> null
      - project             = "oracle-ebs-toolkit-demo" -> null
      - purpose             = "BACKUP_SUBNET" -> null
      - state               = "AVAILABLE" -> null
      - terraform_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
    }

  # google_oracle_database_odb_subnet.client_subnet[0] will be destroyed
  - resource "google_oracle_database_odb_subnet" "client_subnet" {
      - cidr_range          = "10.116.0.0/20" -> null
      - create_time         = "2026-04-13T07:58:27.570096381Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - id                  = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/odbNetworks/oracle-ebs-toolkit-network-odb-network/odbSubnets/oracle-ebs-toolkit-network-client-subnet" -> null
      - odb_subnet_id       = "oracle-ebs-toolkit-network-client-subnet" -> null
      - odbnetwork          = "oracle-ebs-toolkit-network-odb-network" -> null
      - project             = "oracle-ebs-toolkit-demo" -> null
      - purpose             = "CLIENT_SUBNET" -> null
      - state               = "AVAILABLE" -> null
      - terraform_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/compute.instanceAdmin.v1" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/iam.serviceAccountUser" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/iap.tunnelResourceAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/logging.logWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/monitoring.metricWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/secretmanager.secretAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZPUthrXZ0=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/storage.admin" -> null
    }

  # google_secret_manager_secret.exadb_private_key_secret[0] will be destroyed
  - resource "google_secret_manager_secret" "exadb_private_key_secret" {
      - annotations           = {} -> null
      - create_time           = "2026-04-13T07:57:55.853015Z" -> null
      - deletion_protection   = false -> null
      - effective_annotations = {} -> null
      - effective_labels      = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                    = "projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-dbbfcbbc" -> null
      - labels                = {} -> null
      - name                  = "projects/119724395047/secrets/exadb-ssh-private-key-dbbfcbbc" -> null
      - project               = "oracle-ebs-toolkit-demo" -> null
      - secret_id             = "exadb-ssh-private-key-dbbfcbbc" -> null
      - terraform_labels      = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - version_aliases       = {} -> null
        # (2 unchanged attributes hidden)

      - replication {
          - auto {
            }
        }
    }

  # google_secret_manager_secret_version.exadb_private_key_secret_version[0] will be destroyed
  - resource "google_secret_manager_secret_version" "exadb_private_key_secret_version" {
      - create_time            = "2026-04-13T07:58:01.504860Z" -> null
      - deletion_policy        = "DELETE" -> null
      - enabled                = true -> null
      - id                     = "projects/119724395047/secrets/exadb-ssh-private-key-dbbfcbbc/versions/1" -> null
      - is_secret_data_base64  = false -> null
      - name                   = "projects/119724395047/secrets/exadb-ssh-private-key-dbbfcbbc/versions/1" -> null
      - secret                 = "projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-dbbfcbbc" -> null
      - secret_data            = (sensitive value) -> null
      - secret_data_wo         = (write-only attribute) -> null
      - secret_data_wo_version = 0 -> null
      - version                = "1" -> null
        # (1 unchanged attribute hidden)
    }

  # google_service_account.project_sa will be destroyed
  - resource "google_service_account" "project_sa" {
      - account_id   = "project-service-account" -> null
      - disabled     = false -> null
      - display_name = "Project Service Account" -> null
      - email        = "project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - id           = "projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - name         = "projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project      = "oracle-ebs-toolkit-demo" -> null
      - unique_id    = "118124765175151734087" -> null
        # (1 unchanged attribute hidden)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be destroyed
  - resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      - bucket = "b/oracle-ebs-toolkit-storage-bucket-086024db" -> null
      - etag   = "CAI=" -> null
      - id     = "b/oracle-ebs-toolkit-storage-bucket-086024db/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - role   = "roles/storage.objectAdmin" -> null
    }

  # local_file.exadb_private_key[0] will be destroyed
  - resource "local_file" "exadb_private_key" {
      - content              = (sensitive value) -> null
      - content_base64sha256 = "1tY5ahVR+p/+8hWhFlhRWRDMw6w/vbLXmnbZr73ItmE=" -> null
      - content_base64sha512 = "aFioD5DWc+R7ZIrusmN7UCZcMfW9+Hgb1oEgGv9m2d/uSuubMc4ztOTiwL+RG2Zl+TOM4/xV1OU6x+oMrM3owQ==" -> null
      - content_md5          = "58bded8588e782e9bd930d6719d79e1c" -> null
      - content_sha1         = "22c4bd9970490ba9b182c2616f323137cecba340" -> null
      - content_sha256       = "d6d6396a1551fa9ffef215a11658515910ccc3ac3fbdb2d79a76d9afbdc8b661" -> null
      - content_sha512       = "6858a80f90d673e47b648aeeb2637b50265c31f5bdf8781bd681201aff66d9dfee4aeb9b31ce33b4e4e2c0bf911b6665f9338ce3fc55d4e53ac7ea0caccde8c1" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0600" -> null
      - filename             = "./exadb_private_key.pem" -> null
      - id                   = "22c4bd9970490ba9b182c2616f323137cecba340" -> null
    }

  # local_file.exadb_public_key[0] will be destroyed
  - resource "local_file" "exadb_public_key" {
      - content              = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYFE8md/TXQlR6D1J92CLsi92Das5k0vyG4CDi6f5fdnK5kisi+bde8r/MRyqiQSXh2pIV2rKkVgv5Lgf/V67US2o1B5Nwth+RUYOEeCutebahvL922wual9iGAnfQzjse/FkimBEePVOQLoZyUgfF0ljIP/XXhgl6moGeySgpe6JVea5vMcpjT3T1Vqb6D2G4dJotTpa2JUix9WuGHrtRk0jRxus9EDVLnP/IdkVomO6p/kzrRqCgq+klw1yugL6nUX//+lPGDXU7OTuJglT9wQmrGIFiuTFHUBbWrViP6QzsEewEmgkZeijT3+O3g3P6D+cKXihHe/1nn+UpqHmpuUSYYagdNkis7HaYD2RJi0HBVyhpzJsFEy7pj2K4VWr1xY1LHq0B4ChljqaRMlm9Q4oDW2/lbVUSOQ09mH7MvKmWSQmJ8BPAaTdYCqLJPy5yWNsr1v/WLhqs5YgnqxHlU5yIbO2wYcOFE2mbUIrJal32j5lZv46ObaTNlkqGxBnTeWDoUCfen670ifXJXz6TLPWJgM7lu83Gsf2p5tj1M7cF7UVp1YTOEdgLCVeRtyV8JCf2lOfwYvPdmdZwUaATNc4FzUeetBzEQ8ugJaZlhy5CC+YFIfNjGe22eML39IQ5RKsOf9zAjXSzD8V9oDJHsKvS6JlIrIREovOSTOZ/yQ==
        EOT -> null
      - content_base64sha256 = "osGhD90bUXO6XDNkGhGcVfBB8vujudfLvfCmDcxS5Do=" -> null
      - content_base64sha512 = "s2okHUNkeizDaVhd7Dj3dFtOiTzVp+2CXtWEoGxFJmHuoqnVGvNnCXquuV4yTNyC1iyBh1oDXE9S1gCXNgJbZA==" -> null
      - content_md5          = "08a7967111da97818b0898f382bc7f01" -> null
      - content_sha1         = "68b5445e4399079402ed4a9470154e7493600eea" -> null
      - content_sha256       = "a2c1a10fdd1b5173ba5c33641a119c55f041f2fba3b9d7cbbdf0a60dcc52e43a" -> null
      - content_sha512       = "b36a241d43647a2cc369585dec38f7745b4e893cd5a7ed825ed584a06c452661eea2a9d51af367097aaeb95e324cdc82d62c81875a035c4f52d6009736025b64" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0644" -> null
      - filename             = "./exadb_public_key.pub" -> null
      - id                   = "68b5445e4399079402ed4a9470154e7493600eea" -> null
    }

  # null_resource.exascale_configure_and_upload[0] will be destroyed
  - resource "null_resource" "exascale_configure_and_upload" {
      - id       = "797419597963081016" -> null
      - triggers = {
          - "cdb_name"        = "EBSCDB"
          - "oci_api_version" = "20160918"
          - "password"        = (sensitive value)
          - "vm_id"           = "projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app"
        } -> null
    }

  # null_resource.exascale_db_provisioning[0] will be destroyed
  - resource "null_resource" "exascale_db_provisioning" {
      - id       = "9184041753248778086" -> null
      - triggers = {
          - "cdb_name"        = "EBSCDB"
          - "cluster_uri"     = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja"
          - "oci_api_version" = "20160918"
        } -> null
    }

  # null_resource.exascale_ingress_rules[0] will be destroyed
  - resource "null_resource" "exascale_ingress_rules" {
      - id       = "176744551146596870" -> null
      - triggers = {
          - "cluster_uri"     = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja"
          - "oci_api_version" = "20160918"
          - "vpc_cidr"        = "10.115.0.0/20"
        } -> null
    }

  # random_id.bucket_suffix will be destroyed
  - resource "random_id" "bucket_suffix" {
      - b64_std     = "CGAk2w==" -> null
      - b64_url     = "CGAk2w" -> null
      - byte_length = 4 -> null
      - dec         = "140518619" -> null
      - hex         = "086024db" -> null
      - id          = "CGAk2w" -> null
    }

  # random_id.secret_suffix[0] will be destroyed
  - resource "random_id" "secret_suffix" {
      - b64_std     = "27/LvA==" -> null
      - b64_url     = "27_LvA" -> null
      - byte_length = 4 -> null
      - dec         = "3686779836" -> null
      - hex         = "dbbfcbbc" -> null
      - id          = "27_LvA" -> null
    }

  # random_password.admin_password[0] will be destroyed
  - resource "random_password" "admin_password" {
      - bcrypt_hash      = (sensitive value) -> null
      - id               = "none" -> null
      - length           = 16 -> null
      - lower            = true -> null
      - min_lower        = 2 -> null
      - min_numeric      = 2 -> null
      - min_special      = 2 -> null
      - min_upper        = 2 -> null
      - number           = true -> null
      - numeric          = true -> null
      - override_special = "_-" -> null
      - result           = (sensitive value) -> null
      - special          = true -> null
      - upper            = true -> null
    }

  # tls_private_key.exadb_ssh_key[0] will be destroyed
  - resource "tls_private_key" "exadb_ssh_key" {
      - algorithm                     = "RSA" -> null
      - ecdsa_curve                   = "P224" -> null
      - id                            = "011e78a02a77b2f1b2abcdfb0e749551d788643c" -> null
      - private_key_openssh           = (sensitive value) -> null
      - private_key_pem               = (sensitive value) -> null
      - private_key_pem_pkcs8         = (sensitive value) -> null
      - public_key_fingerprint_md5    = "5a:8b:be:06:ee:8e:39:4c:5d:7f:86:9b:f1:49:e1:7d" -> null
      - public_key_fingerprint_sha256 = "SHA256:IHwp0h+6ReB+1vSgc0X08F1KI6bAPJ3AT89WKBOXPZg" -> null
      - public_key_openssh            = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYFE8md/TXQlR6D1J92CLsi92Das5k0vyG4CDi6f5fdnK5kisi+bde8r/MRyqiQSXh2pIV2rKkVgv5Lgf/V67US2o1B5Nwth+RUYOEeCutebahvL922wual9iGAnfQzjse/FkimBEePVOQLoZyUgfF0ljIP/XXhgl6moGeySgpe6JVea5vMcpjT3T1Vqb6D2G4dJotTpa2JUix9WuGHrtRk0jRxus9EDVLnP/IdkVomO6p/kzrRqCgq+klw1yugL6nUX//+lPGDXU7OTuJglT9wQmrGIFiuTFHUBbWrViP6QzsEewEmgkZeijT3+O3g3P6D+cKXihHe/1nn+UpqHmpuUSYYagdNkis7HaYD2RJi0HBVyhpzJsFEy7pj2K4VWr1xY1LHq0B4ChljqaRMlm9Q4oDW2/lbVUSOQ09mH7MvKmWSQmJ8BPAaTdYCqLJPy5yWNsr1v/WLhqs5YgnqxHlU5yIbO2wYcOFE2mbUIrJal32j5lZv46ObaTNlkqGxBnTeWDoUCfen670ifXJXz6TLPWJgM7lu83Gsf2p5tj1M7cF7UVp1YTOEdgLCVeRtyV8JCf2lOfwYvPdmdZwUaATNc4FzUeetBzEQ8ugJaZlhy5CC+YFIfNjGe22eML39IQ5RKsOf9zAjXSzD8V9oDJHsKvS6JlIrIREovOSTOZ/yQ==
        EOT -> null
      - public_key_pem                = <<-EOT
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2BRPJnf010JUeg9Sfdgi
            7Ivdg2rOZNL8huAg4un+X3ZyuZIrIvm3XvK/zEcqokEl4dqSFdqypFYL+S4H/1eu
            1EtqNQeTcLYfkVGDhHgrrXm2oby/dtsLmpfYhgJ30M47HvxZIpgRHj1TkC6GclIH
            xdJYyD/114YJepqBnskoKXuiVXmubzHKY0909Vam+g9huHSaLU6WtiVIsfVrhh67
            UZNI0cbrPRA1S5z/yHZFaJjuqf5M60agoKvpJcNcroC+p1F///pTxg11Ozk7iYJU
            /cEJqxiBYrkxR1AW1q1Yj+kM7BHsBJoJGXoo09/jt4Nz+g/nCl4oR3v9Z5/lKah5
            qblEmGGoHTZIrOx2mA9kSYtBwVcoacybBRMu6Y9iuFVq9cWNSx6tAeAoZY6mkTJZ
            vUOKA1tv5W1VEjkNPZh+zLyplkkJifATwGk3WAqiyT8ucljbK9b/1i4arOWIJ6sR
            5VOciGztsGHDhRNpm1CKyWpd9o+ZWb+Ojm2kzZZKhsQZ03lg6FAn3p+u9In1yV8+
            kyz1iYDO5bvNxrH9qebY9TO3Be1FadWEzhHYCwlXkbclfCQn9pTn8GLz3ZnWcFGg
            EzXOBc1HnrQcxEPLoCWmZYcuQgvmBSHzYxnttnjC9/SEOUSrDn/cwI10sw/FfaAy
            R7Cr0uiZSKyERKLzkkzmf8kCAwEAAQ==
            -----END PUBLIC KEY-----
        EOT -> null
      - rsa_bits                      = 4096 -> null
    }

  # module.cloud_router.google_compute_router.router will be destroyed
  - resource "google_compute_router" "router" {
      - creation_timestamp            = "2026-04-13T00:58:37.711-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router" -> null
      - name                          = "oracle-ebs-toolkit-network-cloud-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - project                       = "oracle-ebs-toolkit-demo" -> null
      - region                        = "northamerica-northeast2" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router" -> null
        # (1 unchanged attribute hidden)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be destroyed
  - resource "google_compute_router_nat" "nats" {
      - drain_nat_ips                        = [] -> null
      - enable_dynamic_port_allocation       = false -> null
      - enable_endpoint_independent_mapping  = false -> null
      - endpoint_types                       = [
          - "ENDPOINT_TYPE_VM",
        ] -> null
      - icmp_idle_timeout_sec                = 30 -> null
      - id                                   = "oracle-ebs-toolkit-demo/northamerica-northeast2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01" -> null
      - max_ports_per_vm                     = 0 -> null
      - min_ports_per_vm                     = 0 -> null
      - name                                 = "oracle-ebs-toolkit-nat-01" -> null
      - nat_ip_allocate_option               = "MANUAL_ONLY" -> null
      - nat_ips                              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01",
        ] -> null
      - project                              = "oracle-ebs-toolkit-demo" -> null
      - region                               = "northamerica-northeast2" -> null
      - router                               = "oracle-ebs-toolkit-network-cloud-router" -> null
      - source_subnetwork_ip_ranges_to_nat   = "LIST_OF_SUBNETWORKS" -> null
      - tcp_established_idle_timeout_sec     = 1200 -> null
      - tcp_time_wait_timeout_sec            = 120 -> null
      - tcp_transitory_idle_timeout_sec      = 30 -> null
      - type                                 = "PUBLIC" -> null
      - udp_idle_timeout_sec                 = 30 -> null
        # (1 unchanged attribute hidden)

      - log_config {
          - enable = true -> null
          - filter = "ALL" -> null
        }

      - subnetwork {
          - name                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
          - secondary_ip_range_names = [] -> null
          - source_ip_ranges_to_nat  = [
              - "ALL_IP_RANGES",
            ] -> null
        }
    }

  # module.ebs_storage_bucket.google_storage_bucket.bucket will be destroyed
  - resource "google_storage_bucket" "bucket" {
      - default_event_based_hold    = false -> null
      - effective_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "oracle-ebs-toolkit"
        } -> null
      - enable_object_retention     = false -> null
      - force_destroy               = true -> null
      - id                          = "oracle-ebs-toolkit-storage-bucket-086024db" -> null
      - labels                      = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - location                    = "NORTHAMERICA-NORTHEAST2" -> null
      - name                        = "oracle-ebs-toolkit-storage-bucket-086024db" -> null
      - project                     = "oracle-ebs-toolkit-demo" -> null
      - project_number              = 119724395047 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/oracle-ebs-toolkit-storage-bucket-086024db" -> null
      - storage_class               = "NEARLINE" -> null
      - terraform_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "oracle-ebs-toolkit"
        } -> null
      - time_created                = "2026-04-13T07:57:58.916Z" -> null
      - uniform_bucket_level_access = true -> null
      - updated                     = "2026-04-13T07:58:13.428Z" -> null
      - url                         = "gs://oracle-ebs-toolkit-storage-bucket-086024db" -> null

      - hierarchical_namespace {
          - enabled = false -> null
        }

      - soft_delete_policy {
          - effective_time             = "2026-04-13T07:57:58.916Z" -> null
          - retention_duration_seconds = 604800 -> null
        }

      - versioning {
          - enabled = true -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:50.524-07:00" -> null
      - description             = "Allow external access to Oracle EBS Apps" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access" -> null
      - name                    = "allow-external-app-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access" -> null
      - source_ranges           = [
          - "0.0.0.0/0",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "external-app-access",
        ] -> null

      - allow {
          - ports    = [
              - "8000",
              - "4443",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:38.486-07:00" -> null
      - description             = "Allow external access to Oracle EBS DB" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access" -> null
      - name                    = "allow-external-db-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access" -> null
      - source_ranges           = [
          - "0.0.0.0/0",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "external-db-access",
        ] -> null

      - allow {
          - ports    = [
              - "1521",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:37.066-07:00" -> null
      - description             = "Allow HTTP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in" -> null
      - name                    = "allow-http-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in" -> null
      - source_ranges           = [
          - "0.0.0.0/0",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "http-server",
        ] -> null

      - allow {
          - ports    = [
              - "80",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:50.581-07:00" -> null
      - description             = "Allow HTTPS traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in" -> null
      - name                    = "allow-https-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in" -> null
      - source_ranges           = [
          - "0.0.0.0/0",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "https-server",
        ] -> null

      - allow {
          - ports    = [
              - "443",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:38.381-07:00" -> null
      - description             = "Allow IAP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in" -> null
      - name                    = "allow-iap-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in" -> null
      - source_ranges           = [
          - "35.235.240.0/20",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "iap-access",
        ] -> null

      - allow {
          - ports    = [] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:38.278-07:00" -> null
      - description             = "Allow ICMP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in" -> null
      - name                    = "allow-icmp-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in" -> null
      - source_ranges           = [
          - "35.235.240.0/20",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "icmp-access",
        ] -> null

      - allow {
          - ports    = [] -> null
          - protocol = "icmp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-04-13T00:58:38.398-07:00" -> null
      - description             = "Allow internal HTTP traffic within the VPC" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access" -> null
      - name                    = "allow-internal-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit-demo" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access" -> null
      - source_ranges           = [
          - "10.115.0.0/20",
        ] -> null
      - source_service_accounts = [] -> null
      - source_tags             = [] -> null
      - target_service_accounts = [] -> null
      - target_tags             = [
          - "internal-access",
        ] -> null

      - allow {
          - ports    = [] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.nat_gateway_route.google_compute_route.route["nat-egress-internet"] will be destroyed
  - resource "google_compute_route" "route" {
      - as_paths                   = [] -> null
      - creation_timestamp         = "2026-04-13T00:58:50.552-07:00" -> null
      - description                = "Public NAT GW - route through IGW to access internet" -> null
      - dest_range                 = "0.0.0.0/0" -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet" -> null
      - name                       = "nat-egress-internet" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - next_hop_gateway           = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/gateways/default-internet-gateway" -> null
      - priority                   = 1000 -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet" -> null
      - tags                       = [
          - "egress-nat",
        ] -> null
      - warnings                   = [] -> null
        # (12 unchanged attributes hidden)
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - service                    = "cloudresourcemanager.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit-demo/compute.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - service                    = "compute.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit-demo/iam.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - service                    = "iam.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit-demo/secretmanager.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - service                    = "secretmanager.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit-demo/storage.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - service                    = "storage.googleapis.com" -> null
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"] will be destroyed
  - resource "google_compute_subnetwork" "subnetwork" {
      - creation_timestamp         = "2026-04-13T00:58:24.042-07:00" -> null
      - enable_flow_logs           = true -> null
      - gateway_address            = "10.115.0.1" -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - ip_cidr_range              = "10.115.0.0/20" -> null
      - name                       = "oracle-ebs-toolkit-subnet-01" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "northamerica-northeast2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - stack_type                 = "IPV4_ONLY" -> null
      - subnetwork_id              = 6521975200025746639 -> null
        # (9 unchanged attributes hidden)

      - log_config {
          - aggregation_interval = "INTERVAL_5_SEC" -> null
          - filter_expr          = "true" -> null
          - flow_sampling        = 0.5 -> null
          - metadata             = "INCLUDE_ALL_METADATA" -> null
          - metadata_fields      = [] -> null
        }
    }

  # module.network.module.vpc.google_compute_network.network will be destroyed
  - resource "google_compute_network" "network" {
      - auto_create_subnetworks                   = false -> null
      - bgp_always_compare_med                    = false -> null
      - bgp_best_path_selection_mode              = "LEGACY" -> null
      - delete_bgp_always_compare_med             = false -> null
      - delete_default_routes_on_create           = true -> null
      - enable_ula_internal_ipv6                  = false -> null
      - id                                        = "projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
      - mtu                                       = 0 -> null
      - name                                      = "oracle-ebs-toolkit-network" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - network_id                                = "4731128679754702058" -> null
      - numeric_id                                = "4731128679754702058" -> null
      - project                                   = "oracle-ebs-toolkit-demo" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-ebs-toolkit-network" -> null
        # (5 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 46 to destroy.

Changes to Outputs:
  - admin_password                = (sensitive value) -> null
  - apps_instance_zone            = "" -> null
  - dbs_instance_zone             = "" -> null
  - deployment_summary            = <<-EOT
        =========================================
                Oracle Vision VM Deployment
        =========================================
         Project ID         : oracle-ebs-toolkit-demo
         Region             : northamerica-northeast2
         Zone               : northamerica-northeast2-a
         VPC Network        : oracle-ebs-toolkit-network

        -----------------------------------------
         Vision Instance
        -----------------------------------------
           • Name           : oracle-exascale-vision-app
           • Internal IP    : 10.115.0.40
           • SSH Command    :
               gcloud compute ssh --zone "northamerica-northeast2-a" "oracle-exascale-vision-app" --tunnel-through-iap --project "oracle-ebs-toolkit-demo"

        -----------------------------------------
         Database Tier
        -----------------------------------------
           • Type           : Oracle Database@Google Cloud (Exascale)
           • Cluster Name   : Exadata VM Cluster
           • SSH Key        : ./exadb_private_key.pem
           • Connection Info: Saved securely to ./exascale_outputs.yaml (TNS, SCAN DNS)
           • Connection String: Pending generation (Available after apply)

        -----------------------------------------
         Storage
        -----------------------------------------
           • Bucket Name    : oracle-ebs-toolkit-storage-bucket-086024db
           • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-086024db

        -----------------------------------------
         User Credentials
        -----------------------------------------
           • Username       : admin
           • Admin Password : Run this command to retrieve the admin password securely:

               terraform output admin_password

        =========================================
         Summary
        -----------------------------------------
           • Total Instances: 1 Exascale Vision VM + 1 Exascale Cluster
           • Storage Bucket : oracle-ebs-toolkit-storage-bucket-086024db
           • Admin Password : Run "terraform output admin_password" to retrieve securely
           • Generated At   : 2026-04-13T09:03:44Z
        =========================================
    EOT -> null
  - exascale_vision_instance_zone = "northamerica-northeast2-a" -> null
  - vision_instance_zone          = "" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

null_resource.exascale_configure_and_upload[0]: Destroying... [id=797419597963081016]
null_resource.exascale_ingress_rules[0]: Destroying... [id=176744551146596870]
null_resource.exascale_configure_and_upload[0]: Provisioning with 'local-exec'...
null_resource.exascale_configure_and_upload[0] (local-exec): Executing: ["/bin/sh" "-c" "rm -f ./exascale_outputs.yaml"]
null_resource.exascale_ingress_rules[0]: Provisioning with 'local-exec'...
null_resource.exascale_ingress_rules[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 0\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      if [ -z \"$CLUSTER_URI\" ]; then\n        exit 0\n      fi\n\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/exadbVmClusters/$CLUSTER_OCID\" 2>/dev/null || true)\n      SUBNET_OCID=$(echo \"$CLUSTER_JSON\" | jq -r '.data.subnetId // empty')\n\n      if [ -z \"$SUBNET_OCID\" ]; then\n        exit 0\n      fi\n\n      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri \"https://iaas.${OCI_REGION}.oraclecloud.com/20160918/subnets/$SUBNET_OCID\" 2>/dev/null || true)\n      VCN_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.vcnId // empty')\n      COMPARTMENT_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.compartmentId // empty')\n\n      if [ -z \"$VCN_OCID\" ] || [ -z \"$COMPARTMENT_OCID\" ]; then\n        exit 0\n      fi\n\n      TARGET_NSG_OCID=$(oci network nsg list \\\n        --compartment-id \"$COMPARTMENT_OCID\" \\\n        --vcn-id \"$VCN_OCID\" \\\n        --all 2>/dev/null | jq -r '\n          .data[] \n          | select(.[\"display-name\"] | endswith(\"_NSG\")) \n          | select(.[\"display-name\"] | contains(\"BCKP\") | not) \n          | .id\n        ' | head -n 1)\n\n      if [ -z \"$TARGET_NSG_OCID\" ]; then\n        exit 0\n      fi\n\n      RULE_IDS=$(oci network nsg rules list --nsg-id \"$TARGET_NSG_OCID\" --all 2>/dev/null | jq -r --arg cidr \"10.115.0.0/20\" '.data[] | select(.source == $cidr) | .id')\n\n      if [ -n \"$RULE_IDS\" ]; then\n        for id in $RULE_IDS; do\n          oci network nsg rules remove --nsg-id \"$TARGET_NSG_OCID\" --security-rule-ids \"[\\\"$id\\\"]\" --force || true\n        done\n      fi\n"]
null_resource.exascale_configure_and_upload[0]: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/iam.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/compute.googleapis.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/secretmanager.googleapis.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/storage.googleapis.com]
google_compute_instance.exascale_vision[0]: Destroying... [id=projects/oracle-ebs-toolkit-demo/zones/northamerica-northeast2-a/instances/oracle-exascale-vision-app]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destruction complete after 9s
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destroying... [id=oracle-ebs-toolkit-demo/northamerica-northeast2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destruction complete after 9s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in]
null_resource.exascale_ingress_rules[0]: Still destroying... [id=176744551146596870, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destruction complete after 10s
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access, 00m10s elapsed]
google_compute_instance.exascale_vision[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...a/instances/oracle-exascale-vision-app, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destruction complete after 13s
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Destroying... [id=projects/119724395047/secrets/exadb-ssh-private-key-dbbfcbbc/versions/1]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destruction complete after 13s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destruction complete after 13s
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Destruction complete after 0s
google_storage_bucket_iam_member.bucket_object_admin: Destroying... [id=b/oracle-ebs-toolkit-storage-bucket-086024db/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destruction complete after 13s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
null_resource.exascale_ingress_rules[0] (local-exec): Usage: oci network nsg rules remove [OPTIONS]

null_resource.exascale_ingress_rules[0] (local-exec): Error: No such option: --force

null_resource.exascale_ingress_rules[0] (local-exec): For OCI CLI commands and parameters suggestion, auto completion and other useful features, try the Interactive mode by typing `oci -i`.
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destruction complete after 14s
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
null_resource.exascale_ingress_rules[0] (local-exec): Usage: oci network nsg rules remove [OPTIONS]

null_resource.exascale_ingress_rules[0] (local-exec): Error: No such option: --force

null_resource.exascale_ingress_rules[0] (local-exec): For OCI CLI commands and parameters suggestion, auto completion and other useful features, try the Interactive mode by typing `oci -i`.
null_resource.exascale_ingress_rules[0]: Destruction complete after 15s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet]
google_storage_bucket_iam_member.bucket_object_admin: Destruction complete after 6s
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Still destroying... [id=oracle-ebs-toolkit-demo/northamerica-no...cloud-router/oracle-ebs-toolkit-nat-01, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in, 00m10s elapsed]
null_resource.exascale_db_provisioning[0]: Destroying... [id=9184041753248778086]
null_resource.exascale_db_provisioning[0]: Provisioning with 'local-exec'...
null_resource.exascale_db_provisioning[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 0\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaxhv3jjhifyweolg6rr7fddebmgcydg4qbbh342ndjqpq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      if [ -z \"$CLUSTER_URI\" ]; then\n        exit 0\n      fi\n\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      if [ -z \"$CLUSTER_OCID\" ] || [ -z \"$OCI_REGION\" ]; then\n        exit 0\n      fi\n\n      CDB_NAME_RAW=\"EBSCDB\"\n      DB_NAME_CLEAN=$(echo \"$CDB_NAME_RAW\" | sed 's/[-_]//g')\n\n      DB_LIST=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases?systemId=$CLUSTER_OCID\" 2>/dev/null || true)\n      DB_OCID=$(echo \"$DB_LIST\" | jq -r --arg dbname \"$DB_NAME_CLEAN\" '.data[] | select((.dbName | ascii_downcase) == ($dbname | ascii_downcase)) | .id' | head -1)\n\n      if [ -n \"$DB_OCID\" ] && [ \"$DB_OCID\" != \"null\" ]; then\n        oci raw-request --http-method DELETE --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases/$DB_OCID\" 2>/dev/null || true\n        sleep 60\n      fi\n\n      DISPLAY_NAME=\"Home_19c_$CDB_NAME_RAW\"\n      API_URL=\"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbHomes\"\n      LIST_URL=\"$API_URL?vmClusterId=$CLUSTER_OCID&displayName=$DISPLAY_NAME\"\n      LIST_RESULT=$(oci raw-request --http-method GET --target-uri \"$LIST_URL\" 2>/dev/null || true)\n      DB_HOME_OCID=$(echo \"$LIST_RESULT\" | jq -r --arg dname \"$DISPLAY_NAME\" '.data[] | select(.displayName == $dname) | .id' | head -1)\n\n      if [ -n \"$DB_HOME_OCID\" ] && [ \"$DB_HOME_OCID\" != \"null\" ]; then\n        oci raw-request --http-method DELETE --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbHomes/$DB_HOME_OCID\" 2>/dev/null || true\n      fi\n"]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/storage.a...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_compute_instance.exascale_vision[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...a/instances/oracle-exascale-vision-app, 00m20s elapsed]
null_resource.exascale_db_provisioning[0] (local-exec): jq: error (at <stdin>:16): Cannot index string with string "dbName"
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destruction complete after 14s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access, 00m10s elapsed]
module.ebs_storage_bucket.google_storage_bucket.bucket: Destroying... [id=oracle-ebs-toolkit-storage-bucket-086024db]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/iam.servi...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destruction complete after 14s
module.cloud_router.google_compute_router.router: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/routers/oracle-ebs-toolkit-network-cloud-router]
null_resource.exascale_db_provisioning[0] (local-exec): jq: error (at <stdin>:16): Cannot index string with string "displayName"
null_resource.exascale_db_provisioning[0]: Destruction complete after 3s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Destroying... [id=projects/oracle-ebs-toolkit-demo/locations/northamerica-northeast2/exadbVmClusters/exadb-vm-cluster-01]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/iap.tunne...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/logging.l...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destruction complete after 11s
random_password.admin_password[0]: Destroying... [id=none]
random_password.admin_password[0]: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destruction complete after 14s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destruction complete after 11s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destruction complete after 12s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destruction complete after 13s
module.ebs_storage_bucket.google_storage_bucket.bucket: Destruction complete after 4s
random_id.bucket_suffix: Destroying... [id=CGAk2w]
random_id.bucket_suffix: Destruction complete after 0s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destruction complete after 13s
google_compute_instance.exascale_vision[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...a/instances/oracle-exascale-vision-app, 00m30s elapsed]
module.cloud_router.google_compute_router.router: Still destroying... [id=projects/oracle-ebs-toolkit-demo/region...racle-ebs-toolkit-network-cloud-router, 00m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 00m10s elapsed]
google_compute_instance.exascale_vision[0]: Destruction complete after 35s
google_service_account.project_sa: Destroying... [id=projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_secret_manager_secret.exadb_private_key_secret[0]: Destroying... [id=projects/oracle-ebs-toolkit-demo/secrets/exadb-ssh-private-key-dbbfcbbc]
google_compute_address.exascale_vision_server_internal_ip[0]: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/exascale-vision-server-internal-ip]
local_file.exadb_private_key[0]: Destroying... [id=22c4bd9970490ba9b182c2616f323137cecba340]
local_file.exadb_public_key[0]: Destroying... [id=68b5445e4399079402ed4a9470154e7493600eea]
local_file.exadb_public_key[0]: Destruction complete after 0s
local_file.exadb_private_key[0]: Destruction complete after 0s
module.cloud_router.google_compute_router.router: Destruction complete after 13s
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/addresses/oracle-ebs-toolkit-nat-01]
google_service_account.project_sa: Destruction complete after 1s
google_compute_address.exascale_vision_server_internal_ip[0]: Destruction complete after 2s
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/northamerica-northeast2/subnetworks/oracle-ebs-toolkit-subnet-01]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destruction complete after 1s
google_secret_manager_secret.exadb_private_key_secret[0]: Destruction complete after 2s
random_id.secret_suffix[0]: Destroying... [id=27_LvA]
random_id.secret_suffix[0]: Destruction complete after 0s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 00m20s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/region...bnetworks/oracle-ebs-toolkit-subnet-01, 00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/oracle-ebs-toolkit-subnet-01"]: Destruction complete after 13s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 00m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 00m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 00m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 01m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 01m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/locati...t2/exadbVmClusters/exadb-vm-cluster-01, 01m20s elapsed]


```