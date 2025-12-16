output "vision_instance_zone" {
  description = "The zone of the Oracle Vision instance."
  value       = try(var.oracle_ebs_vision ? google_compute_instance.vision[0].zone : "", "")
}

output "apps_instance_zone" {
  description = "The zone where the EBS apps instance is deployed"
  value = try(!var.oracle_ebs_vision ? google_compute_instance.apps[0].zone : "", "")
}

output "dbs_instance_zone" {
  description = "The zone where the EBS database instance is deployed"
  value = try(!var.oracle_ebs_vision ? google_compute_instance.dbs[0].zone : "", "")
}

output "deployment_summary" {
  value = var.oracle_ebs_vision ? (
    <<EOT
=========================================
        Oracle Vision VM Deployment
=========================================

 Project ID         : ${var.project_id}
 Region             : ${var.region}
 Zone               : ${var.zone}
 VPC Network        : ${module.network.network_name}

-----------------------------------------
 Vision Instance
-----------------------------------------
   • Name           : ${google_compute_instance.vision[0].name}
   • Internal IP    : ${google_compute_instance.vision[0].network_interface[0].network_ip}
   • External IP    : ${try(google_compute_instance.vision[0].network_interface[0].access_config[0].nat_ip, "N/A")}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${google_compute_instance.vision[0].name}" --tunnel-through-iap --project "${var.project_id}"

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : ${module.ebs_storage_bucket.name}
   • Bucket URL     : ${module.ebs_storage_bucket.url}

-----------------------------------------
 Summary
-----------------------------------------
   • Total Instances: 1
   • Instance Name  : ${google_compute_instance.vision[0].name}
   • Generated At   : ${timestamp()}
=========================================
EOT
    ) : (
    <<EOT
=========================================
        Oracle E-Business Suite Setup
=========================================

 Project ID         : ${var.project_id}
 Region             : ${var.region}
 Zone               : ${var.zone}
 VPC Network        : ${module.network.network_name}

-----------------------------------------
 Apps Instance
-----------------------------------------
   • Name           : ${google_compute_instance.apps[0].name}
   • Internal IP    : ${google_compute_instance.apps[0].network_interface[0].network_ip}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${google_compute_instance.apps[0].name}" --tunnel-through-iap --project "${var.project_id} -- -L 8000:localhost:8000"

-----------------------------------------
 DB Instance
-----------------------------------------
   • Name           : ${google_compute_instance.dbs[0].name}
   • Internal IP    : ${google_compute_instance.dbs[0].network_interface[0].network_ip}
   • SSH Command    :
       gcloud compute ssh --zone "${var.zone}" "${google_compute_instance.dbs[0].name}" --tunnel-through-iap --project "${var.project_id}"

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : ${module.ebs_storage_bucket.name}
   • Bucket URL     : ${module.ebs_storage_bucket.url}

=========================================
 Summary
-----------------------------------------
   • Total Instances: 2
   • Storage Bucket : ${module.ebs_storage_bucket.name}
   • Generated At   : ${timestamp()}
=========================================
EOT
  )
  description = "Auto-calculated summary of either Oracle Vision VM or Oracle E-Business Suite deployment, depending on the toggle."
}
