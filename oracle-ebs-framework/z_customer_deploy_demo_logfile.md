# Oracle EBS Toolkit on GCP | Oracle EBS Vision Demo logfile output example

This file shows example of exeucing Oracle EBS customer data deployment log and outputs as well as timings and expected resutls


### 1. Setup environment

```bash

[user@desktop] mkdir Code
[user@desktop] cd Code
[user@desktop] Code % git clone https://github.com/company/ebs-infra-framework
[user@desktop] Code % cd ebs-infra-framework

[user@desktop] ebs-infra-framework % git pull
[user@desktop] ebs-infra-framework % ls -l
total 432
-rw-r--r--@ 1 user  staff    7746 Sep  8 14:39 Makefile
drwxr-xr-x@ 3 user  staff      96 Aug 21 16:02 projects
-rw-r--r--@ 1 user  staff    6717 Sep 12 09:57 README-customer-data.md
-rw-r--r--@ 1 user  staff    6105 Sep  3 10:23 README.md
drwxr-xr-x@ 6 user  staff     192 Sep  2 11:20 scripts
-rw-r--r--@ 1 user  staff  196588 Aug 29 14:09 vision_deploy_demo_logfile.md
[user@desktop] ebs-infra-framework % make setup
Running setup...
bash scripts/install.sh
gcloud already exists.
✔ Terraform already installed: 1.13.0
✔ terraform-docs already installed: 0.20.0
All tools installed and configured.
Setup complete.
Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'.
[user@desktop] ebs-infra-framework %


[user@desktop] ebs-infra-framework % make verify-gcp-access
 Verifying GCP access for project: oracle-ebs-toolkit
Access to project oracle-ebs-toolkit confirmed.
 Checking IAM roles for user@domain.com...
 User has Owner/Editor role → skipping fine-grained permission checks.

 GCP access check passed for project: oracle-ebs-toolkit
[user@desktop] ebs-infra-framework %

```

### 2. Authenticate with GCP and configure Application Default Credentials:

```bash
[user@desktop] ebs-infra-framework % gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent.com&....


Credentials saved to file: [/Users/user/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).

Quota project "oracle-ebs-toolkit" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.
[user@desktop] ebs-infra-framework %

```

### 3. Deploy EBS + DB

```bash

[user@desktop] ebs-infra-framework % make init
Checking if backend bucket gs://oracle-ebs-toolkit-479...
Initializing Terraform in projects/oracle-ebs-toolkit...
Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/google-beta from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/google from the dependency lock file
- Using previously-installed hashicorp/google-beta v5.45.2
- Using previously-installed hashicorp/random v3.7.2
- Using previously-installed hashicorp/google v5.45.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Terraform initialized successfully.
[user@desktop] ebs-infra-framework % make plan
terraform -chdir=projects/oracle-ebs-toolkit plan \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com"
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 0s [id=service-000000000000@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.ebs_apps_server_internal_ip[0] will be created
  + resource "google_compute_address" "ebs_apps_server_internal_ip" {
      + address            = "10.115.0.10"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "ebs-apps-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.ebs_db_server_internal_ip[0] will be created
  + resource "google_compute_address" "ebs_db_server_internal_ip" {
      + address            = "10.115.0.20"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "ebs-db-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-ebs-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_instance.apps[0] will be created
  + resource "google_compute_instance" "apps" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "managed-by" = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-standard-4"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-ebs-apps"
      + project              = "oracle-ebs-toolkit"
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
          + "oracle-ebs-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "managed-by" = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image                  = "projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + size                   = 512
              + type                   = "pd-ssd"
            }
        }

      + confidential_instance_config (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_ip                  = "10.115.0.10"
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
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = false
          + enable_vtpm                 = true
        }
    }

  # google_compute_instance.dbs[0] will be created
  + resource "google_compute_instance" "dbs" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "managed-by" = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-standard-8"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-ebs-db"
      + project              = "oracle-ebs-toolkit"
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
          + "managed-by" = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image                  = "projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + size                   = 1024
              + type                   = "pd-standard"
            }
        }

      + confidential_instance_config (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
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
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = false
          + enable_vtpm                 = true
        }
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/storage.admin"
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = (known after apply)
      + id           = (known after apply)
      + member       = (known after apply)
      + name         = (known after apply)
      + project      = "oracle-ebs-toolkit"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = (known after apply)
      + role   = "roles/storage.objectAdmin"
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

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-ebs-toolkit-network-cloud-router"
      + network            = "oracle-ebs-toolkit-network"
      + project            = "oracle-ebs-toolkit"
      + region             = "us-west2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-ebs-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-ebs-toolkit"
      + region                              = "us-west2"
      + router                              = "oracle-ebs-toolkit-network-cloud-router"
      + source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
      + tcp_established_idle_timeout_sec    = 1200
      + tcp_time_wait_timeout_sec           = 120
      + tcp_transitory_idle_timeout_sec     = 30
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
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + location                    = "US-WEST2"
      + name                        = (known after apply)
      + project                     = "oracle-ebs-toolkit"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + autoclass {
          + enabled                = false
          + terminal_storage_class = (known after apply)
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + description            = "Public NAT GW - route through IGW to access internet"
      + dest_range             = "0.0.0.0/0"
      + id                     = (known after apply)
      + name                   = "nat-egress-internet"
      + network                = "oracle-ebs-toolkit-network"
      + next_hop_gateway       = "default-internet-gateway"
      + next_hop_instance_zone = (known after apply)
      + next_hop_ip            = (known after apply)
      + next_hop_network       = (known after apply)
      + priority               = 1000
      + project                = "oracle-ebs-toolkit"
      + self_link              = (known after apply)
      + tags                   = [
          + "egress-nat",
        ]
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"] will be created
  + resource "google_compute_subnetwork" "subnetwork" {
      + creation_timestamp         = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + internal_ipv6_prefix       = (known after apply)
      + ip_cidr_range              = "10.115.0.0/20"
      + ipv6_cidr_range            = (known after apply)
      + name                       = "oracle-ebs-toolkit-subnet-01"
      + network                    = "oracle-ebs-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-ebs-toolkit"
      + purpose                    = (known after apply)
      + region                     = "us-west2"
      + secondary_ip_range         = (known after apply)
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)

      + log_config {
          + aggregation_interval = "INTERVAL_5_SEC"
          + filter_expr          = "true"
          + flow_sampling        = 0.5
          + metadata             = "INCLUDE_ALL_METADATA"
        }
    }

  # module.network.module.vpc.google_compute_network.network will be created
  + resource "google_compute_network" "network" {
      + auto_create_subnetworks                   = false
      + delete_default_routes_on_create           = true
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "oracle-ebs-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-ebs-toolkit"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
[user@desktop] ebs-infra-framework % make deploy
terraform -chdir=projects/oracle-ebs-toolkit apply -auto-approve \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com"
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 0s [id=service-000000000000@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.ebs_apps_server_internal_ip[0] will be created
  + resource "google_compute_address" "ebs_apps_server_internal_ip" {
      + address            = "10.115.0.10"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "ebs-apps-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.ebs_db_server_internal_ip[0] will be created
  + resource "google_compute_address" "ebs_db_server_internal_ip" {
      + address            = "10.115.0.20"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "ebs-db-server-internal-ip"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-ebs-toolkit-subnet-01"
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-ebs-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-ebs-toolkit"
      + purpose            = (known after apply)
      + region             = "us-west2"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + terraform_labels   = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_instance.apps[0] will be created
  + resource "google_compute_instance" "apps" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "managed-by" = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-standard-4"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-ebs-apps"
      + project              = "oracle-ebs-toolkit"
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
          + "oracle-ebs-apps",
        ]
      + tags_fingerprint     = (known after apply)
      + terraform_labels     = {
          + "managed-by" = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image                  = "projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + size                   = 512
              + type                   = "pd-ssd"
            }
        }

      + confidential_instance_config (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
          + network_ip                  = "10.115.0.10"
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
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = false
          + enable_vtpm                 = true
        }
    }

  # google_compute_instance.dbs[0] will be created
  + resource "google_compute_instance" "dbs" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "managed-by" = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "managed-by" = "terraform"
        }
      + machine_type         = "e2-standard-8"
      + metadata             = {
          + "enable-oslogin" = "TRUE"
          + "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        }
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "oracle-ebs-db"
      + project              = "oracle-ebs-toolkit"
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
          + "managed-by" = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image                  = "projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322"
              + labels                 = (known after apply)
              + provisioned_iops       = (known after apply)
              + provisioned_throughput = (known after apply)
              + size                   = 1024
              + type                   = "pd-standard"
            }
        }

      + confidential_instance_config (known after apply)

      + network_interface {
          + internal_ipv6_prefix_length = (known after apply)
          + ipv6_access_type            = (known after apply)
          + ipv6_address                = (known after apply)
          + name                        = (known after apply)
          + network                     = (known after apply)
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
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }

      + shielded_instance_config {
          + enable_integrity_monitoring = true
          + enable_secure_boot          = false
          + enable_vtpm                 = true
        }
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = (known after apply)
      + project = "oracle-ebs-toolkit"
      + role    = "roles/storage.admin"
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = (known after apply)
      + id           = (known after apply)
      + member       = (known after apply)
      + name         = (known after apply)
      + project      = "oracle-ebs-toolkit"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = (known after apply)
      + role   = "roles/storage.objectAdmin"
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

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-ebs-toolkit-network-cloud-router"
      + network            = "oracle-ebs-toolkit-network"
      + project            = "oracle-ebs-toolkit"
      + region             = "us-west2"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-ebs-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-ebs-toolkit"
      + region                              = "us-west2"
      + router                              = "oracle-ebs-toolkit-network-cloud-router"
      + source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
      + tcp_established_idle_timeout_sec    = 1200
      + tcp_time_wait_timeout_sec           = 120
      + tcp_transitory_idle_timeout_sec     = 30
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
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + location                    = "US-WEST2"
      + name                        = (known after apply)
      + project                     = "oracle-ebs-toolkit"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-ebs-toolkit"
        }
      + uniform_bucket_level_access = true
      + url                         = (known after apply)

      + autoclass {
          + enabled                = false
          + terminal_storage_class = (known after apply)
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + project            = "oracle-ebs-toolkit"
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
      + description            = "Public NAT GW - route through IGW to access internet"
      + dest_range             = "0.0.0.0/0"
      + id                     = (known after apply)
      + name                   = "nat-egress-internet"
      + network                = "oracle-ebs-toolkit-network"
      + next_hop_gateway       = "default-internet-gateway"
      + next_hop_instance_zone = (known after apply)
      + next_hop_ip            = (known after apply)
      + next_hop_network       = (known after apply)
      + priority               = 1000
      + project                = "oracle-ebs-toolkit"
      + self_link              = (known after apply)
      + tags                   = [
          + "egress-nat",
        ]
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-ebs-toolkit"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"] will be created
  + resource "google_compute_subnetwork" "subnetwork" {
      + creation_timestamp         = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + internal_ipv6_prefix       = (known after apply)
      + ip_cidr_range              = "10.115.0.0/20"
      + ipv6_cidr_range            = (known after apply)
      + name                       = "oracle-ebs-toolkit-subnet-01"
      + network                    = "oracle-ebs-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-ebs-toolkit"
      + purpose                    = (known after apply)
      + region                     = "us-west2"
      + secondary_ip_range         = (known after apply)
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)

      + log_config {
          + aggregation_interval = "INTERVAL_5_SEC"
          + filter_expr          = "true"
          + flow_sampling        = 0.5
          + metadata             = "INCLUDE_ALL_METADATA"
        }
    }

  # module.network.module.vpc.google_compute_network.network will be created
  + resource "google_compute_network" "network" {
      + auto_create_subnetworks                   = false
      + delete_default_routes_on_create           = true
      + enable_ula_internal_ipv6                  = false
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = 0
      + name                                      = "oracle-ebs-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-ebs-toolkit"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)
random_id.bucket_suffix: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=RpsGJA]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creating...
google_service_account.project_sa: Creating...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creating...
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creating...
module.network.module.vpc.google_compute_network.network: Creating...
module.ebs_storage_bucket.google_storage_bucket.bucket: Creating...
module.ebs_storage_bucket.google_storage_bucket.bucket: Creation complete after 2s [id=oracle-ebs-toolkit-storage-bucket-469b0624]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creation complete after 4s [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/iam.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/compute.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/storage.googleapis.com]
google_service_account.project_sa: Still creating... [00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m10s elapsed]
google_service_account.project_sa: Creation complete after 12s [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creating...
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creating...
google_storage_bucket_iam_member.bucket_object_admin: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creating...
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creating...
google_storage_bucket_iam_member.bucket_object_admin: Creation complete after 7s [id=b/oracle-ebs-toolkit-storage-bucket-469b0624/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creation complete after 9s [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creation complete after 10s [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creation complete after 10s [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Creation complete after 24s [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creation complete after 12s [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Still creating... [00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
google_compute_address.ebs_apps_server_internal_ip[0]: Creating...
google_compute_address.ebs_db_server_internal_ip[0]: Creating...
module.cloud_router.google_compute_router.router: Creating...
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creating...
google_compute_address.ebs_db_server_internal_ip[0]: Still creating... [00m10s elapsed]
google_compute_address.ebs_apps_server_internal_ip[0]: Still creating... [00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router.router: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.cloud_router.google_compute_router.router: Creation complete after 13s [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creating...
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
google_compute_address.ebs_db_server_internal_ip[0]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-db-server-internal-ip]
google_compute_instance.dbs[0]: Creating...
google_compute_address.ebs_apps_server_internal_ip[0]: Creation complete after 13s [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-apps-server-internal-ip]
google_compute_instance.apps[0]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Still creating... [00m10s elapsed]
google_compute_instance.dbs[0]: Still creating... [00m10s elapsed]
google_compute_instance.apps[0]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creation complete after 11s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creation complete after 13s [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_compute_instance.dbs[0]: Creation complete after 15s [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db]
google_compute_instance.apps[0]: Creation complete after 15s [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps]

Apply complete! Resources: 32 added, 0 changed, 0 destroyed.

Outputs:

deployment_summary = <<EOT
=========================================
        Oracle E-Business Suite Setup
=========================================

 Project ID         : oracle-ebs-toolkit
 Region             : us-west2
 Zone               : us-west2-a
 VPC Network        : oracle-ebs-toolkit-network

-----------------------------------------
 Apps Instance
-----------------------------------------
   • Name           : oracle-ebs-apps
   • Internal IP    : 10.115.0.10
   • SSH Command    :
       gcloud compute ssh --zone "us-west2-a" "oracle-ebs-apps" --tunnel-through-iap --project "oracle-ebs-toolkit -- -L 8000:localhost:8000"

-----------------------------------------
 DB Instance
-----------------------------------------
   • Name           : oracle-ebs-db
   • Internal IP    : 10.115.0.20
   • SSH Command    :
       gcloud compute ssh --zone "us-west2-a" "oracle-ebs-db" --tunnel-through-iap --project "oracle-ebs-toolkit"

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : oracle-ebs-toolkit-storage-bucket-469b0624
   • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-469b0624

=========================================
 Summary
-----------------------------------------
   • Total Instances: 2
   • Storage Bucket : oracle-ebs-toolkit-storage-bucket-469b0624
   • Generated At   : 2025-09-16T11:44:31Z
=========================================

EOT
[user@desktop] ebs-infra-framework %

```

### 3.1 Prepare Oracle EBS database to be packed for GCP

```bash
< data at customers>
## PACK Application 

[user@customer_ORALCE ~]$ ls -l
total 20
-rw-r--r--. 1 oracle oinstall 1128 May 12 13:04 05121304.log
-rw-r--r--. 1 oracle oinstall 1128 May 13 06:31 05130631.log
drwxr-xr-x. 2 oracle oinstall   25 Aug 19  2024 bea
lrwxrwxrwx. 1 oracle oinstall   29 Sep 16 07:08 EBSapps.env -> /u01/install/APPS/EBSapps.env
-rw-r--r--. 1 oracle oinstall  891 May 13 15:12 L7786519.log
drwxr-xr-x. 2 oracle oinstall 4096 Aug 20 13:58 logs
drwxr-xr-x. 3 oracle oinstall   18 Aug 19  2024 oradiag_oracle
-rw-r--r--. 1 oracle oinstall 2080 May 12 14:31 prefs.ora
[user@customer_ORALCE ~]$ . EBSapps.env run

  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: db.example.com  Service/SID: EBSDB


  Sourcing the RUN File System ...

[user@customer_ORALCE ~]$ cd $ADMIN_SCRIPTS_HOME
[user@customer_ORALCE scripts]$ ./adpreclone.pl appsTier

                     Copyright (c) 2011, 2014 Oracle Corporation
                        Redwood Shores, California, USA

                        Oracle E-Business Suite Rapid Clone

                                 Version 12.2

                      adpreclone Version 120.31.12020000.28

Enter the APPS User Password:
Enter the Weblogic AdminServer password :

 Checking the status of the Oracle WebLogic Administration Server....

 Running perl /u01/install/APPS/fs1/EBSapps/appl/ad/12.0.0/patch/115/bin/adProvisionEBS.pl ebs-get-serverstatus -contextfile=/u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml -servername=AdminServer -promptmsg=hide

The Oracle WebLogic Administration Server is up.
Enter value for 1: Enter value for 2: Enter value for 3: Connected.

wlsDomainName: EBS_domain
WLS Domain Name is VALID.

Running:
perl /u01/install/APPS/fs1/EBSapps/appl/ad/12.0.0/bin/adclone.pl java=/u01/install/APPS/fs1/EBSapps/comn/util/jdk64 mode=stage stage=/u01/install/APPS/fs1/EBSapps/comn/clone component=appsTier method= appctx=/u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml showProgress



 Setting the wls environment

Beginning application tier Stage - Thu Sep 18 06:47:01 2025

/u01/install/APPS/fs1/EBSapps/comn/util/jdk64/bin/java -Xmx600M -Doracle.jdbc.autoCommitSpecCompliant=false -Doracle.jdbc.DateZeroTime=true -Doracle.jdbc.DateZeroTimeExtra=true -DCONTEXT_VALIDATED=false -Doracle.installer.oui_loc=/oui -classpath /u01/install/APPS/fs1/FMW_Home/webtier/lib/xmlparserv2.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.jdbc_11.1.1/ojdbc6dms.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.odl_11.1.1/ojdl.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.dms_11.1.1/dms.jar::/u01/install/APPS/fs1/EBSapps/comn/java/classes:/u01/install/APPS/fs1/FMW_Home/webtier/oui/jlib/OraInstaller.jar:/u01/install/APPS/fs1/FMW_Home/webtier/oui/jlib/ewt3.jar:/u01/install/APPS/fs1/FMW_Home/webtier/oui/jlib/share.jar:/u01/install/APPS/fs1/FMW_Home/webtier/../Oracle_EBS-app1/oui/jlib/srvm.jar:/u01/install/APPS/fs1/FMW_Home/webtier/jlib/ojmisc.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/weblogic.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/jlib/obfuscatepassword.jar  oracle.apps.ad.clone.StageAppsTier -e /u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml -stage /u01/install/APPS/fs1/EBSapps/comn/clone -tmp /tmp -method CUSTOM   -showProgress -nopromptmsg

Log file located at /u01/install/APPS/fs1/inst/apps/EBSDB_apps/admin/log/clone/StageAppsTier_09180647.log

  \     20% completed
ERROR while running Stage...
Thu Sep 18 06:48:21 2025

ERROR while running perl /u01/install/APPS/fs1/EBSapps/appl/ad/12.0.0/bin/adclone.pl java=/u01/install/APPS/fs1/EBSapps/comn/util/jdk64 mode=stage stage=/u01/install/APPS/fs1/EBSapps/comn/clone component=appsTier method= appctx=/u01/install/APPS/fs1/inst/apps/EBSDB_apps/appl/admin/EBSDB_apps.xml showProgress ...
Thu Sep 18 06:48:21 2025
[user@customer_ORALCE scripts]$ df -Ph
Filesystem                  Size  Used Avail Use% Mounted on
devtmpfs                    7.7G     0  7.7G   0% /dev
tmpfs                       7.7G   36M  7.7G   1% /dev/shm
tmpfs                       7.7G  473M  7.3G   7% /run
tmpfs                       7.7G     0  7.7G   0% /sys/fs/cgroup
/dev/mapper/ocivolume-root  389G  367G   23G  95% /
/dev/mapper/ocivolume-oled   10G  5.2G  4.9G  52% /var/oled
/dev/sda2                  1014M  998M   17M  99% /boot
/dev/sda1                   100M  6.0M   94M   6% /boot/efi
tmpfs                       1.6G     0  1.6G   0% /run/user/54321
tmpfs                       1.6G     0  1.6G   0% /run/user/986
/dev/sdb1                   295G   28K  280G   1% /BACKUP
[user@customer_ORALCE scripts]$ cd /BACKUP/
[user@customer_ORALCE BACKUP]$ time tar -czf EBSFS_TO_GCP.tar.gz -C $(dirname $RUN_BASE) $(basename ${RUN_BASE}) $(basename ${NE_BASE})

real	24m43.398s
user	20m20.077s
sys	2m2.927s
[user@customer_ORALCE BACKUP]$ ls -l
total 20258680
-rw-r--r--. 1 oracle oinstall 20744866317 Sep 18 07:16 EBSFS_TO_GCP.tar.gz
drwx------. 2 root   root           16384 Sep 17 12:02 lost+found
[user@customer_ORALCE BACKUP]$



### Pack DATABASE
[user@customer_ORALCE ~]$ source /u01/install/APPS/19.0.0/EBSCDB_db.env
[user@customer_ORALCE ~]$ env | grep ORA
ORA_NLS10=/u01/install/APPS/19.0.0/nls/data/9idata
ORACLE_SID=EBSCDB
ORACLE_HOME=/u01/install/APPS/19.0.0


[user@customer_ORALCE EBSDB_db]$ cd $ORACLE_HOME/appsutil/scripts/EBSDB_db
[user@customer_ORALCE EBSDB_db]$ if [ -d $ORACLE_HOME/appsutil/clone/dbts ]; then
> echo "DIR exists"
> mv -v $ORACLE_HOME/appsutil/clone/dbts $ORACLE_HOME/appsutil/clone/dbts.$(date +%Y%m%d);
> fi
DIR exists
renamed '/u01/install/APPS/19.0.0/appsutil/clone/dbts' -> '/u01/install/APPS/19.0.0/appsutil/clone/dbts.20250918'

[user@customer_ORALCE EBSDB_db]$ ./adpreclone.pl dbTechStack

                     Copyright (c) 2011, 2014 Oracle Corporation
                        Redwood Shores, California, USA

                        Oracle E-Business Suite Rapid Clone

                                 Version 12.2

                      adpreclone Version 120.31.12020000.28

Enter the APPS User Password:
Verifying if Database Patch checker (ETCC) exists in /u01/install/APPS/19.0.0/appsutil/etcc

Enter value for 1: Enter value for 2: Enter value for 3:
Running:
perl /u01/install/APPS/19.0.0/appsutil/bin/adclone.pl java=/u01/install/APPS/19.0.0/appsutil/jre mode=stage stage=/u01/install/APPS/19.0.0/appsutil/clone component=dbTechStack method=CUSTOM dbctx=/u01/install/APPS/19.0.0/appsutil/EBSDB_db.xml showProgress


Beginning rdbms home Stage - Thu Sep 18 07:29:46 2025

/u01/install/APPS/19.0.0/appsutil/jre/bin/java -Xmx600M -Doracle.jdbc.autoCommitSpecCompliant=false -Doracle.jdbc.DateZeroTime=true -Doracle.jdbc.DateZeroTimeExtra=true -DCONTEXT_VALIDATED=false -Doracle.installer.oui_loc=/u01/install/APPS/19.0.0/oui -classpath /u01/install/APPS/19.0.0/lib/xmlparserv2.jar:/u01/install/APPS/19.0.0/jdbc/lib/ojdbc8.jar::/u01/install/APPS/19.0.0/appsutil/java:/u01/install/APPS/19.0.0/jlib/orai18n.jar:/u01/install/APPS/19.0.0/oui/jlib/OraInstaller.jar:/u01/install/APPS/19.0.0/oui/jlib/ewt3.jar:/u01/install/APPS/19.0.0/oui/jlib/share.jar:/u01/install/APPS/19.0.0/oui/jlib/srvm.jar:/u01/install/APPS/19.0.0/jlib/ojmisc.jar   oracle.apps.ad.clone.StageDBTechStack -e /u01/install/APPS/19.0.0/appsutil/EBSDB_db.xml -stage /u01/install/APPS/19.0.0/appsutil/clone -tmp /tmp -method CUSTOM  -showProgress

Log file located at /u01/install/APPS/19.0.0/appsutil/log/EBSDB_db/StageDBTechStack_09180729.log

  |      0% completed

Completed Stage...
Thu Sep 18 07:29:55 2025

This is a CDB instance. Hence not checking duplicate data files.
[user@customer_ORALCE EBSDB_db]$
[user@customer_ORALCE ~]$ cd //BACKUP/
-rw-r--r--. 1 oracle oinstall 20744866317 Sep 18 07:16 EBSFS_TO_GCP.tar.gz
drwx------. 2 root   root           16384 Sep 17 12:02 lost+found
[user@customer_ORALCE /BACKUP]$ time tar -czf RDBMS_TO_GCP.tar.gz -C $(dirname $ORACLE_HOME) $(basename ${ORACLE_HOME})

real	9m38.399s
user	9m7.492s
sys	0m35.158s
[user@customer_ORALCE /BACKUP]$

[user@customer_ORALCE /BACKUP]$ # start database in mount mode
[user@customer_ORALCE /BACKUP]$ echo "shutdown immediate;" | sqlplus -s / as sysdba
Database closed.
Database dismounted.
ORACLE instance shut down.
[user@customer_ORALCE /BACKUP]$ echo "startup mount" | sqlplus -s / as sysdba
ORA-32004: obsolete or deprecated parameter(s) specified for RDBMS instance
ORACLE instance started.

Total System Global Area 5452592496 bytes
Fixed Size		    9192816 bytes
Variable Size		 2835349504 bytes
Database Buffers	 2382364672 bytes
Redo Buffers		  225685504 bytes
Database mounted.
[user@customer_ORALCE /BACKUP]$ BACKUP_DIR=//BACKUP/RMAN_TO_GCP
[user@customer_ORALCE /BACKUP]$ mkdir -p $BACKUP_DIR
[user@customer_ORALCE /BACKUP]$ cd $BACKUP_DIR
[user@customer_ORALCE RMAN_TO_GCP]$ cd $BACKUP_DIRcd $BACKUP_DIR^C
[user@customer_ORALCE RMAN_TO_GCP]$
[user@customer_ORALCE RMAN_TO_GCP]$ cd $BACKUP_DIR
[user@customer_ORALCE RMAN_TO_GCP]$ pwd
//BACKUP/RMAN_TO_GCP
[user@customer_ORALCE RMAN_TO_GCP]$
[user@customer_ORALCE RMAN_TO_GCP]$ rman target / <<EOF
> RUN {
>     CONFIGURE DEVICE TYPE DISK PARALLELISM 8 BACKUP TYPE TO BACKUPSET;
>     CONFIGURE CHANNEL DEVICE TYPE DISK MAXPIECESIZE 30G;
>
>     BACKUP AS BACKUPSET SPFILE
>         FORMAT '${BACKUP_DIR}/spfile_%d_%T_%U.bkp' TAG='FULL_COLD_SPFILE';
>
>     BACKUP AS BACKUPSET CURRENT CONTROLFILE
>         FORMAT '${BACKUP_DIR}/controlfile_%d_%T_%U.bkp' TAG='FULL_COLD_CONTROL';
>
>     BACKUP AS BACKUPSET DATABASE
>         FORMAT '${BACKUP_DIR}/full_%d_%T_ch%U.bkp' TAG='FULL_COLD_BACKUP';
> }
> EXIT;
> EOF

Recovery Manager: Release 19.0.0.0.0 - Production on Thu Sep 18 07:57:09 2025
Version 19.24.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: EBSCDB (DBID=945244187, not open)

RMAN> 2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 12> 13>
using target database control file instead of recovery catalog
old RMAN configuration parameters:
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET;
new RMAN configuration parameters:
CONFIGURE DEVICE TYPE DISK PARALLELISM 8 BACKUP TYPE TO BACKUPSET;
new RMAN configuration parameters are successfully stored

new RMAN configuration parameters:
CONFIGURE CHANNEL DEVICE TYPE DISK MAXPIECESIZE 30 G;
new RMAN configuration parameters are successfully stored

Starting backup at 18-SEP-25
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=3581 device type=DISK
allocated channel: ORA_DISK_2
channel ORA_DISK_2: SID=1581 device type=DISK
allocated channel: ORA_DISK_3
channel ORA_DISK_3: SID=3582 device type=DISK
allocated channel: ORA_DISK_4
channel ORA_DISK_4: SID=1582 device type=DISK
allocated channel: ORA_DISK_5
channel ORA_DISK_5: SID=3583 device type=DISK
allocated channel: ORA_DISK_6
channel ORA_DISK_6: SID=1583 device type=DISK
allocated channel: ORA_DISK_7
channel ORA_DISK_7: SID=3584 device type=DISK
allocated channel: ORA_DISK_8
channel ORA_DISK_8: SID=1584 device type=DISK
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
including current SPFILE in backup set
channel ORA_DISK_1: starting piece 1 at 18-SEP-25
channel ORA_DISK_1: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/spfile_EBSCDB_20250918_e243vcqu_450_1_1.bkp tag=FULL_COLD_SPFILE comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 18-SEP-25

Starting backup at 18-SEP-25
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4
using channel ORA_DISK_5
using channel ORA_DISK_6
using channel ORA_DISK_7
using channel ORA_DISK_8
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
including current control file in backup set
channel ORA_DISK_1: starting piece 1 at 18-SEP-25
channel ORA_DISK_1: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/controlfile_EBSCDB_20250918_e343vcqv_451_1_1.bkp tag=FULL_COLD_CONTROL comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
Finished backup at 18-SEP-25

Starting backup at 18-SEP-25
using channel ORA_DISK_1
using channel ORA_DISK_2
using channel ORA_DISK_3
using channel ORA_DISK_4
using channel ORA_DISK_5
using channel ORA_DISK_6
using channel ORA_DISK_7
using channel ORA_DISK_8
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00117 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSAUX_FNO-497
input datafile file number=00114 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-494
input datafile file number=00131 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_QUEUES_FNO-511
input datafile file number=00141 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-16
input datafile file number=00150 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-25
input datafile file number=00158 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-33
input datafile file number=00166 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-41
input datafile file number=00174 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-49
input datafile file number=00183 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-58
input datafile file number=00191 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-66
input datafile file number=00199 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-74
input datafile file number=00211 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_UNDOTS1_FNO-86
input datafile file number=00209 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-XDB_FNO-84
input datafile file number=00125 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_MEDIA_FNO-505
channel ORA_DISK_1: starting piece 1 at 18-SEP-25
channel ORA_DISK_2: starting full datafile backup set
channel ORA_DISK_2: specifying datafile(s) in backup set
input datafile file number=00213 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_UNDOTS1_FNO-88
input datafile file number=00106 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-486
input datafile file number=00112 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-492
input datafile file number=00127 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_MEDIA_FNO-507
input datafile file number=00140 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-15
input datafile file number=00148 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-23
input datafile file number=00157 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-32
input datafile file number=00165 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-40
input datafile file number=00173 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-48
input datafile file number=00182 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-57
input datafile file number=00190 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-65
input datafile file number=00198 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-73
input datafile file number=00149 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-24
input datafile file number=00135 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SEED_FNO-10
input datafile file number=00203 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-DCM_FNO-78
channel ORA_DISK_2: starting piece 1 at 18-SEP-25
channel ORA_DISK_3: starting full datafile backup set
channel ORA_DISK_3: specifying datafile(s) in backup set
input datafile file number=00212 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_UNDOTS1_FNO-87
input datafile file number=00105 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-485
input datafile file number=00111 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-491
input datafile file number=00126 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_MEDIA_FNO-506
input datafile file number=00139 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-14
input datafile file number=00147 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-22
input datafile file number=00156 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-31
input datafile file number=00164 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-39
input datafile file number=00172 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-47
input datafile file number=00180 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-55
input datafile file number=00189 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-64
input datafile file number=00197 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-72
input datafile file number=00113 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-493
input datafile file number=00181 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-56
channel ORA_DISK_3: starting piece 1 at 18-SEP-25
channel ORA_DISK_4: starting full datafile backup set
channel ORA_DISK_4: specifying datafile(s) in backup set
input datafile file number=00118 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSAUX_FNO-498
input datafile file number=00115 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-495
input datafile file number=00132 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SEED_FNO-512
input datafile file number=00142 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-17
input datafile file number=00151 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-26
input datafile file number=00159 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-34
input datafile file number=00167 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-42
input datafile file number=00175 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-50
input datafile file number=00184 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-59
input datafile file number=00192 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-67
input datafile file number=00200 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-75
input datafile file number=00137 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-12
input datafile file number=00120 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_OMO_FNO-500
input datafile file number=00205 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-MTR_FNO-80
input datafile file number=00202 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-CTXSYS_FNO-77
channel ORA_DISK_4: starting piece 1 at 18-SEP-25
channel ORA_DISK_5: starting full datafile backup set
channel ORA_DISK_5: specifying datafile(s) in backup set
input datafile file number=00100 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-480
input datafile file number=00104 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-484
input datafile file number=00110 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-490
input datafile file number=00124 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_MEDIA_FNO-504
input datafile file number=00138 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-13
input datafile file number=00146 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-21
input datafile file number=00155 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-30
input datafile file number=00163 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-38
input datafile file number=00171 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-46
input datafile file number=00179 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-54
input datafile file number=00188 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-63
input datafile file number=00196 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-71
input datafile file number=00208 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-OWB_FNO-83
input datafile file number=00207 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-OWB_FNO-82
input datafile file number=00130 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_QUEUES_FNO-510
channel ORA_DISK_5: starting piece 1 at 18-SEP-25
channel ORA_DISK_6: starting full datafile backup set
channel ORA_DISK_6: specifying datafile(s) in backup set
input datafile file number=00097 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-477
input datafile file number=00101 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-481
input datafile file number=00107 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-487
input datafile file number=00116 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-496
input datafile file number=00133 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SEED_FNO-2
input datafile file number=00143 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SUMMARY_FNO-18
input datafile file number=00152 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-27
input datafile file number=00160 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-35
input datafile file number=00168 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-43
input datafile file number=00176 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-51
input datafile file number=00185 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-60
input datafile file number=00193 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-68
input datafile file number=00201 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-76
input datafile file number=00218 name=/u01/install/APPS/data/EBSCDB/ECC_ts_01.dbf
input datafile file number=00204 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-DM_ARCHIVE_FNO-79
channel ORA_DISK_6: starting piece 1 at 18-SEP-25
channel ORA_DISK_7: starting full datafile backup set
channel ORA_DISK_7: specifying datafile(s) in backup set
input datafile file number=00098 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-478
input datafile file number=00102 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-482
input datafile file number=00108 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-488
input datafile file number=00119 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_OMO_FNO-499
input datafile file number=00134 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SEED_FNO-9
input datafile file number=00144 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-19
input datafile file number=00153 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-28
input datafile file number=00161 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-36
input datafile file number=00169 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-44
input datafile file number=00177 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-52
input datafile file number=00186 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-61
input datafile file number=00194 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-69
input datafile file number=00210 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_UNDOTS1_FNO-85
input datafile file number=00122 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_ARCHIVE_FNO-502
input datafile file number=00206 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-ODM_DATA_FNO-81
channel ORA_DISK_7: starting piece 1 at 18-SEP-25
channel ORA_DISK_8: starting full datafile backup set
channel ORA_DISK_8: specifying datafile(s) in backup set
input datafile file number=00099 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-479
input datafile file number=00103 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-483
input datafile file number=00109 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-489
input datafile file number=00121 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_ARCHIVE_FNO-501
input datafile file number=00136 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_SEED_FNO-11
input datafile file number=00145 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-20
input datafile file number=00154 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-29
input datafile file number=00162 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-37
input datafile file number=00170 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_DATA_FNO-45
input datafile file number=00178 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-53
input datafile file number=00187 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-62
input datafile file number=00195 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_TX_IDX_FNO-70
input datafile file number=00123 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_INTERFACE_FNO-503
input datafile file number=00129 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_NOLOGGING_FNO-509
input datafile file number=00128 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-APPS_TS_NOLOGGING_FNO-508
channel ORA_DISK_8: starting piece 1 at 18-SEP-25
channel ORA_DISK_4: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che743vcr5_455_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_4: backup set complete, elapsed time: 00:16:16
channel ORA_DISK_4: starting full datafile backup set
channel ORA_DISK_4: specifying datafile(s) in backup set
input datafile file number=00001 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-1
channel ORA_DISK_4: starting piece 1 at 18-SEP-25
channel ORA_DISK_5: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che843vcr9_456_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_5: backup set complete, elapsed time: 00:16:38
channel ORA_DISK_5: starting full datafile backup set
channel ORA_DISK_5: specifying datafile(s) in backup set
input datafile file number=00003 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSAUX_FNO-3
channel ORA_DISK_5: starting piece 1 at 18-SEP-25
channel ORA_DISK_7: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chea43vcre_458_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_7: backup set complete, elapsed time: 00:17:22
channel ORA_DISK_7: starting full datafile backup set
channel ORA_DISK_7: specifying datafile(s) in backup set
input datafile file number=00005 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSTEM_FNO-5
channel ORA_DISK_7: starting piece 1 at 18-SEP-25
channel ORA_DISK_4: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chec43vdpq_460_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_4: backup set complete, elapsed time: 00:01:13
channel ORA_DISK_4: starting full datafile backup set
channel ORA_DISK_4: specifying datafile(s) in backup set
input datafile file number=00004 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-UNDOTBS1_FNO-4
channel ORA_DISK_4: starting piece 1 at 18-SEP-25
channel ORA_DISK_4: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chef43vds4_463_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_4: backup set complete, elapsed time: 00:00:03
channel ORA_DISK_4: starting full datafile backup set
channel ORA_DISK_4: specifying datafile(s) in backup set
input datafile file number=00215 name=/u01/install/APPS/data/EBSCDB/datafile/o1_mf_cdb_undo_lylt8vo1_.dbf
channel ORA_DISK_4: starting piece 1 at 18-SEP-25
channel ORA_DISK_4: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheg43vds8_464_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_4: backup set complete, elapsed time: 00:00:04
channel ORA_DISK_4: starting full datafile backup set
channel ORA_DISK_4: specifying datafile(s) in backup set
input datafile file number=00006 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-SYSAUX_FNO-6
channel ORA_DISK_4: starting piece 1 at 18-SEP-25
channel ORA_DISK_5: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_ched43vdqn_461_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_5: backup set complete, elapsed time: 00:00:56
channel ORA_DISK_5: starting full datafile backup set
channel ORA_DISK_5: specifying datafile(s) in backup set
input datafile file number=00008 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-UNDOTBS1_FNO-8
channel ORA_DISK_5: starting piece 1 at 18-SEP-25
channel ORA_DISK_1: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che443vcr4_452_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:18:09
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00007 name=/u01/install/APPS/data/EBSCDB/EBSCDB_data_D-EBSCDB_TS-USERS_FNO-7
channel ORA_DISK_1: starting piece 1 at 18-SEP-25
channel ORA_DISK_5: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chei43vdsl_466_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_5: backup set complete, elapsed time: 00:00:15
channel ORA_DISK_7: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chee43vds2_462_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_7: backup set complete, elapsed time: 00:00:34
channel ORA_DISK_1: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chej43vdt5_467_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
channel ORA_DISK_4: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheh43vdsl_465_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_4: backup set complete, elapsed time: 00:00:17
channel ORA_DISK_3: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che643vcr5_454_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_3: backup set complete, elapsed time: 00:18:23
channel ORA_DISK_8: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheb43vcrh_459_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_8: backup set complete, elapsed time: 00:18:29
channel ORA_DISK_2: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che543vcr4_453_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_2: backup set complete, elapsed time: 00:18:53
channel ORA_DISK_6: finished piece 1 at 18-SEP-25
piece handle=//BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che943vcre_457_1_1.bkp tag=FULL_COLD_BACKUP comment=NONE
channel ORA_DISK_6: backup set complete, elapsed time: 00:18:44
Finished backup at 18-SEP-25

Starting Control File and SPFILE Autobackup at 18-SEP-25
piece handle=/u01/install/APPS/19.0.0/dbs/c-945244187-20250918-00 comment=NONE
Finished Control File and SPFILE Autobackup at 18-SEP-25

RMAN>

Recovery Manager complete.
[user@customer_ORALCE RMAN_TO_GCP]$

[user@customer_ORALCE /BACKUP]$ ls -laR

-rw-r--r--.  1 oracle oinstall 20744866317 Sep 18 07:16 EBSFS_TO_GCP.tar.gz
-rw-r--r--.  1 oracle oinstall  7801939953 Sep 18 07:43 RDBMS_TO_GCP.tar.gz
drwxr-xr-x.  2 oracle oinstall        4096 Sep 18 08:15 RMAN_TO_GCP

./RMAN_TO_GCP:
total 128370888
-rw-r-----. 1 oracle oinstall    19955712 Sep 18 07:57 controlfile_EBSCDB_20250918_e343vcqv_451_1_1.bkp
-rw-r-----. 1 oracle oinstall 15402057728 Sep 18 08:15 full_EBSCDB_20250918_che443vcr4_452_1_1.bkp
-rw-r-----. 1 oracle oinstall 17784766464 Sep 18 08:16 full_EBSCDB_20250918_che543vcr4_453_1_1.bkp
-rw-r-----. 1 oracle oinstall 16541376512 Sep 18 08:15 full_EBSCDB_20250918_che643vcr5_454_1_1.bkp
-rw-r-----. 1 oracle oinstall 13535412224 Sep 18 08:13 full_EBSCDB_20250918_che743vcr5_455_1_1.bkp
-rw-r-----. 1 oracle oinstall 14304411648 Sep 18 08:14 full_EBSCDB_20250918_che843vcr9_456_1_1.bkp
-rw-r-----. 1 oracle oinstall 18069651456 Sep 18 08:16 full_EBSCDB_20250918_che943vcre_457_1_1.bkp
-rw-r-----. 1 oracle oinstall 14643732480 Sep 18 08:14 full_EBSCDB_20250918_chea43vcre_458_1_1.bkp
-rw-r-----. 1 oracle oinstall 16575602688 Sep 18 08:15 full_EBSCDB_20250918_cheb43vcrh_459_1_1.bkp
-rw-r-----. 1 oracle oinstall  1774698496 Sep 18 08:14 full_EBSCDB_20250918_chec43vdpq_460_1_1.bkp
-rw-r-----. 1 oracle oinstall  1331445760 Sep 18 08:15 full_EBSCDB_20250918_ched43vdqn_461_1_1.bkp
-rw-r-----. 1 oracle oinstall   933666816 Sep 18 08:15 full_EBSCDB_20250918_chee43vds2_462_1_1.bkp
-rw-r-----. 1 oracle oinstall     1359872 Sep 18 08:15 full_EBSCDB_20250918_chef43vds4_463_1_1.bkp
-rw-r-----. 1 oracle oinstall     1851392 Sep 18 08:15 full_EBSCDB_20250918_cheg43vds8_464_1_1.bkp
-rw-r-----. 1 oracle oinstall   360448000 Sep 18 08:15 full_EBSCDB_20250918_cheh43vdsl_465_1_1.bkp
-rw-r-----. 1 oracle oinstall   165732352 Sep 18 08:15 full_EBSCDB_20250918_chei43vdsl_466_1_1.bkp
-rw-r-----. 1 oracle oinstall     5242880 Sep 18 08:15 full_EBSCDB_20250918_chej43vdt5_467_1_1.bkp
-rw-r-----. 1 oracle oinstall      114688 Sep 18 07:57 spfile_EBSCDB_20250918_e243vcqu_450_1_1.bkp
[user@customer_ORALCE /BACKUP]$

[user@customer_ORALCE RMAN_TO_GCP]$ echo "shutdown immediate;" | sqlplus -s / as sysdba
ORA-01109: database not open


Database dismounted.
ORACLE instance shut down.

### TRANSFER TO GCLOUD
[user@customer_ORALCE ~]$ curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  143M  100  143M    0     0   181M      0 --:--:-- --:--:-- --:--:--  181M
[user@customer_ORALCE ~]$ tar -xf google-cloud-cli-linux-x86_64.tar.gz
[user@customer_ORALCE ~]$ ./google-cloud-sdk/install.sh
Welcome to the Google Cloud CLI!

To help improve the quality of this product, we collect anonymized usage data
and anonymized stacktraces when crashes are encountered; additional information
is available at <https://cloud.google.com/sdk/usage-statistics>. This data is
handled in accordance with our privacy policy
<https://cloud.google.com/terms/cloud-privacy-notice>. You may choose to opt in this
collection now (by choosing 'Y' at the below prompt), or at any time in the
future by running the following command:

    gcloud config set disable_usage_reporting false

Do you want to help improve the Google Cloud CLI (y/N)?  N


Your current Google Cloud CLI version is: 539.0.0
The latest available version is: 539.0.0

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                    Components                                                   │
├───────────────┬──────────────────────────────────────────────────────┬──────────────────────────────┬───────────┤
│     Status    │                         Name                         │              ID              │    Size   │
├───────────────┼──────────────────────────────────────────────────────┼──────────────────────────────┼───────────┤
│ Not Installed │ App Engine Go Extensions                             │ app-engine-go                │   4.7 MiB │
│ Not Installed │ Artifact Registry Go Module Package Helper           │ package-go-module            │   < 1 MiB │
│ Not Installed │ Cloud Bigtable Command Line Tool                     │ cbt                          │  20.5 MiB │
│ Not Installed │ Cloud Bigtable Emulator                              │ bigtable                     │   8.5 MiB │
│ Not Installed │ Cloud Datastore Emulator                             │ cloud-datastore-emulator     │  36.2 MiB │
│ Not Installed │ Cloud Firestore Emulator                             │ cloud-firestore-emulator     │  53.6 MiB │
│ Not Installed │ Cloud Pub/Sub Emulator                               │ pubsub-emulator              │  49.8 MiB │
│ Not Installed │ Cloud Run Proxy                                      │ cloud-run-proxy              │  13.3 MiB │
│ Not Installed │ Cloud SQL Proxy v2                                   │ cloud-sql-proxy              │  15.5 MiB │
│ Not Installed │ Cloud Spanner Emulator                               │ cloud-spanner-emulator       │  37.7 MiB │
│ Not Installed │ Google Container Registry's Docker credential helper │ docker-credential-gcr        │   1.8 MiB │
│ Not Installed │ Kustomize                                            │ kustomize                    │   4.3 MiB │
│ Not Installed │ Log Streaming                                        │ log-streaming                │  18.2 MiB │
│ Not Installed │ Managed Flink Client                                 │ managed-flink-client         │ 383.4 MiB │
│ Not Installed │ Minikube                                             │ minikube                     │  47.7 MiB │
│ Not Installed │ Nomos CLI                                            │ nomos                        │  35.0 MiB │
│ Not Installed │ On-Demand Scanning API extraction helper             │ local-extract                │  31.6 MiB │
│ Not Installed │ Skaffold                                             │ skaffold                     │  33.7 MiB │
│ Not Installed │ Spanner Cli                                          │ spanner-cli                  │  12.6 MiB │
│ Not Installed │ Spanner migration tool                               │ spanner-migration-tool       │  29.4 MiB │
│ Not Installed │ Terraform Tools                                      │ terraform-tools              │  66.6 MiB │
│ Not Installed │ anthos-auth                                          │ anthos-auth                  │  22.0 MiB │
│ Not Installed │ config-connector                                     │ config-connector             │ 133.2 MiB │
│ Not Installed │ enterprise-certificate-proxy                         │ enterprise-certificate-proxy │  10.5 MiB │
│ Not Installed │ gcloud Alpha Commands                                │ alpha                        │   < 1 MiB │
│ Not Installed │ gcloud Beta Commands                                 │ beta                         │   < 1 MiB │
│ Not Installed │ gcloud app Java Extensions                           │ app-engine-java              │ 137.2 MiB │
│ Not Installed │ gcloud app Python Extensions                         │ app-engine-python            │   3.8 MiB │
│ Not Installed │ gcloud app Python Extensions (Extra Libraries)       │ app-engine-python-extras     │   < 1 MiB │
│ Not Installed │ gke-gcloud-auth-plugin                               │ gke-gcloud-auth-plugin       │   3.5 MiB │
│ Not Installed │ istioctl                                             │ istioctl                     │  26.9 MiB │
│ Not Installed │ kpt                                                  │ kpt                          │  15.3 MiB │
│ Not Installed │ kubectl                                              │ kubectl                      │   < 1 MiB │
│ Not Installed │ kubectl-oidc                                         │ kubectl-oidc                 │  22.0 MiB │
│ Not Installed │ pkg                                                  │ pkg                          │           │
│ Installed     │ BigQuery Command Line Tool                           │ bq                           │   1.8 MiB │
│ Installed     │ Bundled Python 3.12                                  │ bundled-python3-unix         │  89.3 MiB │
│ Installed     │ Cloud Storage Command Line Tool                      │ gsutil                       │  12.4 MiB │
│ Installed     │ Google Cloud CLI Core Libraries                      │ core                         │  22.5 MiB │
│ Installed     │ Google Cloud CRC32C Hash Tool                        │ gcloud-crc32c                │   1.5 MiB │
└───────────────┴──────────────────────────────────────────────────────┴──────────────────────────────┴───────────┘
To install or remove components at your current Google Cloud CLI version [539.0.0], run:
  $ gcloud components install COMPONENT_ID
  $ gcloud components remove COMPONENT_ID

To update your Google Cloud CLI installation to the latest version [539.0.0], run:
  $ gcloud components update


Modify profile to update your $PATH and enable shell command completion?

Do you want to continue (Y/n)?

The Google Cloud SDK installer will now prompt you to update an rc file to bring the Google Cloud CLIs into your environment.

Enter a path to an rc file to update, or leave blank to use [/home/oracle/.bashrc]:
Backing up [/home/oracle/.bashrc] to [/home/oracle/.bashrc.backup].
[/home/oracle/.bashrc] has been updated.

==> Start a new shell for the changes to take effect.


For more information on how to get started, please visit:
  https://cloud.google.com/sdk/docs/quickstarts


[user@customer_ORALCE ~]$ ./google-cloud-sdk/bin/gcloud init
Welcome! This command will take you through the configuration of gcloud.

Your current configuration has been set to: [default]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.
Reachability Check passed.
Network diagnostic passed (1/1 checks passed).

You must sign in to continue. Would you like to sign in (Y/n)?  Y

Go to the following link in your browser, and complete the sign-in prompts:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=32****

Once finished, enter the verification code provided in your browser: 4/0AVGzR1D****
You are signed in as: [saldabols@pythian.com].

Pick cloud project to use:
 ...
 [32] oracle-ebs-toolkit
 ...
Please enter numeric choice or text value (must exactly match list item):  32

Your current project has been set to: [oracle-ebs-toolkit].

Not setting default zone/region (this feature makes it easier to use
[gcloud compute] by setting an appropriate default value for the
--zone and --region flag).
See https://cloud.google.com/compute/docs/gcloud-compute section on how to set
default compute region and zone manually. If you would like [gcloud init] to be
able to do this for you the next time you run it, make sure the
Compute Engine API is enabled for your project on the
https://console.developers.google.com/apis page.

Created a default .boto configuration file at [/home/oracle/.boto]. See this file and
[https://cloud.google.com/storage/docs/gsutil/commands/config] for more
information about configuring Google Cloud Storage.
The Google Cloud CLI is configured and ready to use!

* Commands that require authentication will use saldabols@pythian.com by default
* Commands will reference project `fitbit-cicd-artifact-dr-1` by default
Run `gcloud help config` to learn how to change individual settings

This gcloud configuration is called [default]. You can create additional configurations if you work with multiple accounts and/or projects.
Run `gcloud topic configurations` to learn more.

Some things to try next:

* Run `gcloud --help` to see the Cloud Platform services you can interact with. And run `gcloud help COMMAND` to get help on any gcloud command.
* Run `gcloud topic --help` to learn about advanced features of the CLI like arg files and output formatting
* Run `gcloud cheat-sheet` to see a roster of go-to `gcloud` commands.
[user@customer_ORALCE ~]$

[user@customer_ORALCE ~]$ ./google-cloud-sdk/bin/gcloud storage cp -r //BACKUP/* gs://ebs-toolkit-bucket1/12214/
WARNING: Parallel composite upload was turned ON to get the best performance on
uploading large objects. If you would like to opt-out and instead
perform a normal upload, run:
`gcloud config set storage/parallel_composite_upload_enabled False`
If you would like to disable this warning, run:
`gcloud config set storage/parallel_composite_upload_enabled True`
Note that with parallel composite uploads, your object might be
uploaded as a composite object
(https://cloud.google.com/storage/docs/composite-objects), which means
that any user who downloads your object will need to use crc32c
checksums to verify data integrity. gcloud storage is capable of
computing crc32c checksums, but this might pose a problem for other
clients.

Copying file:////BACKUP/EBSFS_TO_GCP.tar.gz to gs://ebs-toolkit-bucket1/12214/EBSFS_TO_GCP.tar.gz
Copying file:////BACKUP/RDBMS_TO_GCP.tar.gz to gs://ebs-toolkit-bucket1/12214/RDBMS_TO_GCP.tar.gz
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che843vcr9_456_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che843vcr9_456_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chei43vdsl_466_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chei43vdsl_466_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chea43vcre_458_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chea43vcre_458_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che443vcr4_452_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che443vcr4_452_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_ched43vdqn_461_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_ched43vdqn_461_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/spfile_EBSCDB_20250918_e243vcqu_450_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/spfile_EBSCDB_20250918_e243vcqu_450_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chef43vds4_463_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chef43vds4_463_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheh43vdsl_465_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_cheh43vdsl_465_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che643vcr5_454_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che643vcr5_454_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/controlfile_EBSCDB_20250918_e343vcqv_451_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/controlfile_EBSCDB_20250918_e343vcqv_451_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheg43vds8_464_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_cheg43vds8_464_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chee43vds2_462_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chee43vds2_462_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che743vcr5_455_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che743vcr5_455_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che543vcr4_453_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che543vcr4_453_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_cheb43vcrh_459_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_cheb43vcrh_459_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_che943vcre_457_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_che943vcre_457_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chec43vdpq_460_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chec43vdpq_460_1_1.bkp
Copying file:////BACKUP/RMAN_TO_GCP/full_EBSCDB_20250918_chej43vdt5_467_1_1.bkp to gs://ebs-toolkit-bucket1/12214/RMAN_TO_GCP/full_EBSCDB_20250918_chej43vdt5_467_1_1.bkp
                                                                                                                                                                                                                                                                                                                                                                              Co
Average throughput: 112.9MiB/s
[user@customer_ORALCE ~]$


<expecting this results once put on bucket>

user@cloudshell:~ (oracle-ebs-toolkit)$ gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-469b0624
gs://oracle-ebs-toolkit-storage-bucket-469b0624/EBSFS_TO_GCP.tar.gz
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RDBMS_TO_GCP.tar.gz
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/
user@cloudshell:~ (oracle-ebs-toolkit)$ gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/controlfile_EBSCDB_20250820_1r41j7gq_59_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp
gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp
user@cloudshell:~ (oracle-ebs-toolkit)$ 

```

### 4 Deploy Oracle EBS environment

```bash

[user@desktop] ebs-infra-framework % make deploy_oracle_ebs_scripts

>>> Creating /scripts on oracle-ebs-db
gcloud compute ssh --zone "us-west2-a" "oracle-ebs-db" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

Warning: Permanently added 'compute.1789770921786274685' (ED25519) to the list of known hosts.
mkdir: created directory '/scripts'
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

>>> Copying /scripts/* to oracle-ebs-db
gcloud compute scp --tunnel-through-iap --zone=us-west2-a --project=oracle-ebs-toolkit \
	scripts/ebs/* oracle-ebs-db:/scripts
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

EBSDB_oracle-ebs-db.xml                                      100%   15KB  68.6KB/s   00:00
environment                                                  100%  559     3.1KB/s   00:00
funct.sh                                                     100%   21KB  86.2KB/s   00:00
initEBSCDB.ora                                               100% 4362    24.0KB/s   00:00
listener.ora                                                 100%  938     5.3KB/s   00:00
rman_restore.rman                                            100% 1458     8.3KB/s   00:00

>>> Creating /scripts on oracle-ebs-apps
gcloud compute ssh --zone "us-west2-a" "oracle-ebs-apps" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

Warning: Permanently added 'compute.2669332386661331836' (ED25519) to the list of known hosts.
mkdir: created directory '/scripts'
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

>>> Copying /scripts/* to oracle-ebs-apps
gcloud compute scp --tunnel-through-iap --zone=us-west2-a --project=oracle-ebs-toolkit \
	scripts/ebs/* oracle-ebs-apps:/scripts
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

EBSDB_oracle-ebs-db.xml                                      100%   15KB  65.7KB/s   00:00
environment                                                  100%  559     3.2KB/s   00:00
funct.sh                                                     100%   21KB  85.1KB/s   00:00
initEBSCDB.ora                                               100% 4362    24.0KB/s   00:00
listener.ora                                                 100%  938     5.4KB/s   00:00
rman_restore.rman                                            100% 1458     8.3KB/s   00:00
[user@desktop] ebs-infra-framework %

```

### 5.1 Configure Oracle EBS RDBMS on provisioned infrastructure

```bash

# Execute root activities as functions
[root@oracle-ebs-db ~]#  source /scripts/funct.sh
[root@oracle-ebs-db ~]# rdbms_root_init
Tue Sep 16 12:05:16 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_root_init
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------

### Creating Directories
/home/oracle/scripts already exists
/home/oracle/scripts/logs already exists
Created /backup and set owner to oracle:oinstall
Created /u01/app/oracle/oraInventory and set owner to oracle:oinstall
Created /u01/app/oracle/admin and set owner to oracle:oinstall
Created /u01/oradata/EBSDB/arch and set owner to oracle:oinstall
Created /u01/app/oracle/product/dbhome_1 and set owner to oracle:oinstall
Created /u01/app/oracle/temp/EBSDB and set owner to oracle:oinstall

### Stage Scripts to Oracle user
'/scripts/EBSDB_oracle-ebs-db.xml' -> '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml'
'/scripts/environment' -> '/home/oracle/scripts/environment'
'/scripts/funct.sh' -> '/home/oracle/scripts/funct.sh'
'/scripts/initEBSCDB.ora' -> '/home/oracle/scripts/initEBSCDB.ora'
'/scripts/listener.ora' -> '/home/oracle/scripts/listener.ora'
'/scripts/rman_restore.rman' -> '/home/oracle/scripts/rman_restore.rman'
changed ownership of '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/environment' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/funct.sh' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/initEBSCDB.ora' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/listener.ora' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/logs/20250916_120516_rdbms_root_init.log' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/logs' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/rman_restore.rman' from root:root to oracle:oinstall

### Creating /etc/oraInst.loc
-rw-r--r--. 1 root root 69 Sep 16 12:05 /etc/oraInst.loc

inventory_loc=/u01/app/oracle/oraInventory
inst_group=dba


### Ownerships
chown: cannot access '/backup/*': No such file or directory
failed to change ownership of '/backup/*' to oracle:oinstall
ownership of '/u01/app/oracle/oraInventory' retained as oracle:oinstall
ownership of '/u01/app/oracle/admin' retained as oracle:oinstall
ownership of '/u01/app/oracle/product/dbhome_1' retained as oracle:oinstall
changed ownership of '/u01/app/oracle/product' from root:root to oracle:oinstall
ownership of '/u01/app/oracle/temp/EBSDB' retained as oracle:oinstall
changed ownership of '/u01/app/oracle/temp' from root:root to oracle:oinstall
changed ownership of '/u01/app/oracle' from root:root to oracle:oinstall
changed ownership of '/u01/app' from root:root to oracle:oinstall
ownership of '/u01/oradata/EBSDB/arch' retained as oracle:oinstall
changed ownership of '/u01/oradata/EBSDB' from root:root to oracle:oinstall
changed ownership of '/u01/oradata' from root:root to oracle:oinstall
ownership of '/home/oracle/scripts/logs/20250916_120516_rdbms_root_init.log' retained as oracle:oinstall
ownership of '/home/oracle/scripts/logs' retained as oracle:oinstall
ownership of '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml' retained as oracle:oinstall
ownership of '/home/oracle/scripts/environment' retained as oracle:oinstall
ownership of '/home/oracle/scripts/funct.sh' retained as oracle:oinstall
ownership of '/home/oracle/scripts/initEBSCDB.ora' retained as oracle:oinstall
ownership of '/home/oracle/scripts/listener.ora' retained as oracle:oinstall
ownership of '/home/oracle/scripts/rman_restore.rman' retained as oracle:oinstall
changed ownership of '/home/oracle/scripts' from root:root to oracle:oinstall

log: /home/oracle/scripts/logs/20250916_120516_rdbms_root_init.log
Tue Sep 16 12:05:16 UTC 2025

```

# stage backup

```bash

[root@oracle-ebs-db ~]#
# Swtich to OS user Oracle and execute below functions (preferabley from TMUX session)
sudo su - oracle

[oracle@oracle-ebs-db ~]$ rdbms_stage_backup
Tue Sep 16 12:06:03 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_stage_backup
         =========================================
         Function copies data from bucket (gs://oracle-ebs-toolkit-storage-bucket-469b0624/) to  /backup for furhter processing
         -----------------------------------------

### Stage RDBMS Software backup
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RDBMS_TO_GCP.tar.gz to file:///backup/RDBMS_TO_GCP.tar.gz

.........................

Average throughput: 1.2GiB/s

real	0m6.158s
user	0m11.515s
sys	0m22.226s

### Stage RMAN cold backup: Note: time comsuming step - depends on backups
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/controlfile_EBSCDB_20250820_1r41j7gq_59_1_1.bkp to file:///backup/RMAN_TO_GCP/controlfile_EBSCDB_20250820_1r41j7gq_59_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp

Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp to file:///backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/RMAN_TO_GCP/spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp to file:///backup/RMAN_TO_GCP/spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp
................................................................................................................................................................................................

Average throughput: 124.4MiB/s

real	14m45.919s
user	6m1.391s
sys	6m26.523s

log: /home/oracle/scripts/logs/20250916_120603_rdbms_stage_backup.log
Tue Sep 16 12:20:55 UTC 2025
[oracle@oracle-ebs-db ~]$

```

# Configure Oracle Home

```bash

# Configure Oracle home
[oracle@oracle-ebs-db ~]$ rdbms_stage_oh
Tue Sep 16 12:21:54 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_stage_oh
         =========================================
         Function restores RDBMS HOME from backup
         -----------------------------------------

### Extract RDBMS Software from /backup/
RDBMS backup   : /backup/RDBMS_TO_GCP.tar.gz
Oracle Home    : /u01/app/oracle/product/dbhome_1
Old home base  : 19.0.0/
Extracting non-verbose: (few mins)

real	1m52.852s
user	1m16.204s
sys	0m31.694s
mv: cannot move '/u01/app/oracle/product/19.0.0/.' to '/u01/app/oracle/product/dbhome_1/.': Device or resource busy
mv: '/u01/app/oracle/product/19.0.0/..' and '/u01/app/oracle/product/dbhome_1/..' are the same file
rmdir: removing directory, '/u01/app/oracle/product/19.0.0'
drwxr-xr-x. 73 oracle oinstall 4096 Sep 16 12:23 /u01/app/oracle/product/dbhome_1
total 104
drwxr-xr-x. 73 oracle oinstall  4096 Sep 16 12:23 .
drwxr-xr-x.  3 oracle oinstall    22 Sep 16 12:23 ..
drwxr-xr-x.  2 oracle oinstall   102 Aug 15 12:43 addnode
drwxr-xr-x.  4 oracle oinstall    38 Aug 15 12:43 admin
drwxr-xr-x.  5 oracle oinstall  4096 Aug 15 12:43 apex
drwxr-xr-x. 20 oracle oinstall  4096 Aug 15 12:43 appsutil
drwxr-xr-x.  9 oracle oinstall    93 Aug 15 12:43 assistants
drwxr-xr-x.  2 oracle oinstall  8192 Aug 15 12:43 bin
drwxr-xr-x.  5 oracle oinstall    44 Aug 15 12:43 cfgtoollogs
..

### Configurting RDBMS HOME - relink
writing relink log to: /u01/app/oracle/product/dbhome_1/install/relinkActions2025-09-16_12-23-47PM.log

### Backing up existing TNS and dbs
mv: target '/u01/app/oracle/product/dbhome_1/network/admin/listener.ora.2025-09-16' is not a directory
mv: target '/u01/app/oracle/product/dbhome_1/network/admin/sqlnet.ora.2025-09-16' is not a directory
mv: target '/u01/app/oracle/product/dbhome_1/network/admin/tnsnames.ora.2025-09-16' is not a directory
'/home/oracle/scripts/initEBSCDB.ora' -> '/u01/app/oracle/product/dbhome_1/dbs/initEBSCDB.ora'
'/home/oracle/scripts/listener.ora' -> '/u01/app/oracle/product/dbhome_1/network/admin/listener.ora'

### Startup nomount EBSCBD & listener

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 16-SEP-2025 12:24:33

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Starting /u01/app/oracle/product/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u01/app/oracle/product/dbhome_1/network/admin/listener.ora
Log messages written to /u01/app/oracle/diag/tnslsnr/oracle-ebs-db/ebscdb/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-ebs-db)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                16-SEP-2025 12:24:43
Uptime                    0 days 0 hr. 0 min. 9 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/dbhome_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle-ebs-db/ebscdb/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal)(PORT=1521)))
The listener supports no services
The command completed successfully

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Sep 16 12:24:43 2025
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORA-32004: obsolete or deprecated parameter(s) specified for RDBMS instance
ORACLE instance started.

Total System Global Area 1.6106E+10 bytes
Fixed Size		   13901248 bytes
Variable Size		  536870912 bytes
Database Buffers	 1.5536E+10 bytes
Redo Buffers		   19652608 bytes
SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0

INSTANCE_NAME    HOST_NAME                                                        VERSION_FULL      STARTUP_T STATUS
---------------- ---------------------------------------------------------------- ----------------- --------- ------------
EBSCDB           oracle-ebs-db                                                    19.18.0.0.0       16-SEP-25 STARTED


log: /home/oracle/scripts/logs/20250916_122154_rdbms_stage_oh.log
Tue Sep 16 12:24:55 UTC 2025
[oracle@oracle-ebs-db ~]$

```
# Restore the database 

Use tmux session to avoid network interupts to ssh

```bash

# Restore the database - use tmux session to avoid network interupts to ssh
[oracle@oracle-ebs-db ~]$ tmux -L longjobs
[oracle@oracle-ebs-db ~]$ time rdbms_rman_restore
Tue Sep 16 12:29:58 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT FUNCTION: rdbms_rman_restore
         =========================================
         Function to restore database - time consuming step
         -----------------------------------------

### RMAN: Restoring database from Backup location
total 112651544
-rw-r--r--. 1 oracle oinstall    20414464 Sep 16 12:06 controlfile_EBSCDB_20250820_1r41j7gq_59_1_1.bkp
-rw-r--r--. 1 oracle oinstall 16865206272 Sep 16 12:20 full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp
-rw-r--r--. 1 oracle oinstall 19796369408 Sep 16 12:20 full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp
-rw-r--r--. 1 oracle oinstall 19319119872 Sep 16 12:20 full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp
-rw-r--r--. 1 oracle oinstall 16408010752 Sep 16 12:19 full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp
-rw-r--r--. 1 oracle oinstall 19594862592 Sep 16 12:20 full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp
-rw-r--r--. 1 oracle oinstall 20058210304 Sep 16 12:20 full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp
-rw-r--r--. 1 oracle oinstall  1152311296 Sep 16 12:07 full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp
-rw-r--r--. 1 oracle oinstall  1033715712 Sep 16 12:07 full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp
-rw-r--r--. 1 oracle oinstall     1564672 Sep 16 12:06 full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp
-rw-r--r--. 1 oracle oinstall   478666752 Sep 16 12:07 full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp
-rw-r--r--. 1 oracle oinstall   378003456 Sep 16 12:07 full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp
-rw-r--r--. 1 oracle oinstall   243326976 Sep 16 12:06 full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp
-rw-r--r--. 1 oracle oinstall     5242880 Sep 16 12:06 full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp
-rw-r--r--. 1 oracle oinstall      114688 Sep 16 12:06 spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp

Recovery Manager: Release 19.0.0.0.0 - Production on Tue Sep 16 12:29:59 2025
Version 19.18.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to auxiliary database: EBSCDB (not mounted)

RMAN> run
2> {
3>   ALLOCATE auxiliary CHANNEL c1 DEVICE TYPE DISK;
4>   ALLOCATE auxiliary CHANNEL c2 DEVICE TYPE DISK;
5>   ALLOCATE auxiliary CHANNEL c3 DEVICE TYPE DISK;
6>   ALLOCATE auxiliary CHANNEL c4 DEVICE TYPE DISK;
7>   ALLOCATE auxiliary CHANNEL c5 DEVICE TYPE DISK;
8>   ALLOCATE auxiliary CHANNEL c6 DEVICE TYPE DISK;
9>   ALLOCATE auxiliary CHANNEL c7 DEVICE TYPE DISK;
10>   ALLOCATE auxiliary CHANNEL c8 DEVICE TYPE DISK;
11>   ALLOCATE auxiliary CHANNEL c9 DEVICE TYPE DISK;
12>   ALLOCATE auxiliary CHANNEL c10 DEVICE TYPE DISK;
13>
14>   duplicate database to EBSCDB
15>   spfile
16>   set db_unique_name 'EBSCDB'
17>   set control_files '/u01/oradata/EBSCDB/control01.ctl','/u01/oradata/EBSCDB/control02.ctl'
18>   set db_create_file_dest '/u01/oradata'
19>   set db_recovery_file_dest '/u01/oradata/EBSCDB/arch'
20>   set db_recovery_file_dest_size '200G'
21>   set audit_file_dest '/u01/app/oracle/admin'
22>   set core_dump_dest='/u01/app/oracle'
23>   set diagnostic_dest '/u01/app/oracle'
24>   set pga_aggregate_target '2g'
25>   set sga_target '15g'
26>   set sessions '1600'
27>   set processes '800'
28>   set shared_pool_reserved_size '40M'
29>   set shared_pool_size '400M'
30>   set result_cache_max_size '300M'
31>   set local_listener 'oracle-ebs-db:1521'
32>   backup location '/backup/RMAN_TO_GCP/'
33>   NOFILENAMECHECK;
34>
35>   RELEASE CHANNEL c1;
36>   RELEASE CHANNEL c2;
37>   RELEASE CHANNEL c3;
38>   RELEASE CHANNEL c4;
39>   RELEASE CHANNEL c5;
40>   RELEASE CHANNEL c6;
41>   RELEASE CHANNEL c7;
42>   RELEASE CHANNEL c8;
43>   RELEASE CHANNEL c9;
44>   RELEASE CHANNEL c10;
45> }
46>
allocated channel: c1
channel c1: SID=506 device type=DISK

allocated channel: c2
channel c2: SID=605 device type=DISK

allocated channel: c3
channel c3: SID=701 device type=DISK

allocated channel: c4
channel c4: SID=6 device type=DISK

allocated channel: c5
channel c5: SID=104 device type=DISK

allocated channel: c6
channel c6: SID=205 device type=DISK

allocated channel: c7
channel c7: SID=307 device type=DISK

allocated channel: c8
channel c8: SID=406 device type=DISK

allocated channel: c9
channel c9: SID=507 device type=DISK

allocated channel: c10
channel c10: SID=606 device type=DISK

Starting Duplicate Db at 16-SEP-25
searching for database ID
found backup of database ID 1034752545

contents of Memory Script:
{
   restore clone spfile to  '/u01/app/oracle/product/dbhome_1/dbs/spfileEBSCDB.ora' from
 '/backup/RMAN_TO_GCP/spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp';
   sql clone "alter system set spfile= ''/u01/app/oracle/product/dbhome_1/dbs/spfileEBSCDB.ora''";
}
executing Memory Script

Starting restore at 16-SEP-25

channel c2: skipped, AUTOBACKUP already found
channel c3: skipped, AUTOBACKUP already found
channel c4: skipped, AUTOBACKUP already found
channel c5: skipped, AUTOBACKUP already found
channel c6: skipped, AUTOBACKUP already found
channel c7: skipped, AUTOBACKUP already found
channel c8: skipped, AUTOBACKUP already found
channel c9: skipped, AUTOBACKUP already found
channel c10: skipped, AUTOBACKUP already found
channel c1: restoring spfile from AUTOBACKUP /backup/RMAN_TO_GCP/spfile_EBSCDB_20250820_1q41j7gp_58_1_1.bkp
channel c1: SPFILE restore from AUTOBACKUP complete
Finished restore at 16-SEP-25

sql statement: alter system set spfile= ''/u01/app/oracle/product/dbhome_1/dbs/spfileEBSCDB.ora''

contents of Memory Script:
{
   sql clone "alter system set  db_name =
 ''EBSCDB'' comment=
 ''duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name =
 ''EBSCDB'' comment=
 '''' scope=spfile";
   sql clone "alter system set  control_files =
 ''/u01/oradata/EBSCDB/control01.ctl'', ''/u01/oradata/EBSCDB/control02.ctl'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_create_file_dest =
 ''/u01/oradata'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_recovery_file_dest =
 ''/u01/oradata/EBSCDB/arch'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_recovery_file_dest_size =
 200G comment=
 '''' scope=spfile";
   sql clone "alter system set  audit_file_dest =
 ''/u01/app/oracle/admin'' comment=
 '''' scope=spfile";
   sql clone "alter system set  core_dump_dest =
 ''/u01/app/oracle'' comment=
 '''' scope=spfile";
   sql clone "alter system set  diagnostic_dest =
 ''/u01/app/oracle'' comment=
 '''' scope=spfile";
   sql clone "alter system set  pga_aggregate_target =
 2g comment=
 '''' scope=spfile";
   sql clone "alter system set  sga_target =
 15g comment=
 '''' scope=spfile";
   sql clone "alter system set  sessions =
 1600 comment=
 '''' scope=spfile";
   sql clone "alter system set  processes =
 800 comment=
 '''' scope=spfile";
   sql clone "alter system set  shared_pool_reserved_size =
 40M comment=
 '''' scope=spfile";
   sql clone "alter system set  shared_pool_size =
 400M comment=
 '''' scope=spfile";
   sql clone "alter system set  result_cache_max_size =
 300M comment=
 '''' scope=spfile";
   sql clone "alter system set  local_listener =
 ''oracle-ebs-db:1521'' comment=
 '''' scope=spfile";
   shutdown clone immediate;
   startup clone nomount;
}
executing Memory Script

sql statement: alter system set  db_name =  ''EBSCDB'' comment= ''duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''EBSCDB'' comment= '''' scope=spfile

sql statement: alter system set  control_files =  ''/u01/oradata/EBSCDB/control01.ctl'', ''/u01/oradata/EBSCDB/control02.ctl'' comment= '''' scope=spfile

sql statement: alter system set  db_create_file_dest =  ''/u01/oradata'' comment= '''' scope=spfile

sql statement: alter system set  db_recovery_file_dest =  ''/u01/oradata/EBSCDB/arch'' comment= '''' scope=spfile

sql statement: alter system set  db_recovery_file_dest_size =  200G comment= '''' scope=spfile

sql statement: alter system set  audit_file_dest =  ''/u01/app/oracle/admin'' comment= '''' scope=spfile

sql statement: alter system set  core_dump_dest =  ''/u01/app/oracle'' comment= '''' scope=spfile

sql statement: alter system set  diagnostic_dest =  ''/u01/app/oracle'' comment= '''' scope=spfile

sql statement: alter system set  pga_aggregate_target =  2g comment= '''' scope=spfile

sql statement: alter system set  sga_target =  15g comment= '''' scope=spfile

sql statement: alter system set  sessions =  1600 comment= '''' scope=spfile

sql statement: alter system set  processes =  800 comment= '''' scope=spfile

sql statement: alter system set  shared_pool_reserved_size =  40M comment= '''' scope=spfile

sql statement: alter system set  shared_pool_size =  400M comment= '''' scope=spfile

sql statement: alter system set  result_cache_max_size =  300M comment= '''' scope=spfile

sql statement: alter system set  local_listener =  ''oracle-ebs-db:1521'' comment= '''' scope=spfile

Oracle instance shut down

connected to auxiliary database (not started)
Oracle instance started

Total System Global Area   16106123488 bytes

Fixed Size                    13902048 bytes
Variable Size               1409286144 bytes
Database Buffers           14663286784 bytes
Redo Buffers                  19648512 bytes
allocated channel: c1
channel c1: SID=1205 device type=DISK
allocated channel: c2
channel c2: SID=1401 device type=DISK
allocated channel: c3
channel c3: SID=5 device type=DISK
allocated channel: c4
channel c4: SID=204 device type=DISK
allocated channel: c5
channel c5: SID=405 device type=DISK
allocated channel: c6
channel c6: SID=607 device type=DISK
allocated channel: c7
channel c7: SID=806 device type=DISK
allocated channel: c8
channel c8: SID=1007 device type=DISK
allocated channel: c9
channel c9: SID=1206 device type=DISK
allocated channel: c10
channel c10: SID=1406 device type=DISK

contents of Memory Script:
{
   sql clone "alter system set  db_name =
 ''EBSCDB'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name =
 ''EBSCDB'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   shutdown clone immediate;
   startup clone force nomount
   restore clone primary controlfile from  '/backup/RMAN_TO_GCP/controlfile_EBSCDB_20250820_1r41j7gq_59_1_1.bkp';
   alter clone database mount;
}
executing Memory Script

sql statement: alter system set  db_name =  ''EBSCDB'' comment= ''Modified by RMAN duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''EBSCDB'' comment= ''Modified by RMAN duplicate'' scope=spfile

Oracle instance shut down

Oracle instance started

Total System Global Area   16106123488 bytes

Fixed Size                    13902048 bytes
Variable Size               1409286144 bytes
Database Buffers           14663286784 bytes
Redo Buffers                  19648512 bytes
allocated channel: c1
channel c1: SID=1205 device type=DISK
allocated channel: c2
channel c2: SID=1401 device type=DISK
allocated channel: c3
channel c3: SID=5 device type=DISK
allocated channel: c4
channel c4: SID=204 device type=DISK
allocated channel: c5
channel c5: SID=405 device type=DISK
allocated channel: c6
channel c6: SID=607 device type=DISK
allocated channel: c7
channel c7: SID=806 device type=DISK
allocated channel: c8
channel c8: SID=1007 device type=DISK
allocated channel: c9
channel c9: SID=1206 device type=DISK
allocated channel: c10
channel c10: SID=1406 device type=DISK

Starting restore at 16-SEP-25

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
channel c8: restore complete, elapsed time: 00:00:08
output file name=/u01/oradata/EBSCDB/control01.ctl
output file name=/u01/oradata/EBSCDB/control02.ctl
Finished restore at 16-SEP-25

database mounted
duplicating Online logs to Oracle Managed File (OMF) location
duplicating Datafiles to Oracle Managed File (OMF) location

contents of Memory Script:
{
   set newname for clone datafile  1 to new;
   set newname for clone datafile  3 to new;
   set newname for clone datafile  4 to new;
   set newname for clone datafile  5 to new;
   set newname for clone datafile  6 to new;
   set newname for clone datafile  7 to new;
   set newname for clone datafile  8 to new;
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
   clone database
   ;
}
executing Memory Script

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

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

Starting restore at 16-SEP-25

channel c1: starting datafile backup set restore
channel c1: specifying datafile(s) to restore from backup set
channel c1: restoring datafile 00001 to /u01/oradata/EBSCDB/datafile/o1_mf_system_%u_.dbf
channel c1: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp
channel c2: starting datafile backup set restore
channel c2: specifying datafile(s) to restore from backup set
channel c2: restoring datafile 00003 to /u01/oradata/EBSCDB/datafile/o1_mf_sysaux_%u_.dbf
channel c2: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp
channel c3: starting datafile backup set restore
channel c3: specifying datafile(s) to restore from backup set
channel c3: restoring datafile 00004 to /u01/oradata/EBSCDB/datafile/o1_mf_undotbs1_%u_.dbf
channel c3: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp
channel c4: starting datafile backup set restore
channel c4: specifying datafile(s) to restore from backup set
channel c4: restoring datafile 00005 to /u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_system_%u_.dbf
channel c4: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp
channel c5: starting datafile backup set restore
channel c5: specifying datafile(s) to restore from backup set
channel c5: restoring datafile 00006 to /u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_sysaux_%u_.dbf
channel c5: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp
channel c6: starting datafile backup set restore
channel c6: specifying datafile(s) to restore from backup set
channel c6: restoring datafile 00007 to /u01/oradata/EBSCDB/datafile/o1_mf_users_%u_.dbf
channel c6: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp
channel c7: starting datafile backup set restore
channel c7: specifying datafile(s) to restore from backup set
channel c7: restoring datafile 00008 to /u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_undotbs1_%u_.dbf
channel c7: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp
channel c8: starting datafile backup set restore
channel c8: specifying datafile(s) to restore from backup set
channel c8: restoring datafile 00010 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c8: restoring datafile 00014 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c8: restoring datafile 00021 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c8: restoring datafile 00027 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c8: restoring datafile 00029 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_%u_.dbf
channel c8: restoring datafile 00030 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_%u_.dbf
channel c8: restoring datafile 00039 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00042 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00050 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00057 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00063 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00069 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00075 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00081 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00087 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00094 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00100 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00106 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00112 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c8: restoring datafile 00121 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_xdb_%u_.dbf
channel c8: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp
channel c9: starting datafile backup set restore
channel c9: specifying datafile(s) to restore from backup set
channel c9: restoring datafile 00018 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c9: restoring datafile 00024 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c9: restoring datafile 00031 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_%u_.dbf
channel c9: restoring datafile 00034 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00036 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00046 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00053 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00060 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00066 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00072 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00078 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00084 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00088 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00091 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00097 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00103 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00109 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c9: restoring datafile 00114 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_ctxsys_%u_.dbf
channel c9: restoring datafile 00123 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_%u_.dbf
channel c9: restoring datafile 00126 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_%u_.dbf
channel c9: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp
channel c10: starting datafile backup set restore
channel c10: specifying datafile(s) to restore from backup set
channel c10: restoring datafile 00009 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c10: restoring datafile 00013 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c10: restoring datafile 00016 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c10: restoring datafile 00020 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c10: restoring datafile 00026 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c10: restoring datafile 00038 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00048 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00055 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00062 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00068 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00074 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00080 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00086 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00093 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00099 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00105 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00111 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c10: restoring datafile 00117 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_mtr_%u_.dbf
channel c10: restoring datafile 00118 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_odm_data_%u_.dbf
channel c10: restoring datafile 00119 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_%u_.dbf
channel c10: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp
channel c6: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2841j7mv_72_1_1.bkp tag=FULL_COLD_BACKUP
channel c6: restored backup piece 1
channel c6: restore complete, elapsed time: 00:00:25
channel c6: starting datafile backup set restore
channel c6: specifying datafile(s) to restore from backup set
channel c6: restoring datafile 00011 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c6: restoring datafile 00015 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c6: restoring datafile 00022 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c6: restoring datafile 00028 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c6: restoring datafile 00040 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00041 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00043 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00051 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00056 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00058 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00064 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00070 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00076 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00082 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00089 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00095 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00101 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00107 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00113 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c6: restoring datafile 00116 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dm_archi_%u_.dbf
channel c6: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp
channel c7: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2741j7mv_71_1_1.bkp tag=FULL_COLD_BACKUP
channel c7: restored backup piece 1
channel c7: restore complete, elapsed time: 00:00:40
channel c7: starting datafile backup set restore
channel c7: specifying datafile(s) to restore from backup set
channel c7: restoring datafile 00012 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c7: restoring datafile 00017 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c7: restoring datafile 00023 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c7: restoring datafile 00032 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_%u_.dbf
channel c7: restoring datafile 00044 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00045 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00049 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00052 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00059 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00065 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00071 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00077 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00083 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00090 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00096 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00102 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00108 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c7: restoring datafile 00115 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dcm_%u_.dbf
channel c7: restoring datafile 00125 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_%u_.dbf
channel c7: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp
channel c5: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2641j7mv_70_1_1.bkp tag=FULL_COLD_BACKUP
channel c5: restored backup piece 1
channel c5: restore complete, elapsed time: 00:00:43
channel c5: starting datafile backup set restore
channel c5: specifying datafile(s) to restore from backup set
channel c5: restoring datafile 00019 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c5: restoring datafile 00025 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_%u_.dbf
channel c5: restoring datafile 00033 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00035 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00037 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00047 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00054 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00061 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00067 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00073 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00079 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00085 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00092 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00098 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00104 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00110 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__%u_.dbf
channel c5: restoring datafile 00120 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_%u_.dbf
channel c5: restoring datafile 00122 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_%u_.dbf
channel c5: restoring datafile 00124 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_%u_.dbf
channel c5: reading from backup piece /backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp
channel c4: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2541j7mv_69_1_1.bkp tag=FULL_COLD_BACKUP
channel c4: restored backup piece 1
channel c4: restore complete, elapsed time: 00:00:45
channel c3: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2441j7mu_68_1_1.bkp tag=FULL_COLD_BACKUP
channel c3: restored backup piece 1
channel c3: restore complete, elapsed time: 00:00:51
channel c2: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2341j7mf_67_1_1.bkp tag=FULL_COLD_BACKUP
channel c2: restored backup piece 1
channel c2: restore complete, elapsed time: 00:01:19
channel c1: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2241j7me_66_1_1.bkp tag=FULL_COLD_BACKUP
channel c1: restored backup piece 1
channel c1: restore complete, elapsed time: 00:01:49
channel c6: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2141j7gu_65_1_1.bkp tag=FULL_COLD_BACKUP
channel c6: restored backup piece 1
channel c6: restore complete, elapsed time: 00:43:05
channel c10: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch2041j7gu_64_1_1.bkp tag=FULL_COLD_BACKUP
channel c10: restored backup piece 1
channel c10: restore complete, elapsed time: 00:43:15
channel c8: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1u41j7gu_62_1_1.bkp tag=FULL_COLD_BACKUP
channel c8: restored backup piece 1
channel c8: restore complete, elapsed time: 00:43:50
channel c5: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1s41j7gu_60_1_1.bkp tag=FULL_COLD_BACKUP
channel c5: restored backup piece 1
channel c5: restore complete, elapsed time: 00:43:16
channel c7: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1t41j7gu_61_1_1.bkp tag=FULL_COLD_BACKUP
channel c7: restored backup piece 1
channel c7: restore complete, elapsed time: 00:43:20
channel c9: piece handle=/backup/RMAN_TO_GCP/full_EBSCDB_20250820_ch1v41j7gu_63_1_1.bkp tag=FULL_COLD_BACKUP
channel c9: restored backup piece 1
channel c9: restore complete, elapsed time: 00:43:45
Finished restore at 16-SEP-25

contents of Memory Script:
{
   switch clone datafile all;
}
executing Memory Script

datafile 1 switched to datafile copy
input datafile copy RECID=126 STAMP=1211980526 file name=/u01/oradata/EBSCDB/datafile/o1_mf_system_ndlp4n6y_.dbf
datafile 3 switched to datafile copy
input datafile copy RECID=127 STAMP=1211980526 file name=/u01/oradata/EBSCDB/datafile/o1_mf_sysaux_ndlp4n73_.dbf
datafile 4 switched to datafile copy
input datafile copy RECID=128 STAMP=1211980526 file name=/u01/oradata/EBSCDB/datafile/o1_mf_undotbs1_ndlp4n75_.dbf
datafile 5 switched to datafile copy
input datafile copy RECID=129 STAMP=1211980526 file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_system_ndlp4n7f_.dbf
datafile 6 switched to datafile copy
input datafile copy RECID=130 STAMP=1211980526 file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_sysaux_ndlp4n7l_.dbf
datafile 7 switched to datafile copy
input datafile copy RECID=131 STAMP=1211980526 file name=/u01/oradata/EBSCDB/datafile/o1_mf_users_ndlp4n7r_.dbf
datafile 8 switched to datafile copy
input datafile copy RECID=132 STAMP=1211980526 file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_undotbs1_ndlp4n7v_.dbf
datafile 9 switched to datafile copy
input datafile copy RECID=133 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fm4_.dbf
datafile 10 switched to datafile copy
input datafile copy RECID=134 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5flc_.dbf
datafile 11 switched to datafile copy
input datafile copy RECID=135 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fqs_.dbf
datafile 12 switched to datafile copy
input datafile copy RECID=136 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5wwn_.dbf
datafile 13 switched to datafile copy
input datafile copy RECID=137 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5foq_.dbf
datafile 14 switched to datafile copy
input datafile copy RECID=138 STAMP=1211980526 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fmm_.dbf
datafile 15 switched to datafile copy
input datafile copy RECID=139 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fxv_.dbf
datafile 16 switched to datafile copy
input datafile copy RECID=140 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlqxkxp_.dbf
datafile 17 switched to datafile copy
input datafile copy RECID=141 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xbg_.dbf
datafile 18 switched to datafile copy
input datafile copy RECID=142 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fo3_.dbf
datafile 19 switched to datafile copy
input datafile copy RECID=143 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp602s_.dbf
datafile 20 switched to datafile copy
input datafile copy RECID=144 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5frb_.dbf
datafile 21 switched to datafile copy
input datafile copy RECID=145 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fom_.dbf
datafile 22 switched to datafile copy
input datafile copy RECID=146 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gfn_.dbf
datafile 23 switched to datafile copy
input datafile copy RECID=147 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xc5_.dbf
datafile 24 switched to datafile copy
input datafile copy RECID=148 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fpp_.dbf
datafile 25 switched to datafile copy
input datafile copy RECID=149 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp603z_.dbf
datafile 26 switched to datafile copy
input datafile copy RECID=150 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5g5p_.dbf
datafile 27 switched to datafile copy
input datafile copy RECID=151 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fsr_.dbf
datafile 28 switched to datafile copy
input datafile copy RECID=152 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gkd_.dbf
datafile 29 switched to datafile copy
input datafile copy RECID=153 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqyvyt_.dbf
datafile 30 switched to datafile copy
input datafile copy RECID=154 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqypj9_.dbf
datafile 31 switched to datafile copy
input datafile copy RECID=155 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlrf2xo_.dbf
datafile 32 switched to datafile copy
input datafile copy RECID=156 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlp5xct_.dbf
datafile 33 switched to datafile copy
input datafile copy RECID=157 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr42kv_.dbf
datafile 34 switched to datafile copy
input datafile copy RECID=158 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5ftt_.dbf
datafile 35 switched to datafile copy
input datafile copy RECID=159 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzbdj_.dbf
datafile 36 switched to datafile copy
input datafile copy RECID=160 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr9x0c_.dbf
datafile 37 switched to datafile copy
input datafile copy RECID=161 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp605s_.dbf
datafile 38 switched to datafile copy
input datafile copy RECID=162 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj8_.dbf
datafile 39 switched to datafile copy
input datafile copy RECID=163 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5g5p_.dbf
datafile 40 switched to datafile copy
input datafile copy RECID=164 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqwxkd_.dbf
datafile 41 switched to datafile copy
input datafile copy RECID=165 STAMP=1211980527 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtf2k_.dbf
datafile 42 switched to datafile copy
input datafile copy RECID=166 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzw9t_.dbf
datafile 43 switched to datafile copy
input datafile copy RECID=167 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gys_.dbf
datafile 44 switched to datafile copy
input datafile copy RECID=168 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr32mv_.dbf
datafile 45 switched to datafile copy
input datafile copy RECID=169 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xdj_.dbf
datafile 46 switched to datafile copy
input datafile copy RECID=170 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gdj_.dbf
datafile 47 switched to datafile copy
input datafile copy RECID=171 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp607v_.dbf
datafile 48 switched to datafile copy
input datafile copy RECID=172 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gxh_.dbf
datafile 49 switched to datafile copy
input datafile copy RECID=173 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr294g_.dbf
datafile 50 switched to datafile copy
input datafile copy RECID=174 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gh3_.dbf
datafile 51 switched to datafile copy
input datafile copy RECID=175 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h1f_.dbf
datafile 52 switched to datafile copy
input datafile copy RECID=176 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xff_.dbf
datafile 53 switched to datafile copy
input datafile copy RECID=177 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj9_.dbf
datafile 54 switched to datafile copy
input datafile copy RECID=178 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60c5_.dbf
datafile 55 switched to datafile copy
input datafile copy RECID=179 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0t_.dbf
datafile 56 switched to datafile copy
input datafile copy RECID=180 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt8qf_.dbf
datafile 57 switched to datafile copy
input datafile copy RECID=181 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gnl_.dbf
datafile 58 switched to datafile copy
input datafile copy RECID=182 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h49_.dbf
datafile 59 switched to datafile copy
input datafile copy RECID=183 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xk0_.dbf
datafile 60 switched to datafile copy
input datafile copy RECID=184 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gyt_.dbf
datafile 61 switched to datafile copy
input datafile copy RECID=185 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60nw_.dbf
datafile 62 switched to datafile copy
input datafile copy RECID=186 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h4b_.dbf
datafile 63 switched to datafile copy
input datafile copy RECID=187 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0f_.dbf
datafile 64 switched to datafile copy
input datafile copy RECID=188 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5hfh_.dbf
datafile 65 switched to datafile copy
input datafile copy RECID=189 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xm6_.dbf
datafile 66 switched to datafile copy
input datafile copy RECID=190 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h2z_.dbf
datafile 67 switched to datafile copy
input datafile copy RECID=191 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp6155_.dbf
datafile 68 switched to datafile copy
input datafile copy RECID=192 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpc85w_.dbf
datafile 69 switched to datafile copy
input datafile copy RECID=193 STAMP=1211980528 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbfxn_.dbf
datafile 70 switched to datafile copy
input datafile copy RECID=194 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlph0m6_.dbf
datafile 71 switched to datafile copy
input datafile copy RECID=195 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbndo_.dbf
datafile 72 switched to datafile copy
input datafile copy RECID=196 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbhtw_.dbf
datafile 73 switched to datafile copy
input datafile copy RECID=197 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpdsxk_.dbf
datafile 74 switched to datafile copy
input datafile copy RECID=198 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpno9k_.dbf
datafile 75 switched to datafile copy
input datafile copy RECID=199 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpkpk4_.dbf
datafile 76 switched to datafile copy
input datafile copy RECID=200 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpjbm8_.dbf
datafile 77 switched to datafile copy
input datafile copy RECID=201 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlppnwh_.dbf
datafile 78 switched to datafile copy
input datafile copy RECID=202 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpm3xn_.dbf
datafile 79 switched to datafile copy
input datafile copy RECID=203 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpj9o1_.dbf
datafile 80 switched to datafile copy
input datafile copy RECID=204 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyc9o_.dbf
datafile 81 switched to datafile copy
input datafile copy RECID=205 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpzns5_.dbf
datafile 82 switched to datafile copy
input datafile copy RECID=206 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyltq_.dbf
datafile 83 switched to datafile copy
input datafile copy RECID=207 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq1924_.dbf
datafile 84 switched to datafile copy
input datafile copy RECID=208 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpq4dd_.dbf
datafile 85 switched to datafile copy
input datafile copy RECID=209 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpsq0m_.dbf
datafile 86 switched to datafile copy
input datafile copy RECID=210 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq6hxv_.dbf
datafile 87 switched to datafile copy
input datafile copy RECID=211 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8rp1_.dbf
datafile 88 switched to datafile copy
input datafile copy RECID=212 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlrcprx_.dbf
datafile 89 switched to datafile copy
input datafile copy RECID=213 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq7ysv_.dbf
datafile 90 switched to datafile copy
input datafile copy RECID=214 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqczmo_.dbf
datafile 91 switched to datafile copy
input datafile copy RECID=215 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq18ym_.dbf
datafile 92 switched to datafile copy
input datafile copy RECID=216 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq4xyh_.dbf
datafile 93 switched to datafile copy
input datafile copy RECID=217 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqfrfb_.dbf
datafile 94 switched to datafile copy
input datafile copy RECID=218 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqp25s_.dbf
datafile 95 switched to datafile copy
input datafile copy RECID=219 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnxkg_.dbf
datafile 96 switched to datafile copy
input datafile copy RECID=220 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqrnm6_.dbf
datafile 97 switched to datafile copy
input datafile copy RECID=221 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8456_.dbf
datafile 98 switched to datafile copy
input datafile copy RECID=222 STAMP=1211980529 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqbwcy_.dbf
datafile 99 switched to datafile copy
input datafile copy RECID=223 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqh7x_.dbf
datafile 100 switched to datafile copy
input datafile copy RECID=224 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtq0b_.dbf
datafile 101 switched to datafile copy
input datafile copy RECID=225 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqp0o_.dbf
datafile 102 switched to datafile copy
input datafile copy RECID=226 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqs59k_.dbf
datafile 103 switched to datafile copy
input datafile copy RECID=227 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqkqmq_.dbf
datafile 104 switched to datafile copy
input datafile copy RECID=228 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnyvz_.dbf
datafile 105 switched to datafile copy
input datafile copy RECID=229 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt2r0_.dbf
datafile 106 switched to datafile copy
input datafile copy RECID=230 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqxgml_.dbf
datafile 107 switched to datafile copy
input datafile copy RECID=231 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqst7c_.dbf
datafile 108 switched to datafile copy
input datafile copy RECID=232 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtgkj_.dbf
datafile 109 switched to datafile copy
input datafile copy RECID=233 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr25vx_.dbf
datafile 110 switched to datafile copy
input datafile copy RECID=234 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyh48_.dbf
datafile 111 switched to datafile copy
input datafile copy RECID=235 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqvqn1_.dbf
datafile 112 switched to datafile copy
input datafile copy RECID=236 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyn25_.dbf
datafile 113 switched to datafile copy
input datafile copy RECID=237 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt55w_.dbf
datafile 114 switched to datafile copy
input datafile copy RECID=238 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_ctxsys_ndlrjcfd_.dbf
datafile 115 switched to datafile copy
input datafile copy RECID=239 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dcm_ndlr3bf7_.dbf
datafile 116 switched to datafile copy
input datafile copy RECID=240 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dm_archi_ndlqxx1c_.dbf
datafile 117 switched to datafile copy
input datafile copy RECID=241 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_mtr_ndlr50km_.dbf
datafile 118 switched to datafile copy
input datafile copy RECID=242 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_odm_data_ndlr4x7x_.dbf
datafile 119 switched to datafile copy
input datafile copy RECID=243 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr374j_.dbf
datafile 120 switched to datafile copy
input datafile copy RECID=244 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr0g7d_.dbf
datafile 121 switched to datafile copy
input datafile copy RECID=245 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_xdb_ndlr1v4c_.dbf
datafile 122 switched to datafile copy
input datafile copy RECID=246 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3q6o_.dbf
datafile 123 switched to datafile copy
input datafile copy RECID=247 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp5flr_.dbf
datafile 124 switched to datafile copy
input datafile copy RECID=248 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp601x_.dbf
datafile 125 switched to datafile copy
input datafile copy RECID=249 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlqw7md_.dbf
datafile 126 switched to datafile copy
input datafile copy RECID=250 STAMP=1211980530 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3by3_.dbf

contents of Memory Script:
{
   recover
   clone database
   noredo
    delete archivelog
   ;
}
executing Memory Script

Starting recover at 16-SEP-25

Finished recover at 16-SEP-25
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

Total System Global Area   16106123488 bytes

Fixed Size                    13902048 bytes
Variable Size               1409286144 bytes
Database Buffers           14663286784 bytes
Redo Buffers                  19648512 bytes

contents of Memory Script:
{
   sql clone "alter system set  db_name =
 ''EBSCDB'' comment=
 ''Reset to original value by RMAN'' scope=spfile";
   sql clone "alter system reset  db_unique_name scope=spfile";
}
executing Memory Script

sql statement: alter system set  db_name =  ''EBSCDB'' comment= ''Reset to original value by RMAN'' scope=spfile

sql statement: alter system reset  db_unique_name scope=spfile
Oracle instance started

Total System Global Area   16106123488 bytes

Fixed Size                    13902048 bytes
Variable Size               1409286144 bytes
Database Buffers           14663286784 bytes
Redo Buffers                  19648512 bytes
sql statement: CREATE CONTROLFILE REUSE SET DATABASE "EBSCDB" RESETLOGS NOARCHIVELOG
  MAXLOGFILES     16
  MAXLOGMEMBERS      3
  MAXDATAFILES     1024
  MAXINSTANCES     8
  MAXLOGHISTORY      584
 LOGFILE
  GROUP     1  SIZE 300 M ,
  GROUP     2  SIZE 300 M ,
  GROUP     3  SIZE 300 M
 DATAFILE
  '/u01/oradata/EBSCDB/datafile/o1_mf_system_ndlp4n6y_.dbf',
  '/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_system_ndlp4n7f_.dbf',
  '/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5wwn_.dbf'
 CHARACTER SET AL32UTF8


contents of Memory Script:
{
   set newname for clone tempfile  1 to new;
   set newname for clone tempfile  2 to new;
   set newname for clone tempfile  3 to new;
   set newname for clone tempfile  6 to new;
   switch clone tempfile all;
   catalog clone datafilecopy  "/u01/oradata/EBSCDB/datafile/o1_mf_sysaux_ndlp4n73_.dbf",
 "/u01/oradata/EBSCDB/datafile/o1_mf_undotbs1_ndlp4n75_.dbf",
 "/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_sysaux_ndlp4n7l_.dbf",
 "/u01/oradata/EBSCDB/datafile/o1_mf_users_ndlp4n7r_.dbf",
 "/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_undotbs1_ndlp4n7v_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fm4_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5flc_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fqs_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5foq_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fmm_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fxv_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlqxkxp_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xbg_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fo3_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp602s_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5frb_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fom_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gfn_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xc5_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fpp_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp603z_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5g5p_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fsr_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gkd_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqyvyt_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqypj9_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlrf2xo_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlp5xct_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr42kv_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5ftt_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzbdj_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr9x0c_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp605s_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj8_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5g5p_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqwxkd_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtf2k_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzw9t_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gys_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr32mv_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xdj_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gdj_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp607v_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gxh_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr294g_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gh3_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h1f_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xff_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj9_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60c5_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0t_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt8qf_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gnl_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h49_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xk0_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gyt_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60nw_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h4b_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0f_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5hfh_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xm6_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h2z_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp6155_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpc85w_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbfxn_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlph0m6_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbndo_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbhtw_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpdsxk_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpno9k_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpkpk4_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpjbm8_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlppnwh_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpm3xn_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpj9o1_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyc9o_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpzns5_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyltq_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq1924_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpq4dd_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpsq0m_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq6hxv_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8rp1_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlrcprx_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq7ysv_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqczmo_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq18ym_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq4xyh_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqfrfb_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqp25s_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnxkg_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqrnm6_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8456_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqbwcy_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqh7x_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtq0b_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqp0o_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqs59k_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqkqmq_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnyvz_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt2r0_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqxgml_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqst7c_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtgkj_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr25vx_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyh48_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqvqn1_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyn25_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt55w_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_ctxsys_ndlrjcfd_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dcm_ndlr3bf7_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dm_archi_ndlqxx1c_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_mtr_ndlr50km_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_odm_data_ndlr4x7x_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr374j_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr0g7d_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_xdb_ndlr1v4c_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3q6o_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp5flr_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp601x_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlqw7md_.dbf",
 "/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3by3_.dbf";
   switch clone datafile all;
}
executing Memory Script

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

executing command: SET NEWNAME

renamed tempfile 1 to /u01/oradata/EBSCDB/datafile/o1_mf_temp_%u_.tmp in control file
renamed tempfile 2 to /u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_temp_%u_.tmp in control file
renamed tempfile 3 to /u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_temp_%u_.tmp in control file
renamed tempfile 6 to /u01/oradata/EBSCDB/datafile/o1_mf_temp_%u_.tmp in control file

cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/datafile/o1_mf_sysaux_ndlp4n73_.dbf RECID=1 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/datafile/o1_mf_undotbs1_ndlp4n75_.dbf RECID=2 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_sysaux_ndlp4n7l_.dbf RECID=3 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/datafile/o1_mf_users_ndlp4n7r_.dbf RECID=4 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_undotbs1_ndlp4n7v_.dbf RECID=5 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fm4_.dbf RECID=6 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5flc_.dbf RECID=7 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fqs_.dbf RECID=8 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5foq_.dbf RECID=9 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fmm_.dbf RECID=10 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fxv_.dbf RECID=11 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlqxkxp_.dbf RECID=12 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xbg_.dbf RECID=13 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fo3_.dbf RECID=14 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp602s_.dbf RECID=15 STAMP=1211980556
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5frb_.dbf RECID=16 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fom_.dbf RECID=17 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gfn_.dbf RECID=18 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xc5_.dbf RECID=19 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fpp_.dbf RECID=20 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp603z_.dbf RECID=21 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5g5p_.dbf RECID=22 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fsr_.dbf RECID=23 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gkd_.dbf RECID=24 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqyvyt_.dbf RECID=25 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqypj9_.dbf RECID=26 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlrf2xo_.dbf RECID=27 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlp5xct_.dbf RECID=28 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr42kv_.dbf RECID=29 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5ftt_.dbf RECID=30 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzbdj_.dbf RECID=31 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr9x0c_.dbf RECID=32 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp605s_.dbf RECID=33 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj8_.dbf RECID=34 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5g5p_.dbf RECID=35 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqwxkd_.dbf RECID=36 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtf2k_.dbf RECID=37 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzw9t_.dbf RECID=38 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gys_.dbf RECID=39 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr32mv_.dbf RECID=40 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xdj_.dbf RECID=41 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gdj_.dbf RECID=42 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp607v_.dbf RECID=43 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gxh_.dbf RECID=44 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr294g_.dbf RECID=45 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gh3_.dbf RECID=46 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h1f_.dbf RECID=47 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xff_.dbf RECID=48 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj9_.dbf RECID=49 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60c5_.dbf RECID=50 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0t_.dbf RECID=51 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt8qf_.dbf RECID=52 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gnl_.dbf RECID=53 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h49_.dbf RECID=54 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xk0_.dbf RECID=55 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gyt_.dbf RECID=56 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60nw_.dbf RECID=57 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h4b_.dbf RECID=58 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0f_.dbf RECID=59 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5hfh_.dbf RECID=60 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xm6_.dbf RECID=61 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h2z_.dbf RECID=62 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp6155_.dbf RECID=63 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpc85w_.dbf RECID=64 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbfxn_.dbf RECID=65 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlph0m6_.dbf RECID=66 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbndo_.dbf RECID=67 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbhtw_.dbf RECID=68 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpdsxk_.dbf RECID=69 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpno9k_.dbf RECID=70 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpkpk4_.dbf RECID=71 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpjbm8_.dbf RECID=72 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlppnwh_.dbf RECID=73 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpm3xn_.dbf RECID=74 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpj9o1_.dbf RECID=75 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyc9o_.dbf RECID=76 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpzns5_.dbf RECID=77 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyltq_.dbf RECID=78 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq1924_.dbf RECID=79 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpq4dd_.dbf RECID=80 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpsq0m_.dbf RECID=81 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq6hxv_.dbf RECID=82 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8rp1_.dbf RECID=83 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlrcprx_.dbf RECID=84 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq7ysv_.dbf RECID=85 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqczmo_.dbf RECID=86 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq18ym_.dbf RECID=87 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq4xyh_.dbf RECID=88 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqfrfb_.dbf RECID=89 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqp25s_.dbf RECID=90 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnxkg_.dbf RECID=91 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqrnm6_.dbf RECID=92 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8456_.dbf RECID=93 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqbwcy_.dbf RECID=94 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqh7x_.dbf RECID=95 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtq0b_.dbf RECID=96 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqp0o_.dbf RECID=97 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqs59k_.dbf RECID=98 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqkqmq_.dbf RECID=99 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnyvz_.dbf RECID=100 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt2r0_.dbf RECID=101 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqxgml_.dbf RECID=102 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqst7c_.dbf RECID=103 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtgkj_.dbf RECID=104 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr25vx_.dbf RECID=105 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyh48_.dbf RECID=106 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqvqn1_.dbf RECID=107 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyn25_.dbf RECID=108 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt55w_.dbf RECID=109 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_ctxsys_ndlrjcfd_.dbf RECID=110 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dcm_ndlr3bf7_.dbf RECID=111 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dm_archi_ndlqxx1c_.dbf RECID=112 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_mtr_ndlr50km_.dbf RECID=113 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_odm_data_ndlr4x7x_.dbf RECID=114 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr374j_.dbf RECID=115 STAMP=1211980557
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr0g7d_.dbf RECID=116 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_xdb_ndlr1v4c_.dbf RECID=117 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3q6o_.dbf RECID=118 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp5flr_.dbf RECID=119 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp601x_.dbf RECID=120 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlqw7md_.dbf RECID=121 STAMP=1211980558
cataloged datafile copy
datafile copy file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3by3_.dbf RECID=122 STAMP=1211980558

datafile 3 switched to datafile copy
input datafile copy RECID=1 STAMP=1211980556 file name=/u01/oradata/EBSCDB/datafile/o1_mf_sysaux_ndlp4n73_.dbf
datafile 4 switched to datafile copy
input datafile copy RECID=2 STAMP=1211980556 file name=/u01/oradata/EBSCDB/datafile/o1_mf_undotbs1_ndlp4n75_.dbf
datafile 6 switched to datafile copy
input datafile copy RECID=3 STAMP=1211980556 file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_sysaux_ndlp4n7l_.dbf
datafile 7 switched to datafile copy
input datafile copy RECID=4 STAMP=1211980556 file name=/u01/oradata/EBSCDB/datafile/o1_mf_users_ndlp4n7r_.dbf
datafile 8 switched to datafile copy
input datafile copy RECID=5 STAMP=1211980556 file name=/u01/oradata/EBSCDB/EF10D30BEEA01801E0535C21200AF9F5/datafile/o1_mf_undotbs1_ndlp4n7v_.dbf
datafile 9 switched to datafile copy
input datafile copy RECID=6 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fm4_.dbf
datafile 10 switched to datafile copy
input datafile copy RECID=7 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5flc_.dbf
datafile 11 switched to datafile copy
input datafile copy RECID=8 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fqs_.dbf
datafile 13 switched to datafile copy
input datafile copy RECID=9 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5foq_.dbf
datafile 14 switched to datafile copy
input datafile copy RECID=10 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fmm_.dbf
datafile 15 switched to datafile copy
input datafile copy RECID=11 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fxv_.dbf
datafile 16 switched to datafile copy
input datafile copy RECID=12 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlqxkxp_.dbf
datafile 17 switched to datafile copy
input datafile copy RECID=13 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xbg_.dbf
datafile 18 switched to datafile copy
input datafile copy RECID=14 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fo3_.dbf
datafile 19 switched to datafile copy
input datafile copy RECID=15 STAMP=1211980556 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp602s_.dbf
datafile 20 switched to datafile copy
input datafile copy RECID=16 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5frb_.dbf
datafile 21 switched to datafile copy
input datafile copy RECID=17 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fom_.dbf
datafile 22 switched to datafile copy
input datafile copy RECID=18 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gfn_.dbf
datafile 23 switched to datafile copy
input datafile copy RECID=19 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5xc5_.dbf
datafile 24 switched to datafile copy
input datafile copy RECID=20 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fpp_.dbf
datafile 25 switched to datafile copy
input datafile copy RECID=21 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp603z_.dbf
datafile 26 switched to datafile copy
input datafile copy RECID=22 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5g5p_.dbf
datafile 27 switched to datafile copy
input datafile copy RECID=23 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5fsr_.dbf
datafile 28 switched to datafile copy
input datafile copy RECID=24 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_system_ndlp5gkd_.dbf
datafile 29 switched to datafile copy
input datafile copy RECID=25 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqyvyt_.dbf
datafile 30 switched to datafile copy
input datafile copy RECID=26 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_sysaux_ndlqypj9_.dbf
datafile 31 switched to datafile copy
input datafile copy RECID=27 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlrf2xo_.dbf
datafile 32 switched to datafile copy
input datafile copy RECID=28 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_omo_ndlp5xct_.dbf
datafile 33 switched to datafile copy
input datafile copy RECID=29 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr42kv_.dbf
datafile 34 switched to datafile copy
input datafile copy RECID=30 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5ftt_.dbf
datafile 35 switched to datafile copy
input datafile copy RECID=31 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzbdj_.dbf
datafile 36 switched to datafile copy
input datafile copy RECID=32 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr9x0c_.dbf
datafile 37 switched to datafile copy
input datafile copy RECID=33 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp605s_.dbf
datafile 38 switched to datafile copy
input datafile copy RECID=34 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj8_.dbf
datafile 39 switched to datafile copy
input datafile copy RECID=35 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5g5p_.dbf
datafile 40 switched to datafile copy
input datafile copy RECID=36 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqwxkd_.dbf
datafile 41 switched to datafile copy
input datafile copy RECID=37 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtf2k_.dbf
datafile 42 switched to datafile copy
input datafile copy RECID=38 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqzw9t_.dbf
datafile 43 switched to datafile copy
input datafile copy RECID=39 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gys_.dbf
datafile 44 switched to datafile copy
input datafile copy RECID=40 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr32mv_.dbf
datafile 45 switched to datafile copy
input datafile copy RECID=41 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xdj_.dbf
datafile 46 switched to datafile copy
input datafile copy RECID=42 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gdj_.dbf
datafile 47 switched to datafile copy
input datafile copy RECID=43 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp607v_.dbf
datafile 48 switched to datafile copy
input datafile copy RECID=44 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gxh_.dbf
datafile 49 switched to datafile copy
input datafile copy RECID=45 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr294g_.dbf
datafile 50 switched to datafile copy
input datafile copy RECID=46 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gh3_.dbf
datafile 51 switched to datafile copy
input datafile copy RECID=47 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h1f_.dbf
datafile 52 switched to datafile copy
input datafile copy RECID=48 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xff_.dbf
datafile 53 switched to datafile copy
input datafile copy RECID=49 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gj9_.dbf
datafile 54 switched to datafile copy
input datafile copy RECID=50 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60c5_.dbf
datafile 55 switched to datafile copy
input datafile copy RECID=51 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0t_.dbf
datafile 56 switched to datafile copy
input datafile copy RECID=52 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt8qf_.dbf
datafile 57 switched to datafile copy
input datafile copy RECID=53 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gnl_.dbf
datafile 58 switched to datafile copy
input datafile copy RECID=54 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h49_.dbf
datafile 59 switched to datafile copy
input datafile copy RECID=55 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xk0_.dbf
datafile 60 switched to datafile copy
input datafile copy RECID=56 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5gyt_.dbf
datafile 61 switched to datafile copy
input datafile copy RECID=57 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp60nw_.dbf
datafile 62 switched to datafile copy
input datafile copy RECID=58 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h4b_.dbf
datafile 63 switched to datafile copy
input datafile copy RECID=59 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h0f_.dbf
datafile 64 switched to datafile copy
input datafile copy RECID=60 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5hfh_.dbf
datafile 65 switched to datafile copy
input datafile copy RECID=61 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5xm6_.dbf
datafile 66 switched to datafile copy
input datafile copy RECID=62 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp5h2z_.dbf
datafile 67 switched to datafile copy
input datafile copy RECID=63 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlp6155_.dbf
datafile 68 switched to datafile copy
input datafile copy RECID=64 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpc85w_.dbf
datafile 69 switched to datafile copy
input datafile copy RECID=65 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbfxn_.dbf
datafile 70 switched to datafile copy
input datafile copy RECID=66 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlph0m6_.dbf
datafile 71 switched to datafile copy
input datafile copy RECID=67 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbndo_.dbf
datafile 72 switched to datafile copy
input datafile copy RECID=68 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpbhtw_.dbf
datafile 73 switched to datafile copy
input datafile copy RECID=69 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpdsxk_.dbf
datafile 74 switched to datafile copy
input datafile copy RECID=70 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpno9k_.dbf
datafile 75 switched to datafile copy
input datafile copy RECID=71 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpkpk4_.dbf
datafile 76 switched to datafile copy
input datafile copy RECID=72 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpjbm8_.dbf
datafile 77 switched to datafile copy
input datafile copy RECID=73 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlppnwh_.dbf
datafile 78 switched to datafile copy
input datafile copy RECID=74 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpm3xn_.dbf
datafile 79 switched to datafile copy
input datafile copy RECID=75 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpj9o1_.dbf
datafile 80 switched to datafile copy
input datafile copy RECID=76 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyc9o_.dbf
datafile 81 switched to datafile copy
input datafile copy RECID=77 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpzns5_.dbf
datafile 82 switched to datafile copy
input datafile copy RECID=78 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpyltq_.dbf
datafile 83 switched to datafile copy
input datafile copy RECID=79 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq1924_.dbf
datafile 84 switched to datafile copy
input datafile copy RECID=80 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpq4dd_.dbf
datafile 85 switched to datafile copy
input datafile copy RECID=81 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlpsq0m_.dbf
datafile 86 switched to datafile copy
input datafile copy RECID=82 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq6hxv_.dbf
datafile 87 switched to datafile copy
input datafile copy RECID=83 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8rp1_.dbf
datafile 88 switched to datafile copy
input datafile copy RECID=84 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlrcprx_.dbf
datafile 89 switched to datafile copy
input datafile copy RECID=85 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq7ysv_.dbf
datafile 90 switched to datafile copy
input datafile copy RECID=86 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqczmo_.dbf
datafile 91 switched to datafile copy
input datafile copy RECID=87 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq18ym_.dbf
datafile 92 switched to datafile copy
input datafile copy RECID=88 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq4xyh_.dbf
datafile 93 switched to datafile copy
input datafile copy RECID=89 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqfrfb_.dbf
datafile 94 switched to datafile copy
input datafile copy RECID=90 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqp25s_.dbf
datafile 95 switched to datafile copy
input datafile copy RECID=91 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnxkg_.dbf
datafile 96 switched to datafile copy
input datafile copy RECID=92 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqrnm6_.dbf
datafile 97 switched to datafile copy
input datafile copy RECID=93 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlq8456_.dbf
datafile 98 switched to datafile copy
input datafile copy RECID=94 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqbwcy_.dbf
datafile 99 switched to datafile copy
input datafile copy RECID=95 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqh7x_.dbf
datafile 100 switched to datafile copy
input datafile copy RECID=96 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtq0b_.dbf
datafile 101 switched to datafile copy
input datafile copy RECID=97 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqqp0o_.dbf
datafile 102 switched to datafile copy
input datafile copy RECID=98 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqs59k_.dbf
datafile 103 switched to datafile copy
input datafile copy RECID=99 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqkqmq_.dbf
datafile 104 switched to datafile copy
input datafile copy RECID=100 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqnyvz_.dbf
datafile 105 switched to datafile copy
input datafile copy RECID=101 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt2r0_.dbf
datafile 106 switched to datafile copy
input datafile copy RECID=102 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqxgml_.dbf
datafile 107 switched to datafile copy
input datafile copy RECID=103 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqst7c_.dbf
datafile 108 switched to datafile copy
input datafile copy RECID=104 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqtgkj_.dbf
datafile 109 switched to datafile copy
input datafile copy RECID=105 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlr25vx_.dbf
datafile 110 switched to datafile copy
input datafile copy RECID=106 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyh48_.dbf
datafile 111 switched to datafile copy
input datafile copy RECID=107 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqvqn1_.dbf
datafile 112 switched to datafile copy
input datafile copy RECID=108 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqyn25_.dbf
datafile 113 switched to datafile copy
input datafile copy RECID=109 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_ts__ndlqt55w_.dbf
datafile 114 switched to datafile copy
input datafile copy RECID=110 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_ctxsys_ndlrjcfd_.dbf
datafile 115 switched to datafile copy
input datafile copy RECID=111 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dcm_ndlr3bf7_.dbf
datafile 116 switched to datafile copy
input datafile copy RECID=112 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_dm_archi_ndlqxx1c_.dbf
datafile 117 switched to datafile copy
input datafile copy RECID=113 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_mtr_ndlr50km_.dbf
datafile 118 switched to datafile copy
input datafile copy RECID=114 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_odm_data_ndlr4x7x_.dbf
datafile 119 switched to datafile copy
input datafile copy RECID=115 STAMP=1211980557 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr374j_.dbf
datafile 120 switched to datafile copy
input datafile copy RECID=116 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_owb_ndlr0g7d_.dbf
datafile 121 switched to datafile copy
input datafile copy RECID=117 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_xdb_ndlr1v4c_.dbf
datafile 122 switched to datafile copy
input datafile copy RECID=118 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3q6o_.dbf
datafile 123 switched to datafile copy
input datafile copy RECID=119 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp5flr_.dbf
datafile 124 switched to datafile copy
input datafile copy RECID=120 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlp601x_.dbf
datafile 125 switched to datafile copy
input datafile copy RECID=121 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlqw7md_.dbf
datafile 126 switched to datafile copy
input datafile copy RECID=122 STAMP=1211980558 file name=/u01/oradata/EBSCDB/2809223196EC2AF8E053A740D20A4DB6/datafile/o1_mf_apps_und_ndlr3by3_.dbf

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

sql statement: alter pluggable database all open
Finished Duplicate Db at 16-SEP-25

RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of release command at 09/16/2025 13:16:50
RMAN-06012: channel: c1 not allocated

Recovery Manager complete.

real	46m51.098s
user	0m8.647s
sys	0m0.943s

### RMAN: PDB:
EBSDB rename to EBSDB

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO

Pluggable database altered.


Pluggable database altered.


Session altered.

alter pluggable database rename global_name to EBSDB
*
ERROR at line 1:
ORA-65042: name is already used by an existing container



Pluggable database altered.


Pluggable database altered.


Pluggable database altered.


System altered.


    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 16-SEP-2025 13:16:58

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-ebs-db)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                16-SEP-2025 12:24:43
Uptime                    0 days 0 hr. 52 min. 25 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/dbhome_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle-ebs-db/ebscdb/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal)(PORT=1521)))
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

log: /home/oracle/scripts/logs/20250916_122958_rdbms_rman_restore.log
Tue Sep 16 13:16:58 UTC 2025

real	46m59.867s
user	0m8.714s
sys	0m1.116s
[oracle@oracle-ebs-db ~]$

```
# Complete EBS RDBMS post clone

```bash
# complete EBS RDBMS part
[oracle@oracle-ebs-db ~]$ rdbms_ebs_configure
Tue Sep 16 13:27:11 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT FUNCTION: rdbms_ebs_configure
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------

### Configuring EBSCDB database for EBS usage

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO

Session altered.


Grant succeeded.


Session altered.


PL/SQL procedure successfully completed.


### Cloning Techstack for EBSDB database

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 16-SEP-2025 13:27:12

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-ebs-db)(PORT=1521)))
The command completed successfully

                     Copyright (c) 2002, 2015 Oracle Corporation
                        Redwood Shores, California, USA

                        Oracle E-Business Suite Rapid Clone

                                 Version 12.2

                      adcfgclone Version 120.63.12020000.83
stty: 'standard input': Inappropriate ioctl for device

Enter the APPS password :
stty: 'standard input': Inappropriate ioctl for device


Running Rapid Clone with command:

Running:
perl /u01/app/oracle/product/dbhome_1/appsutil/clone/bin/adclone.pl java=/u01/app/oracle/product/dbhome_1/appsutil/clone/bin/../jre mode=apply stage=/u01/app/oracle/product/dbhome_1/appsutil/clone component=dbTechStack method=CUSTOM dbctxtg=/home/oracle/scripts/EBSDB_oracle-ebs-db.xml showProgress contextValidated=false


Beginning rdbms home Apply - Tue Sep 16 13:27:12 2025

/u01/app/oracle/product/dbhome_1/appsutil/clone/bin/../jre/bin/java -Xmx600M -Doracle.jdbc.autoCommitSpecCompliant=false -Doracle.jdbc.DateZeroTime=true -Doracle.jdbc.DateZeroTimeExtra=true -DCONTEXT_VALIDATED=false -Doracle.installer.oui_loc=/u01/app/oracle/product/dbhome_1/oui -classpath /u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/xmlparserv2.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/ojdbc8.jar::/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/java:/u01/app/oracle/product/dbhome_1/appsutil/clone/../../jlib/orai18n.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/oui/OraInstaller.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/oui/ewt3.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/oui/share.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/oui/srvm.jar:/u01/app/oracle/product/dbhome_1/appsutil/clone/jlib/ojmisc.jar   oracle.apps.ad.clone.ApplyDBTechStack -e /home/oracle/scripts/EBSDB_oracle-ebs-db.xml -stage /u01/app/oracle/product/dbhome_1/appsutil/clone   -showProgress
APPS Password : Log file located at /u01/app/oracle/product/dbhome_1/appsutil/log/EBSDB_oracle-ebs-db/ApplyDBTechStack_09161327.log
  |      0% completed
Log file located at /u01/app/oracle/product/dbhome_1/appsutil/log/EBSDB_oracle-ebs-db/ApplyDBTechStack_09161327.log
  \      0% completed

Completed Apply...
Tue Sep 16 13:29:53 2025

Running:
/u01/app/oracle/product/dbhome_1/bin/sqlplus -s /nolog @/u01/app/oracle/product/dbhome_1/appsutil/clone/bin/sqlCmd.sql > /u01/app/oracle/product/dbhome_1/appsutil/clone/bin/get_ad_codelevel.log 2>&1

Running ETCC to check status of DB technology patches...

Version of /u01/app/oracle/product/dbhome_1/appsutil/etcc/checkDBpatch.sh is 120.105

Running:
/u01/app/oracle/product/dbhome_1/bin/sqlplus -s /nolog @/u01/app/oracle/product/dbhome_1/appsutil/clone/bin/sqlCmd.sql > /u01/app/oracle/product/dbhome_1/appsutil/clone/bin/get_ad_codelevel.log 2>&1

 +===============================================================+
 |    Copyright (c) 2005, 2022 Oracle and/or its affiliates.     |
 |                     All rights reserved.                      |
 |             Oracle E-Business Suite Release 12.2              |
 |          Database EBS Technology Codelevel Checker            |
 +===============================================================+

Validating context file: /home/oracle/scripts/EBSDB_oracle-ebs-db.xml

Using context file from command line argument:
/home/oracle/scripts/EBSDB_oracle-ebs-db.xml


Starting Database EBS Technology Codelevel Checker, Version 120.105
Tue Sep 16 13:29:53 UTC 2025
Log file for this session : /u01/app/oracle/product/dbhome_1/appsutil/clone/bin/log/checkDBpatch_162979.log

Identifying database release.
Database release set to 19.18.0.0.

Multitenant identified.
 - Container database (CDB) identified via s_cdb_name is EBSCDB
 - Pluggable database (PDB) identified via s_pdb_name is EBSDB

Connecting to database.
Database connection successful.

Database EBSDB is in READ WRITE mode.

Identifying APPS and APPLSYS schema names.
 - APPS schema : APPS
 - APPLSYS schema : APPLSYS

Checking for DB-ETCC results table.
Table to store DB-ETCC results already exists in the database.

Bugfix file /u01/app/oracle/product/dbhome_1/appsutil/etcc/db/onprem/txk_R1220_DB_base_bugs.xml : 120.0.12020000.71
This file will be used for identifying missing bugfixes.

Mapping file /u01/app/oracle/product/dbhome_1/appsutil/etcc/db/onprem/txk_R1220_DB_mappings.xml : 120.0.12020000.47
This file will be used for mapping bugfixes to patches.


[WARNING] DB-ETCC: Bugfix XML file (/u01/app/oracle/product/dbhome_1/appsutil/etcc/db/onprem/txk_R1220_DB_base_bugs.xml) is more than 90 days old.

+-----------------------------------------------------------------------------+
   Always use the latest version of ETCC available in patch 17537119, as new
   bugfixes will not be checked by older versions of the utility.
+-----------------------------------------------------------------------------+


Identified RDBMS DST version 32.

Checking Bugfix XML file for 19.18.0.0_RU

Obtained list of bugfixes to be applied and the list to be rolled back.
Now checking Database ORACLE_HOME.

The opatch utility is version 12.2.0.1.36.
DB-ETCC is compatible with this opatch version.

Found patch records in the inventory.

Checking Mapping XML file for 19.18.0.0.230117DBRU

All the required one-off bugfixes are present in Database ORACLE_HOME.

Stored Technology Codelevel Checker results in the database EBSDB successfully.

Finished checking fixes for Oracle Database: Tue Sep 16 13:30:14 UTC 2025

Log file for this session: /u01/app/oracle/product/dbhome_1/appsutil/clone/bin/log/checkDBpatch_162979.log

===============================================================================

### Post Cloning tasks
ln: failed to create symbolic link '/home/oracle/EBSDB_oracle-ebs-db.env': File exists
ln: failed to create symbolic link '/home/oracle/EBSCDB_oracle-ebs-db.env': File exists
ln: failed to create symbolic link '/home/oracle/alert_EBSCDB.log': File exists
Logfile: /u01/app/oracle/product/dbhome_1/appsutil/log/EBSDB_oracle-ebs-db/addlnctl.txt

You are running addlnctl.sh version 120.4

grep: /u01/app/oracle/product/dbhome_1/network/admin/EBSDB_oracle-ebs-db/listener.ora: No such file or directory

Starting listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 16-SEP-2025 13:30:14

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Starting /u01/app/oracle/product/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u01/app/oracle/product/dbhome_1/network/admin/listener.ora
Log messages written to /u01/app/oracle/diag/tnslsnr/oracle-ebs-db/ebscdb/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-ebs-db)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                16-SEP-2025 13:30:14
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/dbhome_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/oracle-ebs-db/ebscdb/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal)(PORT=1521)))
The listener supports no services
The command completed successfully

addlnctl.sh: exiting with status 0

addlnctl.sh: check the logfile /u01/app/oracle/product/dbhome_1/appsutil/log/EBSDB_oracle-ebs-db/addlnctl.txt for more information ...


    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO

Session altered.

BEGIN dbms_service.start_service('ebs_EBSDB'); END;

*
ERROR at line 1:
ORA-44305: service ebs_EBSDB is running
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 86
ORA-06512: at "SYS.DBMS_SERVICE_ERR", line 26
ORA-06512: at "SYS.DBMS_SERVICE", line 486
ORA-06512: at line 1



System altered.


    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 EBSDB			  READ WRITE NO

User altered.


Session altered.


User altered.

/u01/app/oracle/temp
/u01/app/oracle/product/dbhome_1/appsutil/outbound/EBSDB_oracle-ebs-db
/u01/app/oracle/temp/EBSDB
stty: 'standard input': Inappropriate ioctl for device
Enter the APPS Password:
stty: 'standard input': Inappropriate ioctl for device


Script Name    : txkCfgUtlfileDir.pl
Script Version : 120.0.12020000.29
Started        : Tue Sep 16 13:30:14 UTC 2025

Log File       : /u01/app/oracle/product/dbhome_1/appsutil/log/TXK_UTIL_DIR_Tue_Sep_16_13_30_14_2025/txkCfgUtlfileDir.log

Context file: /u01/app/oracle/product/dbhome_1/appsutil/EBSDB_oracle-ebs-db.xml exists.


stty: 'standard input': Inappropriate ioctl for device
Enter the ebs_system Password:
stty: 'standard input': Inappropriate ioctl for device



Completed        : Tue Sep 16 13:30:20 UTC 2025


Successfully Completed the script
ERRORCODE = 0 ERRORCODE_END

The log file for this session is located at: /u01/app/oracle/product/dbhome_1/appsutil/log/EBSDB_oracle-ebs-db/09161330/adconfig.log

AutoConfig is configuring the Database environment...

AutoConfig will consider the custom templates if present.
	Using ORACLE_HOME location : /u01/app/oracle/product/dbhome_1

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.

Value of s_dbcset is AL32UTF8

Character set is not present in the allowed list. Need to add orai18n.jar to the CLASSPATH.

Library orai18n.jar exists.
	Classpath                   : :/u01/app/oracle/product/dbhome_1/jdbc/lib/ojdbc8.jar:/u01/app/oracle/product/dbhome_1/appsutil/java/xmlparserv2.jar:/u01/app/oracle/product/dbhome_1/appsutil/java:/u01/app/oracle/product/dbhome_1/jlib/netcfg.jar:/u01/app/oracle/product/dbhome_1/jlib/ldapjclnt19.jar:/u01/app/oracle/product/dbhome_1/jlib/orai18n.jar

	Using Context file          : /u01/app/oracle/product/dbhome_1/appsutil/EBSDB_oracle-ebs-db.xml

Context Value Management will now update the Context file

	Updating Context file...COMPLETED

	Attempting upload of Context file and templates to database...COMPLETED

Updating rdbms version in Context file to db19
Updating rdbms type in Context file to 64 bits
Configuring templates from ORACLE_HOME ...

AutoConfig completed successfully.

log: /home/oracle/scripts/logs/20250916_132711_rdbms_ebs_configure.log
Tue Sep 16 13:30:41 UTC 2025
[oracle@oracle-ebs-db ~]$
```

# APPLICATION part

## 5.2 Configure Oracle EBS Apps on provisioned infrastructure

```bash
# Connect the server and switcu to root

[user@desktop] ~ % gcloud compute ssh --zone "us-west2-a" oracle-ebs-apps --tunnel-through-iap --project oracle-ebs-toolkit
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

Activate the web console with: systemctl enable --now cockpit.socket

[ext_user_company_com@oracle-ebs-apps ~]$ sudo su -

# Execute root activities as functions
[root@oracle-ebs-apps ~]# source /scripts/funct.sh
[root@oracle-ebs-apps ~]# ebs_root_init
Tue Sep 16 13:37:38 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION ebs_root_init
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------

### Creating Directories
/home/oracle/scripts already exists
/home/oracle/scripts/logs already exists
Created /backup and set owner to oracle:oinstall
Created /u01/ebs122/oraInventory and set owner to oracle:oinstall
/u01/ebs122 already exists
Created /u01/install/APPS/temp/EBSDB and set owner to oracle:oinstall

### Stage Scripts to Oracle user
'/scripts/EBSDB_oracle-ebs-db.xml' -> '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml'
'/scripts/environment' -> '/home/oracle/scripts/environment'
'/scripts/funct.sh' -> '/home/oracle/scripts/funct.sh'
'/scripts/initEBSCDB.ora' -> '/home/oracle/scripts/initEBSCDB.ora'
'/scripts/listener.ora' -> '/home/oracle/scripts/listener.ora'
'/scripts/rman_restore.rman' -> '/home/oracle/scripts/rman_restore.rman'
changed ownership of '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/environment' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/funct.sh' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/initEBSCDB.ora' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/listener.ora' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/logs/20250916_133738_ebs_root_init.log' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/logs' from root:root to oracle:oinstall
changed ownership of '/home/oracle/scripts/rman_restore.rman' from root:root to oracle:oinstall

### Creating /etc/oraInst.loc
-rw-r--r--. 1 root root 54 Sep 16 13:37 /etc/oraInst.loc
inventory_loc=/u01/ebs122/oraInventory
inst_group=dba

### Ownerships
chown: cannot access '/backup/*': No such file or directory
failed to change ownership of '/backup/*' to oracle:oinstall
ownership of '/u01/ebs122/oraInventory' retained as oracle:oinstall
changed ownership of '/u01/ebs122' from root:root to oracle:oinstall
ownership of '/u01/install/APPS/temp/EBSDB' retained as oracle:oinstall
changed ownership of '/u01/install/APPS/temp' from root:root to oracle:oinstall
changed ownership of '/u01/install/APPS' from root:root to oracle:oinstall
changed ownership of '/u01/install' from root:root to oracle:oinstall
ownership of '/home/oracle/scripts/logs/20250916_133738_ebs_root_init.log' retained as oracle:oinstall
ownership of '/home/oracle/scripts/logs' retained as oracle:oinstall
ownership of '/home/oracle/scripts/EBSDB_oracle-ebs-db.xml' retained as oracle:oinstall
ownership of '/home/oracle/scripts/environment' retained as oracle:oinstall
ownership of '/home/oracle/scripts/funct.sh' retained as oracle:oinstall
ownership of '/home/oracle/scripts/initEBSCDB.ora' retained as oracle:oinstall
ownership of '/home/oracle/scripts/listener.ora' retained as oracle:oinstall
ownership of '/home/oracle/scripts/rman_restore.rman' retained as oracle:oinstall
changed ownership of '/home/oracle/scripts' from root:root to oracle:oinstall

log: /home/oracle/scripts/logs/20250916_133738_ebs_root_init.log
Tue Sep 16 13:37:38 UTC 2025
[root@oracle-ebs-apps ~]#

```
## Stage EBS apps FS backup

```bash

# Swtich to OS user Oracle and execute below functions (preferabley from TMUX session)
# stage backup

[root@oracle-ebs-apps ~]# sudo su - oracle
[oracle@oracle-ebs-apps ~]$ # Swtich to OS user Oracle and execute below functions (preferabley from TMUX session)^C
[oracle@oracle-ebs-apps ~]$ tmux -L ebs_part
[oracle@oracle-ebs-apps ~]$ ebs_stage_backup
Tue Sep 16 13:38:42 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION ebs_stage_backup
         =========================================
         Function copies data from bucket (gs://oracle-ebs-toolkit-storage-bucket-469b0624/) to  /backup and unarchive for further processing
         -----------------------------------------

### Stage EBS Software backup
Copying gs://oracle-ebs-toolkit-storage-bucket-469b0624/EBSFS_TO_GCP.tar.gz to file:///backup/EBSFS_TO_GCP.tar.gz

......................................................................................................

Average throughput: 286.1MiB/s

real	1m7.743s
user	0m39.147s
sys	1m25.050s

### Extract EBS Software (silent)

real	4m31.792s
user	3m58.407s
sys	2m11.490s
Done. FS restore log ->  /u01/ebs122/fs_restore_2025-09-16_13-39-49.log

log: /home/oracle/scripts/logs/20250916_133842_ebs_stage_backup.log
Tue Sep 16 13:44:21 UTC 2025
[oracle@oracle-ebs-apps ~]$

```

## Configure Oracle Application

```bash

# Configure Oracle Application
[oracle@oracle-ebs-apps ~]$ ebs_configure
Tue Sep 16 13:54:43 UTC 2025

         =========================================
         EBS ON GCP TOOLKIT FUNCTION: ebs_configure
         =========================================
         Function to configure EBS application: adcfgclone, autoconfig, etc
         -----------------------------------------

### Cloning EBS APPS Tier for EBSDB database
-bash: apps: command not found

                     Copyright (c) 2002, 2015 Oracle Corporation
                        Redwood Shores, California, USA

                        Oracle E-Business Suite Rapid Clone

                                 Version 12.2

                      adcfgclone Version 120.63.12020000.83

		***********************************************************
		In AD-TXK Delta 7, we recommend you clone the run and patch
		file systems in a single operation using the 'dualfs' option.
		Separate cloning of the run and patch file systems will be deprecated
		************************************************************
stty: 'standard input': Inappropriate ioctl for device

Enter the APPS password :
stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Enter the Weblogic AdminServer password :
stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device

Enter the password for DataSource ISGDatasource :
stty: 'standard input': Inappropriate ioctl for device

Running: Context clone...

Log file located at /u01/ebs122/fs1/EBSapps/comn/clone/bin/CloneContext_0916135443.log

Provide the values required for creation of the new APPL_TOP Context file.

Target System Base Directory set to /u01/ebs122

Target System Current File System Base set to /u01/ebs122/fs1

Target System Other File System Base set to /u01/ebs122/fs2

Target System Fusion Middleware Home set to /u01/ebs122/fs1/FMW_Home

Target System Web Oracle Home set to /u01/ebs122/fs1/FMW_Home/webtier

Target System Appl TOP set to /u01/ebs122/fs1/EBSapps/appl

Target System COMMON TOP set to /u01/ebs122/fs1/EBSapps/comn

Target System Instance Top set to /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps

Checking the port pool 0
done: Port Pool 0 is free
Report file located at /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/out/portpool.lst
The new APPL_TOP context file has been created :
  /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml
Check Clone Context logfile /u01/ebs122/fs1/EBSapps/comn/clone/bin/CloneContext_0916135443.log for details.

Running Rapid Clone with command:

Running:
perl /u01/ebs122/fs1/EBSapps/comn/clone/bin/adclone.pl java=/u01/ebs122/fs1/EBSapps/comn/clone/bin/../jre mode=apply stage=/u01/ebs122/fs1/EBSapps/comn/clone component=appsTier method=CUSTOM appctxtg=/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml showProgress contextValidated=true



FMW Pre-requisite check log file location : /u01/ebs122/fs1/EBSapps/comn/clone/FMW/logs/prereqcheck.log

Running: /u01/ebs122/fs1/EBSapps/comn/clone/FMW/t2pjdk/bin/java -classpath /u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/Scripts/ext/jlib/engine.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/OraPrereq.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/OraPrereqChecks.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/OraInstaller.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/OraInstallerNet.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/srvm.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/Scripts/ext/jlib/ojdl.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/Scripts/ext/jlib/ojdl2.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/Scripts/ext/jlib/ojdl-log4j.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/xmlparserv2.jar:/u01/ebs122/fs1/EBSapps/comn/clone/prereq/webtier/oui/jlib/share.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/java oracle.apps.ad.clone.util.FMWOracleHomePreReqCheck -prereqCheckFMW -e /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml -stage /u01/ebs122/fs1/EBSapps/comn/clone -log /u01/ebs122/fs1/EBSapps/comn/clone/FMW/logs/prereqcheck.log

Beginning application tier Apply - Tue Sep 16 13:54:49 2025

/u01/ebs122/fs1/EBSapps/comn/clone/bin/../jre/bin/java -Xmx600M -Doracle.jdbc.autoCommitSpecCompliant=false -Doracle.jdbc.DateZeroTime=true -Doracle.jdbc.DateZeroTimeExtra=true -DCONTEXT_VALIDATED=true -Doracle.installer.oui_loc=/oui -classpath /u01/ebs122/fs1/EBSapps/comn/clone/jlib/xmlparserv2.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/ojdbc6.jar::/u01/ebs122/fs1/EBSapps/comn/clone/jlib/java:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/oui/OraInstaller.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/oui/ewt3.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/oui/share.jar:/u01/ebs122/fs1/FMW_Home/webtier/../Oracle_EBS-app1/oui/jlib/srvm.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/ojmisc.jar:/u01/ebs122/fs1/FMW_Home/wlserver_10.3/server/lib/weblogic.jar:/u01/ebs122/fs1/EBSapps/comn/clone/jlib/obfuscatepassword.jar  oracle.apps.ad.clone.ApplyAppsTier -e /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml -stage /u01/ebs122/fs1/EBSapps/comn/clone    -showProgress -nopromptmsg
Log file located at /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/log/clone/ApplyAppsTier_09161354.log
  -     50% completed       <Sep 16, 2025 2:13:11 PM UTC> <Warning> <JNDI> <BEA-050001> <WLContext.close() was called in a different thread than the one in which it was created.>
  -    100% completed

Completed Apply...
Tue Sep 16 14:15:19 2025

Running:
/u01/ebs122/fs1/EBSapps/10.1.2/bin/sqlplus -s /nolog > /u01/ebs122/fs1/EBSapps/comn/clone/bin/truncate_ad_nodes_config_status.log 2>&1

Running:
/u01/ebs122/fs1/EBSapps/10.1.2/bin/sqlplus -s /nolog > /u01/ebs122/fs1/EBSapps/comn/clone/bin/update_patchbase.log 2>&1

Running:
/u01/ebs122/fs1/EBSapps/10.1.2/bin/sqlplus -s /nolog > /u01/ebs122/fs1/EBSapps/comn/clone/bin/delete_adopvalidnodes.log 2>&1


Do you want to startup the Application Services for EBSDB? (y/n) [n] :
Services not started


Running:
/bin/sqlplus -s /nolog @/u01/ebs122/fs1/EBSapps/comn/clone/bin/sqlCmd.sql > /u01/ebs122/fs1/EBSapps/comn/clone/bin/get_ad_codelevel.log 2>&1

Running:
/u01/ebs122/fs1/EBSapps/10.1.2/bin/sqlplus -s /nolog > /u01/ebs122/fs1/EBSapps/comn/clone/bin/get_run_fs_context.log 2>&1

Running:
perl /u01/ebs122/fs1/EBSapps/appl/ad/12.0.0/patch/115/bin/adcleansrccfg.pl context=/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml promptmsg=hide logfile=/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/log/clone/ApplyAppsTier_09161354.log
*** ALL THE FOLLOWING FILES ARE REQUIRED FOR RESOLVING RUNTIME ERRORS
*** Log File = /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/rgf/TXK/txkSetOAMReg_Tue_Sep_16_14_17_01_2025.log

*** LOG FILE: /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/log/clone/ApplyAppsTier_09161354.log ***

Removing SSO/OID references if present...
Config Cleanup Complete

  E-Business Suite Environment Information
  ----------------------------------------
  File System Type          : SINGLE
  RUN File System           : /u01/ebs122/fs1/EBSapps/appl
  PATCH File System         : NOT APPLICABLE
  Non-Editioned File System : /u01/ebs122/fs_ne


  DB Host: oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal  Service/SID: EBSDB


  Sourcing the RUN File System ...

Log filename : L7624156.log


Report filename : O7624156.out

  E-Business Suite Environment Information
  ----------------------------------------
  File System Type          : SINGLE
  RUN File System           : /u01/ebs122/fs1/EBSapps/appl
  PATCH File System         : NOT APPLICABLE
  Non-Editioned File System : /u01/ebs122/fs_ne


  DB Host: oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal  Service/SID: EBSDB


  Sourcing the RUN File System ...


The log file for this session is located at: /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/log/09161420/adconfig.log


wlsDomainName: EBS_domain
WLS Domain Name is VALID.
AutoConfig is configuring the Applications environment...

AutoConfig will consider the custom templates if present.
	Using CONFIG_HOME location     : /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps
	Classpath                   : /u01/ebs122/fs1/FMW_Home/Oracle_EBS-app1/shared-libs/ebs-appsborg/WEB-INF/lib/ebsAppsborgManifest.jar:/u01/ebs122/fs1/EBSapps/comn/java/classes

	Using Context file          : /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/appl/admin/EBSDB_oracle-ebs-apps.xml

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

  E-Business Suite Environment Information
  ----------------------------------------
  File System Type          : SINGLE
  RUN File System           : /u01/ebs122/fs1/EBSapps/appl
  PATCH File System         : NOT APPLICABLE
  Non-Editioned File System : /u01/ebs122/fs_ne


  DB Host: oracle-ebs-db.us-west2-a.c.oracle-ebs-toolkit.internal  Service/SID: EBSDB


  Sourcing the RUN File System ...


You are running adstrtal.sh version 120.24.12020000.11

stty: 'standard input': Inappropriate ioctl for device

Enter the WebLogic Server password: stty: 'standard input': Inappropriate ioctl for device

The logfile for this session is located at /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adstrtal.log

Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/jtffmctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running jtffmctl.sh version 120.3.12020000.4

Validating Fulfillment patch level via /u01/ebs122/fs1/EBSapps/comn/java/classes
Fulfillment patch level validated.
Starting Fulfillment Server for EBSDB on port 9300 ...

jtffmctl.sh: exiting with status 0


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adopmnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adopmnctl.sh version 120.0.12020000.2

Starting Oracle Process Manager (OPMN) ...

adopmnctl.sh: exiting with status 0

adopmnctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adopmnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adapcctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

You are running adapcctl.sh version 120.0.12020000.6

Starting OPMN managed Oracle HTTP Server (OHS) instance ...

adapcctl.sh: exiting with status 0

adapcctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adapcctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adnodemgrctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adnodemgrctl.sh version 120.11.12020000.12


Calling txkChkEBSDependecies.pl to perform dependency checks for ALL MANAGED SERVERS
Perl script txkChkEBSDependecies.pl got executed successfully



The Node Manager is running

NodeManager log is located at /u01/ebs122/fs1/FMW_Home/wlserver_10.3/common/nodemanager/nmHome1

adnodemgrctl.sh: exiting with status 2

adnodemgrctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adnodemgrctl.txt for more information ...


.end std out.
*** ALL THE FOLLOWING FILES ARE REQUIRED FOR RESOLVING RUNTIME ERRORS
*** Log File = /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/rgf/TXK/txkChkEBSDependecies_Tue_Sep_16_14_23_35_2025/txkChkEBSDependecies_Tue_Sep_16_14_23_35_2025.log

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adalnctl.sh start
Timeout specified in context file: 100 second(s)

script returned:
****************************************************

adalnctl.sh version 120.3.12020000.4

Checking for FNDFS executable.
Starting listener process APPS_EBSDB.

adalnctl.sh: exiting with status 0


adalnctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adalnctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adcmctl.sh start
Timeout specified in context file: 1000 second(s)

script returned:
****************************************************

You are running adcmctl.sh version 120.19.12020000.7

Starting concurrent manager for EBSDB ...
Starting EBSDB_0916@EBSDB Internal Concurrent Manager
Default printer is noprint

adcmctl.sh: exiting with status 0


adcmctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adcmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/adadminsrvctl.sh start -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running adadminsrvctl.sh version 120.10.12020000.11

Starting WLS Admin Server...
Refer /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adadminsrvctl.txt for details

AdminServer logs are located at /u01/ebs122/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/AdminServer/logs

adadminsrvctl.sh: exiting with status 0

adadminsrvctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adadminsrvctl.txt for more information ...


.end std out.

.end err out.

****************************************************





Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/admanagedsrvctl.sh start forms_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting forms_server1...

Server specific logs are located at /u01/ebs122/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/forms_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adformsctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/admanagedsrvctl.sh start oafm_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oafm_server1...

Server specific logs are located at /u01/ebs122/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oafm_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adoafmctl.txt for more information ...


.end std out.

.end err out.

****************************************************



Executing service control script:
/u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/admin/scripts/admanagedsrvctl.sh start oacore_server1 -nopromptmsg
Timeout specified in context file: -1 second(s)

script returned:
****************************************************

You are running admanagedsrvctl.sh version 120.14.12020000.12

Starting oacore_server1...

Server specific logs are located at /u01/ebs122/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oacore_server1/logs

admanagedsrvctl.sh: exiting with status 0

admanagedsrvctl.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adoacorectl.txt for more information ...


.end std out.

.end err out.

****************************************************



All enabled services for this node are started.

adstrtal.sh: Exiting with status 0

adstrtal.sh: check the logfile /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/logs/appl/admin/log/adstrtal.log for more information ...



         =========================================
                 Oracle Customer Deployment
         =========================================
          URL                : http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000
          User               : SYSADMIN
          Password           : SYSADMIN#!1234 (case sensitive)

          hosts file entry   : 127.0.0.1 oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal oracle-ebs-apps
          IAP tunneling      :
          	gcloud compute ssh --zone us-west2-a oracle-ebs-apps --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
         -----------------------------------------


log: /home/oracle/scripts/logs/20250916_135443_ebs_configure.log
Tue Sep 16 14:27:58 UTC 2025
[oracle@oracle-ebs-apps ~]$

```

## 5.3 Connect to Oracle EBS applicaiton

```bash

[user@desktop] ~ % cat /etc/hosts | grep oracle-ebs-apps
127.0.0.1 oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal oracle-ebs-apps
[user@desktop] ~ % gcloud compute ssh --zone "us-west2-a" oracle-ebs-apps --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

bind [127.0.0.1]:8000: Address already in use
channel_setup_fwd_listener_tcpip: cannot listen to port: 8000
Could not request local forwarding.
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Sep 16 13:35:01 2025 from 127.0.0.1


[user@desktop] ~ % curl http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000
<!-- $Header: index.html 120.6 2011/04/15 09:27:28 sbandla ship $ -->
<!--
  ###############################################################

  Do not edit settings in this file manually. They are managed
  automatically and will be overwritten when AutoConfig runs.
  For more information about AutoConfig, refer to the Oracle
  E-Business Suite Setup Guide.

  ###############################################################

  Template <AD_TOP>/admin/template/index.html
  To customize this page, please refer to Oracle MetaLink Note 387859.1.
-->
<!-- dbdrv: none -->

<!-- appdet.html - this is needed to make the page pass
                   the Rapid Install post install check -->
<html>
<HEAD>
<TITLE>E-Business Suite Home Page Redirect</TITLE>
<META http-equiv=REFRESH content="1; URL=http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000/OA_HTML/AppsLogin">
</HEAD>
<body>
<DIV ID="content">
The E-Business Home Page is located at <a href="http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000/OA_HTML/AppsLogin">http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000/OA_HTML/AppsLogin</a><br>
If your browser doesn't automatically redirect to its new location, click
<A HREF="http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000/OA_HTML/AppsLogin">here</A>.
</DIV>
</body>
</html>
[user@desktop] ~ %

```

# 6 Destroy deployment

```bash

[user@desktop] ebs-infra-framework % ls -l
total 432
-rw-r--r--@ 1 user  staff    7746 Sep  8 14:39 Makefile
drwxr-xr-x@ 3 user  staff      96 Aug 21 16:02 projects
-rw-r--r--@ 1 user  staff    6717 Sep 12 09:57 README-customer-data.md
-rw-r--r--@ 1 user  staff    6105 Sep  3 10:23 README.md
drwxr-xr-x@ 6 user  staff     192 Sep  2 11:20 scripts
-rw-r--r--@ 1 user  staff  196588 Aug 29 14:09 vision_deploy_demo_logfile.md
[user@desktop] ebs-infra-framework % make destroy
terraform -chdir=projects/oracle-ebs-toolkit destroy -auto-approve \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com"
random_id.bucket_suffix: Refreshing state... [id=WMds9Q]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/iam.googleapis.com]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/compute.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
google_service_account.project_sa: Refreshing state... [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/storage.googleapis.com]
module.network.module.vpc.google_compute_network.network: Refreshing state... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-000000000000@gs-project-accounts.iam.gserviceaccount.com]
module.ebs_storage_bucket.google_storage_bucket.bucket: Refreshing state... [id=oracle-ebs-toolkit-storage-bucket-58c76cf5]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Refreshing state... [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Refreshing state... [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Refreshing state... [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Refreshing state... [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Refreshing state... [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Refreshing state... [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Refreshing state... [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Refreshing state... [id=b/oracle-ebs-toolkit-storage-bucket-58c76cf5/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_compute_address.ebs_apps_server_internal_ip[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-apps-server-internal-ip]
google_compute_address.ebs_db_server_internal_ip[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-db-server-internal-ip]
google_compute_instance.apps[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
module.cloud_router.google_compute_router.router: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
google_compute_instance.dbs[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_address.ebs_apps_server_internal_ip[0] will be destroyed
  - resource "google_compute_address" "ebs_apps_server_internal_ip" {
      - address            = "10.115.0.10" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2025-09-08T01:43:45.108-07:00" -> null
      - effective_labels   = {} -> null
      - id                 = "projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-apps-server-internal-ip" -> null
      - label_fingerprint  = "42WmSpB8rSM=" -> null
      - labels             = {} -> null
      - name               = "ebs-apps-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-apps-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - terraform_labels   = {} -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_address.ebs_db_server_internal_ip[0] will be destroyed
  - resource "google_compute_address" "ebs_db_server_internal_ip" {
      - address            = "10.115.0.20" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2025-09-08T01:43:45.906-07:00" -> null
      - effective_labels   = {} -> null
      - id                 = "projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-db-server-internal-ip" -> null
      - label_fingerprint  = "42WmSpB8rSM=" -> null
      - labels             = {} -> null
      - name               = "ebs-db-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-db-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - terraform_labels   = {} -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be destroyed
  - resource "google_compute_address" "nat_ip" {
      - address            = "34.102.96.195" -> null
      - address_type       = "EXTERNAL" -> null
      - creation_timestamp = "2025-09-08T01:43:08.171-07:00" -> null
      - effective_labels   = {} -> null
      - id                 = "projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01" -> null
      - label_fingerprint  = "42WmSpB8rSM=" -> null
      - labels             = {} -> null
      - name               = "oracle-ebs-toolkit-nat-01" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01" -> null
      - terraform_labels   = {} -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router",
        ] -> null
        # (6 unchanged attributes hidden)
    }

  # google_compute_instance.apps[0] will be destroyed
  - resource "google_compute_instance" "apps" {
      - can_ip_forward       = false -> null
      - cpu_platform         = "AMD Rome" -> null
      - current_status       = "RUNNING" -> null
      - deletion_protection  = false -> null
      - effective_labels     = {
          - "managed-by" = "terraform"
        } -> null
      - enable_display       = false -> null
      - guest_accelerator    = [] -> null
      - id                   = "projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps" -> null
      - instance_id          = "3054294089262639521" -> null
      - label_fingerprint    = "IMYgndRNCzE=" -> null
      - labels               = {
          - "managed-by" = "terraform"
        } -> null
      - machine_type         = "e2-standard-4" -> null
      - metadata             = {
          - "enable-oslogin" = "TRUE"
          - "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        } -> null
      - metadata_fingerprint = "ggkH0mkjnv8=" -> null
      - name                 = "oracle-ebs-apps" -> null
      - project              = "oracle-ebs-toolkit" -> null
      - resource_policies    = [] -> null
      - self_link            = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps" -> null
      - tags                 = [
          - "egress-nat",
          - "external-app-access",
          - "http-server",
          - "https-server",
          - "iap-access",
          - "icmp-access",
          - "internal-access",
          - "lb-health-check",
          - "oracle-ebs-apps",
        ] -> null
      - tags_fingerprint     = "-bqj0KqqgZ4=" -> null
      - terraform_labels     = {
          - "managed-by" = "terraform"
        } -> null
      - zone                 = "us-west2-a" -> null
        # (3 unchanged attributes hidden)

      - boot_disk {
          - auto_delete                = true -> null
          - device_name                = "persistent-disk-0" -> null
          - mode                       = "READ_WRITE" -> null
          - source                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/disks/oracle-ebs-apps" -> null
            # (3 unchanged attributes hidden)

          - initialize_params {
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - size                        = 512 -> null
              - type                        = "pd-ssd" -> null
                # (1 unchanged attribute hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
          - network_ip                  = "10.115.0.10" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
          - subnetwork_project          = "oracle-ebs-toolkit" -> null
            # (3 unchanged attributes hidden)
        }

      - reservation_affinity {
          - type = "ANY_RESERVATION" -> null
        }

      - scheduling {
          - automatic_restart           = true -> null
          - min_node_cpus               = 0 -> null
          - on_host_maintenance         = "MIGRATE" -> null
          - preemptible                 = false -> null
          - provisioning_model          = "STANDARD" -> null
            # (1 unchanged attribute hidden)
        }

      - service_account {
          - email  = "project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
          - scopes = [
              - "https://www.googleapis.com/auth/cloud-platform",
            ] -> null
        }

      - shielded_instance_config {
          - enable_integrity_monitoring = true -> null
          - enable_secure_boot          = false -> null
          - enable_vtpm                 = true -> null
        }
    }

  # google_compute_instance.dbs[0] will be destroyed
  - resource "google_compute_instance" "dbs" {
      - can_ip_forward       = false -> null
      - cpu_platform         = "AMD Rome" -> null
      - current_status       = "RUNNING" -> null
      - deletion_protection  = false -> null
      - effective_labels     = {
          - "managed-by" = "terraform"
        } -> null
      - enable_display       = false -> null
      - guest_accelerator    = [] -> null
      - id                   = "projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db" -> null
      - instance_id          = "6540124821262641569" -> null
      - label_fingerprint    = "IMYgndRNCzE=" -> null
      - labels               = {
          - "managed-by" = "terraform"
        } -> null
      - machine_type         = "e2-standard-8" -> null
      - metadata             = {
          - "enable-oslogin" = "TRUE"
          - "startup-script" = <<-EOT
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
                dnf install gcc gcc-c++ elfutils-libelf-devel fontconfig-devel libXrender-devel librdmacm-devel unixODBC libnsl.i686 libnsl2.i686 policycoreutils-python-utils -y

                # dnf cleanup
                dnf clean all

                # disable firewall
                systemctl stop firewalld
                systemctl disable firewalld

                # swap | 20g
                fallocate -l 20G /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile

                # dir precreate and owberships
                mkdir -v -p /u01 /u02
                chown oracle:oinstall /u01
                chown applmgr:oinstall /u02

                # OEL8 FIX
                # set hostname for vision instance
                if [ "$(hostname)" = "oracle-vision" ]; then
                    hostnamectl set-hostname apps
                fi

                # remove profiles
                mv /etc/profile.d/modules.sh /etc/profile.d/modules.sh.back
                mv /etc/profile.d/scl-init.sh /etc/profile.d/scl-init.sh.mack
                mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.back

                # link libs
                ln -s /usr/lib/libXm.so.4.0.4 /usr/lib/libXm.so.2

                # unset witch for oracle (Preinstall RPM install oracle)
                if [[ $(grep which /home/oracle/.bash_profile | wc -l) -eq 0 ]]; then echo "unset which" >> /home/oracle/.bash_profile ; fi
            EOT
        } -> null
      - metadata_fingerprint = "ggkH0mkjnv8=" -> null
      - name                 = "oracle-ebs-db" -> null
      - project              = "oracle-ebs-toolkit" -> null
      - resource_policies    = [] -> null
      - self_link            = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db" -> null
      - tags                 = [
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
      - tags_fingerprint     = "Z67z3FXcE1U=" -> null
      - terraform_labels     = {
          - "managed-by" = "terraform"
        } -> null
      - zone                 = "us-west2-a" -> null
        # (3 unchanged attributes hidden)

      - boot_disk {
          - auto_delete                = true -> null
          - device_name                = "persistent-disk-0" -> null
          - mode                       = "READ_WRITE" -> null
          - source                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/disks/oracle-ebs-db" -> null
            # (3 unchanged attributes hidden)

          - initialize_params {
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - size                        = 1024 -> null
              - type                        = "pd-standard" -> null
                # (1 unchanged attribute hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
          - network_ip                  = "10.115.0.20" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
          - subnetwork_project          = "oracle-ebs-toolkit" -> null
            # (3 unchanged attributes hidden)
        }

      - reservation_affinity {
          - type = "ANY_RESERVATION" -> null
        }

      - scheduling {
          - automatic_restart           = true -> null
          - min_node_cpus               = 0 -> null
          - on_host_maintenance         = "MIGRATE" -> null
          - preemptible                 = false -> null
          - provisioning_model          = "STANDARD" -> null
            # (1 unchanged attribute hidden)
        }

      - service_account {
          - email  = "project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
          - scopes = [
              - "https://www.googleapis.com/auth/cloud-platform",
            ] -> null
        }

      - shielded_instance_config {
          - enable_integrity_monitoring = true -> null
          - enable_secure_boot          = false -> null
          - enable_vtpm                 = true -> null
        }
    }

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/compute.instanceAdmin.v1" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/iam.serviceAccountUser" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/iap.tunnelResourceAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/logging.logWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/monitoring.metricWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/secretmanager.secretAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY+Ri4wXjw=" -> null
      - id      = "oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/storage.admin" -> null
    }

  # google_service_account.project_sa will be destroyed
  - resource "google_service_account" "project_sa" {
      - account_id   = "project-service-account" -> null
      - disabled     = false -> null
      - display_name = "Project Service Account" -> null
      - email        = "project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - id           = "projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member       = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - name         = "projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project      = "oracle-ebs-toolkit" -> null
      - unique_id    = "115958380417982267878" -> null
        # (1 unchanged attribute hidden)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be destroyed
  - resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      - bucket = "b/oracle-ebs-toolkit-storage-bucket-58c76cf5" -> null
      - etag   = "CAI=" -> null
      - id     = "b/oracle-ebs-toolkit-storage-bucket-58c76cf5/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - role   = "roles/storage.objectAdmin" -> null
    }

  # random_id.bucket_suffix will be destroyed
  - resource "random_id" "bucket_suffix" {
      - b64_std     = "WMds9Q==" -> null
      - b64_url     = "WMds9Q" -> null
      - byte_length = 4 -> null
      - dec         = "1489464565" -> null
      - hex         = "58c76cf5" -> null
      - id          = "WMds9Q" -> null
    }

  # module.cloud_router.google_compute_router.router will be destroyed
  - resource "google_compute_router" "router" {
      - creation_timestamp            = "2025-09-08T01:43:45.210-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router" -> null
      - name                          = "oracle-ebs-toolkit-network-cloud-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - project                       = "oracle-ebs-toolkit" -> null
      - region                        = "us-west2" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router" -> null
        # (1 unchanged attribute hidden)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"] will be destroyed
  - resource "google_compute_router_nat" "nats" {
      - drain_nat_ips                       = [] -> null
      - enable_dynamic_port_allocation      = false -> null
      - enable_endpoint_independent_mapping = false -> null
      - endpoint_types                      = [
          - "ENDPOINT_TYPE_VM",
        ] -> null
      - icmp_idle_timeout_sec               = 30 -> null
      - id                                  = "oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01" -> null
      - max_ports_per_vm                    = 0 -> null
      - min_ports_per_vm                    = 0 -> null
      - name                                = "oracle-ebs-toolkit-nat-01" -> null
      - nat_ip_allocate_option              = "MANUAL_ONLY" -> null
      - nat_ips                             = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01",
        ] -> null
      - project                             = "oracle-ebs-toolkit" -> null
      - region                              = "us-west2" -> null
      - router                              = "oracle-ebs-toolkit-network-cloud-router" -> null
      - source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS" -> null
      - tcp_established_idle_timeout_sec    = 1200 -> null
      - tcp_time_wait_timeout_sec           = 120 -> null
      - tcp_transitory_idle_timeout_sec     = 30 -> null
      - udp_idle_timeout_sec                = 30 -> null
        # (1 unchanged attribute hidden)

      - log_config {
          - enable = true -> null
          - filter = "ALL" -> null
        }

      - subnetwork {
          - name                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
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
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - enable_object_retention     = false -> null
      - force_destroy               = true -> null
      - id                          = "oracle-ebs-toolkit-storage-bucket-58c76cf5" -> null
      - labels                      = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - location                    = "US-WEST2" -> null
      - name                        = "oracle-ebs-toolkit-storage-bucket-58c76cf5" -> null
      - project                     = "oracle-ebs-toolkit" -> null
      - project_number              = 000000000000 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/oracle-ebs-toolkit-storage-bucket-58c76cf5" -> null
      - storage_class               = "NEARLINE" -> null
      - terraform_labels            = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - uniform_bucket_level_access = true -> null
      - url                         = "gs://oracle-ebs-toolkit-storage-bucket-58c76cf5" -> null

      - soft_delete_policy {
          - effective_time             = "2025-09-08T08:43:07.652Z" -> null
          - retention_duration_seconds = 604800 -> null
        }

      - versioning {
          - enabled = true -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2025-09-08T01:43:45.300-07:00" -> null
      - description             = "Allow external access to Oracle EBS Apps" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access" -> null
      - name                    = "allow-external-app-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access" -> null
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
              - "7001",
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2025-09-08T01:43:45.227-07:00" -> null
      - description             = "Allow external access to Oracle EBS DB" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access" -> null
      - name                    = "allow-external-db-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access" -> null
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
      - creation_timestamp      = "2025-09-08T01:43:45.341-07:00" -> null
      - description             = "Allow HTTP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-http-in" -> null
      - name                    = "allow-http-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-http-in" -> null
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
      - creation_timestamp      = "2025-09-08T01:43:45.213-07:00" -> null
      - description             = "Allow HTTPS traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-https-in" -> null
      - name                    = "allow-https-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-https-in" -> null
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
      - creation_timestamp      = "2025-09-08T01:43:47.429-07:00" -> null
      - description             = "Allow IAP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in" -> null
      - name                    = "allow-iap-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in" -> null
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
      - creation_timestamp      = "2025-09-08T01:43:45.194-07:00" -> null
      - description             = "Allow ICMP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in" -> null
      - name                    = "allow-icmp-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in" -> null
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
      - creation_timestamp      = "2025-09-08T01:43:45.212-07:00" -> null
      - description             = "Allow internal HTTP traffic within the VPC" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access" -> null
      - name                    = "allow-internal-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - priority                = 1000 -> null
      - project                 = "oracle-ebs-toolkit" -> null
      - self_link               = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access" -> null
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
      - description         = "Public NAT GW - route through IGW to access internet" -> null
      - dest_range          = "0.0.0.0/0" -> null
      - id                  = "projects/oracle-ebs-toolkit/global/routes/nat-egress-internet" -> null
      - name                = "nat-egress-internet" -> null
      - network             = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - next_hop_gateway    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/gateways/default-internet-gateway" -> null
      - priority            = 1000 -> null
      - project             = "oracle-ebs-toolkit" -> null
      - self_link           = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/routes/nat-egress-internet" -> null
      - tags                = [
          - "egress-nat",
        ] -> null
        # (5 unchanged attributes hidden)
    }

  # module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit/cloudresourcemanager.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit" -> null
      - service                    = "cloudresourcemanager.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit/compute.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit" -> null
      - service                    = "compute.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit/iam.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit" -> null
      - service                    = "iam.googleapis.com" -> null
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be destroyed
  - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "oracle-ebs-toolkit/storage.googleapis.com" -> null
      - project                    = "oracle-ebs-toolkit" -> null
      - service                    = "storage.googleapis.com" -> null
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"] will be destroyed
  - resource "google_compute_subnetwork" "subnetwork" {
      - creation_timestamp         = "2025-09-08T01:43:31.651-07:00" -> null
      - gateway_address            = "10.115.0.1" -> null
      - id                         = "projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - ip_cidr_range              = "10.115.0.0/20" -> null
      - name                       = "oracle-ebs-toolkit-subnet-01" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "oracle-ebs-toolkit" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "us-west2" -> null
      - secondary_ip_range         = [] -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - stack_type                 = "IPV4_ONLY" -> null
        # (6 unchanged attributes hidden)

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
      - delete_default_routes_on_create           = true -> null
      - enable_ula_internal_ipv6                  = false -> null
      - id                                        = "projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
      - mtu                                       = 0 -> null
      - name                                      = "oracle-ebs-toolkit-network" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - numeric_id                                = "4240068593285540340" -> null
      - project                                   = "oracle-ebs-toolkit" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
        # (3 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 32 to destroy.

Changes to Outputs:
  - deployment_summary = <<-EOT
        =========================================
                Oracle E-Business Suite Setup
        =========================================

         Project ID         : oracle-ebs-toolkit
         Region             : us-west2
         Zone               : us-west2-a
         VPC Network        : oracle-ebs-toolkit-network

        -----------------------------------------
         Apps Instance
        -----------------------------------------
           • Name           : oracle-ebs-apps
           • Internal IP    : 10.115.0.10
           • SSH Command    :
               gcloud compute ssh --zone "us-west2-a" "oracle-ebs-apps" --tunnel-through-iap --project "oracle-ebs-toolkit -- -L 8000:localhost:8000"

        -----------------------------------------
         DB Instance
        -----------------------------------------
           • Name           : oracle-ebs-db
           • Internal IP    : 10.115.0.20
           • SSH Command    :
               gcloud compute ssh --zone "us-west2-a" "oracle-ebs-db" --tunnel-through-iap --project "oracle-ebs-toolkit"

        -----------------------------------------
         Storage
        -----------------------------------------
           • Bucket Name    : oracle-ebs-toolkit-storage-bucket-58c76cf5
           • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-58c76cf5

        =========================================
         Summary
        -----------------------------------------
           • Total Instances: 2
           • Storage Bucket : oracle-ebs-toolkit-storage-bucket-58c76cf5
           • Generated At   : 2025-09-08T08:44:23Z
        =========================================
    EOT -> null
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destroying... [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destroying... [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destroying... [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/storage.googleapis.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/compute.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/iam.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destruction complete after 0s
google_compute_instance.apps[0]: Destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destroying... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destruction complete after 9s
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destroying... [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destruction complete after 9s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destroying... [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still destroying... [id=oracle-ebs-toolkit/roles/monitoring.met...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_compute_instance.apps[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps, 00m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Still destroying... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-...cloud-router/oracle-ebs-toolkit-nat-01, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destruction complete after 10s
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destruction complete after 11s
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destroying... [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destruction complete after 11s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destruction complete after 11s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destroying... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destruction complete after 11s
google_compute_instance.dbs[0]: Destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destruction complete after 12s
google_storage_bucket_iam_member.bucket_object_admin: Destroying... [id=b/oracle-ebs-toolkit-storage-bucket-58c76cf5/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destruction complete after 14s
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destroying... [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still destroying... [id=oracle-ebs-toolkit/roles/compute.instan...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_storage_bucket_iam_member.bucket_object_admin: Destruction complete after 7s
module.cloud_router.google_compute_router.router: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Still destroying... [id=oracle-ebs-toolkit/roles/iap.tunnelReso...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_compute_instance.apps[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps, 00m20s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still destroying... [id=oracle-ebs-toolkit/roles/storage.admin/...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destruction complete after 11s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access, 00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet, 00m10s elapsed]
google_compute_instance.dbs[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db, 00m10s elapsed]
module.ebs_storage_bucket.google_storage_bucket.bucket: Destroying... [id=oracle-ebs-toolkit-storage-bucket-58c76cf5]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destruction complete after 12s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destruction complete after 12s
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destruction complete after 14s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destruction complete after 14s
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still destroying... [id=oracle-ebs-toolkit/roles/secretmanager....le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destruction complete after 13s
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destruction complete after 10s
module.ebs_storage_bucket.google_storage_bucket.bucket: Destruction complete after 3s
random_id.bucket_suffix: Destroying... [id=WMds9Q]
random_id.bucket_suffix: Destruction complete after 0s
module.cloud_router.google_compute_router.router: Still destroying... [id=projects/oracle-ebs-toolkit/regions/us-...racle-ebs-toolkit-network-cloud-router, 00m10s elapsed]
google_compute_instance.apps[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-apps, 00m30s elapsed]
module.cloud_router.google_compute_router.router: Destruction complete after 12s
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
google_compute_instance.dbs[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-ebs-db, 00m20s elapsed]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destruction complete after 2s
google_compute_instance.apps[0]: Destruction complete after 34s
google_compute_address.ebs_apps_server_internal_ip[0]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-apps-server-internal-ip]
google_compute_instance.dbs[0]: Destruction complete after 23s
google_service_account.project_sa: Destroying... [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_compute_address.ebs_db_server_internal_ip[0]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/ebs-db-server-internal-ip]
google_service_account.project_sa: Destruction complete after 1s
google_compute_address.ebs_apps_server_internal_ip[0]: Destruction complete after 2s
google_compute_address.ebs_db_server_internal_ip[0]: Destruction complete after 3s
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Still destroying... [id=projects/oracle-ebs-toolkit/regions/us-...bnetworks/oracle-ebs-toolkit-subnet-01, 00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Destruction complete after 13s
module.network.module.vpc.google_compute_network.network: Destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network, 00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network, 00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network, 00m30s elapsed]
module.network.module.vpc.google_compute_network.network: Destruction complete after 32s

Destroy complete! Resources: 32 destroyed.
[user@desktop] ebs-infra-framework %

```