resource "random_id" "secret_suffix" {
  count       = var.oracle_ebs_exascale ? 1 : 0
  byte_length = 4
}

resource "google_secret_manager_secret" "exadb_private_key_secret" {
  count     = var.oracle_ebs_exascale ? 1 : 0
  project   = var.project_id
  secret_id = "exadb-ssh-private-key-${random_id.secret_suffix[0].hex}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "exadb_private_key_secret_version" {
  count       = var.oracle_ebs_exascale ? 1 : 0
  secret      = google_secret_manager_secret.exadb_private_key_secret[0].id
  secret_data = tls_private_key.exadb_ssh_key[0].private_key_pem
}

resource "random_password" "admin_password" {
  count            = var.oracle_ebs_exascale ? 1 : 0
  length           = 16
  special          = true
  override_special = "_-"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}
