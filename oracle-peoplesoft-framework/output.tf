locals {
  base_deployment_summary = <<-EOT

=========================================
 PeopleSoft VM Configuration
-----------------------------------------
   Instance Name  : ${try(google_compute_instance.apps[0].name, "N/A")}
   Internal IP    : ${try(google_compute_instance.apps[0].network_interface[0].network_ip, "N/A")}
   Zone           : ${var.zone}
   Machine Type   : ${try(google_compute_instance.apps[0].machine_type, "N/A")}
   SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.apps[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 8000:localhost:8000
-----------------------------------------
 Storage
-----------------------------------------
   Bucket Name    : ${module.peoplesoft_storage_bucket.name}
   Bucket URL     : gs://${module.peoplesoft_storage_bucket.name}
=========================================
EOT

  exascale_deployment_summary = <<-EOT

=========================================
 Oracle PeopleSoft on ExaScale @ GCP
-----------------------------------------
 Project ID     : ${var.project_id}
 Region         : ${var.region}
 Zone           : ${var.zone}
 ExaScale Region: ${var.exascale_location}
-----------------------------------------
 Application Tier (GCE)
-----------------------------------------
   Name         : ${try(google_compute_instance.exascale_peoplesoft[0].name, "N/A")}
   Internal IP  : ${try(google_compute_instance.exascale_peoplesoft[0].network_interface[0].network_ip, "N/A")}
-----------------------------------------
 Database Tier (Oracle Database@Google Cloud)
-----------------------------------------
   Type         : Oracle Database@Google Cloud (ExaScale)
   Cluster Name : ${try(google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0].display_name, "N/A")}
   CDB Name     : ${var.cdb_name}
   SSH Key      : ./exadb_private_key.pem
   Connection   : ./exascale_outputs.yaml (TNS, SCAN DNS)
=========================================
EOT
}

output "apps_instance_zone" {
  description = "The zone where the PeopleSoft application VM is deployed (base or ExaScale)."
  value       = var.oracle_peoplesoft_exascale ? try(google_compute_instance.exascale_peoplesoft[0].zone, "") : try(google_compute_instance.apps[0].zone, "")
}

output "deployment_summary" {
  description = "Summary of the Oracle PeopleSoft deployment."
  value       = var.oracle_peoplesoft_exascale ? local.exascale_deployment_summary : local.base_deployment_summary
}
