# Oracle EBS Toolkit on GCP | Customer Oracle EBS environment

This repository provides Terraform configurations and Makefile automation to deploy Oracle EBS infrastructure on Google Cloud Platform.


## Folder Structure

```
.
├── Makefile
├── scripts/
│   └── install.sh
├── pre-commit.yaml
└── projects/
    └── oracle-ebs-toolkit/

```


## Prerequisites

Before starting, ensure the following requirements are met:

### Environment
- GCP Project: A Google Cloud project must already exist for this deployment. Note the `PROJECT_ID`.
- Make: Install the `make` tool (version >= 4.3 recommended).

### Quota Requirements
Before deploying Toolkit, verify that your GCP project has sufficient resource quotas in the target region.

Minimum recommended quotas:
- Persistent Disk SSD (GB): ≥ 1TB

Check your current quotas with:

```
gcloud compute regions describe <REGION> --project=<PROJECT_ID> \
  --format="flattened(quotas[].metric,quotas[].limit,quotas[].usage)" | grep SSD
  ```

If the Persistent Disk SSD quota is less than 1 TB, deployment will fail.

Action if insufficient:

 - Go to Google Cloud Console – Quotas: https://console.cloud.google.com/iam-admin/quotas

 - Filter for Persistent Disk SSD (GB) in your region.

 - Click EDIT QUOTAS and request the desired increase.

 - Once the quotas are approved, proceed with the next steps.

### IAM

Ensure your GCP account has the following IAM roles:

- `roles/iam.serviceAccountUser` – Use service accounts for VM access  
- `roles/iap.tunnelResourceAccessor` – Connect to VMs using IAP tunneling  
- `roles/compute.osAdminLogin` – SSH/RDP access to VMs via OS Login  
- `roles/compute.instanceAdmin.v1` – Start, stop, and manage VM instances  
- **Storage access (choose one):**  
  - `roles/storage.admin` – Full control of Cloud Storage (buckets and objects), **or**  
  - `roles/storage.objectAdmin` – Object-level control only (least privilege option) 

#### Alternatively, the GCP account can have broad roles like:
- `roles/owner`

- `roles/editor`


## Oracle Environment Deployment with customer-cloned Oracle EBS system

All Makefile commands should be run from the project root for all the deployments.

### 1. Setup environment

```bash
# Install required tools
make setup

# Verify GCP access and IAM roles
make verify-gcp-access
```

---

### 2. Authenticate with GCP and configure Application Default Credentials:

Terraform uses Application Default Credentials (ADC) to interact with GCP. Run the following command before initializing Terraform:

```bash
$ gcloud auth application-default login
```

---
### 3. Deploy EBS + DB

Verify the configurations, such as machine type, disk type, and size, in the file: infra.auto.tfvars

*Note: Specify `dbs_boot_disk_size` in GB to ensure it accommodates both the RMAN backup and the fully restored database, plus an additional ~100GB for spare capacity.*

*Note: Specify `dbs_machine_type` from available [E2 family](https://cloud.google.com/workstations/docs/available-machine-types) : e2-standard-4 / e2-standard-8 (default) / 16 / 32*

After verification, execute the following commands.

```bash
# Initialize Terraform backend & modules
make init

# IMPORTANT: Verify the disk type and disk sizes in the infra.auto.tfvars file

# Preview changes
make plan

# Deploy changes
make deploy

```

---
#### 3.1 Prepare Oracle EBS database to be packed for GCP

Run adpreclone and pack the RDBMS Oracle home and Oracle RMAN cold (startup mount) backup

```bash
# set environment at CDB level (customer specific) as oracle OS user and create a TAR archive
# RMAN backup expected location is dir: RMAN_TO_GCP
. ~/EBSCDB_apps.env
BACKUP_DIR=/home/oracle/
mkdir -p $BACKUP_DIR/RMAN_TO_GCP

if [ -d $ORACLE_HOME/appsutil/clone/dbts ]; then 
mv -v $ORACLE_HOME/appsutil/clone/dbts $ORACLE_HOME/appsutil/clone/dbts.$(date +%Y%m%d); 
fi

cd $ORACLE_HOME/appsutil/scripts/*_$(hostname)/
./adpreclone.pl dbTechStack

cd $BACKUP_DIR
time tar -czf RDBMS_TO_GCP.tar.gz -C $(dirname $ORACLE_HOME	) $(basename ${ORACLE_HOME})

# start database in mount mode
echo "shutdown immediate;" | sqlplus -s / as sysdba
echo "startup mount" | sqlplus -s / as sysdba

# navigate to the target directory capable of storing RMAN backup

cd $BACKUP_DIR/RMAN_TO_GCP
# trigger RMAN full cold backup
# parallelism can be altered and needs to set BACKUP_DIR

rman target / <<EOF
RUN {
    CONFIGURE DEVICE TYPE DISK PARALLELISM 8 BACKUP TYPE TO BACKUPSET;
    CONFIGURE CHANNEL DEVICE TYPE DISK MAXPIECESIZE 30G;

    BACKUP AS BACKUPSET SPFILE
        FORMAT '${BACKUP_DIR}/spfile_%d_%T_%U.bkp' TAG='FULL_COLD_SPFILE';

    BACKUP AS BACKUPSET CURRENT CONTROLFILE
        FORMAT '${BACKUP_DIR}/controlfile_%d_%T_%U.bkp' TAG='FULL_COLD_CONTROL';

    BACKUP AS BACKUPSET DATABASE
        FORMAT '${BACKUP_DIR}/full_%d_%T_ch%U.bkp' TAG='FULL_COLD_BACKUP';
}
EXIT;
EOF

# Stop the database
echo "shutdown immediate;" | sqlplus -s / as sysdba
```

---
#### 3.2 Prepare Oracle EBS Application FS to be packed for GCP

Run adpreclone and pack Oracle EBS RunFS and FS_NE

```bash
# set Oracle EBS run FS environment as applmgr OS user and run
. EBSapps.env run

# complete adpreclone
cd $ADMIN_SCRIPTS_HOME
./adpreclone.pl appsTier

# archive Oracle EBS 12.2 (can add verbosity -v and spool to file)
time tar -czf EBSFS_TO_GCP.tar.gz -C $(dirname $RUN_BASE) $(basename ${RUN_BASE}) $(basename ${NE_BASE})

```
---
#### 3.3 Copy media to the GCP bucket

Copy packed media to the GCP bucket

```bash
# Copy 
GCP_BUCKET=$(gcloud storage ls | grep oracle-ebs-toolkit-storage-bucket)
gcloud storage cp RDBMS_TO_GCP.tar.gz${GCP_BUCKET}
gcloud storage cp EBSFS_TO_GCP.tar.gz ${GCP_BUCKET}
gcloud storage cp -r RMAN_TO_GCP ${GCP_BUCKET}

```

### 4 Deploy Oracle EBS environment

Deploy the Oracle Environment from the packed media

```bash
# Deploy scripts to the servers
make deploy_oracle_ebs_scripts

```

---

### 5.1 Configure Oracle EBS RDBMS on provisioned infrastructure

Oracle EBS is a complicated setup with a lot of moving parts, so follow the action plan below: 

*Note: Update scripts/ebs/environment file with current passwords for cloning on GCP. Later passwords can be changed using seeded procedures and the file can be removed from the server*

```bash
# Connect the server and switch to root
gcloud compute ssh oracle-ebs-db --tunnel-through-iap --project ${PROJECT}
sudo su -

# Execute root activities as functions
source /scripts/funct.sh
rdbms_root_init 

# Switch to OS user Oracle and execute the following functions (preferably from TMUX session)
sudo su - oracle

# stage backup
rdbms_stage_backup

# Configure Oracle home
rdbms_stage_oh

# Restore the database
rdbms_rman_restore

# complete EBS RDBMS part
rdbms_ebs_configure

```

---

### 5.2 Configure Oracle EBS Apps on provisioned infrastructure

Oracle EBS application part setup

```bash
# Connect to the server and switch to root
gcloud compute ssh oracle-ebs-apps --tunnel-through-iap --project ${PROCJECT}
sudo su -

# Execute root activities as functions
source /scripts/funct.sh
ebs_root_init 

# Switch to OS user Oracle and execute the following functions (preferably from TMUX session)
sudo su - oracle

# stage backup
ebs_stage_backup

# Configure Oracle Application
ebs_configure

```

---

### 5.3 Connect to Oracle EBS application 

Open IAP tunnel, update /etc/hosts

```bash
# The above configuration script will show the Login URL and the required hosts entry
# On local machine, edit the hosts file and add a line (example below)

cat /etc/hosts
127.0.0.1 oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal oracle-ebs-apps

# Open IAP tunnel (example)
gcloud compute ssh oracle-ebs-apps --tunnel-through-iap --project $PROJECT_ID -- -L 8000:localhost:8000

# open browser and connect to:
http://oracle-ebs-apps.us-west2-a.c.oracle-ebs-toolkit.internal:8000/OA_HTML/AppsLogin

```

---


### 6 Destroy deployment

```bash
# Destroy Deployments
make destroy

```

---

### Notes

- Minimum Customer Oracle EBS environment requirements:
    - Oracle Database 19c with CDB/PDB configuration
    - Oracle EBS 12.2.7 with AD/TXK Delta 12 updates or newer
    - Oracle Linux / Red Hat Enterprise Linux 8 compatible (Reference [Doc ID 1330701.1](https://support.oracle.com/epmos/faces/DocContentDisplay?id=1330701.1))

- `PROJECT_ID` is auto-detected from `gcloud config` or can be passed explicitly:

- Run `make verify-gcp-access` **once** to confirm IAM roles; it is not required for each Terraform command.

- customer_deploy_demo_logfile.md - has example outputs from all the commands in this page as a reference
