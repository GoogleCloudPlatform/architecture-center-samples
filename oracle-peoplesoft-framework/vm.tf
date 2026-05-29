data "google_compute_image" "apps_image" {
  family  = var.apps_image_family
  project = var.apps_image_project
}

resource "google_compute_instance" "apps" {
  name         = "oracle-peoplesoft-apps"
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
    network_ip = google_compute_address.peoplesoft_apps_server_internal_ip.address
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("${path.module}/scripts/app_startup.sh")
  }

  tags = [
    "http-server",
    "https-server",
    "lb-health-check",
    "oracle-peoplesoft-apps",
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

resource "null_resource" "push_scripts" {
  depends_on = [google_compute_instance.apps]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 30 seconds for VM SSH daemon and IAP to initialize..."
      sleep 30

      echo "Pushing .sh files to /tmp via IAP..."
      gcloud compute scp ${path.module}/scripts/peoplesoft/*.sh ${google_compute_instance.apps.name}:/tmp/ \
        --zone="${var.zone}" \
        --project="${var.project_id}" \
        --tunnel-through-iap

      echo "Setting up /scripts directory and assigning to oracle user..."
      gcloud compute ssh ${google_compute_instance.apps.name} \
        --zone="${var.zone}" \
        --project="${var.project_id}" \
        --tunnel-through-iap \
        --command=" \
          echo 'Checking if oracle user exists...'; \
          while ! id -u oracle > /dev/null 2>&1; do \
            echo 'Waiting for startup-script to create oracle user...'; \
            sleep 10; \
          done; \
          sudo mkdir -p /scripts && \
          sudo mv /tmp/*.sh /scripts/ && \
          sudo chown -R oracle:oinstall /scripts && \
          sudo chmod 755 /scripts && \
          sudo chmod a+x /scripts/*.sh \
        "
        
      echo "Scripts successfully pushed, assigned to oracle, and permissions set!"
    EOT
  }
}