data "google_compute_image" "apps_image" {
  family  = var.apps_image_family
  project = var.apps_image_project
}

data "google_compute_image" "dbs_image" {
  family  = var.dbs_image_family
  project = var.dbs_image_project
}

data "google_compute_image" "vision_image" {
  family  = var.vision_image_family
  project = var.vision_image_project
}

resource "google_compute_instance" "apps" {
  count        = var.oracle_ebs_vision ? 0 : 1
  name         = "oracle-ebs-apps"
  machine_type = var.apps_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.apps_image.self_link
      size  = var.apps_boot_disk_size
      type  = var.apps_boot_disk_type
    }
    auto_delete = var.apps_boot_disk_auto_delete
  }

  network_interface {
    subnetwork = values(module.network.subnets)[0].self_link
    network_ip = google_compute_address.ebs_apps_server_internal_ip[0].address
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("${path.module}/scripts/app_startup.sh")
  }

  tags = [
    "http-server",
    "https-server",
    "lb-health-check",
    "oracle-ebs-apps",
    "iap-access",
    "icmp-access",
    "egress-nat",
    "internal-access",
    "external-app-access"
  ]

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
    managed-by = "terraform"
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

}

resource "google_compute_instance" "dbs" {
  count        = var.oracle_ebs_vision ? 0 : 1
  name         = "oracle-ebs-db"
  machine_type = var.dbs_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.dbs_image.self_link
      size  = var.dbs_boot_disk_size
      type  = var.dbs_boot_disk_type
    }
    auto_delete = var.dbs_boot_disk_auto_delete
  }

  network_interface {
    subnetwork = values(module.network.subnets)[0].self_link
    network_ip = google_compute_address.ebs_db_server_internal_ip[0].address
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("${path.module}/scripts/app_startup.sh")
  }

  tags = [
    "http-server",
    "https-server",
    "lb-health-check",
    "oracle-ebs-apps",
    "iap-access",
    "icmp-access",
    "egress-nat",
    "internal-access",
    "external-db-access"
  ]

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
    managed-by = "terraform"
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

}

resource "google_compute_instance" "vision" {
  count        = var.oracle_ebs_vision ? 1 : 0
  name         = "oracle-vision"
  machine_type = var.vision_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.vision_image.self_link
      size  = var.vision_boot_disk_size
      type  = var.vision_boot_disk_type
    }
    auto_delete = var.vision_boot_disk_auto_delete
  }

  network_interface {
    subnetwork = values(module.network.subnets)[0].self_link
    network_ip = google_compute_address.vision_server_internal_ip[0].address
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("${path.module}/scripts/app_startup.sh")
  }

  tags = local.vm_network_tags.vision

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
    application = "oracle-ebs-vision"
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

}
