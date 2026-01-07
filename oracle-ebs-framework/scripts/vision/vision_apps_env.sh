#!/bin/bash
set -e

# environment file for vision apps install
# passwords (defaults)
APPS_USER="apps"
APPS_PASS="apps"
WEBLOGIC_PASS="welcome1"
SYSADMIN_PASS="SYSADMIN12"

# FS PATH
FS_BASE="/u01/install/APPS"

# PROVSIONED BUCKET
BUCKET_NAME=$(gcloud storage ls | grep oracle-ebs-toolkit-storage-bucket)