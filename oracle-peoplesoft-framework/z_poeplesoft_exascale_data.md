# Oracle Peoplesoft Toolkit on Exascale@GCP logfile output example

This file shows example of executing Oracle Peoplesoft Customer environment on Exascale@GCP deployment log and outputs as well as timings and expected results

### 1. Setup the environment

```bash

[user@machine] oracle-peoplesoft-framework % make setup
Running setup...
bash scripts/install.sh
gcloud already exists.
✔ Terraform already installed: 1.13.0
✔ terraform-docs already installed: 0.20.0
All tools installed and configured.
Setup complete.
Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'.
[user@machine] oracle-peoplesoft-framework % gcloud config list
[core]
account = osuser@email.com
disable_usage_reporting = False
project = gcp-project-peoplesoft

Your active configuration is: [default]
[environment: untagged] Read more to tag: g.co/cloud/project-env-tag.
[user@machine] oracle-peoplesoft-framework % make verify-gcp-access
 Verifying GCP access for project: gcp-project-peoplesoft
Access to project gcp-project-peoplesoft confirmed.
 Checking IAM roles for osuser@email.com...
 User has Owner/Editor role → skipping fine-grained permission checks.

 GCP access check passed for project: gcp-project-peoplesoft
[user@machine] oracle-peoplesoft-framework % gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth...


Credentials saved to file: [/Users/osuser/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).




```

### 2. Authenticate with GCP and configure Application Default Credentials:

```bash

[user@machine] oracle-peoplesoft-framework % gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fau...


Credentials saved to file: [/Users/osuser/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).

Quota project "gcp-project-peoplesoft" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
[user@machine] oracle-peoplesoft-framework %


```

### 3. Deploy PeopleSoft Infrastructure

```bash

[user@machine] oracle-peoplesoft-framework % make init
Checking if backend bucket gs://gcp-project-peoplesoft-119724395047-terraform-state exists...
Initializing Terraform in ....
Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/google from the dependency lock file
- Reusing previous version of hashicorp/google-beta from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Reusing previous version of hashicorp/tls from the dependency lock file
- Reusing previous version of hashicorp/null from the dependency lock file
- Using previously-installed hashicorp/null v3.3.0
- Using previously-installed hashicorp/google v6.50.0
- Using previously-installed hashicorp/google-beta v7.33.0
- Using previously-installed hashicorp/random v3.9.0
- Using previously-installed hashicorp/local v2.9.0
- Using previously-installed hashicorp/tls v4.3.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Terraform initialized successfully.
[user@machine] oracle-peoplesoft-framework % make exascale_plan
Using cached grid image ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqakv6zraj2jc6rbptk4smtunilz4dmfa4n5qsrphe2s2ba (version 19.32.0.0.0)
terraform -chdir=. plan \
    -var="project_id=gcp-project-peoplesoft" \
    -var="project_service_account_email=ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" \
    -var="oracle_peoplesoft_exascale=true" \
    -var="exascale_grid_image_id=$(cat .grid_image_id)" \
    -var="exascale_grid_version=$(cat .grid_version)"
Acquiring state lock. This may take a few moments...
data.google_compute_image.apps_image: Reading...
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.apps_image: Read complete after 0s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 0s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.exascale_peoplesoft_server_internal_ip[0] will be created
  + resource "google_compute_address" "exascale_peoplesoft_server_internal_ip" {
      + address            = "10.115.0.40"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "exascale-peoplesoft-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "gcp-project-peoplesoft-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "gcp-project-peoplesoft-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.peoplesoft_apps_server_internal_ip will be created
  + resource "google_compute_address" "peoplesoft_apps_server_internal_ip" {
      + address            = "10.115.0.20"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "peoplesoft-apps-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "gcp-project-peoplesoft-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_instance.apps will be created
  + resource "google_compute_instance" "apps" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-highmem-8"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
                #!/bin/bash
                set -e

                # NOTE: This is Peoplesoft server boot script - all the updates add here

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

                # disable IPV6
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
                sysctl -p

                # dnf oracle packages
                dnf config-manager --set-enabled ol8_addons
                dnf install oracle-ebs-server-R12-preinstall -y
                dnf install oracle-database-preinstall-19c -y
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils tmux expect -y

                # dnf cleanup
                dnf clean all

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown oracle:oinstall /u02

                # for customer data
                mkdir -p /opt/oracle
                chown -Rf oracle:oinstall /opt/oracle

                # Peoplesoft directories for PUM preinstall prerequisites
                mkdir -pv  /u01/install/ /ds2 /srv/dpk/oracle /ds2/dpk/PT862P05B_2509240500-retail-orasrvlnx/oracleserver-2623528/oracle-server/product/19.3.0.0/bin/ /u02/db/oracle-server/admin/CDBCRM/adump
                chown -Rf oracle:oinstall /u02 /u01 /ds2 /srv/
                touch  /etc/oratab
                chown  oracle:oinstall /etc/oratab

                # remove profiles
                mv -v /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv -v /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.back
                mv -v /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

                # function to source env on
                if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # Make it persistent by adding it to /etc/fstab (if not already there)
                if ! grep -q '/swapfile' /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-peoplesoft-apps"
      + project              = "gcp-project-peoplesoft"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-app-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-peoplesoft-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 512
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
          + network_ip                  = "10.115.0.20"
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
          + email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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

  # google_compute_instance.exascale_peoplesoft[0] will be created
  + resource "google_compute_instance" "exascale_peoplesoft" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application"                = "oracle-exascale-peoplesoft"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-exascale-peoplesoft"
          + "managed-by"  = "terraform"
        }
      + machine_type         = "e2-highmem-8"
      + metadata             = (known after apply)
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-exascale-peoplesoft-app"
      + project              = "gcp-project-peoplesoft"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-app-access",
          + "external-db-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-peoplesoft-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "application"                = "oracle-exascale-peoplesoft"
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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 512
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
          + email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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
      + deletion_policy     = "DELETE"
      + deletion_protection = false
      + display_name        = "PeopleSoft Exadata VM Cluster"
      + effective_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id      = (known after apply)
      + exadb_vm_cluster_id = "ps-exadb-vm-cluster-01"
      + gcp_oracle_zone     = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "deployment" = "demo"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_network         = (known after apply)
      + odb_subnet          = (known after apply)
      + project             = "gcp-project-peoplesoft"
      + terraform_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_ecpu_count_per_node = (known after apply)
          + cluster_name                   = "psftcl1"
          + enabled_ecpu_count_per_node    = 8
          + exascale_db_storage_vault      = (known after apply)
          + gi_version                     = (known after apply)
          + grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqakv6zraj2jc6rbptk4smtunilz4dmfa4n5qsrphe2s2ba"
          + hostname                       = (known after apply)
          + hostname_prefix                = "psft-node"
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
      + deletion_policy              = "DELETE"
      + deletion_protection          = false
      + display_name                 = "PeopleSoft Exascale DB Storage Vault"
      + effective_labels             = {
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id               = (known after apply)
      + exascale_db_storage_vault_id = "ps-exascale-db-storage-vault"
      + gcp_oracle_zone              = (known after apply)
      + id                           = (known after apply)
      + location                     = "northamerica-northeast2"
      + name                         = (known after apply)
      + project                      = "gcp-project-peoplesoft"
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
      + network             = "projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network"
      + odb_network_id      = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + odb_subnet_id       = "gcp-project-peoplesoft-network-backup-subnet"
      + odbnetwork          = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + odb_subnet_id       = "gcp-project-peoplesoft-network-client-subnet"
      + odbnetwork          = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
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
      + project               = "gcp-project-peoplesoft"
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
      + account_id   = "ps-project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "gcp-project-peoplesoft"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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
          + "cdb_name"        = "PSFTCDB"
          + "oci_api_version" = "20160918"
          + "password"        = (known after apply)
          + "vm_id"           = (known after apply)
        }
    }

  # null_resource.exascale_db_provisioning[0] will be created
  + resource "null_resource" "exascale_db_provisioning" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "PSFTCDB"
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

  # null_resource.push_scripts will be created
  + resource "null_resource" "push_scripts" {
      + id       = (known after apply)
      + triggers = {
          + "always_run" = (known after apply)
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
      + name               = "gcp-project-peoplesoft-network-cloud-router"
      + network            = "gcp-project-peoplesoft-network"
      + project            = "gcp-project-peoplesoft"
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "gcp-project-peoplesoft-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "gcp-project-peoplesoft"
      + region                              = "northamerica-northeast2"
      + router                              = "gcp-project-peoplesoft-network-cloud-router"
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
          + name                     = "gcp-project-peoplesoft-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle PeopleSoft Apps"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-external-app-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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
              + "2049",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle PeopleSoft DB"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-external-db-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-http-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTPS traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-https-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow IAP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-iap-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow ICMP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-icmp-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow internal HTTP traffic within the VPC"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-internal-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"] will be created
  + resource "google_compute_route" "route" {
      + as_paths                   = (known after apply)
      + creation_timestamp         = (known after apply)
      + description                = "Public NAT GW - route through IGW to access internet"
      + dest_range                 = "0.0.0.0/0"
      + id                         = (known after apply)
      + name                       = "ps-nat-egress-internet"
      + network                    = "gcp-project-peoplesoft-network"
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
      + project                    = "gcp-project-peoplesoft"
      + route_status               = (known after apply)
      + route_type                 = (known after apply)
      + self_link                  = (known after apply)
      + tags                       = [
          + "egress-nat",
        ]
      + warnings                   = (known after apply)
    }

  # module.peoplesoft_storage_bucket.google_storage_bucket.bucket will be created
  + resource "google_storage_bucket" "bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "gcp-project-peoplesoft"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "gcp-project-peoplesoft"
        }
      + location                    = "NORTHAMERICA-NORTHEAST2"
      + name                        = (known after apply)
      + project                     = "gcp-project-peoplesoft"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "gcp-project-peoplesoft"
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

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"] will be created
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
      + name                       = "gcp-project-peoplesoft-subnet-01"
      + network                    = "gcp-project-peoplesoft-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "gcp-project-peoplesoft"
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
      + deletion_policy                           = "DELETE"
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "gcp-project-peoplesoft-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "gcp-project-peoplesoft"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 49 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + apps_instance_zone                = "northamerica-northeast2-a"
  + deployment_summary                = (known after apply)
  + exascale_deployment_summary       = <<-EOT
        =========================================
         Oracle PeopleSoft on ExaScale @ GCP
        -----------------------------------------
         Project ID     : gcp-project-peoplesoft
         Region         : northamerica-northeast2
         Zone           : northamerica-northeast2-a
         ExaScale Region: northamerica-northeast2
        -----------------------------------------
         Application Tier (GCE)
        -----------------------------------------
           • Name         : oracle-exascale-peoplesoft-app
           • Internal IP  : 10.115.0.40
        -----------------------------------------
         Database Tier (Oracle Database@Google Cloud)
        -----------------------------------------
           • Type         : Oracle Database@Google Cloud (ExaScale)
           • Cluster Name : PeopleSoft Exadata VM Cluster
           • CDB Name     : PSFTCDB
           • SSH Key      : ./exadb_private_key.pem
           • Connection   : ./exascale_outputs.yaml (TNS, SCAN DNS)
        =========================================
    EOT
  + exascale_peoplesoft_instance_zone = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework % make exascale_deploy
Using cached grid image ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqakv6zraj2jc6rbptk4smtunilz4dmfa4n5qsrphe2s2ba (version 19.32.0.0.0)
terraform -chdir=. apply -auto-approve \
    -var="project_id=gcp-project-peoplesoft" \
    -var="project_service_account_email=ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" \
    -var="oracle_peoplesoft_exascale=true" \
    -var="exascale_grid_image_id=$(cat .grid_image_id)" \
    -var="exascale_grid_version=$(cat .grid_version)"
data.google_compute_image.apps_image: Reading...
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.apps_image: Read complete after 0s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.exascale_peoplesoft_server_internal_ip[0] will be created
  + resource "google_compute_address" "exascale_peoplesoft_server_internal_ip" {
      + address            = "10.115.0.40"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "exascale-peoplesoft-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "gcp-project-peoplesoft-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "gcp-project-peoplesoft-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_address.peoplesoft_apps_server_internal_ip will be created
  + resource "google_compute_address" "peoplesoft_apps_server_internal_ip" {
      + address            = "10.115.0.20"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "peoplesoft-apps-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "gcp-project-peoplesoft"
      + purpose            = (known after apply)
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
      + subnetwork         = "gcp-project-peoplesoft-subnet-01"
      + terraform_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + users              = (known after apply)
    }

  # google_compute_instance.apps will be created
  + resource "google_compute_instance" "apps" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-highmem-8"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
                #!/bin/bash
                set -e

                # NOTE: This is Peoplesoft server boot script - all the updates add here

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

                # disable IPV6
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
                sysctl -p

                # dnf oracle packages
                dnf config-manager --set-enabled ol8_addons
                dnf install oracle-ebs-server-R12-preinstall -y
                dnf install oracle-database-preinstall-19c -y
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils tmux expect -y

                # dnf cleanup
                dnf clean all

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown oracle:oinstall /u02

                # for customer data
                mkdir -p /opt/oracle
                chown -Rf oracle:oinstall /opt/oracle

                # Peoplesoft directories for PUM preinstall prerequisites
                mkdir -pv  /u01/install/ /ds2 /srv/dpk/oracle /ds2/dpk/PT862P05B_2509240500-retail-orasrvlnx/oracleserver-2623528/oracle-server/product/19.3.0.0/bin/ /u02/db/oracle-server/admin/CDBCRM/adump
                chown -Rf oracle:oinstall /u02 /u01 /ds2 /srv/
                touch  /etc/oratab
                chown  oracle:oinstall /etc/oratab

                # remove profiles
                mv -v /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv -v /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.back
                mv -v /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

                # function to source env on
                if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # Make it persistent by adding it to /etc/fstab (if not already there)
                if ! grep -q '/swapfile' /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-peoplesoft-apps"
      + project              = "gcp-project-peoplesoft"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-app-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-peoplesoft-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 512
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
          + network_ip                  = "10.115.0.20"
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
          + email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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

  # google_compute_instance.exascale_peoplesoft[0] will be created
  + resource "google_compute_instance" "exascale_peoplesoft" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + creation_timestamp   = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application"                = "oracle-exascale-peoplesoft"
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
        }
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-exascale-peoplesoft"
          + "managed-by"  = "terraform"
        }
      + machine_type         = "e2-highmem-8"
      + metadata             = (known after apply)
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-exascale-peoplesoft-app"
      + project              = "gcp-project-peoplesoft"
      + self_link            = (known after apply)
      + tags                 = [
          + "egress-nat",
          + "external-app-access",
          + "external-db-access",
          + "http-server",
          + "https-server",
          + "iap-access",
          + "icmp-access",
          + "internal-access",
          + "lb-health-check",
          + "oracle-peoplesoft-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "application"                = "oracle-exascale-peoplesoft"
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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + resource_policies      = (known after apply)
              + size                   = 512
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
          + email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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
      + deletion_policy     = "DELETE"
      + deletion_protection = false
      + display_name        = "PeopleSoft Exadata VM Cluster"
      + effective_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id      = (known after apply)
      + exadb_vm_cluster_id = "ps-exadb-vm-cluster-01"
      + gcp_oracle_zone     = (known after apply)
      + id                  = (known after apply)
      + labels              = {
          + "deployment" = "demo"
        }
      + location            = "northamerica-northeast2"
      + name                = (known after apply)
      + odb_network         = (known after apply)
      + odb_subnet          = (known after apply)
      + project             = "gcp-project-peoplesoft"
      + terraform_labels    = {
          + "deployment"                 = "demo"
          + "goog-terraform-provisioned" = "true"
        }

      + properties {
          + additional_ecpu_count_per_node = (known after apply)
          + cluster_name                   = "psftcl1"
          + enabled_ecpu_count_per_node    = 8
          + exascale_db_storage_vault      = (known after apply)
          + gi_version                     = (known after apply)
          + grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqakv6zraj2jc6rbptk4smtunilz4dmfa4n5qsrphe2s2ba"
          + hostname                       = (known after apply)
          + hostname_prefix                = "psft-node"
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
      + deletion_policy              = "DELETE"
      + deletion_protection          = false
      + display_name                 = "PeopleSoft Exascale DB Storage Vault"
      + effective_labels             = {
          + "goog-terraform-provisioned" = "true"
        }
      + entitlement_id               = (known after apply)
      + exascale_db_storage_vault_id = "ps-exascale-db-storage-vault"
      + gcp_oracle_zone              = (known after apply)
      + id                           = (known after apply)
      + location                     = "northamerica-northeast2"
      + name                         = (known after apply)
      + project                      = "gcp-project-peoplesoft"
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
      + network             = "projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network"
      + odb_network_id      = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + odb_subnet_id       = "gcp-project-peoplesoft-network-backup-subnet"
      + odbnetwork          = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + odb_subnet_id       = "gcp-project-peoplesoft-network-client-subnet"
      + odbnetwork          = "gcp-project-peoplesoft-network-odb-network"
      + project             = "gcp-project-peoplesoft"
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
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + project = "gcp-project-peoplesoft"
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
      + project               = "gcp-project-peoplesoft"
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
      + account_id   = "ps-project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "gcp-project-peoplesoft"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com"
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
          + "cdb_name"        = "PSFTCDB"
          + "oci_api_version" = "20160918"
          + "password"        = (known after apply)
          + "vm_id"           = (known after apply)
        }
    }

  # null_resource.exascale_db_provisioning[0] will be created
  + resource "null_resource" "exascale_db_provisioning" {
      + id       = (known after apply)
      + triggers = {
          + "cdb_name"        = "PSFTCDB"
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

  # null_resource.push_scripts will be created
  + resource "null_resource" "push_scripts" {
      + id       = (known after apply)
      + triggers = {
          + "always_run" = (known after apply)
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
      + name               = "gcp-project-peoplesoft-network-cloud-router"
      + network            = "gcp-project-peoplesoft-network"
      + project            = "gcp-project-peoplesoft"
      + region             = "northamerica-northeast2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "gcp-project-peoplesoft-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "gcp-project-peoplesoft"
      + region                              = "northamerica-northeast2"
      + router                              = "gcp-project-peoplesoft-network-cloud-router"
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
          + name                     = "gcp-project-peoplesoft-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle PeopleSoft Apps"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-external-app-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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
              + "2049",
            ]
          + protocol = "tcp"
        }

      + log_config {
          + metadata = "INCLUDE_ALL_METADATA"
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow external access to Oracle PeopleSoft DB"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-external-db-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-http-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow HTTPS traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-https-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow IAP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-iap-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow ICMP traffic inbound"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-icmp-in"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"] will be created
  + resource "google_compute_firewall" "rules_ingress_egress" {
      + creation_timestamp = (known after apply)
      + description        = "Allow internal HTTP traffic within the VPC"
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "ps-allow-internal-access"
      + network            = "gcp-project-peoplesoft-network"
      + priority           = 1000
      + project            = "gcp-project-peoplesoft"
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

  # module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"] will be created
  + resource "google_compute_route" "route" {
      + as_paths                   = (known after apply)
      + creation_timestamp         = (known after apply)
      + description                = "Public NAT GW - route through IGW to access internet"
      + dest_range                 = "0.0.0.0/0"
      + id                         = (known after apply)
      + name                       = "ps-nat-egress-internet"
      + network                    = "gcp-project-peoplesoft-network"
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
      + project                    = "gcp-project-peoplesoft"
      + route_status               = (known after apply)
      + route_type                 = (known after apply)
      + self_link                  = (known after apply)
      + tags                       = [
          + "egress-nat",
        ]
      + warnings                   = (known after apply)
    }

  # module.peoplesoft_storage_bucket.google_storage_bucket.bucket will be created
  + resource "google_storage_bucket" "bucket" {
      + effective_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "gcp-project-peoplesoft"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "gcp-project-peoplesoft"
        }
      + location                    = "NORTHAMERICA-NORTHEAST2"
      + name                        = (known after apply)
      + project                     = "gcp-project-peoplesoft"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "gcp-project-peoplesoft"
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

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "gcp-project-peoplesoft"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"] will be created
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
      + name                       = "gcp-project-peoplesoft-subnet-01"
      + network                    = "gcp-project-peoplesoft-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "gcp-project-peoplesoft"
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
      + deletion_policy                           = "DELETE"
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "gcp-project-peoplesoft-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "gcp-project-peoplesoft"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 49 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + apps_instance_zone                = "northamerica-northeast2-a"
  + deployment_summary                = (known after apply)
  + exascale_deployment_summary       = <<-EOT
        =========================================
         Oracle PeopleSoft on ExaScale @ GCP
        -----------------------------------------
         Project ID     : gcp-project-peoplesoft
         Region         : northamerica-northeast2
         Zone           : northamerica-northeast2-a
         ExaScale Region: northamerica-northeast2
        -----------------------------------------
         Application Tier (GCE)
        -----------------------------------------
           • Name         : oracle-exascale-peoplesoft-app
           • Internal IP  : 10.115.0.40
        -----------------------------------------
         Database Tier (Oracle Database@Google Cloud)
        -----------------------------------------
           • Type         : Oracle Database@Google Cloud (ExaScale)
           • Cluster Name : PeopleSoft Exadata VM Cluster
           • CDB Name     : PSFTCDB
           • SSH Key      : ./exadb_private_key.pem
           • Connection   : ./exascale_outputs.yaml (TNS, SCAN DNS)
        =========================================
    EOT
  + exascale_peoplesoft_instance_zone = (known after apply)
tls_private_key.exadb_ssh_key[0]: Creating...
random_id.secret_suffix[0]: Creating...
random_id.bucket_suffix: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=yNOluQ]
random_id.secret_suffix[0]: Creation complete after 0s [id=RBwsDA]
random_password.admin_password[0]: Creating...
random_password.admin_password[0]: Creation complete after 0s [id=none]
module.network.module.vpc.google_compute_network.network: Creating...
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Creating...
google_service_account.project_sa: Creating...
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creating...
google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"]: Creating...
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creating...
google_secret_manager_secret.exadb_private_key_secret[0]: Creating...
google_secret_manager_secret.exadb_private_key_secret[0]: Creation complete after 2s [id=projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-441c2c0c]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creating...
tls_private_key.exadb_ssh_key[0]: Creation complete after 2s [id=295c41905c7e27d6e78be380ab5a2c18d2cb3f7f]
local_file.exadb_public_key[0]: Creating...
local_file.exadb_public_key[0]: Creation complete after 0s [id=060f81f8a05f3af80910ef91fcd68bf610c17f26]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Creating...
google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"]: Creation complete after 4s [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01]
local_file.exadb_private_key[0]: Creating...
local_file.exadb_private_key[0]: Creation complete after 0s [id=94efe110d8f52397e771db0089a8d35f7bbc49de]
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Creating...
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Creation complete after 3s [id=projects/119724395047/secrets/exadb-ssh-private-key-441c2c0c/versions/1]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creation complete after 6s [id=gcp-project-peoplesoft/iam.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creation complete after 6s [id=gcp-project-peoplesoft/compute.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creation complete after 4s [id=gcp-project-peoplesoft/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creation complete after 6s [id=gcp-project-peoplesoft/storage.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creation complete after 6s [id=gcp-project-peoplesoft/secretmanager.googleapis.com]
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Creation complete after 3s [id=gcp-project-peoplesoft-storage-bucket-c8d3a5b9]
module.network.module.vpc.google_compute_network.network: Still creating... [00m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m10s elapsed]
google_service_account.project_sa: Still creating... [00m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m20s elapsed]
google_service_account.project_sa: Still creating... [00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m30s elapsed]
google_service_account.project_sa: Still creating... [00m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m40s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m40s elapsed]
google_service_account.project_sa: Still creating... [00m40s elapsed]
module.network.module.vpc.google_compute_network.network: Creation complete after 45s [id=projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network]
google_service_account.project_sa: Creation complete after 45s [id=projects/gcp-project-peoplesoft/serviceAccounts/ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Creating...
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creating...
google_oracle_database_odb_network.odb_network[0]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creating...
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Creating...
google_oracle_database_odb_network.odb_network[0]: Creation complete after 3s [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creating...
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [00m50s elapsed]
google_storage_bucket_iam_member.bucket_object_admin: Creation complete after 6s [id=b/gcp-project-peoplesoft-storage-bucket-c8d3a5b9/roles/storage.objectAdmin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_oracle_database_odb_subnet.client_subnet[0]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still creating... [00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still creating... [00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Creation complete after 14s [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01]
google_oracle_database_odb_subnet.backup_subnet[0]: Creating...
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still creating... [00m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still creating... [00m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m20s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creation complete after 35s [id=gcp-project-peoplesoft/roles/iam.serviceAccountUser/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creation complete after 38s [id=gcp-project-peoplesoft/roles/secretmanager.secretAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_compute_address.exascale_peoplesoft_server_internal_ip[0]: Creating...
google_compute_address.peoplesoft_apps_server_internal_ip: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creation complete after 38s [id=gcp-project-peoplesoft/roles/monitoring.metricWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Creating...
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creation complete after 39s [id=gcp-project-peoplesoft/roles/logging.logWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creation complete after 39s [id=gcp-project-peoplesoft/roles/iap.tunnelResourceAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creation complete after 40s [id=gcp-project-peoplesoft/roles/storage.admin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Creating...
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creation complete after 40s [id=gcp-project-peoplesoft/roles/compute.instanceAdmin.v1/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Creating...
google_compute_address.exascale_peoplesoft_server_internal_ip[0]: Creation complete after 3s [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/exascale-peoplesoft-server-internal-ip]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Creating...
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m40s elapsed]
google_compute_address.peoplesoft_apps_server_internal_ip: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Creation complete after 12s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Creation complete after 11s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in]
module.cloud_router.google_compute_router.router: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Creation complete after 11s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in]
google_compute_instance.exascale_peoplesoft[0]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Creation complete after 13s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Creation complete after 12s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in]
google_compute_address.peoplesoft_apps_server_internal_ip: Creation complete after 14s [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/peoplesoft-apps-server-internal-ip]
google_compute_instance.apps: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Creation complete after 12s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m40s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [00m50s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router.router: Still creating... [00m10s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still creating... [00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Still creating... [00m10s elapsed]
google_compute_instance.apps: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Creation complete after 12s [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Creation complete after 11s [id=projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet]
module.cloud_router.google_compute_router.router: Creation complete after 13s [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router]
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Creating...
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [00m50s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [01m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m00s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still creating... [00m20s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Creation complete after 21s [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app]
google_compute_instance.apps: Still creating... [00m20s elapsed]
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Still creating... [00m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m00s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m00s elapsed]
google_compute_instance.apps: Creation complete after 23s [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps]
null_resource.push_scripts: Creating...
null_resource.push_scripts: Provisioning with 'local-exec'...
null_resource.push_scripts (local-exec): Executing: ["/bin/sh" "-c" "echo \"Waiting 30 seconds for VM SSH daemon and IAP to initialize...\"\nsleep 30\n\necho \"Pushing .sh files to /tmp via IAP...\"\ngcloud compute scp ./scripts/peoplesoft/*.sh oracle-peoplesoft-apps:/tmp/ \\\n  --zone=\"northamerica-northeast2-a\" \\\n  --project=\"gcp-project-peoplesoft\" \\\n  --tunnel-through-iap\n\necho \"Setting up /scripts directory and assigning to oracle user...\"\ngcloud compute ssh oracle-peoplesoft-apps \\\n  --zone=\"northamerica-northeast2-a\" \\\n  --project=\"gcp-project-peoplesoft\" \\\n  --tunnel-through-iap \\\n  --command=\" \\\n    echo 'Checking if oracle user exists...'; \\\n    while ! id -u oracle > /dev/null 2>&1; do \\\n      echo 'Waiting for startup-script to create oracle user...'; \\\n      sleep 10; \\\n    done; \\\n    sudo mkdir -p /scripts && \\\n    sudo mv /tmp/*.sh /scripts/ && \\\n    sudo chown -R oracle:oinstall /scripts && \\\n    sudo chmod 755 /scripts && \\\n    sudo chmod a+x /scripts/*.sh \\\n  \"\n        \necho \"Scripts successfully pushed, assigned to oracle, and permissions set!\"\n"]
null_resource.push_scripts (local-exec): Waiting 30 seconds for VM SSH daemon and IAP to initialize...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Creation complete after 13s [id=gcp-project-peoplesoft/northamerica-northeast2/gcp-project-peoplesoft-network-cloud-router/gcp-project-peoplesoft-nat-01]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m10s elapsed]
null_resource.push_scripts: Still creating... [00m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m20s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m20s elapsed]
null_resource.push_scripts: Still creating... [00m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m30s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still creating... [02m30s elapsed]
null_resource.push_scripts: Still creating... [00m30s elapsed]
null_resource.push_scripts (local-exec): Pushing .sh files to /tmp via IAP...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m40s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Creation complete after 2m37s [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault]
null_resource.push_scripts (local-exec): WARNING:

null_resource.push_scripts (local-exec): To increase the performance of the tunnel, consider installing NumPy. For instructions,
null_resource.push_scripts (local-exec): please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m40s elapsed]
null_resource.push_scripts (local-exec): Warning: Permanently added 'compute.3957127490812802443' (ED25519) to the list of known hosts.
null_resource.push_scripts (local-exec): ** WARNING: connection is not using a post-quantum key exchange algorithm.
null_resource.push_scripts (local-exec): ** This session may be vulnerable to "store now, decrypt later" attacks.
null_resource.push_scripts (local-exec): ** The server may need to be upgraded. See https://openssh.com/pq.html
null_resource.push_scripts: Still creating... [00m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [01m50s elapsed]
null_resource.push_scripts (local-exec): Setting up /scripts directory and assigning to oracle user...
null_resource.push_scripts (local-exec): WARNING:

null_resource.push_scripts (local-exec): To increase the performance of the tunnel, consider installing NumPy. For instructions,
null_resource.push_scripts (local-exec): please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

null_resource.push_scripts (local-exec): ** WARNING: connection is not using a post-quantum key exchange algorithm.
null_resource.push_scripts (local-exec): ** This session may be vulnerable to "store now, decrypt later" attacks.
null_resource.push_scripts (local-exec): ** The server may need to be upgraded. See https://openssh.com/pq.html
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [01m50s elapsed]
null_resource.push_scripts (local-exec): Checking if oracle user exists...
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [00m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m30s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m40s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [02m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [02m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m30s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m30s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m40s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m40s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [03m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [03m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m50s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m00s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m20s elapsed]
null_resource.push_scripts: Still creating... [03m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m30s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m30s elapsed]
null_resource.push_scripts: Still creating... [03m30s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m40s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m40s elapsed]
null_resource.push_scripts: Still creating... [03m40s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [04m50s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [04m50s elapsed]
null_resource.push_scripts: Still creating... [03m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.client_subnet[0]: Still creating... [05m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Creation complete after 5m7s [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet]
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [05m00s elapsed]
null_resource.push_scripts: Still creating... [04m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [05m10s elapsed]
null_resource.push_scripts: Still creating... [04m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.backup_subnet[0]: Still creating... [05m20s elapsed]
null_resource.push_scripts: Still creating... [04m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
google_oracle_database_odb_subnet.backup_subnet[0]: Creation complete after 5m27s [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Creating...
null_resource.push_scripts: Still creating... [04m30s elapsed]
null_resource.push_scripts (local-exec): Scripts successfully pushed, assigned to oracle, and permissions set!
null_resource.push_scripts: Creation complete after 4m31s [id=4853718893434233236]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [00m40s elapsed]
.....
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still creating... [66m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Creation complete after 1h6m48s [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exadbVmClusters/ps-exadb-vm-cluster-01]
null_resource.exascale_db_provisioning[0]: Creating...
null_resource.exascale_db_provisioning[0]: Provisioning with 'local-exec'...
null_resource.exascale_db_provisioning[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_db_provisioning[0]: Still creating... [00m10s elapsed]
.....
null_resource.exascale_db_provisioning[0]: Still creating... [31m10s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [31m20s elapsed]
null_resource.exascale_db_provisioning[0]: Still creating... [31m30s elapsed]
null_resource.exascale_db_provisioning[0]: Creation complete after 31m35s [id=4209948424162606122]
null_resource.exascale_configure_and_upload[0]: Creating...
null_resource.exascale_ingress_rules[0]: Creating...
null_resource.exascale_ingress_rules[0]: Provisioning with 'local-exec'...
null_resource.exascale_ingress_rules[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 1\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayateau3whny6tk5tzm6njegspp7sez3bqmarl2ezkzi3eq?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      if [ -z \"$CLUSTER_OCID\" ] || [ -z \"$OCI_REGION\" ]; then\n        exit 1\n      fi\n\n      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/exadbVmClusters/$CLUSTER_OCID\" | grep -v \"ServiceError\")\n      SUBNET_OCID=$(echo \"$CLUSTER_JSON\" | jq -r '.data.subnetId // empty')\n\n      if [ -z \"$SUBNET_OCID\" ]; then\n        exit 1\n      fi\n\n      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri \"https://iaas.${OCI_REGION}.oraclecloud.com/20160918/subnets/$SUBNET_OCID\" | grep -v \"ServiceError\")\n      VCN_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.vcnId // empty')\n      COMPARTMENT_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.compartmentId // empty')\n\n      TARGET_NSG_OCID=$(oci network nsg list \\\n        --compartment-id \"$COMPARTMENT_OCID\" \\\n        --vcn-id \"$VCN_OCID\" \\\n        --all | jq -r '\n          .data[] \n          | select(.[\"display-name\"] | endswith(\"_NSG\")) \n          | select(.[\"display-name\"] | contains(\"BCKP\") | not) \n          | .id\n        ' | head -n 1)\n\n      if [ -z \"$TARGET_NSG_OCID\" ]; then\n        exit 1\n      fi\n\n      oci network nsg rules add \\\n        --nsg-id \"$TARGET_NSG_OCID\" \\\n        --region \"$OCI_REGION\" \\\n        --security-rules '[\n          {\n            \"direction\": \"INGRESS\",\n            \"protocol\": \"6\",\n            \"source\": \"10.115.0.0/20\",\n            \"sourceType\": \"CIDR_BLOCK\",\n            \"tcpOptions\": {\n              \"destinationPortRange\": {\"max\": 1521, \"min\": 1521}\n            }\n          },\n          {\n            \"direction\": \"INGRESS\",\n            \"protocol\": \"6\",\n            \"source\": \"10.115.0.0/20\",\n            \"sourceType\": \"CIDR_BLOCK\",\n            \"tcpOptions\": {\n              \"destinationPortRange\": {\"max\": 22, \"min\": 22}\n            }\n          }\n        ]' > /dev/null\n"]
null_resource.exascale_configure_and_upload[0]: Provisioning with 'local-exec'...
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_ingress_rules[0]: Creation complete after 7s [id=5691192788805675965]
null_resource.exascale_configure_and_upload[0]: Still creating... [00m10s elapsed]
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0] (local-exec): (output suppressed due to sensitive value in config)
null_resource.exascale_configure_and_upload[0]: Still creating... [00m20s elapsed]
null_resource.exascale_configure_and_upload[0]: Creation complete after 22s [id=3156355113537750378]

Apply complete! Resources: 49 added, 0 changed, 0 destroyed.

Outputs:

apps_instance_zone = "northamerica-northeast2-a"
deployment_summary = <<EOT

=========================================
 PeopleSoft VM Configuration
-----------------------------------------
   • Instance Name  : oracle-peoplesoft-apps
   • Internal IP    : 10.115.0.20
   • Zone           : northamerica-northeast2-a
   • Machine Type   : e2-highmem-8
   • SSH Command    :
       gcloud compute ssh --zone "northamerica-northeast2-a" "oracle-peoplesoft-apps" --tunnel-through-iap --project "gcp-project-peoplesoft" -- -L 8000:localhost:8000

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : gcp-project-peoplesoft-storage-bucket-c8d3a5b9
   • Bucket URL     : gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9

=========================================
 Summary
-----------------------------------------
   • Total Instances: 1
   • Storage Bucket : gcp-project-peoplesoft-storage-bucket-c8d3a5b9
   • Generated At   : 2026-08-10T13:00:41Z
=========================================

EOT
exascale_deployment_summary = <<EOT

=========================================
 Oracle PeopleSoft on ExaScale @ GCP
-----------------------------------------
 Project ID     : gcp-project-peoplesoft
 Region         : northamerica-northeast2
 Zone           : northamerica-northeast2-a
 ExaScale Region: northamerica-northeast2
-----------------------------------------
 Application Tier (GCE)
-----------------------------------------
   • Name         : oracle-exascale-peoplesoft-app
   • Internal IP  : 10.115.0.40
-----------------------------------------
 Database Tier (Oracle Database@Google Cloud)
-----------------------------------------
   • Type         : Oracle Database@Google Cloud (ExaScale)
   • Cluster Name : PeopleSoft Exadata VM Cluster
   • CDB Name     : PSFTCDB
   • SSH Key      : ./exadb_private_key.pem
   • Connection   : ./exascale_outputs.yaml (TNS, SCAN DNS)
=========================================

EOT
exascale_peoplesoft_instance_zone = "northamerica-northeast2-a"
[user@machine] oracle-peoplesoft-framework %

## stage

[user@machine] oracle-peoplesoft-framework % GCP_BUCKET=$(gcloud storage ls | grep gcp-project-peoplesoft-storage-bucket)
gcloud storage cp gs://oracle-media/CDBFSCM/RDBMS_TO_GCP.tar.gz ${GCP_BUCKET}
Copying gs://oracle-media/CDBFSCM/RDBMS_TO_GCP.tar.gz to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/RDBMS_TO_GCP.tar.gz
  Completed files 1/1 | 6.8GiB/6.8GiB | 57.7MiB/s

Average throughput: 51.3MiB/s
[user@machine] oracle-peoplesoft-framework % gcloud storage cp gs://oracle-media/CDBFSCM/PT_TO_GCP.tar.gz ${GCP_BUCKET}
Copying gs://oracle-media/CDBFSCM/PT_TO_GCP.tar.gz to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PT_TO_GCP.tar.gz
  Completed files 1/1 | 9.6GiB/9.6GiB | 52.9MiB/s

Average throughput: 53.2MiB/s
[user@machine] oracle-peoplesoft-framework % gcloud storage cp gs://oracle-media/CDBFSCM/PS_CFG_HOME_TO_GCP.tar.gz ${GCP_BUCKET}

Copying gs://oracle-media/CDBFSCM/PS_CFG_HOME_TO_GCP.tar.gz to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PS_CFG_HOME_TO_GCP.tar.gz
  Completed files 1/1 | 583.6MiB/583.6MiB | 43.8MiB/s

Average throughput: 54.3MiB/s
[user@machine] oracle-peoplesoft-framework % gcloud storage cp gs://oracle-media/CDBFSCM/domaininfo.txt ${GCP_BUCKET}
gcloud storage cp gs://oracle-media/CDBFSCM/psft.env ${GCP_BUCKET}
Copying gs://oracle-media/CDBFSCM/domaininfo.txt to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/domaininfo.txt
  Completed files 1/1 | 75.0B/75.0B
Copying gs://oracle-media/CDBFSCM/psft.env to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/psft.env
  Completed files 1/1 | 1.1kiB/1.1kiB
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework % gcloud storage cp -r gs://oracle-media/CDBFSCM/"*.bkp" ${GCP_BUCKET}
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
Copying gs://oracle-media/CDBFSCM/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
Copying gs://oracle-media/CDBFSCM/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp to gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
  Completed files 25/25 | 5.9GiB/5.9GiB | 116.4MiB/s

Average throughput: 250.8MiB/s
[user@machine] oracle-peoplesoft-framework % gcloud storage ls ${GCP_BUCKET}
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PS_CFG_HOME_TO_GCP.tar.gz
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PT_TO_GCP.tar.gz
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/RDBMS_TO_GCP.tar.gz
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/domaininfo.txt
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/psft.env
gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
[user@machine] oracle-peoplesoft-framework %


```

### 4. Deploy Oracle PeopleSoft environment

```bash

[user@machine] oracle-peoplesoft-framework % make exascale_deploy_peoplesoft

>>> Getting ExaScale app instance zone from Terraform output
Zone: northamerica-northeast2-a

>>> Creating /scripts on oracle-exascale-peoplesoft-app
mkdir: created directory '/scripts'
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

>>> Copying /scripts/* to oracle-exascale-peoplesoft-app
7zz                                                                                                                                                                                                                                                                                                                                       100% 2811KB   2.4MB/s   00:01
setup_db_exascale.sh                                                                                                                                                                                                                                                                                                                      100% 9302    67.7KB/s   00:00
setup_nfs_share.sh                                                                                                                                                                                                                                                                                                                        100% 3225    23.3KB/s   00:00
setup_ps_apps.sh                                                                                                                                                                                                                                                                                                                          100%   12KB  84.5KB/s   00:00
stage_customer_data.sh                                                                                                                                                                                                                                                                                                                    100% 3243    23.7KB/s   00:00
start_db_setup.sh                                                                                                                                                                                                                                                                                                                         100% 1778    13.2KB/s   00:00
tmp_recreate.sql                                                                                                                                                                                                                                                                                                                          100% 1868    13.4KB/s   00:00

>>> Ownership updates /scripts/ on oracle-exascale-peoplesoft-app
changed ownership of '/scripts/7zz' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/setup_db_exascale.sh' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/setup_nfs_share.sh' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/setup_ps_apps.sh' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/stage_customer_data.sh' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/start_db_setup.sh' from gcp_os_user:gcp_os_user to root:root
changed ownership of '/scripts/tmp_recreate.sql' from gcp_os_user:gcp_os_user to root:root
ownership of '/scripts' retained as root:root
mode of '/scripts/7zz' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)
mode of '/scripts/setup_db_exascale.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/setup_nfs_share.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/setup_ps_apps.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/stage_customer_data.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/start_db_setup.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/tmp_recreate.sql' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)

>>> Setting up nfs share @GCP
Mon Aug 10 15:09:59 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: setup_nfs_sharing
         =========================================================================
         Function setting up NFS sharing b/w apps and database nodes
         -------------------------------------------------------------------------

### Setting up hostname for apps node

### Setting up /etc/exports for NFS sharing

### Contents of /etc/exports for NFS sharing
/u01  10.116.9.39(rw,async,insecure,no_subtree_check,fsid=241,no_root_squash)

### Restarting nfs server service

### Testing SSH connection to Exascale Server: 10.116.9.39
Warning: Permanently added '10.116.9.39' (ECDSA) to the list of known hosts.
SSH connection to Exascale Server is working

### Mounting /buckets on Exascale Vm: 10.116.9.39
mkdir: created directory '/buckets'
total 0
drwxr-xr-x. 2 54321 54321 6 Aug 10 13:05 install

### Status of /buckets on Exascale Vm: 10.116.9.39
10.115.0.40:/u01                                     512G   31G  482G   6% /buckets

### Sending /tmp/exascale_outputs.yaml to Exascale Vm: 10.116.9.39

### Setting up script directory on Exascale Vm: 10.116.9.39
ownership of '/scripts' retained as root:root
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

### Copying scripts on Exascale Vm: 10.116.9.39
/scripts/logs: not a regular file

log: /scripts/logs/20260810_150959_setup_nfs_sharing.log
Mon Aug 10 15:10:01 UTC 2026

>>> Staging Customer data @GCP
Mon Aug 10 15:10:10 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: stage_cust_data
         =========================================================================
         Function fetching Peoplesoft customer data from bucket to local disk
         -------------------------------------------------------------------------

### Files on Bucket: gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/
  46980096  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
  47224320  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
  45193216  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
  50435584  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
  45519872  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
  54131200  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
  46456320  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
  40286208  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
 611988455  2026-08-10T15:07:01Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PS_CFG_HOME_TO_GCP.tar.gz
10276133741  2026-08-10T15:06:26Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PT_TO_GCP.tar.gz
7285357854  2026-08-10T15:02:39Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/RDBMS_TO_GCP.tar.gz
   1163264  2026-08-10T15:07:48Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
        75  2026-08-10T15:07:25Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/domaininfo.txt
 897261568  2026-08-10T15:08:10Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
1018445824  2026-08-10T15:08:11Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
1175093248  2026-08-10T15:08:12Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
 419250176  2026-08-10T15:07:56Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
 632872960  2026-08-10T15:08:01Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
  36503552  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
 349921280  2026-08-10T15:07:57Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
 325869568  2026-08-10T15:07:56Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
 178151424  2026-08-10T15:07:52Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
 479444992  2026-08-10T15:07:57Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
   1720320  2026-08-10T15:07:48Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
 286580736  2026-08-10T15:07:53Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
  66469888  2026-08-10T15:07:50Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
  87138304  2026-08-10T15:07:49Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
   1245184  2026-08-10T15:07:48Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
      1145  2026-08-10T15:07:32Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/psft.env
    114688  2026-08-10T15:07:48Z  gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
TOTAL: 30 objects, 24506955062 bytes (22.82GiB)

### Fetching rman files from: gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ to local disk: /u01/rman
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp

Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp to file:///u01/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp to file:///u01/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp to file:///u01/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp to file:///u01/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
...........................

Average throughput: 1.1GiB/s

### Fetching app files from: gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/ to local disk: /u01/app
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PS_CFG_HOME_TO_GCP.tar.gz to file:///u01/app/PS_CFG_HOME_TO_GCP.tar.gz
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/PT_TO_GCP.tar.gz to file:///u01/app/PT_TO_GCP.tar.gz

Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/RDBMS_TO_GCP.tar.gz to file:///u01/app/RDBMS_TO_GCP.tar.gz
....................................................................................................................................................

Average throughput: 592.9MiB/s
Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/domaininfo.txt to file:///u01/app/domaininfo.txt


Copying gs://gcp-project-peoplesoft-storage-bucket-c8d3a5b9/psft.env to file:///u01/app/psft.env



### Files on local disk: /u01
-rw-r--r--. 1 oracle oinstall   46980096 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
-rw-r--r--. 1 oracle oinstall   47224320 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
-rw-r--r--. 1 oracle oinstall   45193216 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
-rw-r--r--. 1 oracle oinstall   50435584 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
-rw-r--r--. 1 oracle oinstall   45519872 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
-rw-r--r--. 1 oracle oinstall   54131200 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
-rw-r--r--. 1 oracle oinstall   46456320 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
-rw-r--r--. 1 oracle oinstall   40286208 Aug 10 15:10 /u01/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1163264 Aug 10 15:10 /u01/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
-rw-r--r--. 1 oracle oinstall  897261568 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
-rw-r--r--. 1 oracle oinstall 1018445824 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
-rw-r--r--. 1 oracle oinstall 1175093248 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
-rw-r--r--. 1 oracle oinstall  419250176 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
-rw-r--r--. 1 oracle oinstall  632872960 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
-rw-r--r--. 1 oracle oinstall   36503552 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
-rw-r--r--. 1 oracle oinstall  349921280 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
-rw-r--r--. 1 oracle oinstall  325869568 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
-rw-r--r--. 1 oracle oinstall  178151424 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
-rw-r--r--. 1 oracle oinstall  479444992 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1720320 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
-rw-r--r--. 1 oracle oinstall  286580736 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
-rw-r--r--. 1 oracle oinstall   66469888 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
-rw-r--r--. 1 oracle oinstall   87138304 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1245184 Aug 10 15:10 /u01/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
-rw-r--r--. 1 oracle oinstall     114688 Aug 10 15:10 /u01/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
-rw-r--r--. 1 oracle oinstall          75 Aug 10 15:10 /u01/app/domaininfo.txt
-rw-r--r--. 1 oracle oinstall   611988455 Aug 10 15:10 /u01/app/PS_CFG_HOME_TO_GCP.tar.gz
-rw-r--r--. 1 oracle oinstall        1145 Aug 10 15:10 /u01/app/psft.env
-rw-r--r--. 1 oracle oinstall 10276133741 Aug 10 15:10 /u01/app/PT_TO_GCP.tar.gz
-rw-r--r--. 1 oracle oinstall  7285357854 Aug 10 15:10 /u01/app/RDBMS_TO_GCP.tar.gz

### Updating permissions of files on local disk: /u01

log: /scripts/logs/20260810_151010_stage_cust_data.log
Mon Aug 10 15:10:51 UTC 2026

>>> Setting up Peoplesoft database on Exascale@GCP
Mon Aug 10 15:10:58 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: start_db_setup
         =========================================================================
         Function to start database setup on Exascale Vm
         -------------------------------------------------------------------------

### Testing SSH connection to Exascale Server: 10.116.9.39
Warning: Permanently added '10.116.9.39' (ECDSA) to the list of known hosts.
SSH connection to Exascale Server is working

### Setting up Peoplesoft database on Exascale Vm: 10.116.9.39
/scripts/setup_db_exascale.sh: line 7: gcloud: command not found
Mon Aug 10 15:10:58 UTC 2026

         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION rdbms_setup_aux
         =========================================
         Function to startup up AUX instance on Exascale vm
         -----------------------------------------

### Dropping existing PDB PDB1:

### Running command:  dbaascli pdb delete --dbName PSFTCDB --pdbName PDB1
DBAAS CLI version 26.2.1.0.0
Executing command pdb delete --dbName PSFTCDB --pdbName PDB1
Job id: ecaa662f-1241-48eb-85f3-f504826f0efb
Session log: /var/opt/oracle/log/PSFTCDB/pdb/delete/dbaastools_2026-08-10_03-11-01-PM_118225.log
Session ID of the current execution is: 33
-----------------
Running Plugin_initialization job
Completed Plugin_initialization job
-----------------
Running Perform_dbca_prechecks job
Completed Perform_dbca_prechecks job
-----------------
Acquiring read lock: _u02_app_oracle_product_19.0.0.0_dbhome_1
Acquiring read lock: psftcdb
Acquiring write lock: pdb1
Running Delete_pdb_service job
Completed Delete_pdb_service job
-----------------
Running PDB_deletion job
Completed PDB_deletion job
-----------------
Running Delete_tnsnames_entry job
Completed Delete_tnsnames_entry job
-----------------
Running Cleanup_resource_ocid_file job
Completed Cleanup_resource_ocid_file job
Releasing lock: pdb1
Releasing lock: psftcdb
Releasing lock: _u02_app_oracle_product_19.0.0.0_dbhome_1
-----------------
Running Generate_dbsystem_details job
Acquiring native write lock: global_dbsystem_details_generation
Releasing native lock: global_dbsystem_details_generation
Completed Generate_dbsystem_details job

dbaascli execution completed

### Setting up Aux instance on Exascale vm

### Creating initaux.ora file for Aux instance

### Aux Oracle SID is set to CDBFSCM

### Startup nomount CDBFSCM

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Aug 10 15:11:25 2026
Version 19.32.0.0.0

Copyright (c) 1982, 2026, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORACLE instance started.

Total System Global Area  420584536 bytes
Fixed Size        9178200 bytes
Variable Size     335544320 bytes
Database Buffers     67108864 bytes
Redo Buffers        8753152 bytes
SQL> Disconnected from Oracle Database 19c EE Extreme Perf Release 19.0.0.0.0 - Production
Version 19.32.0.0.0

log: /scripts/logs/20260810_151058_rdbms_setup_aux.log
Mon Aug 10 15:11:31 UTC 2026
Mon Aug 10 15:11:31 UTC 2026


         =========================================================================
         Peoplesoft on EXASCALE@GCP TOOLKIT FUNCTION: aux_rman_restore
         =========================================================================
         Function to restore Aux database - time consuming step
         -------------------------------------------------------------------------

### RMAN: Restoring database from Backup location
/buckets/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
/buckets/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
/buckets/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
/buckets/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
/buckets/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp

### Oracle SID is set to CDBFSCM

### RMAN: creating rman_restore.rman file

### RMAN: Starting rman restore...may take a long time...

Recovery Manager: Release 19.0.0.0.0 - Production on Mon Aug 10 15:11:31 2026
Version 19.32.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to auxiliary database: CDBFSCM (not mounted)

RMAN>
RMAN>   run
2>  {
3>    ALLOCATE auxiliary CHANNEL c1 DEVICE TYPE DISK;
4>    ALLOCATE auxiliary CHANNEL c2 DEVICE TYPE DISK;
5>    ALLOCATE auxiliary CHANNEL c3 DEVICE TYPE DISK;
6>    ALLOCATE auxiliary CHANNEL c4 DEVICE TYPE DISK;
7>    ALLOCATE auxiliary CHANNEL c5 DEVICE TYPE DISK;
8>    ALLOCATE auxiliary CHANNEL c6 DEVICE TYPE DISK;
9>    ALLOCATE auxiliary CHANNEL c7 DEVICE TYPE DISK;
10>     ALLOCATE auxiliary CHANNEL c8 DEVICE TYPE DISK;
11>     ALLOCATE auxiliary CHANNEL c9 DEVICE TYPE DISK;
12>     ALLOCATE auxiliary CHANNEL c10 DEVICE TYPE DISK;
13>     duplicate database to CDBFSCM backup location '/buckets/rman' NOFILENAMECHECK;
14>   }
15>
16>
allocated channel: c1
channel c1: SID=25 device type=DISK

allocated channel: c2
channel c2: SID=26 device type=DISK

allocated channel: c3
channel c3: SID=27 device type=DISK

allocated channel: c4
channel c4: SID=28 device type=DISK

allocated channel: c5
channel c5: SID=267 device type=DISK

allocated channel: c6
channel c6: SID=29 device type=DISK

allocated channel: c7
channel c7: SID=30 device type=DISK

allocated channel: c8
channel c8: SID=31 device type=DISK

allocated channel: c9
channel c9: SID=32 device type=DISK

allocated channel: c10
channel c10: SID=33 device type=DISK

Starting Duplicate Db at 10-AUG-26
searching for database ID
found backup of database ID 2271167854

contents of Memory Script:
{
   sql clone "create spfile from memory";
}
executing Memory Script

sql statement: create spfile from memory

contents of Memory Script:
{
   shutdown clone immediate;
   startup clone nomount;
}
executing Memory Script

Oracle instance shut down

connected to auxiliary database (not started)
Oracle instance started

Total System Global Area     420584536 bytes

Fixed Size                     9178200 bytes
Variable Size                335544320 bytes
Database Buffers              67108864 bytes
Redo Buffers                   8753152 bytes

contents of Memory Script:
{
   sql clone "alter system set  control_files =
  ''+DATAPSFTCDB/CDBFSCM/CONTROLFILE/current.272.1240931525'' comment=
 ''Set by RMAN'' scope=spfile";
   sql clone "alter system set  db_name =
 ''CDBFSCM'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name =
 ''CDBFSCM'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   shutdown clone immediate;
   startup clone force nomount
   restore clone primary controlfile from  '/buckets/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp';
   alter clone database mount;
}
executing Memory Script

sql statement: alter system set  control_files =   ''+DATAPSFTCDB/CDBFSCM/CONTROLFILE/current.272.1240931525'' comment= ''Set by RMAN'' scope=spfile

sql statement: alter system set  db_name =  ''CDBFSCM'' comment= ''Modified by RMAN duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''CDBFSCM'' comment= ''Modified by RMAN duplicate'' scope=spfile

Oracle instance shut down

Oracle instance started

Total System Global Area     420584536 bytes

Fixed Size                     9178200 bytes
Variable Size                335544320 bytes
Database Buffers              67108864 bytes
Redo Buffers                   8753152 bytes
allocated channel: c1
channel c1: SID=25 device type=DISK
allocated channel: c2
channel c2: SID=267 device type=DISK
allocated channel: c3
channel c3: SID=26 device type=DISK
allocated channel: c4
channel c4: SID=27 device type=DISK
allocated channel: c5
channel c5: SID=28 device type=DISK
allocated channel: c6
channel c6: SID=29 device type=DISK
allocated channel: c7
channel c7: SID=270 device type=DISK
allocated channel: c8
channel c8: SID=30 device type=DISK
allocated channel: c9
channel c9: SID=271 device type=DISK
allocated channel: c10
channel c10: SID=272 device type=DISK

Starting restore at 10-AUG-26

channel c9: skipped, AUTOBACKUP already found
channel c10: skipped, AUTOBACKUP already found
channel c1: skipped, AUTOBACKUP already found
channel c2: skipped, AUTOBACKUP already found
channel c3: skipped, AUTOBACKUP already found
channel c4: skipped, AUTOBACKUP already found
channel c5: skipped, AUTOBACKUP already found
channel c6: skipped, AUTOBACKUP already found
channel c7: skipped, AUTOBACKUP already found
channel c8: restoring control file
channel c8: restore complete, elapsed time: 00:00:09
output file name=+DATAPSFTCDB/CDBFSCM/CONTROLFILE/current.272.1240931525
Finished restore at 10-AUG-26

database mounted
checkpoint of the data file is more recent than the last archived log
duplicating Online logs to Oracle Managed File (OMF) location
duplicating Datafiles to Oracle Managed File (OMF) location

contents of Memory Script:
{
   set until scn  39362645914649;
   set newname for clone datafile  1 to new;
   set newname for clone datafile  2 to new;
.....
   set newname for clone datafile  199 to new;
   set newname for clone datafile  200 to new;
   restore
   clone database
   ;
}
executing Memory Script

executing command: SET until clause

executing command: SET NEWNAME
.....
executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

Starting restore at 10-AUG-26

channel c1: starting datafile backup set restore
channel c1: specifying datafile(s) to restore from backup set
channel c1: restoring datafile 00001 to +DATAPSFTCDB
channel c1: reading from backup piece /buckets/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
.....
channel c6: restore complete, elapsed time: 00:02:42
channel c8: piece handle=/buckets/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp tag=FULL_COLD_BACKUP
channel c8: restored backup piece 1
channel c8: restore complete, elapsed time: 00:02:38
Finished restore at 10-AUG-26

contents of Memory Script:
{
   switch clone datafile all;
}
executing Memory Script

datafile 1 switched to datafile copy
input datafile copy RECID=201 STAMP=1240931753 file name=+DATAPSFTCDB/CDBFSCM/DATAFILE/system.267.1240931573
datafile 2 switched to datafile copy
input datafile copy RECID=202 STAMP=1240931753 file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/undo_1.271.1240931573
.....
input datafile copy RECID=399 STAMP=1240931756 file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmapp.460.1240931603
datafile 200 switched to datafile copy
input datafile copy RECID=400 STAMP=1240931756 file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmlarge.432.1240931597

contents of Memory Script:
{
   set until scn  39362645914649;
   recover
   clone database
    delete archivelog
   ;
}
executing Memory Script

executing command: SET until clause

Starting recover at 10-AUG-26

starting media recovery
media recovery complete, elapsed time: 00:00:01

Finished recover at 10-AUG-26
released channel: c1
released channel: c2
released channel: c3
released channel: c4
released channel: c5
released channel: c6
released channel: c7
released channel: c8
released channel: c9
released channel: c10
Oracle instance started

Total System Global Area     420584536 bytes

Fixed Size                     9178200 bytes
Variable Size                335544320 bytes
Database Buffers              67108864 bytes
Redo Buffers                   8753152 bytes

contents of Memory Script:
{
   sql clone "alter system set  db_name =
 ''CDBFSCM'' comment=
 ''Reset to original value by RMAN'' scope=spfile";
   sql clone "alter system reset  db_unique_name scope=spfile";
}
executing Memory Script

sql statement: alter system set  db_name =  ''CDBFSCM'' comment= ''Reset to original value by RMAN'' scope=spfile

sql statement: alter system reset  db_unique_name scope=spfile
Oracle instance started

Total System Global Area     420584536 bytes

Fixed Size                     9178200 bytes
Variable Size                335544320 bytes
Database Buffers              67108864 bytes
Redo Buffers                   8753152 bytes
sql statement: CREATE CONTROLFILE REUSE SET DATABASE "CDBFSCM" RESETLOGS ARCHIVELOG
  MAXLOGFILES     16
  MAXLOGMEMBERS      3
  MAXDATAFILES     1024
  MAXINSTANCES     8
  MAXLOGHISTORY      292
 LOGFILE
  GROUP     1  SIZE 200 M ,
  GROUP     2  SIZE 200 M ,
  GROUP     3  SIZE 200 M
 DATAFILE
  '+DATAPSFTCDB/CDBFSCM/DATAFILE/system.267.1240931573',
  '+DATAPSFTCDB/CDBFSCM/546B3A2658E15A97E0630602320AD44D/DATAFILE/system.269.1240931573',
  '+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/system.276.1240931573'
 CHARACTER SET AL32UTF8


contents of Memory Script:
{
   set newname for clone tempfile  1 to new;
   set newname for clone tempfile  2 to new;
   set newname for clone tempfile  3 to new;
   set newname for clone tempfile  4 to new;
   set newname for clone tempfile  5 to new;
   switch clone tempfile all;
   catalog clone datafilecopy  "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/undo_1.271.1240931573",
 "+DATAPSFTCDB/CDBFSCM/DATAFILE/sysaux.268.1240931573",
 "+DATAPSFTCDB/CDBFSCM/DATAFILE/undotbs1.270.1240931573",
 "+DATAPSFTCDB/CDBFSCM/546B3A2658E15A97E0630602320AD44D/DATAFILE/sysaux.273.1240931573",
 "+DATAPSFTCDB/CDBFSCM/DATAFILE/users.274.1240931573",
 "+DATAPSFTCDB/CDBFSCM/546B3A2658E15A97E0630602320AD44D/DATAFILE/undotbs1.275.1240931573",
 "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/sysaux.278.1240931573",
 "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/psdefault.309.1240931575",
 .....
 "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/wslarge.450.1240931599",
 "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmapp.460.1240931603",
 "+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmlarge.432.1240931597";
   switch clone datafile all;
}
executing Memory Script

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

renamed tempfile 1 to +DATAPSFTCDB in control file
renamed tempfile 2 to +DATAPSFTCDB in control file
renamed tempfile 3 to +DATAPSFTCDB in control file
renamed tempfile 4 to +DATAPSFTCDB in control file
renamed tempfile 5 to +DATAPSFTCDB in control file

cataloged datafile copy
datafile copy file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/undo_1.271.1240931573 RECID=1 STAMP=1240931794
cataloged datafile copy
datafile copy file name=+DATAPSFTCDB/CDBFSCM/DATAFILE/sysaux.268.1240931573 RECID=2 STAMP=1240931794
cataloged datafile copy
.....
datafile 199 switched to datafile copy
input datafile copy RECID=196 STAMP=1240931796 file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmapp.460.1240931603
datafile 200 switched to datafile copy
input datafile copy RECID=197 STAMP=1240931796 file name=+DATAPSFTCDB/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/DATAFILE/slmlarge.432.1240931597

contents of Memory Script:
{
   Alter clone database open resetlogs;
}
executing Memory Script

database opened

contents of Memory Script:
{
   sql clone "alter pluggable database all open";
}
executing Memory Script

PL/SQL package SYS.DBMS_BACKUP_RESTORE version 19.29.00.00 in AUXILIARY database is not current
PL/SQL package SYS.DBMS_RCVMAN version 19.29.00.00 in AUXILIARY database is not current
sql statement: alter pluggable database all open
Cannot remove created server parameter file
Finished Duplicate Db at 10-AUG-26

Recovery Manager complete.

real  5m27.768s
user  0m6.459s
sys 0m0.375s

### PDB Name is : FSCM0V

### Unplugging PDB FSCM0V from CDBFSCM

Pluggable database altered.


Pluggable database altered.


Pluggable database dropped.


### Plugging PDB FSCM0V into PSFTCDB1

Pluggable database created.


Warning: PDB altered with errors.


### Running datapatch on FSCM0V
SQL Patching tool version 19.32.0.0.0 Production on Mon Aug 10 15:17:39 2026
Copyright (c) 2012, 2026, Oracle.  All rights reserved.

Log file for this invocation: /u02/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_148268_2026_08_10_15_17_39/sqlpatch_invocation.log

Connecting to database...OK
Gathering database info...done

Note:  Datapatch will only apply or rollback SQL fixes for PDBs
       that are in an open state, no patches will be applied to closed PDBs.
       Please refer to Note: Datapatch: Database 12c Post Patch SQL Automation
       (Doc ID 1585822.1)

Bootstrapping registry and package to current versions...done
Determining current state...done

Current state of interim SQL patches:
Interim patch 39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882)):
  Binary registry: Installed
  PDB CDB$ROOT: Applied successfully on 14-JUL-26 10.22.55.809829 AM
  PDB FSCM0V: Not installed
  PDB PDB$SEED: Applied successfully on 14-JUL-26 10.37.32.870350 AM

Current state of release update SQL patches:
  Binary registry:
    19.32.0.0.0 Release_Update 260705220710: Installed
  PDB CDB$ROOT:
    Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 14-JUL-26 10.36.41.003015 AM
  PDB FSCM0V:
    Applied 19.29.0.0.0 Release_Update 251002005342 successfully on 17-JUN-26 03.11.41.723214 AM
  PDB PDB$SEED:
    Applied 19.32.0.0.0 Release_Update 260705220710 successfully on 14-JUL-26 10.49.11.164986 AM

Adding patches to installation queue and performing prereq checks...done
Installation queue:
  For the following PDBs: CDB$ROOT PDB$SEED
    No interim patches need to be rolled back
    No release update patches need to be installed
    No interim patches need to be applied
  For the following PDBs: FSCM0V
    No interim patches need to be rolled back
    Patch 39472050 (Database Release Update : 19.32.0.0.260721 (39472050)):
      Apply from 19.29.0.0.0 Release_Update 251002005342 to 19.32.0.0.0 Release_Update 260705220710
    The following interim patches will be applied:
      39222882 (OJVM RELEASE UPDATE: 19.32.0.0.260721 (39222882))

Installing patches...
Patch installation complete.  Total patches installed: 2

Validating logfiles...done
Patch 39472050 apply (pdb FSCM0V): SUCCESS
  logfile: /u02/app/oracle/cfgtoollogs/sqlpatch/39472050/28919163/39472050_apply_PSFTCDB_FSCM0V_2026Aug10_15_18_27.log (no errors)
Patch 39222882 apply (pdb FSCM0V): SUCCESS
  logfile: /u02/app/oracle/cfgtoollogs/sqlpatch/39222882/28830205/39222882_apply_PSFTCDB_FSCM0V_2026Aug10_15_18_26.log (no errors)
SQL Patching tool complete on Mon Aug 10 15:19:26 2026

### Recompile Invalids on FSCM0V

Session altered.


TIMESTAMP
--------------------------------------------------------------------------------
COMP_TIMESTAMP UTLRP_BGN        2026-08-10 15:19:26


PL/SQL procedure successfully completed.


TIMESTAMP
--------------------------------------------------------------------------------
COMP_TIMESTAMP UTLRP_END        2026-08-10 15:19:27


OBJECTS WITH ERRORS
-------------------
      0


ERRORS DURING RECOMPILATION
---------------------------
        0


Function created.


PL/SQL procedure successfully completed.


Function dropped.


PL/SQL procedure successfully completed.


Session altered.


Session altered.


TIMESTAMP
--------------------------------------------------------------------------------
COMP_TIMESTAMP UTLRP_BGN        2026-08-10 15:19:31


PL/SQL procedure successfully completed.


TIMESTAMP
--------------------------------------------------------------------------------
COMP_TIMESTAMP UTLRP_END        2026-08-10 15:19:32


OBJECTS WITH ERRORS
-------------------
      0


ERRORS DURING RECOMPILATION
---------------------------
        0


Function created.


PL/SQL procedure successfully completed.


Function dropped.


PL/SQL procedure successfully completed.


### Generate sql for encrypting tablespaces in FSCM0V

Session altered.

ALTER TABLESPACE AMAPP ENCRYPTION ONLINE USING 'AES128' ENCRYPT;
ALTER TABLESPACE AMARCH ENCRYPTION ONLINE USING 'AES128' ENCRYPT;
ALTER TABLESPACE AMLARGE ENCRYPTION ONLINE USING 'AES128' ENCRYPT;
.....
ALTER TABLESPACE WMWORK ENCRYPTION ONLINE USING 'AES128' ENCRYPT;
ALTER TABLESPACE WSAPP ENCRYPTION ONLINE USING 'AES128' ENCRYPT;
ALTER TABLESPACE WSLARGE ENCRYPTION ONLINE USING 'AES128' ENCRYPT;

### Setup encryption keys in FSCM0V

Session altered.


keystore altered.


### Encrypt tablespaces in FSCM0V using AQXnBMdOzk/6v7QbQVZtak8AAAAAAAAAAAAAAAAAAAAAAAAAAAAA

Session altered.


keystore altered.


Tablespace altered.


Tablespace altered.


.....

Tablespace altered.


Tablespace altered.

Default temp tablespace: TEMP
Created replacement: TEMP_REPLACE_153037
Default switched to TEMP_REPLACE_153037
Dropping PSGTT01
Recreating PSGTT01
Dropping PSTEMP
Recreating PSTEMP
Dropping TEMP
Recreating TEMP
Default restored to TEMP
Replacement removed.

PL/SQL procedure successfully completed.


### Restart pdb FSCM0V

Pluggable database altered.


Pluggable database altered.


    CON_ID CON_NAME       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
   2 PDB$SEED       READ ONLY  NO
   3 FSCM0V       READ WRITE NO

log: /scripts/logs/20260810_151131_aux_rman_restore.log
Mon Aug 10 15:30:43 UTC 2026
Mon Aug 10 15:30:43 UTC 2026

         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION drop_aux
         =========================================
         Function to drop AUX instance on Exadata
         -----------------------------------------

### Aux Oracle SID is set to CDBFSCM

### Shutting down and dropping CDBFSCM
Database closed.
Database dismounted.
ORACLE instance shut down.
ORACLE instance started.

Total System Global Area  420584536 bytes
Fixed Size        9178200 bytes
Variable Size     335544320 bytes
Database Buffers     67108864 bytes
Redo Buffers        8753152 bytes
Database mounted.

Database dropped.


log: /scripts/logs/20260810_153043_drop_aux.log
Mon Aug 10 15:31:35 UTC 2026

log: /scripts/logs/20260810_151058_start_db_setup.log
Mon Aug 10 15:31:35 UTC 2026

>>> Setting up Peoplesoft applications @GCP
Mon Aug 10 11:37:09 UTC 2026

         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION rdbms_stage_oh
         =========================================
         Function restores RDBMS HOME from backup
         -----------------------------------------

### Extract RDBMS Software from /u01/app
RDBMS backup   : /u01/app/RDBMS_TO_GCP.tar.gz
Extracting non-verbose: (few mins)

real    1m52.718s
user    1m35.201s
sys 1m13.664s
mv: '/u02/db/oracle-server/19.3.0.0/.' and '/u02/db/oracle-server/19.3.0.0/.' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/..' and '/u02/db/oracle-server/19.3.0.0/..' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/.opatchauto_storage' and '/u02/db/oracle-server/19.3.0.0/.opatchauto_storage' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/.patch_storage' and '/u02/db/oracle-server/19.3.0.0/.patch_storage' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/addnode' and '/u02/db/oracle-server/19.3.0.0/addnode' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/admin' and '/u02/db/oracle-server/19.3.0.0/admin' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/apex' and '/u02/db/oracle-server/19.3.0.0/apex' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/assistants' and '/u02/db/oracle-server/19.3.0.0/assistants' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/bin' and '/u02/db/oracle-server/19.3.0.0/bin' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/cfgtoollogs' and '/u02/db/oracle-server/19.3.0.0/cfgtoollogs' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/client' and '/u02/db/oracle-server/19.3.0.0/client' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/clone' and '/u02/db/oracle-server/19.3.0.0/clone' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/crs' and '/u02/db/oracle-server/19.3.0.0/crs' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/css' and '/u02/db/oracle-server/19.3.0.0/css' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ctx' and '/u02/db/oracle-server/19.3.0.0/ctx' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/cv' and '/u02/db/oracle-server/19.3.0.0/cv' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/data' and '/u02/db/oracle-server/19.3.0.0/data' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dbjava' and '/u02/db/oracle-server/19.3.0.0/dbjava' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dbs' and '/u02/db/oracle-server/19.3.0.0/dbs' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dbs.20260810_102347' and '/u02/db/oracle-server/19.3.0.0/dbs.20260810_102347' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dbs.20260810_103326' and '/u02/db/oracle-server/19.3.0.0/dbs.20260810_103326' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dbs.20260810_104006' and '/u02/db/oracle-server/19.3.0.0/dbs.20260810_104006' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/deinstall' and '/u02/db/oracle-server/19.3.0.0/deinstall' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/demo' and '/u02/db/oracle-server/19.3.0.0/demo' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/diagnostics' and '/u02/db/oracle-server/19.3.0.0/diagnostics' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/drdaas' and '/u02/db/oracle-server/19.3.0.0/drdaas' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/dv' and '/u02/db/oracle-server/19.3.0.0/dv' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/env.ora' and '/u02/db/oracle-server/19.3.0.0/env.ora' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/has' and '/u02/db/oracle-server/19.3.0.0/has' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/hs' and '/u02/db/oracle-server/19.3.0.0/hs' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/install' and '/u02/db/oracle-server/19.3.0.0/install' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/instantclient' and '/u02/db/oracle-server/19.3.0.0/instantclient' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/inventory' and '/u02/db/oracle-server/19.3.0.0/inventory' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/javavm' and '/u02/db/oracle-server/19.3.0.0/javavm' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/jdbc' and '/u02/db/oracle-server/19.3.0.0/jdbc' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/jdk' and '/u02/db/oracle-server/19.3.0.0/jdk' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/jlib' and '/u02/db/oracle-server/19.3.0.0/jlib' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ldap' and '/u02/db/oracle-server/19.3.0.0/ldap' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/lib' and '/u02/db/oracle-server/19.3.0.0/lib' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/log' and '/u02/db/oracle-server/19.3.0.0/log' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/md' and '/u02/db/oracle-server/19.3.0.0/md' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/mgw' and '/u02/db/oracle-server/19.3.0.0/mgw' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/network' and '/u02/db/oracle-server/19.3.0.0/network' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/nls' and '/u02/db/oracle-server/19.3.0.0/nls' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/odbc' and '/u02/db/oracle-server/19.3.0.0/odbc' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/olap' and '/u02/db/oracle-server/19.3.0.0/olap' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/OPatch' and '/u02/db/oracle-server/19.3.0.0/OPatch' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/opmn' and '/u02/db/oracle-server/19.3.0.0/opmn' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/oracore' and '/u02/db/oracle-server/19.3.0.0/oracore' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/oraInst.loc' and '/u02/db/oracle-server/19.3.0.0/oraInst.loc' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ord' and '/u02/db/oracle-server/19.3.0.0/ord' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ords' and '/u02/db/oracle-server/19.3.0.0/ords' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/oss' and '/u02/db/oracle-server/19.3.0.0/oss' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/oui' and '/u02/db/oracle-server/19.3.0.0/oui' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ovm' and '/u02/db/oracle-server/19.3.0.0/ovm' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/owm' and '/u02/db/oracle-server/19.3.0.0/owm' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/patch' and '/u02/db/oracle-server/19.3.0.0/patch' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/perl' and '/u02/db/oracle-server/19.3.0.0/perl' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/plsql' and '/u02/db/oracle-server/19.3.0.0/plsql' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/precomp' and '/u02/db/oracle-server/19.3.0.0/precomp' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/QOpatch' and '/u02/db/oracle-server/19.3.0.0/QOpatch' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/R' and '/u02/db/oracle-server/19.3.0.0/R' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/racg' and '/u02/db/oracle-server/19.3.0.0/racg' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/rdbms' and '/u02/db/oracle-server/19.3.0.0/rdbms' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/relnotes' and '/u02/db/oracle-server/19.3.0.0/relnotes' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/root.sh' and '/u02/db/oracle-server/19.3.0.0/root.sh' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/root.sh.old' and '/u02/db/oracle-server/19.3.0.0/root.sh.old' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/root.sh.old.1' and '/u02/db/oracle-server/19.3.0.0/root.sh.old.1' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/runInstaller' and '/u02/db/oracle-server/19.3.0.0/runInstaller' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/schagent.conf' and '/u02/db/oracle-server/19.3.0.0/schagent.conf' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sdk' and '/u02/db/oracle-server/19.3.0.0/sdk' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sdo' and '/u02/db/oracle-server/19.3.0.0/sdo' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/server_install.rsp' and '/u02/db/oracle-server/19.3.0.0/server_install.rsp' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/slax' and '/u02/db/oracle-server/19.3.0.0/slax' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sqlcl' and '/u02/db/oracle-server/19.3.0.0/sqlcl' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sqlj' and '/u02/db/oracle-server/19.3.0.0/sqlj' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sqlpatch' and '/u02/db/oracle-server/19.3.0.0/sqlpatch' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/sqlplus' and '/u02/db/oracle-server/19.3.0.0/sqlplus' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/srvm' and '/u02/db/oracle-server/19.3.0.0/srvm' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/suptools' and '/u02/db/oracle-server/19.3.0.0/suptools' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/ucp' and '/u02/db/oracle-server/19.3.0.0/ucp' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/usm' and '/u02/db/oracle-server/19.3.0.0/usm' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/utl' and '/u02/db/oracle-server/19.3.0.0/utl' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/wwg' and '/u02/db/oracle-server/19.3.0.0/wwg' are the same file
mv: '/u02/db/oracle-server/19.3.0.0/xdk' and '/u02/db/oracle-server/19.3.0.0/xdk' are the same file
rmdir: removing directory, '/u02/db/oracle-server/19.3.0.0'
rmdir: failed to remove '/u02/db/oracle-server/19.3.0.0': Directory not empty
drwxr-xr-x. 77 oracle oinstall 4096 Jun  8 01:39 /u02/db/oracle-server/19.3.0.0
total 112
drwxr-xr-x. 77 oracle oinstall  4096 Jun  8 01:39 .
drwxr-xr-x.  3 oracle oinstall    22 Aug 10 10:15 ..
drwxr-xr-x.  2 oracle oinstall   102 Jun  8 01:00 addnode
drwxr-x---.  4 oracle oinstall    34 Jun  8 01:39 admin
drwxr-xr-x.  5 oracle oinstall  4096 Nov 19  2025 apex
drwxr-xr-x.  9 oracle oinstall    93 Apr 17  2019 assistants
drwxr-xr-x.  2 oracle oinstall  8192 Jun  8 01:00 bin
drwxr-xr-x.  5 oracle oinstall    44 Jun 15 07:13 cfgtoollogs
drwxr-xr-x.  3 oracle oinstall    19 Nov 19  2025 client
..

### Configurting RDBMS HOME - relink
writing relink log to: /u02/db/oracle-server/19.3.0.0/install/relinkActions2026-08-10_11-39-02AM.log

### Backing up existing TNS and dbs

log: /scripts/logs/20260810_113709_rdbms_stage_oh.log
Mon Aug 10 11:39:37 UTC 2026
Mon Aug 10 11:39:37 UTC 2026

         ====================================================================
         Peoplesoft on EXASCALE@GCP TOOLKIT FUNCTION: setup_tnsnames
         ====================================================================
         Function to setup tnsnames.ora for Peoplesoft on Exascale vm
         --------------------------------------------------------------------

### Setting up tnsnames.ora...
File /tmp/exascale_outputs.yaml exists. Creating EXAINFO file.
chmod: changing permissions of '/scripts/EXAINFO': Operation not permitted

### Testing Oracle Exascale @GCP connection
Exadata connection as sys user validated successfully.
Exadata tns connection string is : (DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.8.147)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.13.175)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.9.98)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=PSFTCDB_6t7_yyz.cynsxusnxs.v6c82d2db.oraclevcn.com)))

### Finding Pdb name in Exasxcale database...

### Pdb name in Exasxcale database is: FSCM0V

### Finding service name in Exasxcale database for FSCM0V

### Service name in Exasxcale database for FSCM0V is: fscm0v.cynsxusnxs.v6c82d2db.oraclevcn.com

### Setting up tnsnames.ora for Peoplesoft apps tier...
tnsnames.ora for Peoplesoft apps tier is:
FSCM0V="(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.8.147)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.13.175)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.116.9.98)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=fscm0v.cynsxusnxs.v6c82d2db.oraclevcn.com)))"

log: /scripts/logs/20260810_113937_setup_tnsnames.log
Mon Aug 10 11:39:38 UTC 2026
Mon Aug 10 11:39:38 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: setup_cust_app
         =========================================================================
         Function to setup up Peoplesoft customer applications on GCP
         -------------------------------------------------------------------------

### Setting up Peoplesoft applications...

### Setting up Environment file..
'/u01/app/psft.env' -> '/u02/app/psft.env'

### Unarchiving PT directory...in /opt/oracle/psft/pt

### Unarchiving CFG directory...

### Replicating configuration home...
/opt/oracle/psft/pt/ps_home8.62.07/appserv/psadmin
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom

Stopping the domain [peoplesoft]..
Verifying domain status....................
The domain has stopped.
Dynamic Process Spawning is enabled for this domain.
Additional processes will be started when the domain experiences increased queuing.
Loading validation table...
WARNING: PSSAMSRV and PSPPMSRV are configured with Min instance set to 1. To avoid loss of service, configure Min instance to at least 2.
Dynamic Process Spawning is enabled for this domain.
Additional processes will be started when the domain experiences increased queuing.
Loading validation table...
WARNING: PSDSTSRV and PSRTISRV are configured with Min instance set to 1. To avoid loss of service, configure Min instance to at least 2.
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom

Creating the domain. This may take several minutes, please be patient.
...................................................
The target domain peoplesoft has been created



Application Server domain APPDOM is already shutdown.



Process Scheduler domain PRCSDOM is already shutdown.


Replicate Application/Batch Cfg Home. Please wait.


Regenerating configuration for Application Server domain: APPDOM
Loading new configuration...
Domain configuration complete.


Regenerating configuration for Process Scheduler domain: PRCSDOM
Loading new configuration...
Domain configuration complete.
Generating new Domains Gateway  configuration...

Replicate PIA Cfg Home. Please wait.

### Updating env file with new configuration home...

### Updating configuration.properties file with new values...
/u02/app/newcfg/webserv/peoplesoft/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/ps
'configuration.properties' -> 'configuration.properties.2026-08-10-11:43:10'

### New psserver value in configuration.properties is ...
psserver=apps.example.com:9033

### Updating setEnv.sh with new values...
/u02/app/newcfg/webserv/peoplesoft/bin
'setEnv.sh' -> 'setEnv.sh.2026-08-10-11:43:10'

### New ADMINSERVER_HOSTNAME value in setEnv.sh is ...
ADMINSERVER_HOSTNAME=apps
PIA_HOME=/u02/app/newcfg
Error: A psconfig.sh script has already been invoked.  Your environment will not be changed

### Configuring domain name for peoplesoft to example.com
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
The configuration has been updated.

### Configuring http port for peoplesoft to 8001
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
The configuration has been updated.

### Starting up weblogic server domain peoplesoft....
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom

Starting the domain [peoplesoft].....
Server state changed to STARTING......
Server state changed to STANDBY..
Server state changed to STARTING.........
Server state changed to ADMIN..
Server state changed to RESUMING..
Server state changed to RUNNING..
Verifying domain status.
The domain has started.


### Starting up appserv server domain APPDOM....
tmadmin - Copyright (c) 1996-2025 Oracle.
All Rights Reserved.
Distributed under license by Oracle.
Tuxedo is a registered trademark.
No bulletin board exists. Entering boot mode.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting admin processes ...


tmboot: WARN: CMDTUX_CAT:8423: WARN: Insecure option NONE is set for SECURITY keyword.


exec BBL -A :
    process id=93539 ... Started.
1 process started.

Attaching to active bulletin board.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting server processes ...

exec TMUSREVT -A :
    process id=93545 ... Started.
exec PSWATCHSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 111709 -D APPDOM -S PSWATCHSRV :
    process id=93547 ... Started.
exec PSPPMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -D APPDOM -S PSPPMSRV :
    process id=93548 ... Started.
exec PSAPPSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s@psappsrv.lst -- -D APPDOM -S PSAPPSRV :
    process id=93553 ... Started.
exec PSAPPSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s@psappsrv.lst -- -D APPDOM -S PSAPPSRV :
    process id=93624 ... Started.
exec PSSAMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -D APPDOM -S PSSAMSRV :
    process id=93691 ... Started.
exec PSBRKHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSBRKHND_dflt:BrkProcess -- -D APPDOM -S PSBRKHND_dflt :
    process id=93697 ... Started.
exec PSBRKDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSBRKDSP_dflt:Dispatch -- -D APPDOM -S PSBRKDSP_dflt :
    process id=93702 ... Started.
exec PSPUBHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSPUBHND_dflt:PubConProcess -- -D APPDOM -S PSPUBHND_dflt :
    process id=93707 ... Started.
exec PSPUBDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSPUBDSP_dflt:Dispatch -- -D APPDOM -S PSPUBDSP_dflt :
    process id=93713 ... Started.
exec PSSUBHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSSUBHND_dflt:SubConProcess -- -D APPDOM -S PSSUBHND_dflt :
    process id=93739 ... Started.
exec PSSUBDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSSUBDSP_dflt:Dispatch -- -D APPDOM -S PSSUBDSP_dflt :
    process id=93744 ... Started.
exec PSMONITORSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 111709 -D APPDOM -S PSMONITORSRV :
    process id=93749 ... Started.
exec WSL -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -n //apps.example.com:7000 -z 0 -Z 256 -I 5 -T 60 -m 1 -M 3 -x 40 -c 5000 -p 7001 -P 7003 :
    process id=93836 ... Started.
exec JSL -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -n //0.0.0.0:9033 -m 5 -M 7 -I 5 -j ANY -x 40 -z 0 -Z 256 -S 10 -c 1000000 -w JSH :
    process id=93838 ... Started.
exec TMMETADATA -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -f /u02/app/newcfg/appserv/APPDOM/metadata.rep :
    process id=93844 ... Started.
16 processes started.

Archived a copy of the domain configuration to /u02/app/newcfg/appserv/APPDOM/Archive/psappsrv.cfg



Attempting to start Application Server domain bulletin board APPDOM...




Attempting to start Application Server domain APPDOM...


### Starting up process server domain PRCSDOM....
tmadmin - Copyright (c) 1996-2025 Oracle.
All Rights Reserved.
Distributed under license by Oracle.
Tuxedo is a registered trademark.
No bulletin board exists. Entering boot mode.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting admin processes ...


tmboot: WARN: CMDTUX_CAT:8423: WARN: Insecure option NONE is set for SECURITY keyword.


exec BBL -A :
    process id=93888 ... Started.
1 process started.

Attaching to active bulletin board.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting server processes ...

exec PSRTISRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -S PSRTISRV :
    process id=93894 ... Started.
exec PSPPMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -S PSPPMSRV :
    process id=93899 ... Started.
exec PSMSTPRC -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -CD FSCM0V -PS PRCS5240 -A start -S PSMSTPRC :
    process id=93904 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
    process id=93924 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
    process id=93990 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
    process id=94054 ... Started.
exec PSDSTSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -p 1,600:1,1 -sPostReport -- -CD FSCM0V -PS PRCS5240 -A start -S PSDSTSRV :
    process id=94119 ... Started.
exec PSPRCSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -sInitiateRequest -- -CD FSCM0V -PS PRCS5240 -A start -S PSPRCSRV :
    process id=94124 ... Started.
exec PSMONITORSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 165803 -PS PRCS5240 -S PSMONITORSRV :
    process id=94132 ... Started.
9 processes started.

Archived a copy of the domain configuration to /u02/app/newcfg/appserv/prcs/PRCSDOM/Archive/psprcs.cfg



Attempting to start Process Scheduler domain bulletin board PRCSDOM...




Attempting to start Process Scheduler domain PRCSDOM...


### Status of weblogic server domain peoplesoft....
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
started

### Status of appserv server domain APPDOM....
Started

### Status of process server domain PRCSDOM....
Started

### Creating Peoplesoft auto start script

### Creating cron autostart


         =================================================
                 Oracle Peoplsoft Deployment: Customer Data: CDBFSCM
         =================================================
          URL                : http://apps.example.com:8001/ps/signon.html
          User               : VP1
          Password           : ** None of the passwords was changed through the process **

          hosts file entry   : 127.0.0.1 apps.example.com apps.example.com
          IAP tunneling      :
            gcloud compute ssh apps.example.com --tunnel-through-iap --project gcp-project-peoplesoft -- -L 8001:localhost:8001
         -----------------------------------------


log: /scripts/logs/20260810_113938_setup_cust_app.log
Mon Aug 10 11:44:42 UTC 2026

         -----------------------------------------

[user@machine] oracle-peoplesoft-framework % cat /etc/hosts| grep apps
127.0.0.1 apps.example.com apps
127.0.0.1 apps.us-central1-a.c.oracle-ebs-toolkit.internal apps
127.0.0.1 oracle-ebs-apps.c.gcp-project-peoplesoft.internal
127.0.0.1 oracle-peoplesoft-apps.c.gcp-project-peoplesoft.internal oracle-peoplesoft-apps
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework %
[user@machine] oracle-peoplesoft-framework %    gcloud compute ssh oracle-exascale-peoplesoft-app --tunnel-through-iap --project gcp-project-peoplesoft -- -L 8001:localhost:8001

[user@machine] ~ % curl http://apps.example.com:8001/ps/signon.html
<HTML>
<HEAD>
<!--
* ***************************************************************
*  This software and related documentation are provided under a
*  license agreement containing restrictions on use and
*  disclosure and are protected by intellectual property
*  laws. Except as expressly permitted in your license agreement
*  or allowed by law, you may not use, copy, reproduce,
*  translate, broadcast, modify, license, transmit, distribute,
*  exhibit, perform, publish or display any part, in any form or
*  by any means. Reverse engineering, disassembly, or
*  decompilation of this software, unless required by law for
*  interoperability, is prohibited.
*  The information contained herein is subject to change without
*  notice and is not warranted to be error-free. If you find any
*  errors, please report them to us in writing.
*
*  Copyright (C) 1988, 2025, Oracle and/or its affiliates.
*  All Rights Reserved.
* ***************************************************************
-->
<!--
-->
<!--
*
-->
<!--* ******************************************************************
* ******************************************************************
*
*
*
*
* ******************************************************************
*
********************************************************************-->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta HTTP-EQUIV='Refresh' CONTENT='1; URL=../psp/ps/?cmd=login'>
</HEAD>
</HTML>
[user@machine] ~ %



```

### 5. Destroy Oracle PeopleSoft infrastructure

```bash

[user@machine] oracle-peoplesoft-framework % make exascale_destroy
terraform -chdir=. destroy \
    -var="project_id=gcp-project-peoplesoft" \
    -var="project_service_account_email=ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" \
    -var="oracle_peoplesoft_exascale=true" \
    -var="exascale_grid_image_id=$(cat .grid_image_id)" \
    -var="exascale_grid_version=$(cat .grid_version)" \
    -var="exascale_deletion_protection=false"
random_id.bucket_suffix: Refreshing state... [id=qfuQhw]
random_id.secret_suffix[0]: Refreshing state... [id=AWLUyw]
random_password.admin_password[0]: Refreshing state... [id=none]
tls_private_key.exadb_ssh_key[0]: Refreshing state... [id=b8e3e4877d593f2ca716c101b13782ff0c4bdb89]
local_file.exadb_public_key[0]: Refreshing state... [id=bc82372e4622ecda67e057c3b11f712c2cc178d0]
local_file.exadb_private_key[0]: Refreshing state... [id=4c5656b68d99192b3fb082e7f695f1250ff1c758]
module.network.module.vpc.google_compute_network.network: Refreshing state... [id=projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.apps_image: Reading...
google_service_account.project_sa: Refreshing state... [id=projects/gcp-project-peoplesoft/serviceAccounts/ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Refreshing state... [id=gcp-project-peoplesoft/compute.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Refreshing state... [id=gcp-project-peoplesoft/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Refreshing state... [id=gcp-project-peoplesoft/secretmanager.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Refreshing state... [id=gcp-project-peoplesoft/iam.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Refreshing state... [id=gcp-project-peoplesoft/storage.googleapis.com]
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730]
google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"]: Refreshing state... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01]
google_secret_manager_secret.exadb_private_key_secret[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-0162d4cb]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Refreshing state... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01]
google_oracle_database_odb_network.odb_network[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network]
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Refreshing state... [id=gcp-project-peoplesoft-storage-bucket-a9fb9087]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Refreshing state... [id=gcp-project-peoplesoft/roles/logging.logWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Refreshing state... [id=gcp-project-peoplesoft/roles/iap.tunnelResourceAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Refreshing state... [id=gcp-project-peoplesoft/roles/monitoring.metricWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Refreshing state... [id=gcp-project-peoplesoft/roles/iam.serviceAccountUser/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Refreshing state... [id=gcp-project-peoplesoft/roles/compute.instanceAdmin.v1/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Refreshing state... [id=gcp-project-peoplesoft/roles/secretmanager.secretAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Refreshing state... [id=gcp-project-peoplesoft/roles/storage.admin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Refreshing state... [id=projects/119724395047/secrets/exadb-ssh-private-key-0162d4cb/versions/1]
google_oracle_database_odb_subnet.client_subnet[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet]
google_oracle_database_odb_subnet.backup_subnet[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet]
google_storage_bucket_iam_member.bucket_object_admin: Refreshing state... [id=b/gcp-project-peoplesoft-storage-bucket-a9fb9087/roles/storage.objectAdmin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_compute_address.peoplesoft_apps_server_internal_ip: Refreshing state... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/peoplesoft-apps-server-internal-ip]
google_compute_address.exascale_peoplesoft_server_internal_ip[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/exascale-peoplesoft-server-internal-ip]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exadbVmClusters/ps-exadb-vm-cluster-01]
google_compute_instance.exascale_peoplesoft[0]: Refreshing state... [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in]
module.cloud_router.google_compute_router.router: Refreshing state... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Refreshing state... [id=projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet]
google_compute_instance.apps: Refreshing state... [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps]
null_resource.exascale_db_provisioning[0]: Refreshing state... [id=674647006718827274]
null_resource.exascale_ingress_rules[0]: Refreshing state... [id=384734829590778732]
null_resource.exascale_configure_and_upload[0]: Refreshing state... [id=1363489200522231787]
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Refreshing state... [id=gcp-project-peoplesoft/northamerica-northeast2/gcp-project-peoplesoft-network-cloud-router/gcp-project-peoplesoft-nat-01]
null_resource.push_scripts: Refreshing state... [id=1985750050220397445]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_address.exascale_peoplesoft_server_internal_ip[0] will be destroyed
  - resource "google_compute_address" "exascale_peoplesoft_server_internal_ip" {
      - address            = "10.115.0.40" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2026-08-09T23:49:59.745-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/exascale-peoplesoft-server-internal-ip" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "exascale-peoplesoft-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "gcp-project-peoplesoft" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "northamerica-northeast2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/exascale-peoplesoft-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"] will be destroyed
  - resource "google_compute_address" "nat_ip" {
      - address            = "34.130.222.98" -> null
      - address_type       = "EXTERNAL" -> null
      - creation_timestamp = "2026-08-09T23:49:11.094-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "gcp-project-peoplesoft-nat-01" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "gcp-project-peoplesoft" -> null
      - region             = "northamerica-northeast2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router",
        ] -> null
        # (6 unchanged attributes hidden)
    }

  # google_compute_address.peoplesoft_apps_server_internal_ip will be destroyed
  - resource "google_compute_address" "peoplesoft_apps_server_internal_ip" {
      - address            = "10.115.0.20" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2026-08-09T23:49:59.729-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/peoplesoft-apps-server-internal-ip" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "peoplesoft-apps-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "gcp-project-peoplesoft" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "northamerica-northeast2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/peoplesoft-apps-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_instance.apps will be destroyed
  - resource "google_compute_instance" "apps" {
      - can_ip_forward             = false -> null
      - cpu_platform               = "AMD Rome" -> null
      - creation_timestamp         = "2026-08-09T23:50:16.458-07:00" -> null
      - current_status             = "RUNNING" -> null
      - deletion_protection        = false -> null
      - effective_labels           = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
        } -> null
      - enable_display             = false -> null
      - id                         = "projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps" -> null
      - instance_id                = "8997672985952569928" -> null
      - label_fingerprint          = "haXWq_2O7D4=" -> null
      - labels                     = {
          - "managed-by" = "terraform"
        } -> null
      - machine_type               = "e2-highmem-8" -> null
      - metadata                   = {
          - "enable-oslogin" = "TRUE"
          - "startup-script" = <<-EOT
                #!/bin/bash
                set -e

                # NOTE: This is Peoplesoft server boot script - all the updates add here

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

                # disable IPV6
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
                sysctl -p

                # dnf oracle packages
                dnf config-manager --set-enabled ol8_addons
                dnf install oracle-ebs-server-R12-preinstall -y
                dnf install oracle-database-preinstall-19c -y
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils tmux expect -y

                # dnf cleanup
                dnf clean all

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown oracle:oinstall /u02

                # for customer data
                mkdir -p /opt/oracle
                chown -Rf oracle:oinstall /opt/oracle

                # Peoplesoft directories for PUM preinstall prerequisites
                mkdir -pv  /u01/install/ /ds2 /srv/dpk/oracle /ds2/dpk/PT862P05B_2509240500-retail-orasrvlnx/oracleserver-2623528/oracle-server/product/19.3.0.0/bin/ /u02/db/oracle-server/admin/CDBCRM/adump
                chown -Rf oracle:oinstall /u02 /u01 /ds2 /srv/
                touch  /etc/oratab
                chown  oracle:oinstall /etc/oratab

                # remove profiles
                mv -v /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv -v /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.back
                mv -v /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

                # function to source env on
                if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # Make it persistent by adding it to /etc/fstab (if not already there)
                if ! grep -q '/swapfile' /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi
            EOT
        } -> null
      - metadata_fingerprint       = "jteTi0LyM8E=" -> null
      - name                       = "oracle-peoplesoft-apps" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - resource_policies          = [] -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps" -> null
      - tags                       = [
          - "egress-nat",
          - "external-app-access",
          - "http-server",
          - "https-server",
          - "iap-access",
          - "icmp-access",
          - "internal-access",
          - "lb-health-check",
          - "oracle-peoplesoft-apps",
        ] -> null
      - tags_fingerprint           = "RGl2piC5NLk=" -> null
      - terraform_labels           = {
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
          - source                          = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/disks/oracle-peoplesoft-apps" -> null
            # (6 unchanged attributes hidden)

          - initialize_params {
              - architecture                = "X86_64" -> null
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - resource_policies           = [] -> null
              - size                        = 512 -> null
              - type                        = "pd-balanced" -> null
                # (2 unchanged attributes hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
          - network_ip                  = "10.115.0.20" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
          - subnetwork_project          = "gcp-project-peoplesoft" -> null
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
          - email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
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

  # google_compute_instance.exascale_peoplesoft[0] will be destroyed
  - resource "google_compute_instance" "exascale_peoplesoft" {
      - can_ip_forward             = false -> null
      - cpu_platform               = "AMD Rome" -> null
      - creation_timestamp         = "2026-08-09T23:50:14.673-07:00" -> null
      - current_status             = "RUNNING" -> null
      - deletion_protection        = false -> null
      - effective_labels           = {
          - "application"                = "oracle-exascale-peoplesoft"
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
        } -> null
      - enable_display             = false -> null
      - id                         = "projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app" -> null
      - instance_id                = "3106662956194384457" -> null
      - label_fingerprint          = "Vqf34AuBqTs=" -> null
      - labels                     = {
          - "application" = "oracle-exascale-peoplesoft"
          - "managed-by"  = "terraform"
        } -> null
      - machine_type               = "e2-highmem-8" -> null
      - metadata                   = {
          - "enable-oslogin"              = "TRUE"
          - "exadb_private_key_secret_id" = "projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-0162d4cb"
          - "exadb_public_key"            = <<-EOT
                ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXEmfnrjWKjF5HJ4k+XNRDadxcfqslsp7k6MsK8ygwjMZ0aBnNOAzSARhtTI9IUa4MF8MG58vc3iNtm2Vzmr3UF+MihQPwhZdbR2jp9eAcrMXDJYhHbJWQAn+aTZjcLf7rGFN5uru1sLaC0LQVN/6WbjBz70jvy1TUBbshMxtYAcjQw1jlRRYE+4wqzzq9IAUh0Xk23jVO7ad21qOLYW+wZq2lsOutHt9ygWi0rWl2Ri8xS6fSYw/K/KHoQjYybfikS5gvmo1fHhOTKVPTLnvLf3kXGoPjEXps1wg8y46uytc0Qb747HP9DcE/wrSkHj5yuo6h+cbCqaQMpDGIdoMdFQx5twt93JMg7ROQdodxZ60e08BvHR4FKwj5fvraJQR7185ihx9DEsQq9eZhDOWV92N4PEqGCNo0rqD2aOFy7OcHIZO9f+QtC9CV2pkVBjnCG40j2VH1OgZ3HLO9as+KzhVbCsPdZQHV0eocCijfXiESNZwBKs1BsY8WmaYNUAQkpY2JNPc8KMkrn+UdmK/ZxO5+QEM+pc3M8Xz7X7tOqDp79q2rRfmDlQCkOPl/LiXIBuGzCnRMw+t2jzW1LP4PNfnqOc4wm5ool3bisILXBFJqHdpdHOT5EQ2tLESGEmpnwQimAH0Jyleh9h9Uu0egUuHD8jcdjY5S6TWQzHqgvw==
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

                # disable IPV6
                sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
                sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
                sysctl -p

                # dnf oracle packages
                dnf config-manager --set-enabled ol8_addons
                dnf install oracle-ebs-server-R12-preinstall -y
                dnf install oracle-database-preinstall-19c -y
                dnf install jq tmux gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown oracle:oinstall /u02

                # for customer data
                mkdir -p /opt/oracle
                chown -Rf oracle:oinstall /opt/oracle

                # Peoplesoft directories for PUM preinstall prerequisites
                mkdir -pv  /u01/install/ /ds2 /srv/dpk/oracle /ds2/dpk/PT862P05B_2509240500-retail-orasrvlnx/oracleserver-2623528/oracle-server/product/19.3.0.0/bin/ /u02/db/oracle-server/admin/CDBCRM/adump
                chown -Rf oracle:oinstall /u02 /u01 /ds2 /srv/
                touch  /etc/oratab
                chown  oracle:oinstall /etc/oratab

                # remove profiles
                mv -v /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv -v /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.back
                mv -v /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi

                # function to source env on
                if [[ $(grep funct.sh /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "source /scripts/funct.sh" >> /home/oracle/.bash_profile ; fi

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # Make it persistent by adding it to /etc/fstab (if not already there)
                if ! grep -q '/swapfile' /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi

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
      - metadata_fingerprint       = "ObbSLwp18A4=" -> null
      - name                       = "oracle-exascale-peoplesoft-app" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - resource_policies          = [] -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app" -> null
      - tags                       = [
          - "egress-nat",
          - "external-app-access",
          - "external-db-access",
          - "http-server",
          - "https-server",
          - "iap-access",
          - "icmp-access",
          - "internal-access",
          - "lb-health-check",
          - "oracle-peoplesoft-apps",
        ] -> null
      - tags_fingerprint           = "EL4LQA01dsE=" -> null
      - terraform_labels           = {
          - "application"                = "oracle-exascale-peoplesoft"
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
          - source                          = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/disks/oracle-exascale-peoplesoft-app" -> null
            # (6 unchanged attributes hidden)

          - initialize_params {
              - architecture                = "X86_64" -> null
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260730" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - resource_policies           = [] -> null
              - size                        = 512 -> null
              - type                        = "pd-balanced" -> null
                # (2 unchanged attributes hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
          - network_ip                  = "10.115.0.40" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
          - subnetwork_project          = "gcp-project-peoplesoft" -> null
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
          - email  = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
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
      - backup_odb_subnet   = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet" -> null
      - create_time         = "2026-08-10T06:55:11.208331636Z" -> null
      - deletion_policy     = "DELETE" -> null
      - deletion_protection = false -> null
      - display_name        = "PeopleSoft Exadata VM Cluster" -> null
      - effective_labels    = {
          - "deployment"                 = "demo"
          - "goog-terraform-provisioned" = "true"
        } -> null
      - entitlement_id      = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - exadb_vm_cluster_id = "ps-exadb-vm-cluster-01" -> null
      - gcp_oracle_zone     = "northamerica-northeast2-a-r2" -> null
      - id                  = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exadbVmClusters/ps-exadb-vm-cluster-01" -> null
      - labels              = {
          - "deployment" = "demo"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exadbVmClusters/ps-exadb-vm-cluster-01" -> null
      - odb_network         = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network" -> null
      - odb_subnet          = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet" -> null
      - project             = "gcp-project-peoplesoft" -> null
      - terraform_labels    = {
          - "deployment"                 = "demo"
          - "goog-terraform-provisioned" = "true"
        } -> null

      - properties {
          - additional_ecpu_count_per_node = 0 -> null
          - cluster_name                   = "psftcl1" -> null
          - enabled_ecpu_count_per_node    = 8 -> null
          - exascale_db_storage_vault      = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault" -> null
          - gi_version                     = "19.32.0.0.0" -> null
          - grid_image_id                  = "ocid1.dbpatch.oc1.ca-toronto-1.an2g6ljrt5t4sqqakv6zraj2jc6rbptk4smtunilz4dmfa4n5qsrphe2s2ba" -> null
          - hostname                       = "psft-node" -> null
          - hostname_prefix                = "psft-node" -> null
          - license_model                  = "BRING_YOUR_OWN_LICENSE" -> null
          - lifecycle_state                = "AVAILABLE" -> null
          - memory_size_gb                 = 22 -> null
          - node_count                     = 1 -> null
          - oci_uri                        = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja" -> null
          - scan_listener_port_tcp         = 1521 -> null
          - shape_attribute                = "BLOCK_STORAGE" -> null
          - ssh_public_keys                = [
              - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXEmfnrjWKjF5HJ4k+XNRDadxcfqslsp7k6MsK8ygwjMZ0aBnNOAzSARhtTI9IUa4MF8MG58vc3iNtm2Vzmr3UF+MihQPwhZdbR2jp9eAcrMXDJYhHbJWQAn+aTZjcLf7rGFN5uru1sLaC0LQVN/6WbjBz70jvy1TUBbshMxtYAcjQw1jlRRYE+4wqzzq9IAUh0Xk23jVO7ad21qOLYW+wZq2lsOutHt9ygWi0rWl2Ri8xS6fSYw/K/KHoQjYybfikS5gvmo1fHhOTKVPTLnvLf3kXGoPjEXps1wg8y46uytc0Qb747HP9DcE/wrSkHj5yuo6h+cbCqaQMpDGIdoMdFQx5twt93JMg7ROQdodxZ60e08BvHR4FKwj5fvraJQR7185ihx9DEsQq9eZhDOWV92N4PEqGCNo0rqD2aOFy7OcHIZO9f+QtC9CV2pkVBjnCG40j2VH1OgZ3HLO9as+KzhVbCsPdZQHV0eocCijfXiESNZwBKs1BsY8WmaYNUAQkpY2JNPc8KMkrn+UdmK/ZxO5+QEM+pc3M8Xz7X7tOqDp79q2rRfmDlQCkOPl/LiXIBuGzCnRMw+t2jzW1LP4PNfnqOc4wm5ool3bisILXBFJqHdpdHOT5EQ2tLESGEmpnwQimAH0Jyleh9h9Uu0egUuHD8jcdjY5S6TWQzHqgvw==",
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
      - create_time                  = "2026-08-10T06:49:12.678653602Z" -> null
      - deletion_policy              = "DELETE" -> null
      - deletion_protection          = false -> null
      - display_name                 = "PeopleSoft Exascale DB Storage Vault" -> null
      - effective_labels             = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - entitlement_id               = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - exascale_db_storage_vault_id = "ps-exascale-db-storage-vault" -> null
      - gcp_oracle_zone              = "northamerica-northeast2-a-r2" -> null
      - id                           = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault" -> null
      - labels                       = {} -> null
      - location                     = "northamerica-northeast2" -> null
      - name                         = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault" -> null
      - project                      = "gcp-project-peoplesoft" -> null
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
          - oci_uri                        = "https://cloud.oracle.com/dbaas/exadb-xs/exascaleStorageVaults/ocid1.exascaledbstoragevault.oc1.ca-toronto-1.an2g6ljr33xv2ayadzhlyr25qmyyck5l2dpogyawqckiywwp45kn44usoiia?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja" -> null
          - ocid                           = "ocid1.exascaledbstoragevault.oc1.ca-toronto-1.an2g6ljr33xv2ayadzhlyr25qmyyck5l2dpogyawqckiywwp45kn44usoiia" -> null
          - state                          = "AVAILABLE" -> null
          - vm_cluster_count               = 1 -> null
          - vm_cluster_ids                 = [
              - "ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q",
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
      - create_time         = "2026-08-10T06:49:49.265081787Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - entitlement_id      = "e9ba70fb-1d6d-4539-8f05-e4a61819531e" -> null
      - id                  = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network" -> null
      - network             = "projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - odb_network_id      = "gcp-project-peoplesoft-network-odb-network" -> null
      - project             = "gcp-project-peoplesoft" -> null
      - state               = "AVAILABLE" -> null
      - terraform_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
    }

  # google_oracle_database_odb_subnet.backup_subnet[0] will be destroyed
  - resource "google_oracle_database_odb_subnet" "backup_subnet" {
      - cidr_range          = "10.116.128.0/20" -> null
      - create_time         = "2026-08-10T06:49:50.614881306Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - id                  = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet" -> null
      - odb_subnet_id       = "gcp-project-peoplesoft-network-backup-subnet" -> null
      - odbnetwork          = "gcp-project-peoplesoft-network-odb-network" -> null
      - project             = "gcp-project-peoplesoft" -> null
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
      - create_time         = "2026-08-10T06:49:51.023263522Z" -> null
      - deletion_protection = false -> null
      - effective_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
      - id                  = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet" -> null
      - labels              = {
          - "terraform_created" = "true"
        } -> null
      - location            = "northamerica-northeast2" -> null
      - name                = "projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet" -> null
      - odb_subnet_id       = "gcp-project-peoplesoft-network-client-subnet" -> null
      - odbnetwork          = "gcp-project-peoplesoft-network-odb-network" -> null
      - project             = "gcp-project-peoplesoft" -> null
      - purpose             = "CLIENT_SUBNET" -> null
      - state               = "AVAILABLE" -> null
      - terraform_labels    = {
          - "goog-terraform-provisioned" = "true"
          - "terraform_created"          = "true"
        } -> null
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/compute.instanceAdmin.v1/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/compute.instanceAdmin.v1" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/iam.serviceAccountUser/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/iam.serviceAccountUser" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/iap.tunnelResourceAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/iap.tunnelResourceAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/logging.logWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/logging.logWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/monitoring.metricWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/monitoring.metricWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/secretmanager.secretAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/secretmanager.secretAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZYq8Fmjlc=" -> null
      - id      = "gcp-project-peoplesoft/roles/storage.admin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project = "gcp-project-peoplesoft" -> null
      - role    = "roles/storage.admin" -> null
    }

  # google_secret_manager_secret.exadb_private_key_secret[0] will be destroyed
  - resource "google_secret_manager_secret" "exadb_private_key_secret" {
      - annotations           = {} -> null
      - create_time           = "2026-08-10T06:49:10.376908Z" -> null
      - deletion_protection   = false -> null
      - effective_annotations = {} -> null
      - effective_labels      = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                    = "projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-0162d4cb" -> null
      - labels                = {} -> null
      - name                  = "projects/119724395047/secrets/exadb-ssh-private-key-0162d4cb" -> null
      - project               = "gcp-project-peoplesoft" -> null
      - secret_id             = "exadb-ssh-private-key-0162d4cb" -> null
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
      - create_time            = "2026-08-10T06:49:13.381948Z" -> null
      - deletion_policy        = "DELETE" -> null
      - enabled                = true -> null
      - id                     = "projects/119724395047/secrets/exadb-ssh-private-key-0162d4cb/versions/1" -> null
      - is_secret_data_base64  = false -> null
      - name                   = "projects/119724395047/secrets/exadb-ssh-private-key-0162d4cb/versions/1" -> null
      - secret                 = "projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-0162d4cb" -> null
      - secret_data            = (sensitive value) -> null
      - secret_data_wo         = (write-only attribute) -> null
      - secret_data_wo_version = 0 -> null
      - version                = "1" -> null
        # (1 unchanged attribute hidden)
    }

  # google_service_account.project_sa will be destroyed
  - resource "google_service_account" "project_sa" {
      - account_id   = "ps-project-service-account" -> null
      - disabled     = false -> null
      - display_name = "Project Service Account" -> null
      - email        = "ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - id           = "projects/gcp-project-peoplesoft/serviceAccounts/ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - name         = "projects/gcp-project-peoplesoft/serviceAccounts/ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - project      = "gcp-project-peoplesoft" -> null
      - unique_id    = "113573810398644690145" -> null
        # (1 unchanged attribute hidden)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be destroyed
  - resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      - bucket = "b/gcp-project-peoplesoft-storage-bucket-a9fb9087" -> null
      - etag   = "CAI=" -> null
      - id     = "b/gcp-project-peoplesoft-storage-bucket-a9fb9087/roles/storage.objectAdmin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - member = "serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com" -> null
      - role   = "roles/storage.objectAdmin" -> null
    }

  # local_file.exadb_private_key[0] will be destroyed
  - resource "local_file" "exadb_private_key" {
      - content              = (sensitive value) -> null
      - content_base64sha256 = "+3+IAyQSBVSFrihIHjPjJZ4NhRxfdmtsRsOU61iwUOY=" -> null
      - content_base64sha512 = "lSas2cD3ExUoc0QT+O8705EJ5dvUfrE9sKo6gqDuPqyvDHQTmBEINuLUkbb6s4xPPC5SM4E1GN1+L7zjEiRXPQ==" -> null
      - content_md5          = "59f886cd577330d374273b1e036f161f" -> null
      - content_sha1         = "4c5656b68d99192b3fb082e7f695f1250ff1c758" -> null
      - content_sha256       = "fb7f88032412055485ae28481e33e3259e0d851c5f766b6c46c394eb58b050e6" -> null
      - content_sha512       = "9526acd9c0f7131528734413f8ef3bd39109e5dbd47eb13db0aa3a82a0ee3eacaf0c741398110836e2d491b6fab38c4f3c2e5233813518dd7e2fbce31224573d" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0600" -> null
      - filename             = "./exadb_private_key.pem" -> null
      - id                   = "4c5656b68d99192b3fb082e7f695f1250ff1c758" -> null
    }

  # local_file.exadb_public_key[0] will be destroyed
  - resource "local_file" "exadb_public_key" {
      - content              = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXEmfnrjWKjF5HJ4k+XNRDadxcfqslsp7k6MsK8ygwjMZ0aBnNOAzSARhtTI9IUa4MF8MG58vc3iNtm2Vzmr3UF+MihQPwhZdbR2jp9eAcrMXDJYhHbJWQAn+aTZjcLf7rGFN5uru1sLaC0LQVN/6WbjBz70jvy1TUBbshMxtYAcjQw1jlRRYE+4wqzzq9IAUh0Xk23jVO7ad21qOLYW+wZq2lsOutHt9ygWi0rWl2Ri8xS6fSYw/K/KHoQjYybfikS5gvmo1fHhOTKVPTLnvLf3kXGoPjEXps1wg8y46uytc0Qb747HP9DcE/wrSkHj5yuo6h+cbCqaQMpDGIdoMdFQx5twt93JMg7ROQdodxZ60e08BvHR4FKwj5fvraJQR7185ihx9DEsQq9eZhDOWV92N4PEqGCNo0rqD2aOFy7OcHIZO9f+QtC9CV2pkVBjnCG40j2VH1OgZ3HLO9as+KzhVbCsPdZQHV0eocCijfXiESNZwBKs1BsY8WmaYNUAQkpY2JNPc8KMkrn+UdmK/ZxO5+QEM+pc3M8Xz7X7tOqDp79q2rRfmDlQCkOPl/LiXIBuGzCnRMw+t2jzW1LP4PNfnqOc4wm5ool3bisILXBFJqHdpdHOT5EQ2tLESGEmpnwQimAH0Jyleh9h9Uu0egUuHD8jcdjY5S6TWQzHqgvw==
        EOT -> null
      - content_base64sha256 = "XkssoMy2R4CpI6WeBnN4t9rufItmVTJoW2t17G+GRFg=" -> null
      - content_base64sha512 = "rsYH0FraDltz6gxTP8LiWD4eHjTFKIkB+D2SPSWCo73Eb0iVyBPW9NFqMBlMWNwqXzMvI+OTOF3EEEPpupAFzg==" -> null
      - content_md5          = "4a1d5bdc20be6a51e5dce1e75eb20962" -> null
      - content_sha1         = "bc82372e4622ecda67e057c3b11f712c2cc178d0" -> null
      - content_sha256       = "5e4b2ca0ccb64780a923a59e067378b7daee7c8b665532685b6b75ec6f864458" -> null
      - content_sha512       = "aec607d05ada0e5b73ea0c533fc2e2583e1e1e34c5288901f83d923d2582a3bdc46f4895c813d6f4d16a30194c58dc2a5f332f23e393385dc41043e9ba9005ce" -> null
      - directory_permission = "0777" -> null
      - file_permission      = "0644" -> null
      - filename             = "./exadb_public_key.pub" -> null
      - id                   = "bc82372e4622ecda67e057c3b11f712c2cc178d0" -> null
    }

  # null_resource.exascale_configure_and_upload[0] will be destroyed
  - resource "null_resource" "exascale_configure_and_upload" {
      - id       = "1363489200522231787" -> null
      - triggers = {
          - "cdb_name"        = "PSFTCDB"
          - "oci_api_version" = "20160918"
          - "password"        = (sensitive value)
          - "vm_id"           = "projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app"
        } -> null
    }

  # null_resource.exascale_db_provisioning[0] will be destroyed
  - resource "null_resource" "exascale_db_provisioning" {
      - id       = "674647006718827274" -> null
      - triggers = {
          - "cdb_name"        = "PSFTCDB"
          - "cluster_uri"     = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja"
          - "oci_api_version" = "20160918"
        } -> null
    }

  # null_resource.exascale_ingress_rules[0] will be destroyed
  - resource "null_resource" "exascale_ingress_rules" {
      - id       = "384734829590778732" -> null
      - triggers = {
          - "cluster_uri"     = "https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja"
          - "oci_api_version" = "20160918"
          - "vpc_cidr"        = "10.115.0.0/20"
        } -> null
    }

  # null_resource.push_scripts will be destroyed
  - resource "null_resource" "push_scripts" {
      - id       = "1985750050220397445" -> null
      - triggers = {
          - "always_run" = "2026-08-10T09:59:45Z"
        } -> null
    }

  # random_id.bucket_suffix will be destroyed
  - resource "random_id" "bucket_suffix" {
      - b64_std     = "qfuQhw==" -> null
      - b64_url     = "qfuQhw" -> null
      - byte_length = 4 -> null
      - dec         = "2851836039" -> null
      - hex         = "a9fb9087" -> null
      - id          = "qfuQhw" -> null
    }

  # random_id.secret_suffix[0] will be destroyed
  - resource "random_id" "secret_suffix" {
      - b64_std     = "AWLUyw==" -> null
      - b64_url     = "AWLUyw" -> null
      - byte_length = 4 -> null
      - dec         = "23254219" -> null
      - hex         = "0162d4cb" -> null
      - id          = "AWLUyw" -> null
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
      - id                            = "b8e3e4877d593f2ca716c101b13782ff0c4bdb89" -> null
      - private_key_openssh           = (sensitive value) -> null
      - private_key_pem               = (sensitive value) -> null
      - private_key_pem_pkcs8         = (sensitive value) -> null
      - public_key_fingerprint_md5    = "34:05:65:94:ce:76:b3:3a:41:21:7d:20:0f:25:47:47" -> null
      - public_key_fingerprint_sha256 = "SHA256:6hW1606hA6rjeDqqD4NlAgLikXow0PfSxWjrStFvKto" -> null
      - public_key_openssh            = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXEmfnrjWKjF5HJ4k+XNRDadxcfqslsp7k6MsK8ygwjMZ0aBnNOAzSARhtTI9IUa4MF8MG58vc3iNtm2Vzmr3UF+MihQPwhZdbR2jp9eAcrMXDJYhHbJWQAn+aTZjcLf7rGFN5uru1sLaC0LQVN/6WbjBz70jvy1TUBbshMxtYAcjQw1jlRRYE+4wqzzq9IAUh0Xk23jVO7ad21qOLYW+wZq2lsOutHt9ygWi0rWl2Ri8xS6fSYw/K/KHoQjYybfikS5gvmo1fHhOTKVPTLnvLf3kXGoPjEXps1wg8y46uytc0Qb747HP9DcE/wrSkHj5yuo6h+cbCqaQMpDGIdoMdFQx5twt93JMg7ROQdodxZ60e08BvHR4FKwj5fvraJQR7185ihx9DEsQq9eZhDOWV92N4PEqGCNo0rqD2aOFy7OcHIZO9f+QtC9CV2pkVBjnCG40j2VH1OgZ3HLO9as+KzhVbCsPdZQHV0eocCijfXiESNZwBKs1BsY8WmaYNUAQkpY2JNPc8KMkrn+UdmK/ZxO5+QEM+pc3M8Xz7X7tOqDp79q2rRfmDlQCkOPl/LiXIBuGzCnRMw+t2jzW1LP4PNfnqOc4wm5ool3bisILXBFJqHdpdHOT5EQ2tLESGEmpnwQimAH0Jyleh9h9Uu0egUuHD8jcdjY5S6TWQzHqgvw==
        EOT -> null
      - public_key_pem                = <<-EOT
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1xJn5641ioxeRyeJPlzU
            Q2ncXH6rJbKe5OjLCvMoMIzGdGgZzTgM0gEYbUyPSFGuDBfDBufL3N4jbZtlc5q9
            1BfjIoUD8IWXW0do6fXgHKzFwyWIR2yVkAJ/mk2Y3C3+6xhTebq7tbC2gtC0FTf+
            lm4wc+9I78tU1AW7ITMbWAHI0MNY5UUWBPuMKs86vSAFIdF5Nt41Tu2ndtaji2Fv
            sGatpbDrrR7fcoFotK1pdkYvMUun0mMPyvyh6EI2Mm34pEuYL5qNXx4TkylT0y57
            y395FxqD4xF6bNcIPMuOrsrXNEG++Oxz/Q3BP8K0pB4+crqOofnGwqmkDKQxiHaD
            HRUMebcLfdyTIO0TkHaHcWetHtPAbx0eBSsI+X762iUEe9fOYocfQxLEKvXmYQzl
            lfdjeDxKhgjaNK6g9mjhcuznByGTvX/kLQvQldqZFQY5whuNI9lR9ToGdxyzvWrP
            is4VWwrD3WUB1dHqHAoo314hEjWcASrNQbGPFpmmDVAEJKWNiTT3PCjJK5/lHZiv
            2cTufkBDPqXNzPF8+1+7Tqg6e/atq0X5g5UApDj5fy4lyAbhswp0TMPrdo81tSz+
            DzX56jnOMJuaKJd24rCC1wRSah3aXRzk+RENrSxEhhJqZ8EIpgB9CcpXofYfVLtH
            oFLhw/I3HY2OUuk1kMx6oL8CAwEAAQ==
            -----END PUBLIC KEY-----
        EOT -> null
      - rsa_bits                      = 4096 -> null
    }

  # module.cloud_router.google_compute_router.router will be destroyed
  - resource "google_compute_router" "router" {
      - creation_timestamp            = "2026-08-09T23:49:59.858-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router" -> null
      - name                          = "gcp-project-peoplesoft-network-cloud-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - project                       = "gcp-project-peoplesoft" -> null
      - region                        = "northamerica-northeast2" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router" -> null
        # (1 unchanged attribute hidden)
    }

  # module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"] will be destroyed
  - resource "google_compute_router_nat" "nats" {
      - drain_nat_ips                        = [] -> null
      - enable_dynamic_port_allocation       = false -> null
      - enable_endpoint_independent_mapping  = false -> null
      - endpoint_types                       = [
          - "ENDPOINT_TYPE_VM",
        ] -> null
      - icmp_idle_timeout_sec                = 30 -> null
      - id                                   = "gcp-project-peoplesoft/northamerica-northeast2/gcp-project-peoplesoft-network-cloud-router/gcp-project-peoplesoft-nat-01" -> null
      - max_ports_per_vm                     = 0 -> null
      - min_ports_per_vm                     = 0 -> null
      - name                                 = "gcp-project-peoplesoft-nat-01" -> null
      - nat_ip_allocate_option               = "MANUAL_ONLY" -> null
      - nat_ips                              = [
          - "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01",
        ] -> null
      - project                              = "gcp-project-peoplesoft" -> null
      - region                               = "northamerica-northeast2" -> null
      - router                               = "gcp-project-peoplesoft-network-cloud-router" -> null
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
          - name                     = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
          - secondary_ip_range_names = [] -> null
          - source_ip_ranges_to_nat  = [
              - "ALL_IP_RANGES",
            ] -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:12.285-07:00" -> null
      - description             = "Allow external access to Oracle PeopleSoft Apps" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access" -> null
      - name                    = "ps-allow-external-app-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access" -> null
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
              - "2049",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:11.838-07:00" -> null
      - description             = "Allow external access to Oracle PeopleSoft DB" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access" -> null
      - name                    = "ps-allow-external-db-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access" -> null
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:49:59.183-07:00" -> null
      - description             = "Allow HTTP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in" -> null
      - name                    = "ps-allow-http-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in" -> null
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:01.403-07:00" -> null
      - description             = "Allow HTTPS traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in" -> null
      - name                    = "ps-allow-https-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in" -> null
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:00.512-07:00" -> null
      - description             = "Allow IAP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in" -> null
      - name                    = "ps-allow-iap-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in" -> null
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:03.595-07:00" -> null
      - description             = "Allow ICMP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in" -> null
      - name                    = "ps-allow-icmp-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in" -> null
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

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-08-09T23:50:11.032-07:00" -> null
      - description             = "Allow internal HTTP traffic within the VPC" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access" -> null
      - name                    = "ps-allow-internal-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - priority                = 1000 -> null
      - project                 = "gcp-project-peoplesoft" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access" -> null
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

  # module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"] will be destroyed
  - resource "google_compute_route" "route" {
      - as_paths                   = [] -> null
      - creation_timestamp         = "2026-08-09T23:49:59.245-07:00" -> null
      - description                = "Public NAT GW - route through IGW to access internet" -> null
      - dest_range                 = "0.0.0.0/0" -> null
      - id                         = "projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet" -> null
      - name                       = "ps-nat-egress-internet" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - next_hop_gateway           = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/gateways/default-internet-gateway" -> null
      - priority                   = 1000 -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet" -> null
      - tags                       = [
          - "egress-nat",
        ] -> null
      - warnings                   = [] -> null
        # (12 unchanged attributes hidden)
    }

  # module.peoplesoft_storage_bucket.google_storage_bucket.bucket will be destroyed
  - resource "google_storage_bucket" "bucket" {
      - default_event_based_hold    = false -> null
      - effective_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "gcp-project-peoplesoft"
        } -> null
      - enable_object_retention     = false -> null
      - force_destroy               = true -> null
      - id                          = "gcp-project-peoplesoft-storage-bucket-a9fb9087" -> null
      - labels                      = {
          - "managed-by" = "terraform"
          - "service"    = "gcp-project-peoplesoft"
        } -> null
      - location                    = "NORTHAMERICA-NORTHEAST2" -> null
      - name                        = "gcp-project-peoplesoft-storage-bucket-a9fb9087" -> null
      - project                     = "gcp-project-peoplesoft" -> null
      - project_number              = 119724395047 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/gcp-project-peoplesoft-storage-bucket-a9fb9087" -> null
      - storage_class               = "NEARLINE" -> null
      - terraform_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "gcp-project-peoplesoft"
        } -> null
      - time_created                = "2026-08-10T06:49:15.729Z" -> null
      - uniform_bucket_level_access = true -> null
      - updated                     = "2026-08-10T06:49:24.028Z" -> null
      - url                         = "gs://gcp-project-peoplesoft-storage-bucket-a9fb9087" -> null

      - hierarchical_namespace {
          - enabled = false -> null
        }

      - soft_delete_policy {
          - effective_time             = "2026-08-10T06:49:15.729Z" -> null
          - retention_duration_seconds = 604800 -> null
        }

      - versioning {
          - enabled = true -> null
        }
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "gcp-project-peoplesoft/cloudresourcemanager.googleapis.com" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - service                    = "cloudresourcemanager.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "gcp-project-peoplesoft/compute.googleapis.com" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - service                    = "compute.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "gcp-project-peoplesoft/iam.googleapis.com" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - service                    = "iam.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "gcp-project-peoplesoft/secretmanager.googleapis.com" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - service                    = "secretmanager.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "gcp-project-peoplesoft/storage.googleapis.com" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - service                    = "storage.googleapis.com" -> null
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"] will be destroyed
  - resource "google_compute_subnetwork" "subnetwork" {
      - creation_timestamp         = "2026-08-09T23:49:45.634-07:00" -> null
      - enable_flow_logs           = true -> null
      - gateway_address            = "10.115.0.1" -> null
      - id                         = "projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
      - ip_cidr_range              = "10.115.0.0/20" -> null
      - name                       = "gcp-project-peoplesoft-subnet-01" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "gcp-project-peoplesoft" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "northamerica-northeast2" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01" -> null
      - stack_type                 = "IPV4_ONLY" -> null
      - subnetwork_id              = 6446337325501041254 -> null
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
      - deletion_policy                           = "DELETE" -> null
      - enable_ula_internal_ipv6                  = false -> null
      - id                                        = "projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
      - mtu                                       = 0 -> null
      - name                                      = "gcp-project-peoplesoft-network" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - network_id                                = "2281581180079098505" -> null
      - numeric_id                                = "2281581180079098505" -> null
      - project                                   = "gcp-project-peoplesoft" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network" -> null
        # (5 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 49 to destroy.

Changes to Outputs:
  - apps_instance_zone                = "northamerica-northeast2-a" -> null
  - deployment_summary                = <<-EOT
        =========================================
         PeopleSoft VM Configuration
        -----------------------------------------
           • Instance Name  : oracle-peoplesoft-apps
           • Internal IP    : 10.115.0.20
           • Zone           : northamerica-northeast2-a
           • Machine Type   : e2-highmem-8
           • SSH Command    :
               gcloud compute ssh --zone "northamerica-northeast2-a" "oracle-peoplesoft-apps" --tunnel-through-iap --project "gcp-project-peoplesoft" -- -L 8000:localhost:8000

        -----------------------------------------
         Storage
        -----------------------------------------
           • Bucket Name    : gcp-project-peoplesoft-storage-bucket-a9fb9087
           • Bucket URL     : gs://gcp-project-peoplesoft-storage-bucket-a9fb9087

        =========================================
         Summary
        -----------------------------------------
           • Total Instances: 1
           • Storage Bucket : gcp-project-peoplesoft-storage-bucket-a9fb9087
           • Generated At   : 2026-08-10T09:59:45Z
        =========================================
    EOT -> null
  - exascale_deployment_summary       = <<-EOT
        =========================================
         Oracle PeopleSoft on ExaScale @ GCP
        -----------------------------------------
         Project ID     : gcp-project-peoplesoft
         Region         : northamerica-northeast2
         Zone           : northamerica-northeast2-a
         ExaScale Region: northamerica-northeast2
        -----------------------------------------
         Application Tier (GCE)
        -----------------------------------------
           • Name         : oracle-exascale-peoplesoft-app
           • Internal IP  : 10.115.0.40
        -----------------------------------------
         Database Tier (Oracle Database@Google Cloud)
        -----------------------------------------
           • Type         : Oracle Database@Google Cloud (ExaScale)
           • Cluster Name : PeopleSoft Exadata VM Cluster
           • CDB Name     : PSFTCDB
           • SSH Key      : ./exadb_private_key.pem
           • Connection   : ./exascale_outputs.yaml (TNS, SCAN DNS)
        =========================================
    EOT -> null
  - exascale_peoplesoft_instance_zone = "northamerica-northeast2-a" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

null_resource.push_scripts: Destroying... [id=1985750050220397445]
null_resource.exascale_ingress_rules[0]: Destroying... [id=384734829590778732]
null_resource.exascale_configure_and_upload[0]: Destroying... [id=1363489200522231787]
null_resource.exascale_ingress_rules[0]: Provisioning with 'local-exec'...
null_resource.exascale_configure_and_upload[0]: Provisioning with 'local-exec'...
null_resource.push_scripts: Destruction complete after 0s
null_resource.exascale_configure_and_upload[0] (local-exec): Executing: ["/bin/sh" "-c" "rm -f ./exascale_outputs.yaml /tmp/exascale_outputs.yaml"]
null_resource.exascale_ingress_rules[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 0\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      if [ -z \"$CLUSTER_URI\" ]; then\n        exit 0\n      fi\n\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/exadbVmClusters/$CLUSTER_OCID\" 2>/dev/null || true)\n      SUBNET_OCID=$(echo \"$CLUSTER_JSON\" | jq -r '.data.subnetId // empty')\n\n      if [ -z \"$SUBNET_OCID\" ]; then\n        exit 0\n      fi\n\n      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri \"https://iaas.${OCI_REGION}.oraclecloud.com/20160918/subnets/$SUBNET_OCID\" 2>/dev/null || true)\n      VCN_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.vcnId // empty')\n      COMPARTMENT_OCID=$(echo \"$SUBNET_JSON\" | jq -r '.data.compartmentId // empty')\n\n      if [ -z \"$VCN_OCID\" ] || [ -z \"$COMPARTMENT_OCID\" ]; then\n        exit 0\n      fi\n\n      TARGET_NSG_OCID=$(oci network nsg list \\\n        --compartment-id \"$COMPARTMENT_OCID\" \\\n        --vcn-id \"$VCN_OCID\" \\\n        --all 2>/dev/null | jq -r '\n          .data[] \n          | select(.[\"display-name\"] | endswith(\"_NSG\")) \n          | select(.[\"display-name\"] | contains(\"BCKP\") | not) \n          | .id\n        ' | head -n 1)\n\n      if [ -z \"$TARGET_NSG_OCID\" ]; then\n        exit 0\n      fi\n\n      RULE_IDS=$(oci network nsg rules list --nsg-id \"$TARGET_NSG_OCID\" --all 2>/dev/null | jq -r --arg cidr \"10.115.0.0/20\" '.data[] | select(.source == $cidr) | .id')\n\n      if [ -n \"$RULE_IDS\" ]; then\n        for id in $RULE_IDS; do\n          oci network nsg rules remove --nsg-id \"$TARGET_NSG_OCID\" --security-rule-ids \"[\\\"$id\\\"]\" --force || true\n        done\n      fi\n"]
null_resource.exascale_configure_and_upload[0]: Destruction complete after 0s
google_storage_bucket_iam_member.bucket_object_admin: Destroying... [id=b/gcp-project-peoplesoft-storage-bucket-a9fb9087/roles/storage.objectAdmin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destroying... [id=gcp-project-peoplesoft/roles/monitoring.metricWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destroying... [id=gcp-project-peoplesoft/roles/iap.tunnelResourceAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destroying... [id=gcp-project-peoplesoft/roles/logging.logWriter/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destroying... [id=gcp-project-peoplesoft/compute.googleapis.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destroying... [id=gcp-project-peoplesoft/roles/iam.serviceAccountUser/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destruction complete after 0s
google_compute_instance.apps: Destroying... [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-peoplesoft-apps]
google_compute_instance.exascale_peoplesoft[0]: Destroying... [id=projects/gcp-project-peoplesoft/zones/northamerica-northeast2-a/instances/oracle-exascale-peoplesoft-app]
google_storage_bucket_iam_member.bucket_object_admin: Destruction complete after 6s
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destroying... [id=gcp-project-peoplesoft/roles/secretmanager.secretAccessor/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
null_resource.exascale_ingress_rules[0]: Still destroying... [id=384734829590778732, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still destroying... [id=gcp-project-peoplesoft/roles/logging.l...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still destroying... [id=gcp-project-peoplesoft/roles/iap.tunne...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still destroying... [id=gcp-project-peoplesoft/roles/iam.servi...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still destroying... [id=gcp-project-peoplesoft/roles/monitorin...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access, 00m10s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...st2-a/instances/oracle-peoplesoft-apps, 00m10s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destruction complete after 15s
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destroying... [id=gcp-project-peoplesoft/iam.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destroying... [id=gcp-project-peoplesoft/storage.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destruction complete after 15s
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destroying... [id=gcp-project-peoplesoft/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destruction complete after 0s
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Destroying... [id=projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destruction complete after 16s
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destroying... [id=gcp-project-peoplesoft/roles/storage.admin/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still destroying... [id=gcp-project-peoplesoft/roles/secretman...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destruction complete after 16s
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Destroying... [id=projects/119724395047/secrets/exadb-ssh-private-key-0162d4cb/versions/1]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destruction complete after 10s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access]
google_secret_manager_secret_version.exadb_private_key_secret_version[0]: Destruction complete after 1s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access]
null_resource.exascale_ingress_rules[0] (local-exec): Usage: oci network nsg rules remove [OPTIONS]

null_resource.exascale_ingress_rules[0] (local-exec): Error: No such option: --force

null_resource.exascale_ingress_rules[0] (local-exec): For OCI CLI commands and parameters suggestion, auto completion and other useful features, try the Interactive mode by typing `oci -i`.
null_resource.exascale_ingress_rules[0]: Still destroying... [id=384734829590778732, 00m20s elapsed]
null_resource.exascale_ingress_rules[0] (local-exec): Usage: oci network nsg rules remove [OPTIONS]

null_resource.exascale_ingress_rules[0] (local-exec): Error: No such option: --force

null_resource.exascale_ingress_rules[0] (local-exec): For OCI CLI commands and parameters suggestion, auto completion and other useful features, try the Interactive mode by typing `oci -i`.
null_resource.exascale_ingress_rules[0]: Destruction complete after 20s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-app-access, 00m20s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in, 00m20s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...st2-a/instances/oracle-peoplesoft-apps, 00m20s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destroying... [id=gcp-project-peoplesoft/roles/compute.instanceAdmin.v1/serviceAccount:ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-app-access"]: Destruction complete after 22s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in]
google_compute_instance.apps: Destruction complete after 23s
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Destroying... [id=gcp-project-peoplesoft/northamerica-northeast2/gcp-project-peoplesoft-network-cloud-router/gcp-project-peoplesoft-nat-01]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-icmp-in, 00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/routes/ps-nat-egress-internet, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still destroying... [id=gcp-project-peoplesoft/roles/storage.a...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-icmp-in"]: Destruction complete after 11s
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destroying... [id=gcp-project-peoplesoft/secretmanager.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in]
module.nat_gateway_route.google_compute_route.route["ps-nat-egress-internet"]: Destruction complete after 11s
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Destroying... [id=gcp-project-peoplesoft-storage-bucket-a9fb9087]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-external-db-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-internal-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-internal-access"]: Destruction complete after 11s
null_resource.exascale_db_provisioning[0]: Destroying... [id=674647006718827274]
null_resource.exascale_db_provisioning[0]: Provisioning with 'local-exec'...
null_resource.exascale_db_provisioning[0] (local-exec): Executing: ["/bin/bash" "-c" "      set -e\n\n      if ! command -v jq &> /dev/null; then\n        exit 0\n      fi\n\n      CLUSTER_URI=\"https://cloud.oracle.com/dbaas/exadb-xs/exadbVmClusters/ocid1.exadbvmcluster.oc1.ca-toronto-1.an2g6ljr33xv2ayaai2rjqri53y6szuhavcxfanbnimgqoc77scp6uceou3q?region=ca-toronto-1&tenant=pytsjosegcp&compartmentId=ocid1.compartment.oc1..aaaaaaaaaexfjapm4xs74xjvtqevggl6gg4hxfauafnblcjk5i3nsrav5rja\"\n      if [ -z \"$CLUSTER_URI\" ]; then\n        exit 0\n      fi\n\n      CLUSTER_OCID=$(echo \"$CLUSTER_URI\" | grep -oE 'ocid1\\.[^/?&]+' | head -1)\n      OCI_REGION=$(echo \"$CLUSTER_OCID\" | cut -d'.' -f4)\n\n      if [ -z \"$CLUSTER_OCID\" ] || [ -z \"$OCI_REGION\" ]; then\n        exit 0\n      fi\n\n      CDB_NAME_RAW=\"PSFTCDB\"\n      DB_NAME_CLEAN=$(echo \"$CDB_NAME_RAW\" | sed 's/[-_]//g')\n\n      DB_LIST=$(oci raw-request --http-method GET --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases?systemId=$CLUSTER_OCID\" 2>/dev/null || true)\n      DB_OCID=$(echo \"$DB_LIST\" | jq -r --arg dbname \"$DB_NAME_CLEAN\" '.data[] | select((.dbName | ascii_downcase) == ($dbname | ascii_downcase)) | .id' | head -1)\n\n      if [ -n \"$DB_OCID\" ] && [ \"$DB_OCID\" != \"null\" ]; then\n        oci raw-request --http-method DELETE --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/databases/$DB_OCID\" 2>/dev/null || true\n        sleep 60\n      fi\n\n      DISPLAY_NAME=\"Home_19c_$CDB_NAME_RAW\"\n      API_URL=\"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbHomes\"\n      LIST_URL=\"$API_URL?vmClusterId=$CLUSTER_OCID&displayName=$DISPLAY_NAME\"\n      LIST_RESULT=$(oci raw-request --http-method GET --target-uri \"$LIST_URL\" 2>/dev/null || true)\n      DB_HOME_OCID=$(echo \"$LIST_RESULT\" | jq -r --arg dname \"$DISPLAY_NAME\" '.data[] | select(.displayName == $dname) | .id' | head -1)\n\n      if [ -n \"$DB_HOME_OCID\" ] && [ \"$DB_HOME_OCID\" != \"null\" ]; then\n        oci raw-request --http-method DELETE --target-uri \"https://database.${OCI_REGION}.oraclecloud.com/20160918/dbHomes/$DB_HOME_OCID\" 2>/dev/null || true\n      fi\n"]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-external-db-access"]: Destruction complete after 13s
google_compute_address.peoplesoft_apps_server_internal_ip: Destroying... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/peoplesoft-apps-server-internal-ip]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destruction complete after 14s
google_compute_address.peoplesoft_apps_server_internal_ip: Destruction complete after 1s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-http-in, 00m30s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 00m30s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destruction complete after 9s
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Destruction complete after 4s
random_id.bucket_suffix: Destroying... [id=qfuQhw]
random_id.bucket_suffix: Destruction complete after 0s
null_resource.exascale_db_provisioning[0] (local-exec): jq: error (at <stdin>:16): Cannot index string with string "dbName"
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-https-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-http-in"]: Destruction complete after 32s
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Still destroying... [id=gcp-project-peoplesoft/northamerica-no...outer/gcp-project-peoplesoft-nat-01, 00m10s elapsed]
null_resource.exascale_db_provisioning[0] (local-exec): jq: error (at <stdin>:16): Cannot index string with string "displayName"
null_resource.exascale_db_provisioning[0]: Destruction complete after 5s
random_password.admin_password[0]: Destroying... [id=none]
random_password.admin_password[0]: Destruction complete after 0s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Destroying... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exadbVmClusters/ps-exadb-vm-cluster-01]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-https-in"]: Destruction complete after 11s
module.cloud_router.google_compute_router_nat.nats["gcp-project-peoplesoft-nat-01"]: Destruction complete after 12s
module.cloud_router.google_compute_router.router: Destroying... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/routers/gcp-project-peoplesoft-network-cloud-router]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Still destroying... [id=projects/gcp-project-peoplesoft/global/firewalls/ps-allow-iap-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["ps-allow-iap-in"]: Destruction complete after 12s
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 00m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 00m10s elapsed]
module.cloud_router.google_compute_router.router: Still destroying... [id=projects/gcp-project-peoplesoft/region...eoplesoft-toolkit-network-cloud-router, 00m10s elapsed]
module.cloud_router.google_compute_router.router: Destruction complete after 13s
google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"]: Destroying... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/gcp-project-peoplesoft-nat-01]
google_compute_address.nat_ip["gcp-project-peoplesoft-nat-01"]: Destruction complete after 2s
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 00m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 00m20s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 00m30s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 00m40s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m20s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 00m50s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m00s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m10s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Still destroying... [id=projects/gcp-project-peoplesoft/zones/...stances/oracle-exascale-peoplesoft-app, 01m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m20s elapsed]
google_compute_instance.exascale_peoplesoft[0]: Destruction complete after 1m56s
google_service_account.project_sa: Destroying... [id=projects/gcp-project-peoplesoft/serviceAccounts/ps-project-service-account@gcp-project-peoplesoft.iam.gserviceaccount.com]
google_compute_address.exascale_peoplesoft_server_internal_ip[0]: Destroying... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/addresses/exascale-peoplesoft-server-internal-ip]
google_secret_manager_secret.exadb_private_key_secret[0]: Destroying... [id=projects/gcp-project-peoplesoft/secrets/exadb-ssh-private-key-0162d4cb]
local_file.exadb_private_key[0]: Destroying... [id=4c5656b68d99192b3fb082e7f695f1250ff1c758]
local_file.exadb_public_key[0]: Destroying... [id=bc82372e4622ecda67e057c3b11f712c2cc178d0]
local_file.exadb_public_key[0]: Destruction complete after 0s
local_file.exadb_private_key[0]: Destruction complete after 0s
google_service_account.project_sa: Destruction complete after 1s
google_compute_address.exascale_peoplesoft_server_internal_ip[0]: Destruction complete after 1s
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Destroying... [id=projects/gcp-project-peoplesoft/regions/northamerica-northeast2/subnetworks/gcp-project-peoplesoft-subnet-01]
google_secret_manager_secret.exadb_private_key_secret[0]: Destruction complete after 3s
random_id.secret_suffix[0]: Destroying... [id=AWLUyw]
random_id.secret_suffix[0]: Destruction complete after 0s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m30s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Still destroying... [id=projects/gcp-project-peoplesoft/region...ks/gcp-project-peoplesoft-subnet-01, 00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["northamerica-northeast2/gcp-project-peoplesoft-subnet-01"]: Destruction complete after 12s
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 01m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 02m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 02m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 02m20s elapsed]
.....
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 27m30s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 27m40s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 27m50s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 28m00s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...exadbVmClusters/ps-exadb-vm-cluster-01, 28m10s elapsed]
google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0]: Destruction complete after 28m14s
google_oracle_database_odb_subnet.client_subnet[0]: Destroying... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-client-subnet]
google_oracle_database_odb_subnet.backup_subnet[0]: Destroying... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network/odbSubnets/gcp-project-peoplesoft-network-backup-subnet]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Destroying... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/exascaleDbStorageVaults/ps-exascale-db-storage-vault]
tls_private_key.exadb_ssh_key[0]: Destroying... [id=b8e3e4877d593f2ca716c101b13782ff0c4bdb89]
tls_private_key.exadb_ssh_key[0]: Destruction complete after 0s
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...ageVaults/ps-exascale-db-storage-vault, 00m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-client-subnet, 00m10s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-backup-subnet, 00m10s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...ageVaults/ps-exascale-db-storage-vault, 00m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-client-subnet, 00m20s elapsed]
google_oracle_database_odb_subnet.backup_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-backup-subnet, 00m20s elapsed]
google_oracle_database_exascale_db_storage_vault.exascale_vault[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...ageVaults/ps-exascale-db-storage-vault, 00m30s elapsed]
.....
google_oracle_database_odb_subnet.client_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-client-subnet, 05m00s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-client-subnet, 05m10s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Still destroying... [id=projects/gcp-project-peoplesoft/locati...oplesoft-toolkit-network-client-subnet, 05m20s elapsed]
google_oracle_database_odb_subnet.client_subnet[0]: Destruction complete after 5m27s
google_oracle_database_odb_network.odb_network[0]: Destroying... [id=projects/gcp-project-peoplesoft/locations/northamerica-northeast2/odbNetworks/gcp-project-peoplesoft-network-odb-network]
google_oracle_database_odb_network.odb_network[0]: Destruction complete after 0s
module.network.module.vpc.google_compute_network.network: Destroying... [id=projects/gcp-project-peoplesoft/global/networks/gcp-project-peoplesoft-network]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/gcp-project-peoplesoft/global...orks/gcp-project-peoplesoft-network, 00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/gcp-project-peoplesoft/global...orks/gcp-project-peoplesoft-network, 00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Destruction complete after 22s

Destroy complete! Resources: 49 destroyed.
[user@machine] oracle-peoplesoft-framework %

```
