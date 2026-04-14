output "vision_instance_zone" {
  description = "The zone of the Oracle Vision instance."
  value       = try(regex("zones/([^/]+)/", google_compute_instance.vision[0].self_link)[0], "")
}

output "exascale_vision_instance_zone" {
  description = "The zone of the Oracle Exascale Vision instance."
  value       = try(regex("zones/([^/]+)/", google_compute_instance.exascale_vision[0].self_link)[0], "")  
}

output "apps_instance_zone" {
  description = "The zone where the EBS apps instance is deployed"
  value = try(
    !var.oracle_ebs_vision ? regex("zones/([^/]+)/", google_compute_instance.apps[0].self_link)[0] : "",
    ""
  )
}

output "dbs_instance_zone" {
  description = "The zone where the EBS database instance is deployed"
  value = try(
    !var.oracle_ebs_vision ? regex("zones/([^/]+)/", google_compute_instance.dbs[0].self_link)[0] : "",
    ""
  )
}

output "admin_password" {
  description = "Admin password for Oracle E-Business Suite. Retrieve securely using 'terraform output admin_password'."
  value       = one(random_password.admin_password[*].result)
  sensitive   = true  
}

output "deployment_summary" {
  description = "Dynamic summary of the deployed Oracle EBS infrastructure."
  value       = <<EOT
=========================================
%{if var.oracle_ebs_vision || var.oracle_ebs_exascale~}
        Oracle Vision VM Deployment
%{else~}
        Oracle E-Business Suite Setup
%{endif~}
=========================================
 Project ID         : ${var.project_id}
 Region             : ${var.region}
 Zone               : ${var.zone}
 VPC Network        : ${try(module.network.network_name, "N/A")}

-----------------------------------------
 %{if var.oracle_ebs_vision || var.oracle_ebs_exascale}Vision Instance%{else}Apps Tier%{endif}
-----------------------------------------
%{if var.oracle_ebs_exascale~}
   • Name           : ${try(google_compute_instance.exascale_vision[0].name, "N/A")}
   • Internal IP    : ${try(google_compute_instance.exascale_vision[0].network_interface[0].network_ip, "N/A")}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.exascale_vision[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"
%{else~}
%{if var.oracle_ebs_vision~}
   • Name           : ${try(google_compute_instance.vision[0].name, "N/A")}
   • Internal IP    : ${try(google_compute_instance.vision[0].network_interface[0].network_ip, "N/A")}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.vision[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"
%{else~}
   • Name           : ${try(google_compute_instance.apps[0].name, "N/A")}
   • Internal IP    : ${try(google_compute_instance.apps[0].network_interface[0].network_ip, "N/A")}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.apps[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 8000:localhost:8000
%{endif~}
%{endif~}

-----------------------------------------
 Database Tier
-----------------------------------------
%{if var.oracle_ebs_exascale~}
   • Type           : Oracle Database@Google Cloud (Exascale)
   • Cluster Name   : ${try(google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0].display_name, "N/A")}
   • SSH Key        : ./exadb_private_key.pem
   • Connection Info: Saved securely to ./exascale_outputs.yaml (TNS, SCAN DNS)
   • Connection String: ${try(yamldecode(file("${path.module}/exascale_outputs.yaml")).connection_strings.cdbIpDefault, "Pending generation (Available after apply)")}
%{else~}
%{if var.oracle_ebs_vision~}
   • Type           : Integrated Compute Engine DB (Included on Vision VM)
%{else~}
   • Type           : Google Compute Engine VM
   • Name           : ${try(google_compute_instance.dbs[0].name, "N/A")}
   • Internal IP    : ${try(google_compute_instance.dbs[0].network_interface[0].network_ip, "N/A")}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.dbs[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"
%{endif~}
%{endif~}

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : ${try(module.ebs_storage_bucket.name, "N/A")}
   • Bucket URL     : ${try(module.ebs_storage_bucket.url, "N/A")}

-----------------------------------------
 User Credentials
-----------------------------------------
   • Username       : admin
   • Admin Password : Run this command to retrieve the admin password securely:
       
       terraform output admin_password

=========================================
 Summary
-----------------------------------------
%{if var.oracle_ebs_exascale~}
   • Total Instances: 1 Exascale Vision VM + 1 Exascale Cluster
%{else~}
%{if var.oracle_ebs_vision~}
   • Total Instances: 1 Compute VM 
%{else~}
   • Apps Instances : ${try(length(google_compute_instance.apps), 0)}
   • DB Instances   : ${try(length(google_compute_instance.dbs), 0)}
%{endif~}
%{endif~}
   • Storage Bucket : ${try(module.ebs_storage_bucket.name, "N/A")}
   • Admin Password : Run "terraform output admin_password" to retrieve securely
   • Generated At   : ${timestamp()}
=========================================
EOT
}
