output "apps_instance_zone" {
  description = "The zone where the PeopleSoft application VM is deployed."
  value       = google_compute_instance.apps.zone
}

output "deployment_summary" {
  description = "Summary of the Oracle PeopleSoft deployment."
  value       = <<-EOT

=========================================
 PeopleSoft VM Configuration
-----------------------------------------
   • Instance Name  : ${google_compute_instance.apps.name}
   • Internal IP    : ${google_compute_instance.apps.network_interface[0].network_ip}
   • Zone           : ${var.zone}
   • Machine Type   : ${google_compute_instance.apps.machine_type}
   • SSH Command    : 
       gcloud compute ssh --zone "${var.zone}" "${google_compute_instance.apps.name}" --tunnel-through-iap --project "${var.project_id}" -- -L 8000:localhost:8000

-----------------------------------------
 Storage
-----------------------------------------
   • Bucket Name    : ${module.peoplesoft_storage_bucket.name}
   • Bucket URL     : gs://${module.peoplesoft_storage_bucket.name}

=========================================
 Summary
-----------------------------------------
   • Total Instances: 1
   • Storage Bucket : ${module.peoplesoft_storage_bucket.name}
   • Generated At   : ${timestamp()}
=========================================
EOT
}
