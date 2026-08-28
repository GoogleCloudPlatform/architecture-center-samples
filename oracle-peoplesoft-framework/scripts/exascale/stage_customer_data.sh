#!/bin/bash
set -e

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi
if [ -z "$BUCKET" ]; then BUCKET=$(gcloud storage ls | grep oracle-peoplesoft-toolkit-storage-bucket); fi

# paths
local_media=/u01

print_task(){
    echo -e "\n\033[1m### ${1} \033[0m"    
}

## COMMON FUCNTIONS
function_example() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function precreates dirs, files, ownership and other activites
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Doing Stuff - function "

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

is_root_user() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0  # true, user is root
    else
        echo "User is not root"
        return 1  # false, user is not root
    fi
}

is_oracle_user() {
    if [ "$(id -un)" = "oracle" ]; then
        return 0  # true, user is oracle
    else
        echo "User is not oracle"
        return 1  # false, user is not oracle
    fi
}

stage_cust_data() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function fetching Peoplesoft customer data from bucket to local disk
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Files on Bucket: ${BUCKET}"
    gcloud storage ls -l ${BUCKET}

    print_task "Fetching rman files from: ${BUCKET} to local disk: ${local_media}/rman"
	mkdir -p ${local_media}/rman
    gcloud storage cp ${BUCKET}*.bkp ${local_media}/rman
	
    print_task "Fetching app files from: ${BUCKET} to local disk: ${local_media}/app"
	mkdir -p ${local_media}/app
	gcloud storage cp ${BUCKET}*.tar.gz ${local_media}/app
	gcloud storage cp ${BUCKET}domaininfo.txt ${local_media}/app/
    gcloud storage cp ${BUCKET}psft.env ${local_media}/app/
	
    print_task "Files on local disk: ${local_media}"
    ls -l ${local_media}/rman/*
    ls -l ${local_media}/app/*
    
    print_task "Updating permissions of files on local disk: ${local_media}"
    chmod -R 777 ${local_media}/rman
    chmod -R 777 ${local_media}/app

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

# Main
stage_cust_data;
