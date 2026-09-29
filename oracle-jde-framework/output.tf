output "vision_instance_zone" {
  description = "The zone of the Oracle Vision instance."
  value       = try(var.oracle_jde_vision ? google_compute_instance.jde_demo_prov[0].zone : "", "")
}

output "jde_storage_bucket" {
  description = "The URL of the storage bucket."
  value       = module.jde_storage_bucket.url
}

output "deployment_summary" {
  value = var.oracle_jde_vision ? (
    <<EOT
==================================================================================
        Oracle JD Edwards EnterpriseOne One-Click Provisioning Demo 
==================================================================================

 Project ID         : ${var.project_id}
 Region             : ${var.region}
 Zone               : ${var.zone}
 VPC Network        : ${module.network.network_name}

----------------------------------------------------------------------------------
 JD Edwards Demo Instances
----------------------------------------------------------------------------------
   • Provisoning Server Name : ${try(google_compute_instance.jde_demo_prov[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_demo_prov[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_demo_prov[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_demo_prov[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 3000:localhost:3000 -L 8998:localhost:8998

   • Database Server Name    : ${try(google_compute_instance.jde_demo_db[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_demo_db[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_demo_db[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_demo_db[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 1521:localhost:1521

   • Enterprise Server Name  : ${try(google_compute_instance.jde_demo_ent[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_demo_ent[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_demo_ent[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_demo_ent[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"

   • Web Server Name         : ${try(google_compute_instance.jde_demo_web[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_demo_web[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_demo_web[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_demo_web[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"  -- -L 7001:localhost:7001 -L 8000:localhost:8000

   • Deployment Server Name  : ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_demo_dep[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_demo_dep[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • RDP Reset Password      : gcloud compute reset-windows-password ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")} 
   • RDP Command             : gcloud compute start-iap-tunnel ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")} 3389 --local-host-port=localhost:3389 

----------------------------------------------------------------------------------
 Local /etc/hosts file for IAP tunneling
----------------------------------------------------------------------------------
   127.0.0.1 ${try(google_compute_instance.jde_demo_prov[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_prov[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_prov[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_demo_db[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_db[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_db[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_demo_ent[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_ent[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_ent[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_demo_web[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_web[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_web[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_demo_dep[0].name, "N/A")}
----------------------------------------------------------------------------------
 Storage
----------------------------------------------------------------------------------
   • Bucket Name    : ${module.jde_storage_bucket.name}
   • Bucket URL     : ${module.jde_storage_bucket.url}

----------------------------------------------------------------------------------
   • Generated At   : ${timestamp()}
==================================================================================
EOT
    ) : (
    <<EOT
==================================================================================
        Oracle JD Edwards EnterpriseOne: Customer Data Setup 
==================================================================================

 Project ID         : ${var.project_id}
 Region             : ${var.region}
 Zone               : ${var.zone}
 VPC Network        : ${module.network.network_name}

----------------------------------------------------------------------------------
 JD Edwards Instances: Customer Data
----------------------------------------------------------------------------------
   • Provisoning Server Name : ${try(google_compute_instance.jde_prov[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_prov[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_prov[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_prov[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 3000:localhost:3000 -L 8998:localhost:8998

   • Database Server Name    : ${try(google_compute_instance.jde_db[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_db[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_db[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_db[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}" -- -L 1521:localhost:1521

   • Enterprise Server Name  : ${try(google_compute_instance.jde_ent[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_ent[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_ent[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_ent[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"

   • Web Server Name         : ${try(google_compute_instance.jde_web[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_web[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_web[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command             : gcloud compute ssh --zone "${var.zone}" "${try(google_compute_instance.jde_web[0].name, "N/A")}" --tunnel-through-iap --project "${var.project_id}"  -- -L 7001:localhost:7001 -L 8000:localhost:8000

   • Deployment Server Name  : ${try(google_compute_instance.jde_dep[0].name, "N/A")}
   • Internal IP             : ${try(google_compute_instance.jde_dep[0].network_interface[0].network_ip, "N/A")}
   • External IP             : ${try(google_compute_instance.jde_dep[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • RDP Reset Password      : gcloud compute reset-windows-password ${try(google_compute_instance.jde_dep[0].name, "N/A")} 
   • RDP Command             : gcloud compute start-iap-tunnel ${try(google_compute_instance.jde_dep[0].name, "N/A")} 3389 --local-host-port=localhost:3389 

----------------------------------------------------------------------------------
 Local /etc/hosts file for IAP tunneling
----------------------------------------------------------------------------------
   127.0.0.1 ${try(google_compute_instance.jde_prov[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_prov[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_prov[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_db[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_db[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_db[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_ent[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_ent[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_ent[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_web[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_web[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_web[0].name, "N/A")}
   127.0.0.1 ${try(google_compute_instance.jde_dep[0].name, "N/A")}.c.${var.project_id}.internal ${try(google_compute_instance.jde_dep[0].name, "N/A")}.${var.zone}.c.${var.project_id}.internal ${try(google_compute_instance.jde_dep[0].name, "N/A")}
---------------------------------------------------------------------------------

----------------------------------------------------------------------------------
 Storage
----------------------------------------------------------------------------------
   • Bucket Name    : ${module.jde_storage_bucket.name}
   • Bucket URL     : ${module.jde_storage_bucket.url}

----------------------------------------------------------------------------------
   • Generated At   : ${timestamp()}
==================================================================================
EOT
  )
  description = "Auto-calculated summary of either Oracle JDE Enterprise One depending on the toggle."
}

output "exascale_deployment_summary" {
  value = var.oracle_jde_exascale ? (<<-EOT

=========================================
 Oracle jde on ExaScale @ GCP
-----------------------------------------
 Project ID     : ${var.project_id}
 Region         : ${var.region}
 Zone           : ${var.zone}
 ExaScale Region: ${var.exascale_location}
-----------------------------------------
 Application Tier (GCE)
-----------------------------------------
   Name         : ${try(google_compute_instance.exascale_jde[0].name, "N/A")}
   Internal IP  : ${try(google_compute_instance.exascale_jde[0].network_interface[0].network_ip, "N/A")}
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
  ) : ""
  description = "Summary of Oracle jde on ExaScale deployment."
}
