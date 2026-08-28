locals {
  is_peoplesoft_exa = var.oracle_peoplesoft_exascale

  exascale_vm_network_tags = [
    "http-server",
    "https-server",
    "lb-health-check",
    "oracle-exascale-peoplesoft-app",
    "iap-access",
    "icmp-access",
    "egress-nat",
    "internal-access",
    "external-app-access",
    "external-db-access"
  ]
}

resource "google_compute_address" "exascale_peoplesoft_server_internal_ip" {
  count        = local.is_peoplesoft_exa ? 1 : 0
  name         = "exascale-peoplesoft-server-internal-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = values(module.network.subnets)[0].name
  address      = var.exascale_peoplesoft_server_internal_ip
}

resource "google_compute_instance" "exascale_peoplesoft" {
  count        = local.is_peoplesoft_exa ? 1 : 0
  name         = "oracle-exascale-peoplesoft-app"
  machine_type = var.exascale_apps_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.apps_image.self_link
      size  = var.exascale_apps_boot_disk_size
      type  = var.exascale_apps_boot_disk_type
    }
    auto_delete = var.exascale_apps_boot_disk_auto_delete
  }

  network_interface {
    subnetwork = values(module.network.subnets)[0].self_link
    network_ip = length(google_compute_address.exascale_peoplesoft_server_internal_ip) > 0 ? google_compute_address.exascale_peoplesoft_server_internal_ip[0].address : null
  }

  metadata = {
    enable-oslogin              = "TRUE"
    startup-script              = file("${path.module}/scripts/exascale_app_startup.sh")
    exadb_private_key_secret_id = try(google_secret_manager_secret.exadb_private_key_secret[0].id, "")
    exadb_public_key            = try(tls_private_key.exadb_ssh_key[0].public_key_openssh, "")
  }

  tags = local.exascale_vm_network_tags

  service_account {
    email  = google_service_account.project_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = {
    managed-by  = "terraform"
    application = "oracle-exascale-peoplesoft"
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  depends_on = [local_file.exadb_private_key, local_file.exadb_public_key]
}
