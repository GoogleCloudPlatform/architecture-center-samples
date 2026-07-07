# Oracle Peoplesoft Toolkit on GCP logfile output example

This file shows example of executing Oracle Peoplesoft Customer environment on GCP deployment log and outputs as well as timings and expected results


### 1. Setup the environment

```bash
Last login: Wed May 20 14:09:06 on ttys002

[user@host] ~ % cd GitHub/architecture-center-samples/oracle-peoplesoft-framework
[user@host] oracle-peoplesoft-framework % ls -l
total 136
-rw-r--r--@ 1 user  staff   407 May 20 14:21 backend.tf
-rw-r--r--@ 1 user  staff   684 May 20 14:21 buckets.tf
-rw-r--r--@ 1 user  staff  2771 May 20 14:21 firewall-rules.tf
-rw-r--r--@ 1 user  staff   849 May 20 14:21 infra.auto.tfvars
-rw-r--r--@ 1 user  staff   359 May 20 14:21 locals.tf
-rw-r--r--@ 1 user  staff  5309 May 20 14:21 Makefile
-rw-r--r--@ 1 user  staff  1173 May 20 14:21 output.tf
-rw-r--r--@ 1 user  staff   434 May 20 14:21 project.tf
-rw-r--r--@ 1 user  staff   149 May 20 14:21 provider.tf
-rw-r--r--@ 1 user  staff  5468 May 20 14:29 README.md
drwxr-xr-x@ 5 user  staff   160 May 20 14:21 scripts
-rw-r--r--@ 1 user  staff   407 May 20 14:21 service-accounts.tf
-rw-r--r--@ 1 user  staff  6259 May 20 14:21 variables.tf
-rw-r--r--@ 1 user  staff  2855 May 20 14:21 vm.tf
-rw-r--r--@ 1 user  staff  2284 May 20 14:21 vpc.tf
[user@host] oracle-peoplesoft-framework % make setup
Running setup...
bash scripts/install.sh
gcloud already exists.
✔ Terraform already installed: 1.13.0
✔ terraform-docs already installed: 0.20.0
All tools installed and configured.
Setup complete.
Make sure you are setup with gcloud init with the project that will be used for this deployment and proceed to verify-gcp-access'.
[user@host] oracle-peoplesoft-framework % gcloud config list
[core]
account = user@example.com
disable_usage_reporting = False
project = oracle-plpsft-toolkit-demo

Your active configuration is: [default]
[environment: untagged] Read more to tag: g.co/cloud/project-env-tag.
[user@host] oracle-peoplesoft-framework % make verify-gcp-access
 Verifying GCP access for project: oracle-plpsft-toolkit-demo
Access to project oracle-plpsft-toolkit-demo confirmed.
 Checking IAM roles for user@example.com...
 User has Owner/Editor role → skipping fine-grained permission checks.

 GCP access check passed for project: oracle-plpsft-toolkit-demo
```

---

### 3. Deploy Peoplesoft Infrastructure

Run the commands below to deploy the Oracle Peoplesoft single-node demo environment:

```bash


[user@host] oracle-peoplesoft-framework % make init
Checking if backend bucket gs://oracle-plpsft-toolkit-demo-119724395047-terraform-state exists...
Initializing Terraform in ....
Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Downloading registry.terraform.io/terraform-google-modules/cloud-router/google 6.1.0 for cloud_router...
- cloud_router in .terraform/modules/cloud_router
Downloading registry.terraform.io/terraform-google-modules/network/google 18.1.0 for firewall_rules...
- firewall_rules in .terraform/modules/firewall_rules/modules/firewall-rules
Downloading registry.terraform.io/terraform-google-modules/network/google 18.1.0 for nat_gateway_route...
- nat_gateway_route in .terraform/modules/nat_gateway_route/modules/routes
Downloading registry.terraform.io/terraform-google-modules/network/google 18.1.0 for network...
- network in .terraform/modules/network
- network.firewall_rules in .terraform/modules/network/modules/firewall-rules
- network.private_service_access in .terraform/modules/network/modules/private-service-access
- network.routes in .terraform/modules/network/modules/routes
- network.subnets in .terraform/modules/network/modules/subnets
- network.vpc in .terraform/modules/network/modules/vpc
Downloading registry.terraform.io/terraform-google-modules/cloud-storage/google 12.3.0 for peoplesoft_storage_bucket...
- peoplesoft_storage_bucket in .terraform/modules/peoplesoft_storage_bucket/modules/simple_bucket
Downloading registry.terraform.io/terraform-google-modules/kms/google 4.1.2 for peoplesoft_storage_bucket.encryption_key...
- peoplesoft_storage_bucket.encryption_key in .terraform/modules/peoplesoft_storage_bucket.encryption_key
Downloading registry.terraform.io/terraform-google-modules/project-factory/google 18.2.0 for project_services...
- project_services in .terraform/modules/project_services/modules/project_services
Initializing provider plugins...
- Finding hashicorp/google-beta versions matching ">= 3.43.0, >= 4.64.0, >= 6.18.0, >= 6.19.0, >= 6.37.0, < 8.0.0"...
- Finding hashicorp/google versions matching ">= 3.33.0, >= 3.43.0, >= 3.83.0, >= 4.51.0, >= 4.64.0, >= 5.31.0, >= 6.18.0, >= 6.19.0, >= 6.28.0, >= 6.37.0, < 7.0.0, < 8.0.0"...
- Finding latest version of hashicorp/random...
- Finding latest version of hashicorp/null...
- Installing hashicorp/google-beta v7.33.0...
- Installed hashicorp/google-beta v7.33.0 (signed by HashiCorp)
- Installing hashicorp/google v6.50.0...
- Installed hashicorp/google v6.50.0 (signed by HashiCorp)
- Installing hashicorp/random v3.9.0...
- Installed hashicorp/random v3.9.0 (signed by HashiCorp)
- Installing hashicorp/null v3.3.0...
- Installed hashicorp/null v3.3.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Terraform initialized successfully.
[user@host] oracle-peoplesoft-framework % make plan
terraform -chdir=. plan \
	  -var="project_id=oracle-plpsft-toolkit-demo" \
	  -var="project_service_account_email=project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
data.google_compute_image.apps_image: Reading...
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-peoplesoft-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-plpsft-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "us-central1"
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
      + project            = "oracle-plpsft-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "us-central1"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-peoplesoft-toolkit-subnet-01"
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
      + project              = "oracle-plpsft-toolkit-demo"
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
      + zone                 = "us-central1-a"

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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513"
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
          + email  = "project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
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

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/storage.admin"
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "oracle-plpsft-toolkit-demo"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + role   = "roles/storage.objectAdmin"
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

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-peoplesoft-toolkit-network-cloud-router"
      + network            = "oracle-peoplesoft-toolkit-network"
      + project            = "oracle-plpsft-toolkit-demo"
      + region             = "us-central1"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-peoplesoft-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-plpsft-toolkit-demo"
      + region                              = "us-central1"
      + router                              = "oracle-peoplesoft-toolkit-network-cloud-router"
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
          + name                     = "oracle-peoplesoft-toolkit-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network                    = "oracle-peoplesoft-toolkit-network"
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
      + project                    = "oracle-plpsft-toolkit-demo"
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
          + "service"                    = "oracle-peoplesoft-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-peoplesoft-toolkit"
        }
      + location                    = "US-CENTRAL1"
      + name                        = (known after apply)
      + project                     = "oracle-plpsft-toolkit-demo"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-peoplesoft-toolkit"
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
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"] will be created
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
      + name                       = "oracle-peoplesoft-toolkit-subnet-01"
      + network                    = "oracle-peoplesoft-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-plpsft-toolkit-demo"
      + purpose                    = (known after apply)
      + region                     = "us-central1"
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
      + name                                      = "oracle-peoplesoft-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-plpsft-toolkit-demo"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
[user@host] oracle-peoplesoft-framework % make deploy
terraform -chdir=. apply -auto-approve \
	  -var="project_id=oracle-plpsft-toolkit-demo" \
	  -var="project_service_account_email=project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
data.google_compute_image.apps_image: Reading...
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"] will be created
  + resource "google_compute_address" "nat_ip" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + effective_labels   = {
          + "goog-terraform-provisioned" = "true"
        }
      + id                 = (known after apply)
      + label_fingerprint  = (known after apply)
      + name               = "oracle-peoplesoft-toolkit-nat-01"
      + network_tier       = (known after apply)
      + prefix_length      = (known after apply)
      + project            = "oracle-plpsft-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "us-central1"
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
      + project            = "oracle-plpsft-toolkit-demo"
      + purpose            = (known after apply)
      + region             = "us-central1"
      + self_link          = (known after apply)
      + subnetwork         = "oracle-peoplesoft-toolkit-subnet-01"
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
      + project              = "oracle-plpsft-toolkit-demo"
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
      + zone                 = "us-central1-a"

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
              + image                  = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513"
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
          + email  = "project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
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

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/compute.instanceAdmin.v1"
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/iam.serviceAccountUser"
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/iap.tunnelResourceAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/logging.logWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/monitoring.metricWriter"
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/secretmanager.secretAccessor"
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be created
  + resource "google_project_iam_member" "project_sa_roles" {
      + etag    = (known after apply)
      + id      = (known after apply)
      + member  = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + project = "oracle-plpsft-toolkit-demo"
      + role    = "roles/storage.admin"
    }

  # google_service_account.project_sa will be created
  + resource "google_service_account" "project_sa" {
      + account_id   = "project-service-account"
      + disabled     = false
      + display_name = "Project Service Account"
      + email        = "project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + id           = (known after apply)
      + member       = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + name         = (known after apply)
      + project      = "oracle-plpsft-toolkit-demo"
      + unique_id    = (known after apply)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be created
  + resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      + bucket = (known after apply)
      + etag   = (known after apply)
      + id     = (known after apply)
      + member = "serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com"
      + role   = "roles/storage.objectAdmin"
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

  # module.cloud_router.google_compute_router.router will be created
  + resource "google_compute_router" "router" {
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "oracle-peoplesoft-toolkit-network-cloud-router"
      + network            = "oracle-peoplesoft-toolkit-network"
      + project            = "oracle-plpsft-toolkit-demo"
      + region             = "us-central1"
      + self_link          = (known after apply)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"] will be created
  + resource "google_compute_router_nat" "nats" {
      + auto_network_tier                   = (known after apply)
      + drain_nat_ips                       = (known after apply)
      + enable_dynamic_port_allocation      = (known after apply)
      + enable_endpoint_independent_mapping = (known after apply)
      + endpoint_types                      = (known after apply)
      + icmp_idle_timeout_sec               = 30
      + id                                  = (known after apply)
      + min_ports_per_vm                    = (known after apply)
      + name                                = "oracle-peoplesoft-toolkit-nat-01"
      + nat_ip_allocate_option              = "MANUAL_ONLY"
      + nat_ips                             = (known after apply)
      + project                             = "oracle-plpsft-toolkit-demo"
      + region                              = "us-central1"
      + router                              = "oracle-peoplesoft-toolkit-network-cloud-router"
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
          + name                     = "oracle-peoplesoft-toolkit-subnet-01"
          + secondary_ip_range_names = []
          + source_ip_ranges_to_nat  = [
              + "ALL_IP_RANGES",
            ]
        }
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network            = "oracle-peoplesoft-toolkit-network"
      + priority           = 1000
      + project            = "oracle-plpsft-toolkit-demo"
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
      + network                    = "oracle-peoplesoft-toolkit-network"
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
      + project                    = "oracle-plpsft-toolkit-demo"
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
          + "service"                    = "oracle-peoplesoft-toolkit"
        }
      + force_destroy               = true
      + id                          = (known after apply)
      + labels                      = {
          + "managed-by" = "terraform"
          + "service"    = "oracle-peoplesoft-toolkit"
        }
      + location                    = "US-CENTRAL1"
      + name                        = (known after apply)
      + project                     = "oracle-plpsft-toolkit-demo"
      + project_number              = (known after apply)
      + public_access_prevention    = "inherited"
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "NEARLINE"
      + terraform_labels            = {
          + "goog-terraform-provisioned" = "true"
          + "managed-by"                 = "terraform"
          + "service"                    = "oracle-peoplesoft-toolkit"
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
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "cloudresourcemanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["compute.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "compute.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["iam.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "iam.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["secretmanager.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "secretmanager.googleapis.com"
    }

  # module.project_services.google_project_service.project_services["storage.googleapis.com"] will be created
  + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = "oracle-plpsft-toolkit-demo"
      + service                    = "storage.googleapis.com"
    }

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"] will be created
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
      + name                       = "oracle-peoplesoft-toolkit-subnet-01"
      + network                    = "oracle-peoplesoft-toolkit-network"
      + private_ip_google_access   = true
      + private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
      + project                    = "oracle-plpsft-toolkit-demo"
      + purpose                    = (known after apply)
      + region                     = "us-central1"
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
      + name                                      = "oracle-peoplesoft-toolkit-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "oracle-plpsft-toolkit-demo"
      + routing_mode                              = "REGIONAL"
      + self_link                                 = (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + deployment_summary = (known after apply)
random_id.bucket_suffix: Creating...
random_id.bucket_suffix: Creation complete after 0s [id=0YTmow]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creating...
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creating...
google_service_account.project_sa: Creating...
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Creating...
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Creating...
module.network.module.vpc.google_compute_network.network: Creating...
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Creation complete after 2s [id=oracle-peoplesoft-toolkit-storage-bucket-d184e6a3]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Creation complete after 5s [id=oracle-plpsft-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Creation complete after 5s [id=oracle-plpsft-toolkit-demo/iam.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Creation complete after 5s [id=oracle-plpsft-toolkit-demo/secretmanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Creation complete after 5s [id=oracle-plpsft-toolkit-demo/compute.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Creation complete after 5s [id=oracle-plpsft-toolkit-demo/storage.googleapis.com]
google_service_account.project_sa: Still creating... [00m10s elapsed]
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Still creating... [00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still creating... [00m10s elapsed]
google_service_account.project_sa: Creation complete after 14s [id=projects/oracle-plpsft-toolkit-demo/serviceAccounts/project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Creating...
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creating...
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creating...
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creating...
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creating...
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creating...
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Creation complete after 16s [id=projects/oracle-plpsft-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01]
google_storage_bucket_iam_member.bucket_object_admin: Creation complete after 6s [id=b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Still creating... [00m20s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Creation complete after 9s [id=oracle-plpsft-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Creation complete after 10s [id=oracle-plpsft-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Still creating... [00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Creation complete after 10s [id=oracle-plpsft-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
module.network.module.vpc.google_compute_network.network: Creation complete after 24s [id=projects/oracle-plpsft-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Creating...
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Creation complete after 11s [id=oracle-plpsft-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Creation complete after 11s [id=oracle-plpsft-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Creation complete after 11s [id=oracle-plpsft-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Creation complete after 12s [id=oracle-plpsft-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-plpsft-toolkit-demo.iam.gserviceaccount.com]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Still creating... [00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Creation complete after 14s [id=projects/oracle-plpsft-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01]
google_compute_address.peoplesoft_apps_server_internal_ip: Creating...
module.cloud_router.google_compute_router.router: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creating...
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creating...
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creating...
module.cloud_router.google_compute_router.router: Creation complete after 3s [id=projects/oracle-plpsft-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router]
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Creating...
google_compute_address.peoplesoft_apps_server_internal_ip: Creation complete after 4s [id=projects/oracle-plpsft-toolkit-demo/regions/us-central1/addresses/peoplesoft-apps-server-internal-ip]
google_compute_instance.apps: Creating...
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still creating... [00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still creating... [00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-external-app-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Creation complete after 12s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Creation complete after 13s [id=projects/oracle-plpsft-toolkit-demo/global/firewalls/allow-iap-in]
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Still creating... [00m10s elapsed]
google_compute_instance.apps: Still creating... [00m10s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Creation complete after 13s [id=oracle-plpsft-toolkit-demo/us-central1/oracle-peoplesoft-toolkit-network-cloud-router/oracle-peoplesoft-toolkit-nat-01]
google_compute_instance.apps: Still creating... [00m20s elapsed]
google_compute_instance.apps: Still creating... [00m30s elapsed]
google_compute_instance.apps: Still creating... [00m40s elapsed]
google_compute_instance.apps: Still creating... [00m50s elapsed]
google_compute_instance.apps: Creation complete after 56s [id=projects/oracle-plpsft-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps]
null_resource.push_scripts: Creating...
null_resource.push_scripts: Provisioning with 'local-exec'...
null_resource.push_scripts (local-exec): Executing: ["/bin/sh" "-c" "echo \"Waiting 30 seconds for VM SSH daemon and IAP to initialize...\"\nsleep 30\n\necho \"Pushing .sh files to /tmp via IAP...\"\ngcloud compute scp ./scripts/peoplesoft/*.sh oracle-peoplesoft-apps:/tmp/ \\\n  --zone=\"us-central1-a\" \\\n  --project=\"oracle-plpsft-toolkit-demo\" \\\n  --tunnel-through-iap\n\necho \"Setting up /scripts directory and assigning to oracle user...\"\ngcloud compute ssh oracle-peoplesoft-apps \\\n  --zone=\"us-central1-a\" \\\n  --project=\"oracle-plpsft-toolkit-demo\" \\\n  --tunnel-through-iap \\\n  --command=\" \\\n    echo 'Checking if oracle user exists...'; \\\n    while ! id -u oracle > /dev/null 2>&1; do \\\n      echo 'Waiting for startup-script to create oracle user...'; \\\n      sleep 10; \\\n    done; \\\n    sudo mkdir -p /scripts && \\\n    sudo mv /tmp/*.sh /scripts/ && \\\n    sudo chown -R oracle:oinstall /scripts && \\\n    sudo chmod 777 /scripts && \\\n    sudo chmod a+x /scripts/*.sh \\\n  \"\n        \necho \"Scripts successfully pushed, assigned to oracle, and permissions set!\"\n"]
null_resource.push_scripts (local-exec): Waiting 30 seconds for VM SSH daemon and IAP to initialize...
null_resource.push_scripts: Still creating... [00m10s elapsed]
null_resource.push_scripts: Still creating... [00m20s elapsed]
null_resource.push_scripts: Still creating... [00m30s elapsed]
null_resource.push_scripts (local-exec): Pushing .sh files to /tmp via IAP...
null_resource.push_scripts (local-exec): WARNING:

null_resource.push_scripts (local-exec): To increase the performance of the tunnel, consider installing NumPy. For instructions,
null_resource.push_scripts (local-exec): please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

null_resource.push_scripts (local-exec): Warning: Permanently added 'compute.3112946527704720700' (ED25519) to the list of known hosts.
null_resource.push_scripts (local-exec): ** WARNING: connection is not using a post-quantum key exchange algorithm.
null_resource.push_scripts (local-exec): ** This session may be vulnerable to "store now, decrypt later" attacks.
null_resource.push_scripts (local-exec): ** The server may need to be upgraded. See https://openssh.com/pq.html
null_resource.push_scripts: Still creating... [00m40s elapsed]
null_resource.push_scripts (local-exec): Setting up /scripts directory and assigning to oracle user...
null_resource.push_scripts (local-exec): WARNING:

null_resource.push_scripts (local-exec): To increase the performance of the tunnel, consider installing NumPy. For instructions,
null_resource.push_scripts (local-exec): please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

null_resource.push_scripts (local-exec): ** WARNING: connection is not using a post-quantum key exchange algorithm.
null_resource.push_scripts (local-exec): ** This session may be vulnerable to "store now, decrypt later" attacks.
null_resource.push_scripts (local-exec): ** The server may need to be upgraded. See https://openssh.com/pq.html
null_resource.push_scripts (local-exec): Checking if oracle user exists...
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [00m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m30s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m40s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [01m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m30s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m40s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [02m50s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m00s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m10s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m20s elapsed]
null_resource.push_scripts (local-exec): Waiting for startup-script to create oracle user...
null_resource.push_scripts: Still creating... [03m30s elapsed]
null_resource.push_scripts (local-exec): Scripts successfully pushed, assigned to oracle, and permissions set!
null_resource.push_scripts: Creation complete after 3m36s [id=6371038218310223271]

Apply complete! Resources: 32 added, 0 changed, 0 destroyed.

Outputs:

deployment_summary = <<EOT

=========================================
 PeopleSoft VM Configuration
-----------------------------------------
   • Instance Name  : oracle-peoplesoft-apps
   • Internal IP    : 10.115.0.20
   • Zone           : us-central1-a
   • Machine Type   : e2-highmem-8
   • SSH Command    :
       gcloud compute ssh --zone "us-central1-a" "oracle-peoplesoft-apps" --tunnel-through-iap --project "oracle-plpsft-toolkit-demo" -- -L 8000:localhost:8000

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : oracle-peoplesoft-toolkit-storage-bucket-d184e6a3
   • Bucket URL     : gs://oracle-peoplesoft-toolkit-storage-bucket-d184e6a3

=========================================
 Summary
-----------------------------------------
   • Total Instances: 1
   • Storage Bucket : oracle-peoplesoft-toolkit-storage-bucket-d184e6a3
   • Generated At   : 2026-05-20T11:33:29Z
=========================================

EOT

```

---

### 4. Deploy Oracle Peoplesoft environment

This process lasts ~90-120 minutes

```bash

[user@host] oracle-peoplesoft-framework % make deploy_customer_peoplesoft
 
>>>Oracle Peoplesoft Customer Setup
[oracle@peoplesoft-clone ~]$ time stage_cust_data
Tue Jul  7 01:31:25 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: stage_cust_data
         =========================================================================
         Function fetching Peoplesoft customer data from bucket to local disk
         ------------------------------------------------------------------------- 

### Files on Bucket: gs://oracle-media/CDBFSCM 
         0  2026-06-23T00:12:28Z  gs://oracle-media/CDBFSCM/
  46980096  2026-06-23T00:30:42Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
  47224320  2026-06-23T00:28:42Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
  45193216  2026-06-23T00:28:48Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
  50435584  2026-06-23T00:29:30Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
  45519872  2026-06-23T00:28:18Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
  54131200  2026-06-23T00:29:23Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
  46456320  2026-06-23T00:28:54Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
  40286208  2026-06-23T00:27:53Z  gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
 611977205  2026-06-23T01:04:51Z  gs://oracle-media/CDBFSCM/PS_CFG_HOME_TO_GCP.tar.gz
10276014525  2026-06-23T02:25:57Z  gs://oracle-media/CDBFSCM/PT_TO_GCP.tar.gz
7285357854  2026-06-23T06:30:58Z  gs://oracle-media/CDBFSCM/RDBMS_TO_GCP.tar.gz
   1163264  2026-06-23T00:16:55Z  gs://oracle-media/CDBFSCM/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
        75  2026-07-07T01:21:43Z  gs://oracle-media/CDBFSCM/domaininfo.txt
 897261568  2026-06-23T01:09:19Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
1018445824  2026-06-23T01:14:22Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
1175093248  2026-06-23T01:14:52Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
 419250176  2026-06-23T00:52:37Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
 632872960  2026-06-23T01:03:27Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
  36503552  2026-06-23T00:27:16Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
 349921280  2026-06-23T00:49:49Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
 325869568  2026-06-23T00:49:41Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
 178151424  2026-06-23T00:20:51Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
 479444992  2026-06-23T00:24:53Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
   1720320  2026-06-23T00:17:29Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
 286580736  2026-06-23T00:48:47Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
  66469888  2026-06-23T00:29:57Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
  87138304  2026-06-23T00:32:09Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
   1245184  2026-06-23T00:17:13Z  gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
      1145  2026-07-07T01:21:18Z  gs://oracle-media/CDBFSCM/psft.env
    114688  2026-06-23T00:16:43Z  gs://oracle-media/CDBFSCM/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
TOTAL: 31 objects, 24506824596 bytes (22.82GiB)

### Fetching rman files from: gs://oracle-media/CDBFSCM to local disk: /u01/install/rman 
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
  
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
Copying gs://oracle-media/CDBFSCM/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp to file:///u01/install/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
Copying gs://oracle-media/CDBFSCM/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp to file:///u01/install/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
Copying gs://oracle-media/CDBFSCM/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp to file:///u01/install/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
Copying gs://oracle-media/CDBFSCM/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp to file:///u01/install/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
.........................................................

Average throughput: 546.7MiB/s

### Fetching app files from: gs://oracle-media/CDBFSCM to local disk: /u01/install/app 
Copying gs://oracle-media/CDBFSCM/PS_CFG_HOME_TO_GCP.tar.gz to file:///u01/install/app/PS_CFG_HOME_TO_GCP.tar.gz
Copying gs://oracle-media/CDBFSCM/PT_TO_GCP.tar.gz to file:///u01/install/app/PT_TO_GCP.tar.gz
  
Copying gs://oracle-media/CDBFSCM/RDBMS_TO_GCP.tar.gz to file:///u01/install/app/RDBMS_TO_GCP.tar.gz
.............................................................................................................................................................................................................................

Average throughput: 395.3MiB/s
Copying gs://oracle-media/CDBFSCM/domaininfo.txt to file:///u01/install/app/domaininfo.txt
  


### Files on local disk: /u01/install 
-rw-r--r--. 1 oracle oinstall   46980096 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
-rw-r--r--. 1 oracle oinstall   47224320 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
-rw-r--r--. 1 oracle oinstall   45193216 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
-rw-r--r--. 1 oracle oinstall   50435584 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
-rw-r--r--. 1 oracle oinstall   45519872 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
-rw-r--r--. 1 oracle oinstall   54131200 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
-rw-r--r--. 1 oracle oinstall   46456320 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
-rw-r--r--. 1 oracle oinstall   40286208 Jul  7 01:31 /u01/install/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1163264 Jul  7 01:31 /u01/install/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
-rw-r--r--. 1 oracle oinstall  897261568 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
-rw-r--r--. 1 oracle oinstall 1018445824 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
-rw-r--r--. 1 oracle oinstall 1175093248 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
-rw-r--r--. 1 oracle oinstall  419250176 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
-rw-r--r--. 1 oracle oinstall  632872960 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
-rw-r--r--. 1 oracle oinstall   36503552 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
-rw-r--r--. 1 oracle oinstall  349921280 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
-rw-r--r--. 1 oracle oinstall  325869568 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
-rw-r--r--. 1 oracle oinstall  178151424 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
-rw-r--r--. 1 oracle oinstall  479444992 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1720320 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
-rw-r--r--. 1 oracle oinstall  286580736 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
-rw-r--r--. 1 oracle oinstall   66469888 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
-rw-r--r--. 1 oracle oinstall   87138304 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
-rw-r--r--. 1 oracle oinstall    1245184 Jul  7 01:31 /u01/install/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
-rw-r--r--. 1 oracle oinstall     114688 Jul  7 01:31 /u01/install/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
-rw-r--r--. 1 oracle oinstall          75 Jul  7 01:32 /u01/install/app/domaininfo.txt
-rw-r--r--. 1 oracle oinstall   611977205 Jul  7 01:31 /u01/install/app/PS_CFG_HOME_TO_GCP.tar.gz
-rw-r--r--. 1 oracle oinstall 10276014525 Jul  7 01:32 /u01/install/app/PT_TO_GCP.tar.gz
-rw-r--r--. 1 oracle oinstall  7285357854 Jul  7 01:32 /u01/install/app/RDBMS_TO_GCP.tar.gz

log: /scripts/logs/20260707_013125_stage_cust_data.log
Tue Jul  7 01:32:27 UTC 2026

real	1m1.623s
user	1m10.143s
sys	4m43.626s
[oracle@peoplesoft-clone ~]$

[oracle@peoplesoft-clone ~]$ time rdbms_stage_oh
Tue Jul  7 01:39:55 UTC 2026

         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_stage_oh
         =========================================
         Function restores RDBMS HOME from backup
         -----------------------------------------

### Extract RDBMS Software from /u01/install/app 
RDBMS backup   : /u01/install/app/RDBMS_TO_GCP.tar.gz
Extracting non-verbose: (few mins)

real	1m48.499s
user	1m37.955s
sys	1m0.402s
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
drwxr-xr-x. 74 oracle oinstall 4096 Jun  8 01:39 /u02/db/oracle-server/19.3.0.0
total 112
drwxr-xr-x. 74 oracle oinstall  4096 Jun  8 01:39 .
drwxr-xr-x.  3 oracle oinstall    22 Jul  7 01:39 ..
drwxr-xr-x.  2 oracle oinstall   102 Jun  8 01:00 addnode
drwxr-x---.  3 oracle oinstall    20 Jun  8 01:39 admin
drwxr-xr-x.  5 oracle oinstall  4096 Nov 19  2025 apex
drwxr-xr-x.  9 oracle oinstall    93 Apr 17  2019 assistants
drwxr-xr-x.  2 oracle oinstall  8192 Jun  8 01:00 bin
drwxr-xr-x.  5 oracle oinstall    44 Jun 15 07:13 cfgtoollogs
drwxr-xr-x.  3 oracle oinstall    19 Nov 19  2025 client
..

### Configurting RDBMS HOME - relink 

### Oracle SID is set to CDBFSCM 
writing relink log to: /u02/db/oracle-server/19.3.0.0/install/relinkActions2026-07-07_01-41-44AM.log

### Backing up existing TNS and dbs 

### Setting up tnsnames.ora and listener.ora 

### Starting up listener 

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 07-JUL-2026 01:42:23

Copyright (c) 1991, 2025, Oracle.  All rights reserved.

Starting /u02/db/oracle-server/19.3.0.0/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /u02/db/oracle-server/19.3.0.0/network/admin/listener.ora
Log messages written to /u02/db/oracle-server/diag/tnslsnr/peoplesoft-clone/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal)(PORT=1521)))

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                07-JUL-2026 01:42:24
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u02/db/oracle-server/19.3.0.0/network/admin/listener.ora
Listener Log File         /u02/db/oracle-server/diag/tnslsnr/peoplesoft-clone/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal)(PORT=1521)))
The listener supports no services
The command completed successfully

### Setting up pfile 

### Startup nomount CDBFSCM 

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Jul 7 01:42:24 2026
Version 19.28.0.0.0

Copyright (c) 1982, 2025, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORACLE instance started.

Total System Global Area  436206376 bytes
Fixed Size		    8940328 bytes
Variable Size		  285212672 bytes
Database Buffers	  134217728 bytes
Redo Buffers		    7835648 bytes
SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.28.0.0.0

log: /scripts/logs/20260707_013955_rdbms_stage_oh.log
Tue Jul  7 01:42:32 UTC 2026

real	2m37.028s
user	2m5.240s
sys	1m11.751s
[oracle@peoplesoft-clone ~]$

[oracle@peoplesoft-clone ~]$ time rdbms_rman_restore
Tue Jul  7 01:51:11 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: rdbms_rman_restore
         =========================================================================
         Function to restore database - time consuming step
         ------------------------------------------------------------------------- 

### RMAN: Restoring database from Backup location 
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1c4r0qp4_44_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1d4r0qp4_45_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1e4r0qp4_46_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1f4r0qp4_47_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1g4r0qp4_48_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1h4r0qp4_49_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1i4r0qp4_50_1_1.bkp
/u01/install/rman/ARCH_CDBFSCM_20260619_ch1j4r0qp4_51_1_1.bkp
/u01/install/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch0t4r0qlj_29_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch0u4r0qlj_30_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch0v4r0qlj_31_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch104r0qlj_32_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch114r0qlj_33_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch124r0qlj_34_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch134r0qlj_35_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch144r0qlj_36_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch154r0qm2_37_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch164r0qms_38_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch174r0qmt_39_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch184r0qn0_40_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch194r0qn7_41_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch1a4r0qnm_42_1_1.bkp
/u01/install/rman/full_CDBFSCM_20260619_ch1b4r0qnm_43_1_1.bkp
/u01/install/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp

### Oracle SID is set to CDBFSCM 

### RMAN: creating rman_restore.rman file 

### RMAN: Starting rman restore...may take a long time... 

Recovery Manager: Release 19.0.0.0.0 - Production on Tue Jul 7 01:51:11 2026
Version 19.28.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to auxiliary database: CDBFSCM (not mounted)

RMAN> 
RMAN> 	run
2> 	{
3> 	  ALLOCATE auxiliary CHANNEL c1 DEVICE TYPE DISK;
4> 	  ALLOCATE auxiliary CHANNEL c2 DEVICE TYPE DISK;
5> 	  ALLOCATE auxiliary CHANNEL c3 DEVICE TYPE DISK;
6> 	  ALLOCATE auxiliary CHANNEL c4 DEVICE TYPE DISK;
7> 	  ALLOCATE auxiliary CHANNEL c5 DEVICE TYPE DISK;
8> 	  ALLOCATE auxiliary CHANNEL c6 DEVICE TYPE DISK;
9> 	  ALLOCATE auxiliary CHANNEL c7 DEVICE TYPE DISK;
10> 	  ALLOCATE auxiliary CHANNEL c8 DEVICE TYPE DISK;
11> 	  ALLOCATE auxiliary CHANNEL c9 DEVICE TYPE DISK;
12> 	  ALLOCATE auxiliary CHANNEL c10 DEVICE TYPE DISK;
13> 	  duplicate database to CDBFSCM
14> 	  spfile
15> 	  set db_unique_name 'CDBFSCM'
16> 	  set control_files '/u02/db/oradata/CDBFSCM/control01.ctl','/u02/db/oradata/CDBFSCM/control02.ctl'
17> 	  set db_create_file_dest '/u02/db/oradata/'
18> 	  set db_create_online_log_dest_1 '/u02/db/oradata/CDBFSCM'
19> 	  set db_recovery_file_dest '/u02/db/oracle-server/fast_recovery_area'
20> 	  set db_recovery_file_dest_size '100G'
21> 	  set audit_file_dest '/u02/db/oracle-server/admin'
22> 	  set core_dump_dest='/u02/db/oracle-server'
23> 	  set diagnostic_dest '/u02/db/oracle-server'
24> 	  set pga_aggregate_target '2g'
25> 	  set sga_target '15g'
26> 	  set sga_max_size '15g'
27> 	  set sessions '2000'
28> 	  set processes '1000'
29> 	  set shared_pool_reserved_size '40M'
30> 	  set shared_pool_size '400M'
31> 	  set result_cache_max_size '300M'
32> 	  set recyclebin 'OFF'
33> 	  backup location '/u01/install/rman'
34> 	  NOFILENAMECHECK;
35> 	}
36> 
37> 
allocated channel: c1
channel c1: SID=218 device type=DISK

allocated channel: c2
channel c2: SID=290 device type=DISK

allocated channel: c3
channel c3: SID=360 device type=DISK

allocated channel: c4
channel c4: SID=431 device type=DISK

allocated channel: c5
channel c5: SID=503 device type=DISK

allocated channel: c6
channel c6: SID=5 device type=DISK

allocated channel: c7
channel c7: SID=76 device type=DISK

allocated channel: c8
channel c8: SID=149 device type=DISK

allocated channel: c9
channel c9: SID=219 device type=DISK

allocated channel: c10
channel c10: SID=291 device type=DISK

Starting Duplicate Db at 07-JUL-26
searching for database ID
found backup of database ID 2271167854

contents of Memory Script:
{
   restore clone spfile to  '/u02/db/oracle-server/19.3.0.0/dbs/spfileCDBFSCM.ora' from 
 '/u01/install/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp';
   sql clone "alter system set spfile= ''/u02/db/oracle-server/19.3.0.0/dbs/spfileCDBFSCM.ora''";
}
executing Memory Script

Starting restore at 07-JUL-26

channel c2: skipped, AUTOBACKUP already found
channel c3: skipped, AUTOBACKUP already found
channel c4: skipped, AUTOBACKUP already found
channel c5: skipped, AUTOBACKUP already found
channel c6: skipped, AUTOBACKUP already found
channel c7: skipped, AUTOBACKUP already found
channel c8: skipped, AUTOBACKUP already found
channel c9: skipped, AUTOBACKUP already found
channel c10: skipped, AUTOBACKUP already found
channel c1: restoring spfile from AUTOBACKUP /u01/install/rman/spfile_CDBFSCM_20260619_0r4r0qle_27_1_1.bkp
channel c1: SPFILE restore from AUTOBACKUP complete
Finished restore at 07-JUL-26

sql statement: alter system set spfile= ''/u02/db/oracle-server/19.3.0.0/dbs/spfileCDBFSCM.ora''

contents of Memory Script:
{
   sql clone "alter system set  db_name = 
 ''CDBFSCM'' comment=
 ''duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name = 
 ''CDBFSCM'' comment=
 '''' scope=spfile";
   sql clone "alter system set  control_files = 
 ''/u02/db/oradata/CDBFSCM/control01.ctl'', ''/u02/db/oradata/CDBFSCM/control02.ctl'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_create_file_dest = 
 ''/u02/db/oradata/'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_create_online_log_dest_1 = 
 ''/u02/db/oradata/CDBFSCM'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_recovery_file_dest = 
 ''/u02/db/oracle-server/fast_recovery_area'' comment=
 '''' scope=spfile";
   sql clone "alter system set  db_recovery_file_dest_size = 
 100G comment=
 '''' scope=spfile";
   sql clone "alter system set  audit_file_dest = 
 ''/u02/db/oracle-server/admin'' comment=
 '''' scope=spfile";
   sql clone "alter system set  core_dump_dest = 
 ''/u02/db/oracle-server'' comment=
 '''' scope=spfile";
   sql clone "alter system set  diagnostic_dest = 
 ''/u02/db/oracle-server'' comment=
 '''' scope=spfile";
   sql clone "alter system set  pga_aggregate_target = 
 2g comment=
 '''' scope=spfile";
   sql clone "alter system set  sga_target = 
 15g comment=
 '''' scope=spfile";
   sql clone "alter system set  sga_max_size = 
 15g comment=
 '''' scope=spfile";
   sql clone "alter system set  sessions = 
 2000 comment=
 '''' scope=spfile";
   sql clone "alter system set  processes = 
 1000 comment=
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
   sql clone "alter system set  recyclebin = 
 ''OFF'' comment=
 '''' scope=spfile";
   shutdown clone immediate;
   startup clone nomount;
}
executing Memory Script

sql statement: alter system set  db_name =  ''CDBFSCM'' comment= ''duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''CDBFSCM'' comment= '''' scope=spfile

sql statement: alter system set  control_files =  ''/u02/db/oradata/CDBFSCM/control01.ctl'', ''/u02/db/oradata/CDBFSCM/control02.ctl'' comment= '''' scope=spfile

sql statement: alter system set  db_create_file_dest =  ''/u02/db/oradata/'' comment= '''' scope=spfile

sql statement: alter system set  db_create_online_log_dest_1 =  ''/u02/db/oradata/CDBFSCM'' comment= '''' scope=spfile

sql statement: alter system set  db_recovery_file_dest =  ''/u02/db/oracle-server/fast_recovery_area'' comment= '''' scope=spfile

sql statement: alter system set  db_recovery_file_dest_size =  100G comment= '''' scope=spfile

sql statement: alter system set  audit_file_dest =  ''/u02/db/oracle-server/admin'' comment= '''' scope=spfile

sql statement: alter system set  core_dump_dest =  ''/u02/db/oracle-server'' comment= '''' scope=spfile

sql statement: alter system set  diagnostic_dest =  ''/u02/db/oracle-server'' comment= '''' scope=spfile

sql statement: alter system set  pga_aggregate_target =  2g comment= '''' scope=spfile

sql statement: alter system set  sga_target =  15g comment= '''' scope=spfile

sql statement: alter system set  sga_max_size =  15g comment= '''' scope=spfile

sql statement: alter system set  sessions =  2000 comment= '''' scope=spfile

sql statement: alter system set  processes =  1000 comment= '''' scope=spfile

sql statement: alter system set  shared_pool_reserved_size =  40M comment= '''' scope=spfile

sql statement: alter system set  shared_pool_size =  400M comment= '''' scope=spfile

sql statement: alter system set  result_cache_max_size =  300M comment= '''' scope=spfile

sql statement: alter system set  recyclebin =  ''OFF'' comment= '''' scope=spfile

Oracle instance shut down

connected to auxiliary database (not started)
Oracle instance started

Total System Global Area   16106124048 bytes

Fixed Size                    13931280 bytes
Variable Size                671088640 bytes
Database Buffers           15401484288 bytes
Redo Buffers                  19619840 bytes
allocated channel: c1
channel c1: SID=1751 device type=DISK
allocated channel: c2
channel c2: SID=6 device type=DISK
allocated channel: c3
channel c3: SID=254 device type=DISK
allocated channel: c4
channel c4: SID=505 device type=DISK
allocated channel: c5
channel c5: SID=757 device type=DISK
allocated channel: c6
channel c6: SID=1007 device type=DISK
allocated channel: c7
channel c7: SID=1506 device type=DISK
allocated channel: c8
channel c8: SID=1257 device type=DISK
allocated channel: c9
channel c9: SID=1756 device type=DISK
allocated channel: c10
channel c10: SID=7 device type=DISK

contents of Memory Script:
{
   sql clone "alter system set  db_name = 
 ''CDBFSCM'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name = 
 ''CDBFSCM'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   shutdown clone immediate;
   startup clone force nomount
   restore clone primary controlfile from  '/u01/install/rman/controlfile_CDBFSCM_20260619_0s4r0qlf_28_1_1.bkp';
   alter clone database mount;
}
executing Memory Script

sql statement: alter system set  db_name =  ''CDBFSCM'' comment= ''Modified by RMAN duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''CDBFSCM'' comment= ''Modified by RMAN duplicate'' scope=spfile

Oracle instance shut down

Oracle instance started

Total System Global Area   16106124048 bytes

Fixed Size                    13931280 bytes
Variable Size                671088640 bytes
Database Buffers           15401484288 bytes
Redo Buffers                  19619840 bytes
allocated channel: c1
channel c1: SID=1751 device type=DISK
allocated channel: c2
channel c2: SID=6 device type=DISK
allocated channel: c3
channel c3: SID=254 device type=DISK
allocated channel: c4
channel c4: SID=505 device type=DISK
allocated channel: c5
channel c5: SID=757 device type=DISK
allocated channel: c6
channel c6: SID=1007 device type=DISK
allocated channel: c7
channel c7: SID=1257 device type=DISK
allocated channel: c8
channel c8: SID=1506 device type=DISK
allocated channel: c9
channel c9: SID=1756 device type=DISK
allocated channel: c10
channel c10: SID=7 device type=DISK

Starting restore at 07-JUL-26

channel c2: skipped, AUTOBACKUP already found
channel c3: skipped, AUTOBACKUP already found
channel c4: skipped, AUTOBACKUP already found
channel c5: skipped, AUTOBACKUP already found
channel c6: skipped, AUTOBACKUP already found
channel c7: skipped, AUTOBACKUP already found
channel c8: skipped, AUTOBACKUP already found
channel c9: skipped, AUTOBACKUP already found
channel c10: skipped, AUTOBACKUP already found
channel c1: restoring control file
channel c1: restore complete, elapsed time: 00:00:08
output file name=/u02/db/oradata/CDBFSCM/control01.ctl
output file name=/u02/db/oradata/CDBFSCM/control02.ctl
Finished restore at 07-JUL-26

database mounted
checkpoint of the data file is more recent than the last archived log
duplicating Online logs to Oracle Managed File (OMF) location
duplicating Datafiles to Oracle Managed File (OMF) location

contents of Memory Script:
{
   set until scn  39362645914649;
   set newname for clone datafile  1 to new;
   set newname for clone datafile  2 to new;
   set newname for clone datafile  3 to new;
   set newname for clone datafile  4 to new;
   set newname for clone datafile  5 to new;
   .............
   .............
   .............
   .............
   .............
   .............
   .............
   input datafile copy RECID=179 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tdapp_o4rpzdn8_.dbf
datafile 183 switched to datafile copy
input datafile copy RECID=180 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tdlarge_o4rq03c5_.dbf
datafile 184 switched to datafile copy
input datafile copy RECID=181 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tdwork_o4rq05gq_.dbf
datafile 185 switched to datafile copy
input datafile copy RECID=182 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tlapp_o4rq0d5c_.dbf
datafile 186 switched to datafile copy
input datafile copy RECID=183 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tlwork_o4rq06mn_.dbf
datafile 187 switched to datafile copy
input datafile copy RECID=184 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_tpmapp_o4rq0865_.dbf
datafile 188 switched to datafile copy
input datafile copy RECID=185 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_trapp_o4rpz1n3_.dbf
datafile 189 switched to datafile copy
input datafile copy RECID=186 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_trarch_o4rq08c4_.dbf
datafile 190 switched to datafile copy
input datafile copy RECID=187 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_trimage_o4rpzm51_.dbf
datafile 191 switched to datafile copy
input datafile copy RECID=188 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_trlarge_o4rpzvgp_.dbf
datafile 192 switched to datafile copy
input datafile copy RECID=189 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_trwork_o4rpz2kn_.dbf
datafile 193 switched to datafile copy
input datafile copy RECID=190 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wmapp_o4rpz7dm_.dbf
datafile 194 switched to datafile copy
input datafile copy RECID=191 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wmimage_o4rq08s2_.dbf
datafile 195 switched to datafile copy
input datafile copy RECID=192 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wmlarge_o4rpzcvb_.dbf
datafile 196 switched to datafile copy
input datafile copy RECID=193 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wmwork_o4rq094q_.dbf
datafile 197 switched to datafile copy
input datafile copy RECID=194 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wsapp_o4rpz2mb_.dbf
datafile 198 switched to datafile copy
input datafile copy RECID=195 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_wslarge_o4rq0bjh_.dbf
datafile 199 switched to datafile copy
input datafile copy RECID=196 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_slmapp_o4rq008y_.dbf
datafile 200 switched to datafile copy
input datafile copy RECID=197 STAMP=1237946209 file name=/u02/db/oradata/CDBFSCM/546B5F8ED2DC6766E0630602320A23B0/datafile/o1_mf_slmlarge_o4rpztgt_.dbf

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
Finished Duplicate Db at 07-JUL-26

Recovery Manager complete.

real	5m59.516s
user	0m13.087s
sys	0m2.055s

System altered.


NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
local_listener			     string	 peoplesoft-clone:1521

System altered.


    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 FSCM0V			  READ WRITE NO

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 07-JUL-2026 01:57:11

Copyright (c) 1991, 2025, Oracle.  All rights reserved.

Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                07-JUL-2026 01:42:24
Uptime                    0 days 0 hr. 14 min. 47 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u02/db/oracle-server/19.3.0.0/network/admin/listener.ora
Listener Log File         /u02/db/oracle-server/diag/tnslsnr/peoplesoft-clone/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal)(PORT=1521)))
Services Summary...
Service "546b5f8ed2dc6766e0630602320a23b0" has 1 instance(s).
  Instance "CDBFSCM", status READY, has 1 handler(s) for this service...
Service "CDBFSCM" has 1 instance(s).
  Instance "CDBFSCM", status READY, has 1 handler(s) for this service...
Service "CDBFSCMXDB" has 1 instance(s).
  Instance "CDBFSCM", status READY, has 1 handler(s) for this service...
Service "fscm0v" has 1 instance(s).
  Instance "CDBFSCM", status READY, has 1 handler(s) for this service...
The command completed successfully

### RMAN: Setting up tnsnames for the application.. 

log: /scripts/logs/20260707_015111_rdbms_rman_restore.log
Tue Jul  7 01:57:11 UTC 2026

real	5m59.965s
user	0m13.153s
sys	0m2.350s
[oracle@peoplesoft-clone ~]$

[oracle@peoplesoft-clone ~]$ time setup_cust_app
Tue Jul  7 03:41:11 UTC 2026


         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: setup_cust_app
         =========================================================================
         Function to setup up Peoplesoft customer applications on GCP
         ------------------------------------------------------------------------- 

### Setting up Peoplesoft applications... 

### Setting up Environment file.. 
'/u01/install/app/psft.env' -> '/u02/app/psft.env'

### Unarchiving PT directory...in /opt/oracle/psft 

### Unarchiving CFG directory... 

### Replicating configuration home... 
/opt/oracle/psft/pt/ps_home8.62.07/appserv/psadmin
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
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
............................................
The target domain peoplesoft has been created


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
'configuration.properties' -> 'configuration.properties.2026-07-07-03:43:59'

### New psserver value in configuration.properties is ... 
psserver=peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal:9033

### Updating setEnv.sh with new values... 
/u02/app/newcfg/webserv/peoplesoft/bin
'setEnv.sh' -> 'setEnv.sh.2026-07-07-03:43:59'

### New ADMINSERVER_HOSTNAME value in setEnv.sh is ... 
ADMINSERVER_HOSTNAME=peoplesoft-clone
PIA_HOME=/u02/app/newcfg
Error: A psconfig.sh script has already been invoked.  Your environment will not be changed

### Configuring domain name for peoplesoft to c.oracle-ebs-toolkit-demo.internal 
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
The configuration has been updated.

### Configuring http port for peoplesoft to 8001 
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom
The configuration has been updated.

### Starting up weblogic server domain peoplesoft.... 
Picked up _JAVA_OPTIONS: -Djava.security.egd=file:/dev/./urandom

Starting the domain [peoplesoft]....
Server state changed to STARTING......
Server state changed to STANDBY..
Server state changed to STARTING........
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
	process id=523226 ... Started.
1 process started.

Attaching to active bulletin board.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting server processes ...

exec TMUSREVT -A :
	process id=523236 ... Started.
exec PSWATCHSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 236832 -D APPDOM -S PSWATCHSRV :
	process id=523237 ... Started.
exec PSPPMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -D APPDOM -S PSPPMSRV :
	process id=523239 ... Started.
exec PSAPPSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s@psappsrv.lst -- -D APPDOM -S PSAPPSRV :
	process id=523248 ... Started.
exec PSAPPSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s@psappsrv.lst -- -D APPDOM -S PSAPPSRV :
	process id=523322 ... Started.
exec PSSAMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -D APPDOM -S PSSAMSRV :
	process id=523393 ... Started.
exec PSBRKHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSBRKHND_dflt:BrkProcess -- -D APPDOM -S PSBRKHND_dflt :
	process id=523403 ... Started.
exec PSBRKDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSBRKDSP_dflt:Dispatch -- -D APPDOM -S PSBRKDSP_dflt :
	process id=523412 ... Started.
exec PSPUBHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSPUBHND_dflt:PubConProcess -- -D APPDOM -S PSPUBHND_dflt :
	process id=523421 ... Started.
exec PSPUBDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSPUBDSP_dflt:Dispatch -- -D APPDOM -S PSPUBDSP_dflt :
	process id=523431 ... Started.
exec PSSUBHND -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSSUBHND_dflt:SubConProcess -- -D APPDOM -S PSSUBHND_dflt :
	process id=523461 ... Started.
exec PSSUBDSP -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -s PSSUBDSP_dflt:Dispatch -- -D APPDOM -S PSSUBDSP_dflt :
	process id=523470 ... Started.
exec PSMONITORSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 236832 -D APPDOM -S PSMONITORSRV :
	process id=523482 ... Started.
exec WSL -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -n //peoplesoft-clone:7000 -z 0 -Z 256 -I 5 -T 60 -m 1 -M 3 -x 40 -c 5000 -p 7001 -P 7003 :
	process id=523572 ... Started.
exec JSL -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -n //0.0.0.0:9033 -m 5 -M 7 -I 5 -j ANY -x 40 -z 0 -Z 256 -S 10 -c 1000000 -w JSH :
	process id=523574 ... Started.
exec TMMETADATA -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -f /u02/app/newcfg/appserv/APPDOM/metadata.rep :
	process id=523580 ... Started.
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
	process id=523624 ... Started.
1 process started.

Attaching to active bulletin board.

> INFO: Oracle Tuxedo, Version 22.1.0.0.0, 64-bit, Patch Level 043

Booting server processes ...

exec PSRTISRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -S PSRTISRV :
	process id=523629 ... Started.
exec PSPPMSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -S PSPPMSRV :
	process id=523638 ... Started.
exec PSMSTPRC -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -CD FSCM0V -PS PRCS5240 -A start -S PSMSTPRC :
	process id=523647 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
	process id=523657 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
	process id=523727 ... Started.
exec PSAESRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -- -CD FSCM0V -S PSAESRV :
	process id=523796 ... Started.
exec PSDSTSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -p 1,600:1,1 -sPostReport -- -CD FSCM0V -PS PRCS5240 -A start -S PSDSTSRV :
	process id=523864 ... Started.
exec PSPRCSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -sInitiateRequest -- -CD FSCM0V -PS PRCS5240 -A start -S PSPRCSRV :
	process id=523873 ... Started.
exec PSMONITORSRV -o ./LOGS/stdout_%SRVID%.%PROCID% -e ./LOGS/stderr_%SRVID%.%PROCID% -A -- -ID 191603 -PS PRCS5240 -S PSMONITORSRV :
	process id=523885 ... Started.
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

### Application server login information...
	 
	 Please access the Peoplesoft application weblogic server on GCP at the following location...
	 
	 http://peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal:8001
	 
	 Please use your normal credentials to login
	 
	 Please add the following line to your /etc/hosts file...
	 127.0.0.1 peoplesoft-clone.c.oracle-ebs-toolkit-demo.internal peoplesoft-clone
	 
	 Command to login to the server and open port 8001 locally:...
	 gcloud compute ssh --zone <zone name> peoplesoft-clone --tunnel-through-iap --project <project name> -- -L  8001:localhost:8001 

log: /scripts/logs/20260707_034111_setup_cust_app.log
Tue Jul  7 03:45:19 UTC 2026

real	4m7.663s
user	3m0.982s
sys	2m1.160s
[oracle@peoplesoft-clone ~]$
 
```

Add the following line (127.0.0.1 oracle-peoplesoft-apps.c.oracle-ebs-toolkit-demo.internal oracle-peoplesoft-apps) to the local hosts file:

```bash
# Mac hosts file 
cat /etc/hosts
    127.0.0.1 oracle-peoplesoft-apps.c.oracle-ebs-toolkit-demo.internal oracle-peoplesoft-apps

# Windows hosts file
C:\windows\system32\drivers\etc\hosts
    127.0.0.1 oracle-peoplesoft-apps.c.oracle-ebs-toolkit-demo.internal oracle-peoplesoft-apps
```

Open IAP tunnel

```bash
# open tunnel
[user@host] oracle-peoplesoft-framework % gcloud compute ssh "oracle-peoplesoft-apps" --tunnel-through-iap  \
 --project "oracle-ebs-toolkit-demo" -- -L 8000:localhost:8000
No zone specified. Using zone [us-central1-a] for instance: [oracle-peoplesoft-apps].
WARNING:

To increase the performance of the tunnel, consider installing NumPy. For instructions,
please see https://cloud.google.com/iap/docs/using-tcp-forwarding#increasing_the_tcp_upload_bandwidth

** WARNING: connection is not using a post-quantum key exchange algorithm.
** This session may be vulnerable to "store now, decrypt later" attacks.
** The server may need to be upgraded. See https://openssh.com/pq.html
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed May 20 11:39:29 2026 from 35.235.244.34
[user@oracle-peoplesoft-apps ~]$

```

Open a browser and login to http://oracle-peoplesoft-apps.c.oracle-ebs-toolkit-demo.internal:8000 

![Oracle Peoplesoft Demo Env](images/screen1.png "Oracle Peoplesoft Demo Env")

---

### 7. Destroy Media

```bash

[user@host] oracle-peoplesoft-framework %  make destroy
terraform -chdir=. destroy -auto-approve \
	  -var="project_id=oracle-ebs-toolkit-demo" \
	  -var="project_service_account_email=project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com"
Acquiring state lock. This may take a few moments...
random_id.bucket_suffix: Refreshing state... [id=0YTmow]
data.google_compute_image.apps_image: Reading...
google_service_account.project_sa: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Reading...
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/iam.googleapis.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/compute.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/secretmanager.googleapis.com]
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Refreshing state... [id=oracle-ebs-toolkit-demo/storage.googleapis.com]
module.network.module.vpc.google_compute_network.network: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01]
module.peoplesoft_storage_bucket.data.google_storage_project_service_account.gcs_account: Read complete after 1s [id=service-119724395047@gs-project-accounts.iam.gserviceaccount.com]
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Refreshing state... [id=oracle-peoplesoft-toolkit-storage-bucket-d184e6a3]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
data.google_compute_image.apps_image: Read complete after 1s [id=projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Refreshing state... [id=oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Refreshing state... [id=b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_compute_address.peoplesoft_apps_server_internal_ip: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/peoplesoft-apps-server-internal-ip]
module.cloud_router.google_compute_router.router: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet]
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Refreshing state... [id=oracle-ebs-toolkit-demo/us-central1/oracle-peoplesoft-toolkit-network-cloud-router/oracle-peoplesoft-toolkit-nat-01]
google_compute_instance.apps: Refreshing state... [id=projects/oracle-ebs-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps]
null_resource.push_scripts: Refreshing state... [id=6865174509411776404]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"] will be destroyed
  - resource "google_compute_address" "nat_ip" {
      - address            = "35.254.231.210" -> null
      - address_type       = "EXTERNAL" -> null
      - creation_timestamp = "2026-05-20T04:31:51.719-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "oracle-peoplesoft-toolkit-nat-01" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit-demo" -> null
      - region             = "us-central1" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router",
        ] -> null
        # (6 unchanged attributes hidden)
    }

  # google_compute_address.peoplesoft_apps_server_internal_ip will be destroyed
  - resource "google_compute_address" "peoplesoft_apps_server_internal_ip" {
      - address            = "10.115.0.20" -> null
      - address_type       = "INTERNAL" -> null
      - creation_timestamp = "2026-05-20T04:32:29.934-07:00" -> null
      - effective_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - id                 = "projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/peoplesoft-apps-server-internal-ip" -> null
      - label_fingerprint  = "vezUS-42LLM=" -> null
      - labels             = {} -> null
      - name               = "peoplesoft-apps-server-internal-ip" -> null
      - network_tier       = "PREMIUM" -> null
      - prefix_length      = 0 -> null
      - project            = "oracle-ebs-toolkit-demo" -> null
      - purpose            = "GCE_ENDPOINT" -> null
      - region             = "us-central1" -> null
      - self_link          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/peoplesoft-apps-server-internal-ip" -> null
      - subnetwork         = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01" -> null
      - terraform_labels   = {
          - "goog-terraform-provisioned" = "true"
        } -> null
      - users              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps",
        ] -> null
        # (4 unchanged attributes hidden)
    }

  # google_compute_instance.apps will be destroyed
  - resource "google_compute_instance" "apps" {
      - can_ip_forward             = false -> null
      - cpu_platform               = "AMD Rome" -> null
      - creation_timestamp         = "2026-05-20T04:32:35.730-07:00" -> null
      - current_status             = "RUNNING" -> null
      - deletion_protection        = false -> null
      - effective_labels           = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
        } -> null
      - enable_display             = false -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps" -> null
      - instance_id                = "3112946527704720700" -> null
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
      - metadata_fingerprint       = "z0GrkrEO-64=" -> null
      - name                       = "oracle-peoplesoft-apps" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - resource_policies          = [] -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps" -> null
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
      - zone                       = "us-central1-a" -> null
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
          - source                          = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/zones/us-central1-a/disks/oracle-peoplesoft-apps" -> null
            # (6 unchanged attributes hidden)

          - initialize_params {
              - architecture                = "X86_64" -> null
              - enable_confidential_compute = false -> null
              - image                       = "https://www.googleapis.com/compute/v1/projects/oracle-linux-cloud/global/images/oracle-linux-8-v20260513" -> null
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
          - network                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
          - network_ip                  = "10.115.0.20" -> null
          - queue_count                 = 0 -> null
          - stack_type                  = "IPV4_ONLY" -> null
          - subnetwork                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01" -> null
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

  # google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/compute.instanceAdmin.v1" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/iam.serviceAccountUser" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/iap.tunnelResourceAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/logging.logWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/logging.logWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/monitoring.metricWriter" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/secretmanager.secretAccessor" -> null
    }

  # google_project_iam_member.project_sa_roles["roles/storage.admin"] will be destroyed
  - resource "google_project_iam_member" "project_sa_roles" {
      - etag    = "BwZSPiVtcsA=" -> null
      - id      = "oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member  = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - project = "oracle-ebs-toolkit-demo" -> null
      - role    = "roles/storage.admin" -> null
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
      - unique_id    = "108921076477304787570" -> null
        # (1 unchanged attribute hidden)
    }

  # google_storage_bucket_iam_member.bucket_object_admin will be destroyed
  - resource "google_storage_bucket_iam_member" "bucket_object_admin" {
      - bucket = "b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3" -> null
      - etag   = "CAI=" -> null
      - id     = "b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - member = "serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com" -> null
      - role   = "roles/storage.objectAdmin" -> null
    }

  # null_resource.push_scripts will be destroyed
  - resource "null_resource" "push_scripts" {
      - id       = "6865174509411776404" -> null
      - triggers = {
          - "always_run" = "2026-05-20T13:28:21Z"
        } -> null
    }

  # random_id.bucket_suffix will be destroyed
  - resource "random_id" "bucket_suffix" {
      - b64_std     = "0YTmow==" -> null
      - b64_url     = "0YTmow" -> null
      - byte_length = 4 -> null
      - dec         = "3515147939" -> null
      - hex         = "d184e6a3" -> null
      - id          = "0YTmow" -> null
    }

  # module.cloud_router.google_compute_router.router will be destroyed
  - resource "google_compute_router" "router" {
      - creation_timestamp            = "2026-05-20T04:32:29.991-07:00" -> null
      - encrypted_interconnect_router = false -> null
      - id                            = "projects/oracle-ebs-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router" -> null
      - name                          = "oracle-peoplesoft-toolkit-network-cloud-router" -> null
      - network                       = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
      - project                       = "oracle-ebs-toolkit-demo" -> null
      - region                        = "us-central1" -> null
      - self_link                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router" -> null
        # (1 unchanged attribute hidden)
    }

  # module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"] will be destroyed
  - resource "google_compute_router_nat" "nats" {
      - drain_nat_ips                        = [] -> null
      - enable_dynamic_port_allocation       = false -> null
      - enable_endpoint_independent_mapping  = false -> null
      - endpoint_types                       = [
          - "ENDPOINT_TYPE_VM",
        ] -> null
      - icmp_idle_timeout_sec                = 30 -> null
      - id                                   = "oracle-ebs-toolkit-demo/us-central1/oracle-peoplesoft-toolkit-network-cloud-router/oracle-peoplesoft-toolkit-nat-01" -> null
      - max_ports_per_vm                     = 0 -> null
      - min_ports_per_vm                     = 0 -> null
      - name                                 = "oracle-peoplesoft-toolkit-nat-01" -> null
      - nat_ip_allocate_option               = "MANUAL_ONLY" -> null
      - nat_ips                              = [
          - "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01",
        ] -> null
      - project                              = "oracle-ebs-toolkit-demo" -> null
      - region                               = "us-central1" -> null
      - router                               = "oracle-peoplesoft-toolkit-network-cloud-router" -> null
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
          - name                     = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01" -> null
          - secondary_ip_range_names = [] -> null
          - source_ip_ranges_to_nat  = [
              - "ALL_IP_RANGES",
            ] -> null
        }
    }

  # module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"] will be destroyed
  - resource "google_compute_firewall" "rules_ingress_egress" {
      - creation_timestamp      = "2026-05-20T04:32:29.933-07:00" -> null
      - description             = "Allow external access to Oracle EBS Apps" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access" -> null
      - name                    = "allow-external-app-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:29.492-07:00" -> null
      - description             = "Allow external access to Oracle EBS DB" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access" -> null
      - name                    = "allow-external-db-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:30.071-07:00" -> null
      - description             = "Allow HTTP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in" -> null
      - name                    = "allow-http-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:30.064-07:00" -> null
      - description             = "Allow HTTPS traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in" -> null
      - name                    = "allow-https-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:29.330-07:00" -> null
      - description             = "Allow IAP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in" -> null
      - name                    = "allow-iap-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:29.270-07:00" -> null
      - description             = "Allow ICMP traffic inbound" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in" -> null
      - name                    = "allow-icmp-in" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp      = "2026-05-20T04:32:29.481-07:00" -> null
      - description             = "Allow internal HTTP traffic within the VPC" -> null
      - destination_ranges      = [] -> null
      - direction               = "INGRESS" -> null
      - disabled                = false -> null
      - id                      = "projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access" -> null
      - name                    = "allow-internal-access" -> null
      - network                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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
      - creation_timestamp         = "2026-05-20T04:32:29.541-07:00" -> null
      - description                = "Public NAT GW - route through IGW to access internet" -> null
      - dest_range                 = "0.0.0.0/0" -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet" -> null
      - name                       = "nat-egress-internet" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
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

  # module.peoplesoft_storage_bucket.google_storage_bucket.bucket will be destroyed
  - resource "google_storage_bucket" "bucket" {
      - default_event_based_hold    = false -> null
      - effective_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "oracle-peoplesoft-toolkit"
        } -> null
      - enable_object_retention     = false -> null
      - force_destroy               = true -> null
      - id                          = "oracle-peoplesoft-toolkit-storage-bucket-d184e6a3" -> null
      - labels                      = {
          - "managed-by" = "terraform"
          - "service"    = "oracle-peoplesoft-toolkit"
        } -> null
      - location                    = "US-CENTRAL1" -> null
      - name                        = "oracle-peoplesoft-toolkit-storage-bucket-d184e6a3" -> null
      - project                     = "oracle-ebs-toolkit-demo" -> null
      - project_number              = 119724395047 -> null
      - public_access_prevention    = "inherited" -> null
      - requester_pays              = false -> null
      - self_link                   = "https://www.googleapis.com/storage/v1/b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3" -> null
      - storage_class               = "NEARLINE" -> null
      - terraform_labels            = {
          - "goog-terraform-provisioned" = "true"
          - "managed-by"                 = "terraform"
          - "service"                    = "oracle-peoplesoft-toolkit"
        } -> null
      - time_created                = "2026-05-20T11:31:51.837Z" -> null
      - uniform_bucket_level_access = true -> null
      - updated                     = "2026-05-20T11:32:05.952Z" -> null
      - url                         = "gs://oracle-peoplesoft-toolkit-storage-bucket-d184e6a3" -> null

      - hierarchical_namespace {
          - enabled = false -> null
        }

      - soft_delete_policy {
          - effective_time             = "2026-05-20T11:31:51.837Z" -> null
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

  # module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"] will be destroyed
  - resource "google_compute_subnetwork" "subnetwork" {
      - creation_timestamp         = "2026-05-20T04:32:15.982-07:00" -> null
      - enable_flow_logs           = true -> null
      - gateway_address            = "10.115.0.1" -> null
      - id                         = "projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01" -> null
      - ip_cidr_range              = "10.115.0.0/20" -> null
      - name                       = "oracle-peoplesoft-toolkit-subnet-01" -> null
      - network                    = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
      - private_ip_google_access   = true -> null
      - private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS" -> null
      - project                    = "oracle-ebs-toolkit-demo" -> null
      - purpose                    = "PRIVATE" -> null
      - region                     = "us-central1" -> null
      - self_link                  = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01" -> null
      - stack_type                 = "IPV4_ONLY" -> null
      - subnetwork_id              = 2218680301693969744 -> null
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
      - id                                        = "projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
      - mtu                                       = 0 -> null
      - name                                      = "oracle-peoplesoft-toolkit-network" -> null
      - network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL" -> null
      - network_id                                = "4331050736623297864" -> null
      - numeric_id                                = "4331050736623297864" -> null
      - project                                   = "oracle-ebs-toolkit-demo" -> null
      - routing_mode                              = "REGIONAL" -> null
      - self_link                                 = "https://www.googleapis.com/compute/v1/projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network" -> null
        # (5 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 32 to destroy.

Changes to Outputs:
  - apps_instance_zone = "us-central1-a" -> null
  - deployment_summary = <<-EOT
        =========================================
         PeopleSoft VM Configuration
        -----------------------------------------
           • Instance Name  : oracle-peoplesoft-apps
           • Internal IP    : 10.115.0.20
           • Zone           : us-central1-a
           • Machine Type   : e2-highmem-8
           • SSH Command    :
               gcloud compute ssh --zone "us-central1-a" "oracle-peoplesoft-apps" --tunnel-through-iap --project "oracle-ebs-toolkit-demo" -- -L 8000:localhost:8000

        -----------------------------------------
         Storage
        -----------------------------------------
           • Bucket Name    : oracle-peoplesoft-toolkit-storage-bucket-d184e6a3
           • Bucket URL     : gs://oracle-peoplesoft-toolkit-storage-bucket-d184e6a3

        =========================================
         Summary
        -----------------------------------------
           • Total Instances: 1
           • Storage Bucket : oracle-peoplesoft-toolkit-storage-bucket-d184e6a3
           • Generated At   : 2026-05-20T13:28:21Z
        =========================================
    EOT -> null
null_resource.push_scripts: Destroying... [id=6865174509411776404]
null_resource.push_scripts: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/logging.logWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/iam.serviceAccountUser/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/compute.instanceAdmin.v1/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/secretmanager.secretAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/cloudresourcemanager.googleapis.com]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/compute.googleapis.com]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/secretmanager.googleapis.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access]
module.project_services.google_project_service.project_services["secretmanager.googleapis.com"]: Destruction complete after 0s
google_compute_instance.apps: Destroying... [id=projects/oracle-ebs-toolkit-demo/zones/us-central1-a/instances/oracle-peoplesoft-apps]
module.project_services.google_project_service.project_services["compute.googleapis.com"]: Destruction complete after 0s
module.project_services.google_project_service.project_services["cloudresourcemanager.googleapis.com"]: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/monitoring.metricWriter/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_storage_bucket_iam_member.bucket_object_admin: Destroying... [id=b/oracle-peoplesoft-toolkit-storage-bucket-d184e6a3/roles/storage.objectAdmin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in]
google_storage_bucket_iam_member.bucket_object_admin: Destruction complete after 6s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in]
google_project_iam_member.project_sa_roles["roles/monitoring.metricWriter"]: Destruction complete after 10s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in]
google_project_iam_member.project_sa_roles["roles/secretmanager.secretAccessor"]: Destruction complete after 10s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/compute.i...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/logging.l...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Still destroying... [id=oracle-ebs-toolkit-demo/roles/iam.servi...s-toolkit-demo.iam.gserviceaccount.com, 00m10s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-icmp-in, 00m10s elapsed]
google_project_iam_member.project_sa_roles["roles/compute.instanceAdmin.v1"]: Destruction complete after 11s
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Destroying... [id=oracle-ebs-toolkit-demo/us-central1/oracle-peoplesoft-toolkit-network-cloud-router/oracle-peoplesoft-toolkit-nat-01]
google_project_iam_member.project_sa_roles["roles/logging.logWriter"]: Destruction complete after 11s
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/storage.googleapis.com]
module.project_services.google_project_service.project_services["storage.googleapis.com"]: Destruction complete after 0s
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/storage.admin/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/iam.serviceAccountUser"]: Destruction complete after 12s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-icmp-in"]: Destruction complete after 13s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-iap-in, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-iap-in"]: Destruction complete after 12s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destroying... [id=oracle-ebs-toolkit-demo/roles/iap.tunnelResourceAccessor/serviceAccount:project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_project_iam_member.project_sa_roles["roles/storage.admin"]: Destruction complete after 9s
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destroying... [id=oracle-ebs-toolkit-demo/iam.googleapis.com]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-http-in, 00m10s elapsed]
module.project_services.google_project_service.project_services["iam.googleapis.com"]: Destruction complete after 0s
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Destroying... [id=oracle-peoplesoft-toolkit-storage-bucket-d184e6a3]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-app-access, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-internal-access, 00m20s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-external-db-access, 00m20s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 00m20s elapsed]
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Still destroying... [id=oracle-ebs-toolkit-demo/us-central1/ora...outer/oracle-peoplesoft-toolkit-nat-01, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-app-access"]: Destruction complete after 12s
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/routes/nat-egress-internet, 00m10s elapsed]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-http-in"]: Destruction complete after 12s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-internal-access"]: Destruction complete after 22s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-external-db-access"]: Destruction complete after 23s
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global/firewalls/allow-https-in, 00m10s elapsed]
module.nat_gateway_route.google_compute_route.route["nat-egress-internet"]: Destruction complete after 11s
module.peoplesoft_storage_bucket.google_storage_bucket.bucket: Destruction complete after 4s
random_id.bucket_suffix: Destroying... [id=0YTmow]
random_id.bucket_suffix: Destruction complete after 0s
module.cloud_router.google_compute_router_nat.nats["oracle-peoplesoft-toolkit-nat-01"]: Destruction complete after 13s
module.cloud_router.google_compute_router.router: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/routers/oracle-peoplesoft-toolkit-network-cloud-router]
module.firewall_rules.google_compute_firewall.rules_ingress_egress["allow-https-in"]: Destruction complete after 13s
google_project_iam_member.project_sa_roles["roles/iap.tunnelResourceAccessor"]: Destruction complete after 9s
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 00m30s elapsed]
module.cloud_router.google_compute_router.router: Still destroying... [id=projects/oracle-ebs-toolkit-demo/region...eoplesoft-toolkit-network-cloud-router, 00m10s elapsed]
module.cloud_router.google_compute_router.router: Destruction complete after 13s
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/oracle-peoplesoft-toolkit-nat-01]
google_compute_address.nat_ip["oracle-peoplesoft-toolkit-nat-01"]: Destruction complete after 2s
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 00m40s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 00m50s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m00s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m10s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m20s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m30s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m40s elapsed]
google_compute_instance.apps: Still destroying... [id=projects/oracle-ebs-toolkit-demo/zones/...al1-a/instances/oracle-peoplesoft-apps, 01m50s elapsed]
google_compute_instance.apps: Destruction complete after 1m52s
google_service_account.project_sa: Destroying... [id=projects/oracle-ebs-toolkit-demo/serviceAccounts/project-service-account@oracle-ebs-toolkit-demo.iam.gserviceaccount.com]
google_compute_address.peoplesoft_apps_server_internal_ip: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/addresses/peoplesoft-apps-server-internal-ip]
google_service_account.project_sa: Destruction complete after 1s
google_compute_address.peoplesoft_apps_server_internal_ip: Destruction complete after 2s
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Destroying... [id=projects/oracle-ebs-toolkit-demo/regions/us-central1/subnetworks/oracle-peoplesoft-toolkit-subnet-01]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Still destroying... [id=projects/oracle-ebs-toolkit-demo/region...ks/oracle-peoplesoft-toolkit-subnet-01, 00m10s elapsed]
module.network.module.subnets.google_compute_subnetwork.subnetwork["us-central1/oracle-peoplesoft-toolkit-subnet-01"]: Destruction complete after 13s
module.network.module.vpc.google_compute_network.network: Destroying... [id=projects/oracle-ebs-toolkit-demo/global/networks/oracle-peoplesoft-toolkit-network]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global...orks/oracle-peoplesoft-toolkit-network, 00m10s elapsed]
module.network.module.vpc.google_compute_network.network: Still destroying... [id=projects/oracle-ebs-toolkit-demo/global...orks/oracle-peoplesoft-toolkit-network, 00m20s elapsed]
module.network.module.vpc.google_compute_network.network: Destruction complete after 24s

Destroy complete! Resources: 32 destroyed.
[user@host] oracle-peoplesoft-framework % %

```