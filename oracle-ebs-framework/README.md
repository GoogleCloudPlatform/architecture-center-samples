# Oracle EBS Toolkit on Google Cloud | Oracle EBS Vision

This folder provides Terraform configurations and Makefile automation to deploy Oracle EBS infrastructure on Google Cloud.


## Architecture Diagram

### Oracle Vision on Google Cloud
![Oracle Vision on Google Cloud Technical Architecture Diagram](images/Oracle%20Vision%20on%20GCP_%20Technical%20Architecture%20diagram.png "Oracle Vision on GCP Technical Architecture Diagram")

### Oracle Customer EBS on Google Cloud
![Oracle Customer EBS on Google Cloud Technical Architecture Diagram](images/Oracle%20Customer%20EBS%20on%20GCP_%20Technical%20Architecture%20diagram.png "Oracle Customer EBS on GCP Technical Architecture Diagram")

## Prerequisites

Before starting, ensure the following requirements are met:

### Environment
- Google Cloud project: A Google Cloud project must already exist for this deployment. Note the `PROJECT_ID`.
- Make: Install the `make` tool (version >= 4.3 recommended).

### Quota Requirements
Before deploying Toolkit, verify that your Google Cloud project has sufficient resource quotas in the target region.

Minimum recommended quotas:
- Persistent Disk SSD (GB): ≥ 1TB

Check your current quotas with:

```
gcloud compute regions describe <REGION> --project=<PROJECT_ID> \
  --format="flattened(quotas[].metric,quotas[].limit,quotas[].usage)" | grep SSD
  ```

If the Persistent Disk SSD quota is less than 1 TB, the deployment will fail.

Action if insufficient:

 - Go to Google Cloud Console – Quotas: https://console.cloud.google.com/iam-admin/quotas

 - Filter for Persistent Disk SSD (GB) in your region.

 - Click EDIT QUOTAS and request the desired increase.

 - Once the quotas are approved, proceed with the next steps.

### IAM

Ensure your Google Cloud account has the following IAM roles:

- `roles/iam.serviceAccountUser` – Use service accounts for VM access  
- `roles/iap.tunnelResourceAccessor` – Connect to VMs using IAP tunneling  
- `roles/compute.osAdminLogin` – SSH/RDP access to VMs via OS Login  
- `roles/compute.instanceAdmin.v1` – Start, stop, and manage VM instances  
- **Storage access (choose one):**  
  - `roles/storage.admin` – Full control of Cloud Storage (buckets and objects), **or**  
  - `roles/storage.objectAdmin` – Object-level control only (least privilege option) 

#### Alternatively, the Google Cloud account can have broad roles like:
- `roles/owner`

- `roles/editor`

## Oracle EBS Vision Deployment

All Makefile commands should be run from the project root for all the deployments.

### 1. Setup the environment

```bash
# Install required tools
make setup

# Verify Google Cloud account and project
gcloud config list

# Verify Google Cloud access and IAM roles
make verify-gcp-access
```

---

### 2. Authenticate with Google Cloud and configure Application Default Credentials:

Terraform uses Application Default Credentials (ADC) to interact with Google Cloud. Run the following command before initializing Terraform:

```bash
gcloud auth application-default login
```

---

### 3. Deploy EBS Vision Infrastructure

Run the commands below to deploy the Oracle EBS single-node vision environment:

```bash
# Initialize Terraform backend and modules
make init

# IMPORTANT: Verify the disk type and disk sizes in the infra.auto.tfvars file

# Plan the changes
make vision_plan

# Deploy the changes
make vision_deploy
```

---

### 4. Stage Vision Media files

1) Login to https://edelivery.oracle.com using your Oracle account
2) Search for "Oracle VM Virtual Appliance for Oracle E-Business Suite" and download the media (~ 19 V*.zip files)
3) Copy those Oracle EBS vision media to the Google Cloud Storage bucket created by the steps above 

* NOTE: deploy process will do md5sum, in case of data issues compare README_DISK -> assemble_12212.zip -> md5sumwhenshipped.txt"

```bash
# Example
gcloud storage cp V*.zip gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/

    Copying file://V1034614-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034614-01_1of2.zip
    Copying file://V1034614-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034614-01_2of2.zip
    Copying file://V1034637-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034637-01_1of2.zip
    Copying file://V1034637-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034637-01_2of2.zip
    Copying file://V1034645-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034645-01_1of2.zip
    Copying file://V1034645-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034645-01_2of2.zip
    Copying file://V1034652-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034652-01_1of2.zip
    Copying file://V1034652-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034652-01_2of2.zip
    Copying file://V1034656-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034656-01_1of2.zip
    Copying file://V1034656-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034656-01_2of2.zip
    Copying file://V1034663-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034663-01_1of2.zip
    Copying file://V1034663-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034663-01_2of2.zip
    Copying file://V1034669-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034669-01_1of2.zip
    Copying file://V1034669-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034669-01_2of2.zip
    Copying file://V1034670-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034670-01_1of2.zip
    Copying file://V1034670-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034670-01_2of2.zip
    Copying file://V1034671-01_1of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034671-01_1of2.zip
    Copying file://V1034671-01_2of2.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1034671-01_2of2.zip
    Copying file://V1035290-01.zip to gs://oracle-ebs-toolkit-storage-bucket-9e70a5a7/V1035290-01.zip
```

---

### 5. Deploy Oracle EBS Vision environment

This process lasts ~50-60 minutes

```bash
# Deploy changes
make vision_deploy_oracle_ebs
```

Add the following line (127.0.0.1 apps.example.com apps) to the local hosts file:

```bash
# Mac hosts file 
cat /etc/hosts
    127.0.0.1 apps.example.com apps

# Windows hosts file
C:\windows\system32\drivers\etc\hosts
    127.0.0.1 apps.example.com apps
```

Open IAP tunnel

```bash
# open tunnel
gcloud compute ssh "oracle-vision" --tunnel-through-iap  \
 --project "oracle-ebs-toolkit" -- -L 8000:localhost:8000

```

Add http://apps.example.com:8000 to the Java Security Exception list.
Open a browser and login to http://apps.example.com:8000 using sysadmin/SYSADMIN12 (case sensitive)

---

### 6. Available additional commands

After the Oracle EBS Vision environment deployment process few extra functions are available.
Also server can be stoped/started, and Oracle EBS will autostart/stop along.

```bash
# Review EBS Vision environment details for troubleshooting deployment
make vision_ebs_troubleshoot

# Start EBS Vision environment
make vision_ebs_start

# Stop EBS Vision environment
make vision_ebs_stop
```

---

### 7. Destroy Vision Media

```bash
# Destroy Vision infrastructure (including buckets and VM)
make vision_destroy
```
---

### Notes

- `PROJECT_ID` is auto-detected from `gcloud config` or can be passed explicitly

- Run `make verify-gcp-access` **once** to confirm IAM roles; it is not required for each Terraform command.
