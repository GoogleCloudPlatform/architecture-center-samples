resource "google_oracle_database_odb_network" "odb_network" {
  count          = var.oracle_ebs_exascale ? 1 : 0
  odb_network_id = "${var.network_name}-odb-network"
  project        = var.project_id
  location       = var.exascale_location
  network        = "projects/${var.project_id}/global/networks/${module.network.network_name}"

  labels = {
    terraform_created = "true"
  }

  deletion_protection = false
}

resource "google_oracle_database_odb_subnet" "client_subnet" {
  count         = var.oracle_ebs_exascale ? 1 : 0
  odb_subnet_id = "${var.network_name}-client-subnet"
  odbnetwork    = google_oracle_database_odb_network.odb_network[0].odb_network_id
  location      = var.exascale_location
  project       = var.project_id
  cidr_range    = var.exascale_client_subnet_cidr
  purpose       = "CLIENT_SUBNET"

  labels = {
    terraform_created = "true"
  }

  deletion_protection = false
}

resource "google_oracle_database_odb_subnet" "backup_subnet" {
  count         = var.oracle_ebs_exascale ? 1 : 0
  odb_subnet_id = "${var.network_name}-backup-subnet"
  odbnetwork    = google_oracle_database_odb_network.odb_network[0].odb_network_id
  location      = var.exascale_location
  project       = var.project_id
  cidr_range    = var.exascale_backup_subnet_cidr
  purpose       = "BACKUP_SUBNET"

  labels = {
    terraform_created = "true"
  }

  deletion_protection = false
}
