# Oracle EBS Toolkit on GCP | Oracle EBS Vision Demo logfile output example

This file shows example of exeucing Oracle EBS Vision deployment log and outputs as well as timings and expected resutls

### Setup Environment

```bash
 
[user@desktop] mkdir Code
[user@desktop] cd Code
[user@desktop] Code % git clone https://github.com/company/ebs-infra-framework
[user@desktop] Code % cd ebs-infra-framework

[user@desktop] ebs-infra-framework % ls -lart
drwxr-xr-x@  3 user group    96 Aug 21 16:02 projects
-rw-r--r--@  1 user group   642 Aug 21 18:19 .pre-commit-config.yaml
drwxr-xr-x@  5 user group   160 Aug 21 18:22 scripts
-rw-r--r--@  1 user group  4322 Aug 27 09:57 README-customer-data.md
drwxr-xr-x@ 29 user group   928 Aug 27 10:05 ..
-rw-r--r--@  1 user group  5503 Aug 27 16:23 README.md
drwxr-xr-x@  9 user group   288 Aug 29 12:07 .
-rw-r--r--@  1 user group  6735 Aug 29 12:07 Makefile
drwxr-xr-x@ 15 user group   480 Aug 29 12:07 .git

[user@desktop] ebs-infra-framework % git pull
Current branch develop is up to date.

[user@desktop] ebs-infra-framework % make setup
Running setup...
bash scripts/install.sh
gcloud already exists.
✔ Terraform already installed: 1.13.0
✔ terraform-docs already installed: 0.20.0
All tools installed and configured.
Setup complete.
Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'.

[user@desktop] ebs-infra-framework % make verify-gcp-access
 Verifying GCP access for project: oracle-ebs-toolkit
Access to project oracle-ebs-toolkit confirmed.
 Checking IAM roles for user@email.com...
 User has Owner/Editor role → skipping fine-grained permission checks.

 GCP access check passed for project: oracle-ebs-toolkit


```

###  Authenticate with GCP and configure Application Default Credentials:

```bash

[user@desktop] ebs-infra-framework % gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent......


Credentials saved to file: [/Users/user/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).

Quota project "oracle-ebs-toolkit" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.

```

### Deploy EBS Vision Infrastructure

```bash
[user@desktop] ebs-infra-framework % make init
Checking if backend bucket gs://oracle-ebs-toolkit-123456-terraform-state exists...
Initializing Terraform in projects/oracle-ebs-toolkit...
Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/google-beta from the dependency lock file
- Reusing previous version of hashicorp/google from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/google-beta v5.45.2
- Using previously-installed hashicorp/google v5.45.2
- Using previously-installed hashicorp/random v3.7.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Terraform initialized successfully.

[user@desktop] ebs-infra-framework % make vision_plan
terraform -chdir=projects/oracle-ebs-toolkit plan \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" \
	  -var="oracle_ebs_vision=true"
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 0s [id=service-123456@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

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

  # google_compute_address.vision_server_internal_ip[0] will be created
  + resource "google_compute_address" "vision_server_internal_ip" {
      + address            = "10.115.0.30"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "vision-server-internal-ip"
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

  # google_compute_instance.vision[0] will be created
  + resource "google_compute_instance" "vision" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
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
                # set hostname
                hostnamectl set-hostname apps

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
      + name                 = "oracle-vision"
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
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = false
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
          + network_ip                  = "10.115.0.30"
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
      + force_destroy               = false
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

Plan: 30 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

[user@desktop] ebs-infra-framework % make vision_deploy
terraform -chdir=projects/oracle-ebs-toolkit apply -auto-approve \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" \
	  -var="oracle_ebs_vision=true"
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-123456@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

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

  # google_compute_address.vision_server_internal_ip[0] will be created
  + resource "google_compute_address" "vision_server_internal_ip" {
      + address            = "10.115.0.30"
      + address_type       = "INTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = (known after apply)
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "vision-server-internal-ip"
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

  # google_compute_instance.vision[0] will be created
  + resource "google_compute_instance" "vision" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + effective_labels     = {
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
        }
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + labels               = {
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
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
                # set hostname
                hostnamectl set-hostname apps

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
      + name                 = "oracle-vision"
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
          + "application" = "oracle-ebs-vision"
          + "managed-by"  = "terraform"
        }
      + zone                 = "us-west2-a"

      + boot_disk {
          + auto_delete                = false
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
          + network_ip                  = "10.115.0.30"
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
      + force_destroy               = false
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

Plan: 30 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)
random_id.bucket_suffix: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=x4VfEA]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creating...
module.network.module.vpc.google_compute_network.network: Creating...
google_service_account.project_sa: Creating...
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creating...
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creating...
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creating...
module.ebs_storage_bucket.google_storage_bucket.bucket: Creating...
module.ebs_storage_bucket.google_storage_bucket.bucket: Creation complete after 3s [id=oracle-ebs-toolkit-storage-bucket-c7855f10]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/iam.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/compute.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/storage.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creation complete after 4s [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
google_service_account.project_sa: Still creating... [00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m10s elapsed]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Still creating... [00m10s elapsed]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Creation complete after 14s [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
google_service_account.project_sa: Creation complete after 15s [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creating...
google_storage_bucket_iam_member.bucket_object_admin: Creating...
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creating...
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creating...
module.network.module.vpc.google_compute_network.network: Still creating... [00m20s elapsed]
google_storage_bucket_iam_member.bucket_object_admin: Creation complete after 7s [id=b/oracle-ebs-toolkit-storage-bucket-c7855f10/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creation complete after 9s [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creation complete after 9s [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creation complete after 10s [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Creation complete after 25s [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creation complete after 10s [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creation complete after 11s [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Still creating... [00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Creation complete after 14s [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creating...
google_compute_address.vision_server_internal_ip[0]: Creating...
module.cloud_router.google_compute_router.router: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creating...
google_compute_address.vision_server_internal_ip[0]: Creation complete after 2s [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/vision-server-internal-ip]
google_compute_instance.vision[0]: Creating...
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router.router: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
google_compute_instance.vision[0]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creation complete after 12s [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
module.cloud_router.google_compute_router.router: Creation complete after 13s [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creating...
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Creation complete after 4s [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_compute_instance.vision[0]: Creation complete after 17s [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision]

Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

Outputs:

deployment_summary = <<EOT
=========================================
        Oracle Vision VM Deployment
=========================================

 Project ID         : oracle-ebs-toolkit
 Region             : us-west2
 Zone               : us-west2-a
 VPC Network        : oracle-ebs-toolkit-network

-----------------------------------------
 Vision Instance
-----------------------------------------
   • Name           : oracle-vision
   • Internal IP    : 10.115.0.30
   • External IP    : N/A
   • SSH Command    :
       gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project "oracle-ebs-toolkit"

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : oracle-ebs-toolkit-storage-bucket-c7855f10
   • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-c7855f10

-----------------------------------------
 Summary
-----------------------------------------
   • Total Instances: 1
   • Instance Name  : oracle-vision
   • Generated At   : 2025-08-29T09:13:21Z
=========================================

EOT

[user@desktop] ebs-infra-framework % 

```

### Deploy Oracle EBS Vision environment

```bash

# copy files to bucket
[user@desktop] ebs-infra-framework %  gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-c7855f10
[user@desktop] ebs-infra-framework % # copy VISION Media to bucket -> follow instructions
[user@desktop] ebs-infra-framework % gcloud storage ls gs://oracle-ebs-toolkit-storage-bucket-c7855f10
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1035290-01.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/p31090393_1036_Linux-x86-64.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/p31090393_122140_Linux-x86-64 (2).zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/Vision_media/


[user@desktop] ebs-infra-framework % time make vision_deploy_oracle_ebs

>>> Creating /scripts on oracle-vision
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo mkdir -vp /scripts && sudo chmod -v 777 /scripts"
Warning: Permanently added 'compute.5191411279643595211' (ED25519) to the list of known hosts.
mkdir: created directory '/scripts'
mode of '/scripts' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)

>>> Copying /scripts/* to oracle-vision
gcloud compute scp --tunnel-through-iap --zone=us-west2-a --project=oracle-ebs-toolkit \
	scripts/vision/* oracle-vision:/scripts
7zz                                                                                                                                                                                                                                                                                                                                       100% 2811KB   1.8MB/s   00:01
vision_apps_env.sh                                                                                                                                                                                                                                                                                                                        100%  305     1.8KB/s   00:00
vision_apps_fs_mount.sh                                                                                                                                                                                                                                                                                                                   100% 1144     6.4KB/s   00:00
vision_apps_fs_prepare.sh                                                                                                                                                                                                                                                                                                                 100% 4108    22.1KB/s   00:00
vision_apps_startup.sh                                                                                                                                                                                                                                                                                                                    100% 3541    12.6KB/s   00:00
vision_apps_troubleshoot.sh                                                                                                                                                                                                                                                                                                               100% 1627     9.3KB/s   00:00

>>> Ownership updates /scripts/ on oracle-vision
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo chown -Rfv root:root /scripts && sudo chmod -Rfv 777 /scripts/*"
changed ownership of '/scripts/7zz' from ext_user_company_com:ext_user_company_com to root:root
changed ownership of '/scripts/vision_apps_env.sh' from ext_user_company_com:ext_user_company_com to root:root
changed ownership of '/scripts/vision_apps_fs_mount.sh' from ext_user_company_com:ext_user_company_com to root:root
changed ownership of '/scripts/vision_apps_fs_prepare.sh' from ext_user_company_com:ext_user_company_com to root:root
changed ownership of '/scripts/vision_apps_startup.sh' from ext_user_company_com:ext_user_company_com to root:root
changed ownership of '/scripts/vision_apps_troubleshoot.sh' from ext_user_company_com:ext_user_company_com to root:root
ownership of '/scripts' retained as root:root
mode of '/scripts/7zz' changed from 0755 (rwxr-xr-x) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_env.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_fs_mount.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_fs_prepare.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_startup.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)
mode of '/scripts/vision_apps_troubleshoot.sh' changed from 0644 (rw-r--r--) to 0777 (rwxrwxrwx)

>>> Deploying Oracle EBS vision: Runtime ~ 40-50 minutes
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo /scripts/vision_apps_fs_prepare.sh | tee -a  /scripts/vision_apps_fs_prepare.sh.\.log"

### step: creating dir on server: /VMDK

### step: transfering Vision zip files to server
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_1of2.zip to file:///VMDK/V1034614-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_2of2.zip to file:///VMDK/V1034614-01_2of2.zip

Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_1of2.zip to file:///VMDK/V1034637-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_2of2.zip to file:///VMDK/V1034637-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_1of2.zip to file:///VMDK/V1034645-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_2of2.zip to file:///VMDK/V1034645-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_1of2.zip to file:///VMDK/V1034652-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_2of2.zip to file:///VMDK/V1034652-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_1of2.zip to file:///VMDK/V1034656-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_2of2.zip to file:///VMDK/V1034656-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_1of2.zip to file:///VMDK/V1034663-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_2of2.zip to file:///VMDK/V1034663-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_1of2.zip to file:///VMDK/V1034669-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_2of2.zip to file:///VMDK/V1034669-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_1of2.zip to file:///VMDK/V1034670-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_2of2.zip to file:///VMDK/V1034670-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_1of2.zip to file:///VMDK/V1034671-01_1of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_2of2.zip to file:///VMDK/V1034671-01_2of2.zip
Copying gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1035290-01.zip to file:///VMDK/V1035290-01.zip
..............................................................................................................................................................................................................................................................................................................................................................................................................................................................

Average throughput: 777.6MiB/s

real	1m31.112s
user	2m41.894s
sys	3m1.891s

### step: Extract zip files
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
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.17  kp
Archive:  V1035290-01.zip
  inflating: Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ova.18
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

real	1m46.338s
user	0m0.254s
sys	1m11.828s
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

real	1m39.768s
user	0m2.564s
sys	1m29.805s
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

real	22m36.269s
user	16m55.999s
sys	5m15.209s

### step: Get and Attach LVM
1.lvm
/dev/loop0: [2050]:436223373 (/VMDK/1.lvm)
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
no crontab for root
Add crontab: mount FS on startup

### step: hostname update to apps
apps
Add crontab: set hostname on startup

### step: Oracle EBS Vision startup
Directory /u01/install/APPS is available.
no crontab for oracle
Add crontab

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 09:53:58 2025
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORACLE instance shut down.
SQL> Disconnected
Logfile: /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt

You are running addlnctl.sh version 120.4

grep: /u01/install/APPS/19.0.0/network/admin/EBSDB_apps/listener.ora: No such file or directory

Starting listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 29-AUG-2025 09:54:03

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
Start Date                29-AUG-2025 09:54:03
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


SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 09:54:03 2025
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

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 09:54:31 2025
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

grep: /u01/install/APPS/19.0.0/network/admin/EBSDB_apps/listener.ora: No such file or directory

Finding status of listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 29-AUG-2025 09:54:32

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=apps.example.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                29-AUG-2025 09:54:03
Uptime                    0 days 0 hr. 0 min. 28 sec
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


  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: apps.example.com  Service/SID: EBSDB


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
*** Log File = /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/rgf/TXK/txkChkEBSDependecies_Fri_Aug_29_09_54_40_2025/txkChkEBSDependecies_Fri_Aug_29_09_54_40_2025.log

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
Starting EBSDB_0829@EBSDB Internal Concurrent Manager
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

Log filename : L7623482.log


Report filename : O7623482.out


         =========================================
                 Oracle Vision Deployment
         =========================================
          UR                 : http://apps.example.com:8000
          User               : SYSADMIN
          Password           : SYSADMIN12 (case sensitive)

          hosts file entry   : 127.0.0.1 apps.example.com apps
          IAP tunneling      :
          	cloud compute ssh --zone us-west2-a oracle-vision --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
         -----------------------------------------

make vision_deploy_oracle_ebs  3.54s user 1.42s system 0% cpu 41:29.30 total


```

### Available additional commands

Stop/Start/Troubleshoot/Connect

```bash

[user@desktop] ebs-infra-framework % cat /etc/hosts | grep apps
127.0.0.1 apps.example.com apps

[user@desktop] ebs-infra-framework % gcloud compute ssh --zone us-west2-a oracle-vision --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Aug 29 06:41:54 2025 from 35.235.241.194
[ext_user_company_com@apps ~]$ curl http://apps.example.com:8000
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
<META http-equiv=REFRESH content="1; URL=http://apps.example.com:8000/OA_HTML/AppsLogin">
</HEAD>
<body>
<DIV ID="content">
The E-Business Home Page is located at <a href="http://apps.example.com:8000/OA_HTML/AppsLogin">http://apps.example.com:8000/OA_HTML/AppsLogin</a><br>
If your browser doesn't automatically redirect to its new location, click
<A HREF="http://apps.example.com:8000/OA_HTML/AppsLogin">here</A>.
</DIV>
</body>
</html>
[ext_user_company_com@apps ~]$ exit
logout
Connection to compute.5191411279643595211 closed.


[user@desktop] ebs-infra-framework % make vision_ebs_troubleshoot

>>>Troubleshooting - printing deployemnt Oracle OBS details
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo bash -c '/scripts/vision_apps_troubleshoot.sh | tee -a  /scripts/vision_apps_troubleshoot.sh.\.log'"

Oracle EBS Vision deployment troubleshooting script

### uptime
 10:08:46 up 55 min,  0 users,  load average: 0.16, 0.58, 1.45

### List avilalble buckets
gs://ebs-toolkit-bucket1/
gs://oracle-ebs-toolkit-123456-terraform-state/
gs://oracle-ebs-toolkit-daisy-bkt-us/
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/
gs://oracle-ebs-toolkit-terraform-states/

### Bucket for Oracle EBS Vision media
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/

### Contents of bucket: gs://oracle-ebs-toolkit-storage-bucket-c7855f10/ - expecting Oracle vision media files in V.zip format
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034614-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034637-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034645-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034652-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034656-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034663-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034669-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034670-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_1of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1034671-01_2of2.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/V1035290-01.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/p31090393_1036_Linux-x86-64.zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/p31090393_122140_Linux-x86-64 (2).zip
gs://oracle-ebs-toolkit-storage-bucket-c7855f10/Vision_media/

### DNF preinstalled Oracle packages
Installed Packages
oracle-database-preinstall-19c.x86_64           1.0-2.el8         @ol8_appstream
oracle-ebs-server-R12-preinstall.x86_64         1.0-3.el8         @ol8_addons

### /VMKD contents - expecting .vmdk file and 1.lvm file
total 494033492
-rw-r--r-- 1 root root   1073741824 Apr 26  2023 0.img
-rw-r--r-- 1 root root 428421939200 Aug 29 10:08 1.lvm
-rw-rw---- 1 halt root  76394591232 Apr 26  2023 Oracle-E-Business-Suite-12.2.12_VISION_INSTALL-disk001.vmdk
-rw-r----- 1 halt root         9534 Apr 26  2023 Oracle-E-Business-Suite-12.2.12_VISION_INSTALL.ovf

### /scripts contents - expecting vision_apps_fs_prepare.sh, vision_apps_startup.sh and 7zz
total 2864
-rwxrwxrwx 1 root                      root                      2878000 Aug 29 09:17 7zz
-rwxrwxrwx 1 root                      root                          305 Aug 29 09:17 vision_apps_env.sh
-rwxrwxrwx 1 root                      root                         1144 Aug 29 09:17 vision_apps_fs_mount.sh
-rwxrwxrwx 1 root                      root                         4108 Aug 29 09:17 vision_apps_fs_prepare.sh
-rw-rw-r-- 1 ext_user_company_com ext_user_company_com   21670 Aug 29 09:58 vision_apps_fs_prepare.sh..log
-rwxrwxrwx 1 root                      root                         3541 Aug 29 09:17 vision_apps_startup.sh
-rwxrwxrwx 1 root                      root                         1627 Aug 29 09:17 vision_apps_troubleshoot.sh
-rw-r--r-- 1 root                      root                         2830 Aug 29 10:08 vision_apps_troubleshoot.sh..log

### root crontab - expecting script to mount LVM on reboot
@reboot hostnamectl set-hostname apps

### oracle crontab - expecting script to start EBS on reboot

### /etc/hosts file has apps entry
10.115.0.30 apps.example.com apps oracle-vision.us-west2-a.c.oracle-ebs-toolkit.internal oracle-vision

### server hostaname is set to: apps
apps

### /u01/ Filesystem is mounted
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/ol-home  341G  301G   40G  89% /u01

### Environment files are present
-rw-r--r--. 1 oracle oinstall 6469 Apr 22  2023 /u01/install/APPS/EBSapps.env

### Oracle Database running
oracle      2760       1  0 09:54 ?        00:00:00 ora_pmon_EBSCDB

### Oracle listener running
oracle      2741       1  0 09:54 ?        00:00:00 /u01/install/APPS/19.0.0/bin/tnslsnr EBSCDB -inherit
oracle      4221       1  0 09:55 ?        00:00:00 /u01/install/APPS/fs1/EBSapps/10.1.2/bin/tnslsnr APPS_EBSDB -inherit

### Oracle EBS apps running
oracle      3728    3606  0 09:54 ?        00:00:00 /u01/install/APPS/fs1/FMW_Home/webtier/ohs/bin/httpd.worker -DSSL
oracle      3836    3728  0 09:54 ?        00:00:00 /u01/install/APPS/fs1/FMW_Home/webtier/ohs/bin/httpd.worker -DSSL
oracle      3839    3728  0 09:54 ?        00:00:00 /u01/install/APPS/fs1/FMW_Home/webtier/ohs/bin/httpd.worker -DSSL
oracle      3843    3728  0 09:54 ?        00:00:00 /u01/install/APPS/fs1/FMW_Home/webtier/ohs/bin/httpd.worker -DSSL
oracle      3845    3728  0 09:54 ?        00:00:00 /u01/install/APPS/fs1/FMW_Home/webtier/ohs/bin/httpd.worker -DSSL
oracle      6270    4119 10 09:56 ?        00:01:15 /u01/install/APPS/fs1/EBSapps/comn/util/jdk64/bin/java -Dweblogic.Name=oacore_server1 -Djava.security.policy=null -Djava.library.path=/u01/install/APPS/fs1/FMW_Home/patch_wls1036/profiles/default/native:/u01/install/APPS/fs1/EBSapps/comn/util/jdk32/jre/lib/i386/server:/u01/install/APPS/fs1/EBSapps/comn/util/jdk32/jre/lib/i386:/u01/install/APPS/fs1/EBSapps/comn/util/jdk32/jre/../lib/i386:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386/server:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386/native_threads:/u01/install/APPS/fs1/EBSapps/appl/cz/12.0.0/bin:/u01/install/APPS/fs1/EBSapps/10.1.2/lib32:/u01/install/APPS/fs1/EBSapps/10.1.2/lib:/usr/X11R6/lib:/usr/openwin/lib:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386/server:/u01/install/APPS/fs1/EBSapps/10.1.2/jdk/jre/lib/i386/native_threads:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/native/linux/x86_64:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/native/linux/x86_64/oci920_8:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib -Djava.class.path=/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.jdbc_11.1.1/ojdbc6dms.jar:/u01/install/APPS/fs1/FMW_Home/patch_wls1036/profiles/default/sys_manifest_classpath/weblogic_patch.jar:/u01/install/APPS/fs1/EBSapps/comn/util/jdk64/lib/tools.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/weblogic_sp.jar:/u01/install/APPS/fs1/FMW_Home/modules/javax.mail_1.6.2.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/weblogic.jar:/u01/install/APPS/fs1/FMW_Home/modules/features/weblogic.server.modules_10.3.6.0.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/webservices.jar:/u01/install/APPS/fs1/FMW_Home/modules/org.apache.ant_1.7.1/lib/ant-all.jar:/u01/install/APPS/fs1/FMW_Home/modules/net.sf.antcontrib_1.1.0.0_1-0b2/lib/ant-contrib.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/soa/modules/commons-cli-1.1.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/soa/modules/oracle.soa.mgmt_11.1.1/soa-infra-mgmt.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/webcenter/modules/oracle.portlet.server_11.1.1/oracle-portlet-api.jar:/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.jrf_11.1.1/jrf.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/common/derby/lib/derbyclient.jar:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/xqrl.jar:/u01/install/APPS/fs1/EBSapps/comn/java/classes/oracle/apps/fnd/jar/xdoprotocolwrapper.jar:/u01/install/APPS/fs1/EBSapps/comn/java/classes/oracle/apps/fnd/jar/ebsdomainstartup.jar:/u01/install/APPS/fs1/EBSapps/comn/java/classes/oracle/apps/fnd/jar/wlsconnfilter.jar -Dweblogic.system.BootIdentityFile=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/oacore_server1/security/boot.properties -Dweblogic.nodemanager.ServiceEnabled=true -XX:PermSize=128m -XX:MaxPermSize=512m -Xms2048m -Xmx2048m -Djava.security.policy=/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/lib/weblogic.policy -Djava.security.egd=file:/dev/./urandom -Dweblogic.ProductionModeEnabled=true -da -Dplatform.home=/u01/install/APPS/fs1/FMW_Home/wlserver_10.3 -Dwls.home=/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server -Dweblogic.home=/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server -Dcommon.components.home=/u01/install/APPS/fs1/FMW_Home/oracle_common -Djrf.version=11.1.1 -Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.Jdk14Logger -Ddomain.home=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain -Djrockit.optfile=/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.jrf_11.1.1/jrocket_optfile.txt -Doracle.server.config.dir=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/config/fmwconfig/servers/AdminServer -Doracle.domain.config.dir=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/config/fmwconfig -Digf.arisidbeans.carmlloc=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/config/fmwconfig/carml -Digf.arisidstack.home=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/config/fmwconfig/arisidprovider -Doracle.security.jps.config=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/config/fmwconfig/jps-config.xml -Doracle.deployed.app.dir=/u01/install/APPS/fs1/FMW_Home/user_projects/domains/EBS_domain/servers/AdminServer/tmp/_WL_user -Doracle.deployed.app.ext=/- -Dweblogic.alternateTypesDirectory=/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.ossoiap_11.1.1,/u01/install/APPS/fs1/FMW_Home/oracle_common/modules/oracle.oamprovider_11.1.1 -Djava.protocol.handler.pkgs=oracle.mds.net.protocol -Dweblogic.jdbc.remoteEnabled=false -Dportlet.oracle.home=/u01/install/APPS/fs1/FMW_Home/oracle_common -Dem.oracle.home=/u01/install/APPS/fs1/FMW_Home/oracle_common -Dweblogic.management.discover=true -Dwlw.iterativeDev=false -Dwlw.testConsole=false -Dwlw.logErrorsToConsole=false -Dweblogic.ext.dirs=/u01/install/APPS/fs1/FMW_Home/patch_wls1036/profiles/default/sysext_manifest_classpath -Dweblogic.wsee.wstx.wsat.deployed=false -Dweblogic.resourcepool.max_test_wait_secs=0 -Dweblogic.Name=oacore_server1 -Dweblogic.management.server=http://apps.example.com:7001 -Djava.library.path=/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64:/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64/server:/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64/native_threads:/u01/install/APPS/fs1/EBSapps/appl/cz/12.0.0/bin64:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib64:${LD_LIBRARY_PATH:=}:/u01/install/APPS/fs1/EBSapps/10.1.2/lib:/usr/X11R6/lib:/usr/openwin/lib:/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64:/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64/server:/u01/install/APPS/fs1/FMW_Home/webtier/jdk/jre/lib/amd64/native_threads:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib64:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib:/u01/install/APPS/fs1/FMW_Home/patch_wls1036/profiles/default/native:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/native/linux/x86_64:/u01/install/APPS/fs1/FMW_Home/wlserver_10.3/server/native/linux/x86_64/oci920_8::/u01/install/APPS/fs1/FMW_Home/webtier/lib:/u01/install/APPS/fs1/EBSapps/appl/cz/12.0.0/bin64:/u01/install/APPS/fs1/EBSapps/appl/iby/12.0.0/bin:/u01/install/APPS/fs1/EBSapps/appl/pon/12.0.0/bin64:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib64:/u01/install/APPS/fs1/EBSapps/appl/sht/12.0.0/lib -DserverType=wlx -Doracle.xdkjava.security.resolveEntityDefault=false -Doracle.xml.parser.XMLParser.ExpandEntityRef=false -Doracle.jdbc.autoCommitSpecCompliant=false -Doracle.jdbc.DateZeroTime=true -Doracle.jdbc.DateZeroTimeExtra=true weblogic.Server
root        7065    6988  0 10:08 ?        00:00:00 grep -E httpd|oacore

### Call frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1197  100  1197    0     0   584k      0 --:--:-- --:--:-- --:--:-- 1168k
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
<META http-equiv=REFRESH content="1; URL=http://apps.example.com:8000/OA_HTML/AppsLogin">
</HEAD>
<body>
<DIV ID="content">
The E-Business Home Page is located at <a href="http://apps.example.com:8000/OA_HTML/AppsLogin">http://apps.example.com:8000/OA_HTML/AppsLogin</a><br>
If your browser doesn't automatically redirect to its new location, click
<A HREF="http://apps.example.com:8000/OA_HTML/AppsLogin">here</A>.
</DIV>
</body>
</html>


[user@desktop] ebs-infra-framework % make vision_ebs_stop

>>>Oracle Vision EBS: Stop
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	   --command "sudo -u oracle bash -c 'kill -9 -1; ps -fea | grep oracle'"
root        7103    7102 28 10:09 ?        00:00:00 sudo -u oracle bash -c kill -9 -1; ps -fea | grep oracle
oracle      7118    7103  0 10:09 ?        00:00:00 bash -c kill -9 -1; ps -fea | grep oracle
oracle      7119    7118  0 10:09 ?        00:00:00 ps -fea
oracle      7120    7118  0 10:09 ?        00:00:00 grep oracle

[user@desktop] ebs-infra-framework % make vision_ebs_start

>>>Oracle Vision EBS: Startup
gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project oracle-ebs-toolkit \
	  --command "sudo -u oracle bash -c '/scripts/vision_apps_startup.sh | tee -a /scripts/vision_apps_startup.sh.log'"
Directory /u01/install/APPS is available.
Add crontab

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 10:09:50 2025
Version 19.18.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0

SQL> ORACLE instance shut down.
SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.18.0.0.0
Logfile: /u01/install/APPS/19.0.0/appsutil/log/EBSDB_apps/addlnctl.txt

You are running addlnctl.sh version 120.4

grep: /u01/install/APPS/19.0.0/network/admin/EBSDB_apps/listener.ora: No such file or directory

Starting listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 29-AUG-2025 10:09:53

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
Start Date                29-AUG-2025 10:09:53
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


SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 10:09:53 2025
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

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Aug 29 10:10:06 2025
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

grep: /u01/install/APPS/19.0.0/network/admin/EBSDB_apps/listener.ora: No such file or directory

Finding status of listener process EBSCDB ...


LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 29-AUG-2025 10:10:06

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=apps.example.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     EBSCDB
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                29-AUG-2025 10:09:53
Uptime                    0 days 0 hr. 0 min. 12 sec
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


  E-Business Suite Environment Information
  ----------------------------------------
  RUN File System           : /u01/install/APPS/fs1/EBSapps/appl
  PATCH File System         : /u01/install/APPS/fs2/EBSapps/appl
  Non-Editioned File System : /u01/install/APPS/fs_ne


  DB Host: apps.example.com  Service/SID: EBSDB


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
*** Log File = /u01/install/APPS/fs1/inst/apps/EBSDB_apps/logs/appl/rgf/TXK/txkChkEBSDependecies_Fri_Aug_29_10_10_10_2025/txkChkEBSDependecies_Fri_Aug_29_10_10_10_2025.log

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
Starting EBSDB_0829@EBSDB Internal Concurrent Manager
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

Log filename : L7624481.log


Report filename : O7624481.out


         =========================================
                 Oracle Vision Deployment
         =========================================
          UR                 : http://apps.example.com:8000
          User               : SYSADMIN
          Password           : SYSADMIN12 (case sensitive)

          hosts file entry   : 127.0.0.1 apps.example.com apps
          IAP tunneling      :
          	cloud compute ssh --zone us-west2-a oracle-vision --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
         -----------------------------------------



[user@desktop] ebs-infra-framework % gcloud compute ssh --zone us-west2-a oracle-vision --tunnel-through-iap --project oracle-ebs-toolkit -- -L 8000:localhost:8000
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Aug 29 10:07:27 2025 from 35.235.241.192
[ext_user_company_com@apps ~]$ curl http://apps.example.com:8000
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
<META http-equiv=REFRESH content="1; URL=http://apps.example.com:8000/OA_HTML/AppsLogin">
</HEAD>
<body>
<DIV ID="content">
The E-Business Home Page is located at <a href="http://apps.example.com:8000/OA_HTML/AppsLogin">http://apps.example.com:8000/OA_HTML/AppsLogin</a><br>
If your browser doesn't automatically redirect to its new location, click
<A HREF="http://apps.example.com:8000/OA_HTML/AppsLogin">here</A>.
</DIV>
</body>
</html>
[ext_user_company_com@apps ~]$ logout
Connection to compute.5191411279643595211 closed.


```

### Destroy Environment

Note: expected to keep the bucket and VM disk after destory

```bash



[user@desktop] ebs-infra-framework % make vision_destroy
terraform -chdir=projects/oracle-ebs-toolkit destroy -auto-approve \
	  -var="project_id=oracle-ebs-toolkit" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" \
	  -var="oracle_ebs_vision=true"
random_id.bucket_suffix: Refreshing state... [id=x4VfEA]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/storage.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/compute.googleapis.com]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit/iam.googleapis.com]
module.network.module.vpc.google_compute_network.network: Refreshing state... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
google_service_account.project_sa: Refreshing state... [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
module.ebs_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-123456@gs-project-accounts.iam.gserviceaccount.com]
module.ebs_storage_bucket.google_storage_bucket.bucket: Refreshing state... [id=oracle-ebs-toolkit-storage-bucket-c7855f10]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Refreshing state... [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Refreshing state... [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Refreshing state... [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Refreshing state... [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Refreshing state... [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Refreshing state... [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Refreshing state... [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Refreshing state... [id=b/oracle-ebs-toolkit-storage-bucket-c7855f10/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_compute_address.vision_server_internal_ip[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/vision-server-internal-ip]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
module.cloud_router.google_compute_router.router: Refreshing state... [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Refreshing state... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
google_compute_instance.vision[0]: Refreshing state... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision]
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Refreshing state... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"] will be destroyed
  - resource "google_compute_address" "nat_ip" {
      - address            = "34.102.114.168" -> null
      - address_type       = "EXTERNAL" -> null
      - creation_timestamp = "2025-08-29T02:12:25.774-07:00" -> null
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

  # google_compute_address.vision_server_internal_ip[0] will be destroyed
  - resource "google_compute_address" "vision_server_internal_ip" {
      - address            = "10.115.0.30" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2025-08-29T02:13:03.746-07:00" -> null
      - effective_labels   = {} -> null
      - id                 = "projects/oracle-ebs-toolkit/regions/us-west2/addresses/vision-server-internal-ip" -> null
      - label_fingerprint  = "42WmSpB8rSM=" -> null
      - labels             = {} -> null
      - name               = "vision-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "us-west2" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/addresses/vision-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01" -> null
      - terraform_labels   = {} -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_instance.vision[0] will be destroyed
  - resource "google_compute_instance" "vision" {
      - can_ip_forward       = false -> null
      - cpu_platform         = "AMD Rome" -> null
      - current_status       = "RUNNING" -> null
      - deletion_protection  = false -> null
      - effective_labels     = {
          - "application" = "oracle-ebs-vision"
          - "managed-by"  = "terraform"
        } -> null
      - enable_display       = false -> null
      - guest_accelerator    = [] -> null
      - id                   = "projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision" -> null
      - instance_id          = "5191411279643595211" -> null
      - label_fingerprint    = "H8MwPh5m8cg=" -> null
      - labels               = {
          - "application" = "oracle-ebs-vision"
          - "managed-by"  = "terraform"
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
                # set hostname
                hostnamectl set-hostname apps

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
      - metadata_fingerprint = "mwLdxs6s9bo=" -> null
      - name                 = "oracle-vision" -> null
      - project              = "oracle-ebs-toolkit" -> null
      - resource_policies    = [] -> null
      - self_link            = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision" -> null
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
          - "application" = "oracle-ebs-vision"
          - "managed-by"  = "terraform"
        } -> null
      - zone                 = "us-west2-a" -> null
        # (3 unchanged attributes hidden)

      - boot_disk {
          - auto_delete                = false -> null
          - device_name                = "persistent-disk-0" -> null
          - mode                       = "READ_WRITE" -> null
          - source                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/zones/us-west2-a/disks/oracle-vision" -> null
            # (3 unchanged attributes hidden)

          - initialize_params {
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20250322" -> null
              - labels                      = {} -> null
              - provisioned_iops            = 0 -> null
              - provisioned_throughput      = 0 -> null
              - resource_manager_tags       = {} -> null
              - size                        = 1024 -> null
              - type                        = "pd-ssd" -> null
                # (1 unchanged attribute hidden)
            }
        }

      - network_interface {
          - internal_ipv6_prefix_length = 0 -> null
          - name                        = "nic0" -> null
          - network                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
          - network_ip                  = "10.115.0.30" -> null
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
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/compute.instanceAdmin.v1" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/iam.serviceAccountUser" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/iap.tunnelResourceAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/logging.logWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/monitoring.metricWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
      - id      = "oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit" -> null
      - role    = "roles/secretmanager.secretAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwY9fWymctM=" -> null
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
      - unique_id    = "107877639534189706975" -> null
        # (1 unchanged attribute hidden)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be destroyed
  - resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      - bucket = "b/oracle-ebs-toolkit-storage-bucket-c7855f10" -> null
      - etag   = "CAI=" -> null
      - id     = "b/oracle-ebs-toolkit-storage-bucket-c7855f10/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - member = "serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com" -> null
      - role   = "roles/storage.objectAdmin" -> null
    }

  # random_id.bucket_suffix will be destroyed
  - resource "random_id" "bucket_suffix" {
      - b64_std     = "x4VfEA==" -> null
      - b64_url     = "x4VfEA" -> null
      - byte_length = 4 -> null
      - dec         = "3347406608" -> null
      - hex         = "c7855f10" -> null
      - id          = "x4VfEA" -> null
    }

  # module.cloud_router.google_compute_router.router will be destroyed
  - resource "google_compute_router" "router" {
      - creation_timestamp            = "2025-08-29T02:13:03.611-07:00" -> null
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
      - force_destroy               = false -> null
      - id                          = "oracle-ebs-toolkit-storage-bucket-c7855f10" -> null
      - labels                      = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - location                    = "US-WEST2" -> null
      - name                        = "oracle-ebs-toolkit-storage-bucket-c7855f10" -> null
      - project                     = "oracle-ebs-toolkit" -> null
      - project_number              = 123456 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/oracle-ebs-toolkit-storage-bucket-c7855f10" -> null
      - storage_class               = "NEARLINE" -> null
      - terraform_labels            = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-ebs-toolkit"
        } -> null
      - uniform_bucket_level_access = true -> null
      - url                         = "gs://oracle-ebs-toolkit-storage-bucket-c7855f10" -> null

      - soft_delete_policy {
          - effective_time             = "2025-08-29T09:12:25.333Z" -> null
          - retention_duration_seconds = 604800 -> null
        }

      - versioning {
          - enabled = true -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2025-08-29T02:13:03.650-07:00" -> null
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
            ] -> null
          - protocol = "tcp" -> null
        }

      - log_config {
          - metadata = "INCLUDE_ALL_METADATA" -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2025-08-29T02:13:03.641-07:00" -> null
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
      - creation_timestamp      = "2025-08-29T02:13:03.660-07:00" -> null
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
      - creation_timestamp      = "2025-08-29T02:13:03.578-07:00" -> null
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
      - creation_timestamp      = "2025-08-29T02:13:03.681-07:00" -> null
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
      - creation_timestamp      = "2025-08-29T02:13:03.665-07:00" -> null
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
      - creation_timestamp      = "2025-08-29T02:13:03.648-07:00" -> null
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
      - creation_timestamp         = "2025-08-29T02:12:50.155-07:00" -> null
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
      - numeric_id                                = "4935778313699119126" -> null
      - project                                   = "oracle-ebs-toolkit" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network" -> null
        # (3 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 30 to destroy.

Changes to Outputs:
  - deployment_summary = <<-EOT
        =========================================
                Oracle Vision VM Deployment
        =========================================

         Project ID         : oracle-ebs-toolkit
         Region             : us-west2
         Zone               : us-west2-a
         VPC Network        : oracle-ebs-toolkit-network

        -----------------------------------------
         Vision Instance
        -----------------------------------------
           • Name           : oracle-vision
           • Internal IP    : 10.115.0.30
           • External IP    : N/A
           • SSH Command    :
               gcloud compute ssh --zone "us-west2-a" "oracle-vision" --tunnel-through-iap --project "oracle-ebs-toolkit"

        -----------------------------------------
         Storage
        -----------------------------------------
           • Bucket Name    : oracle-ebs-toolkit-storage-bucket-c7855f10
           • Bucket URL     : gs://oracle-ebs-toolkit-storage-bucket-c7855f10

        -----------------------------------------
         Summary
        -----------------------------------------
           • Total Instances: 1
           • Instance Name  : oracle-vision
           • Generated At   : 2025-08-29T09:13:21Z
        =========================================
    EOT -> null
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destroying... [id=oracle-ebs-toolkit/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Destroying... [id=b/oracle-ebs-toolkit-storage-bucket-c7855f10/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destroying... [id=oracle-ebs-toolkit/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/compute.googleapis.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destroying... [id=oracle-ebs-toolkit/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destroying... [id=oracle-ebs-toolkit/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destruction complete after 0s
google_compute_instance.vision[0]: Destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destroying... [id=oracle-ebs-toolkit/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Destruction complete after 8s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destruction complete after 10s
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destroying... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-toolkit-network-cloud-router/oracle-ebs-toolkit-nat-01]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destruction complete after 10s
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destroying... [id=oracle-ebs-toolkit/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still destroying... [id=oracle-ebs-toolkit/roles/monitoring.met...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still destroying... [id=oracle-ebs-toolkit/roles/compute.instan...le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still destroying... [id=oracle-ebs-toolkit/roles/secretmanager....le-ebs-toolkit.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-http-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-db-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-icmp-in, 00m10s elapsed]
google_compute_instance.vision[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destruction complete after 10s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destruction complete after 11s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destruction complete after 11s
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/iam.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit/storage.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destruction complete after 0s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destruction complete after 12s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destruction complete after 12s
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destroying... [id=oracle-ebs-toolkit/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destroying... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destruction complete after 12s
module.ebs_storage_bucket.google_storage_bucket.bucket: Destroying... [id=oracle-ebs-toolkit-storage-bucket-c7855f10]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-https-in, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destruction complete after 7s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destruction complete after 11s
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destruction complete after 10s
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Still destroying... [id=oracle-ebs-toolkit/us-west2/oracle-ebs-...cloud-router/oracle-ebs-toolkit-nat-01, 00m10s elapsed]
google_compute_instance.vision[0]: Still destroying... [id=projects/oracle-ebs-toolkit/zones/us-west2-a/instances/oracle-vision, 00m20s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-iap-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-internal-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/firewalls/allow-external-app-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destruction complete after 12s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still destroying... [id=projects/oracle-ebs-toolkit/global/routes/nat-egress-internet, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destruction complete after 12s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destruction complete after 12s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destruction complete after 12s
module.cloud_router.google_compute_router_nat.nats["oracle-ebs-toolkit-nat-01"]: Destruction complete after 14s
module.cloud_router.google_compute_router.router: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/routers/oracle-ebs-toolkit-network-cloud-router]
google_compute_instance.vision[0]: Destruction complete after 25s
google_service_account.project_sa: Destroying... [id=projects/oracle-ebs-toolkit/serviceAccounts/project-service-account@oracle-ebs-toolkit.iam.gserviceaccount.com]
google_compute_address.vision_server_internal_ip[0]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/vision-server-internal-ip]
google_service_account.project_sa: Destruction complete after 1s
google_compute_address.vision_server_internal_ip[0]: Destruction complete after 2s
module.cloud_router.google_compute_router.router: Still destroying... [id=projects/oracle-ebs-toolkit/regions/us-...racle-ebs-toolkit-network-cloud-router, 00m10s elapsed]
module.cloud_router.google_compute_router.router: Destruction complete after 14s
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/addresses/oracle-ebs-toolkit-nat-01]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Destroying... [id=projects/oracle-ebs-toolkit/regions/us-west2/subnetworks/oracle-ebs-toolkit-subnet-01]
google_compute_address.nat_ip["oracle-ebs-toolkit-nat-01"]: Destruction complete after 2s
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Still destroying... [id=projects/oracle-ebs-toolkit/regions/us-...bnetworks/oracle-ebs-toolkit-subnet-01, 00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-west2/oracle-ebs-toolkit-subnet-01"]: Destruction complete after 11s
module.network.module.vpc.google_compute_network.network: Destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network, 00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit/global/networks/oracle-ebs-toolkit-network, 00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Destruction complete after 22s
╷
│ Error: Error trying to delete bucket oracle-ebs-toolkit-storage-bucket-c7855f10 containing objects without `force_destroy` set to true
│
│
╵
Releasing state lock. This may take a few moments...
make: *** [vision_destroy] Error 1

[user@desktop] ebs-infra-framework %

```
