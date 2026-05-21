#!/bin/bash

# This script contains utility functions for the EBS project

#Source Env
# if [ -f ~/scripts/environment ]; then
#     source /home/oracle/scripts/environment
# else     
#     source /scripts/environment
# fi

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi
if [ -z "$BUCKET" ]; then BUCKET=$(gcloud storage ls | grep oracle-peoplesoft-toolkit-storage-bucket); fi

# paths
local_media=/u01/install

## function list | Common
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

print_task(){
    echo -e "\n\033[1m### ${1} \033[0m"    
}

print_summary(){
    file=$(find ~/psft_dpk_work/psft_dpk_setup*.log | tail -1)
    p_user=$(grep "DB user" $file | grep -oP '(?<=DB user \[)[^\]]+')
    p_type=$(grep "Global Database Name" $file | sed 's/.*:CDB//')

    echo -e "\n\033[1m
         =================================================
                 Oracle Peoplsoft Deployment: ${p_type}
         =================================================
          URL                : http://$(hostname -f):8000/ps/signon.html
          User               : ${p_user}
          Password           : Manager123

          hosts file entry   : 127.0.0.1 $(hostname -f) $(hostname)
          IAP tunneling      : 
          	gcloud compute ssh "${hostname}" --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8000:localhost:8000
         -----------------------------------------
    \033[0m"    
}

## function list | Peoplesoft

## COMMON FUCNTIONS
function_example() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function precreates dirs, files, ownership and other root activites
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    # Check if OS is ready
    
    ### actual function betweens these comments
    print_task "Doing Stuff - function "


    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

stage_poeplesoft_media() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function fetching Peoplesoft HCM media from bucket to local disk
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Files on Bucket: ${BUCKET}"
    gcloud storage ls -l ${BUCKET}

    print_task "Fetching files from: ${BUCKET} to local disk: ${local_media}"
    gcloud storage cp ${BUCKET}*.zip ${local_media}/

    print_task "Files on local disk: ${local_media}"
    ls -l ${local_media}

    print_task "MD5 Checksums for files on local disk: ${local_media}"
    md5sum ${local_media}/*.zip

    print_task "Preparing Peoplesoft media for installation - unzipping and pre-staging files for installation"
    cd ${local_media}
   
   for f in *.zip; do
    echo "Checking $f for Peoplesoft install file..."
    if unzip -l "$f" | grep -q "setup/psft-dpk-setup.sh"; then
        echo "Found psft-dpk-setup.sh in $f! Unzipping..."
        unzip -qo "$f"
        break
    fi
    done
    
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

install_poeplesoft() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to install Peoplesoft local disk
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Peoplesoft install files"
    cd ${local_media}/setup
    ls -la

    print_task "Veirifing psft-dpk-setup.sh is in place for installation"
    if ! TARGET_FILE=$(find ${local_media} -name "psft-dpk-setup.sh" 2>/dev/null | grep .); then
        echo -e "\033[1;31m
        ERROR: Install media not found!
        Make sure to upload the correct Peoplesoft install media from Oracle E-Delivery:
         - PeopleSoft Human Capital Management 9.2 Update Image 54 or later 
         - PeopleSoft Customer Relationship Management 9.2 Update Image 23 or later 
         \033[0m" >&2
        exit 1
    else    
        print_task "All Good: $TARGET_FILE found - proceeding with installation"
    fi

    print_task "Preparing Installation"
    cp -v /scripts/wrapper.sh ${local_media}/setup
    chmod +x ${local_media}/setup/wrapper.sh

    print_task "Executing Peoplesoft Installation"
    print_task "!!! note: time consuming ~90-120 mins step"
    cd ${local_media}/setup/
    ./wrapper.sh
    
    print_task "Creating cron autostart"
    # add reboot script to cron
    if [ $(crontab  -l | grep start_poeplesoft | wc -l) -eq 0 ]; then
        job="@reboot source ~/.bash_profile && start_poeplesoft | tee -a /scripts/logs/start_poeplesoft.log 2>&1"
        ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
    fi

    print_summary

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date                  

 } 2>&1 | tee -a ${logfile}
}

## maintenacne operations
stop_poeplesoft() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to stop Peoplesoft services
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    # Check if OS is ready
    
    ### actual function betweens these comments
    print_task "Stop Peoplesoft Application Servers and Process Schedulers"

    source /u02/pt/psft_env.sh
    psadmin -w shutdown -d peoplesoft
    psadmin -c shutdown -d APPDOM
    psadmin -p shutdown -d PRCSDOM

    print_task "Stop Peoplesoft Database listener and database"
    export ORACLE_SID=$(cat /etc/oratab | awk -F: '{print $1}')
    lsnrctl  stop
    sqlplus / as sysdba <<EOF
set echo on
shutdown immediate;
exit;
EOF

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

start_poeplesoft() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to stop Peoplesoft services
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    # Check if OS is ready
    
    ### actual function betweens these comments
    source /u02/pt/psft_env.sh
    export ORACLE_SID=$(cat /etc/oratab | awk -F: '{print $1}')
    
    print_task "Start Peoplesoft Database listener and database"
    
    lsnrctl  start
    sqlplus / as sysdba <<EOF
set echo on
startup;
exit;
EOF

    lsnrctl  status

    print_task "Start Peoplesoft Application Servers and Process Schedulers"
    psadmin -p start -d PRCSDOM
    psadmin -c start -d APPDOM
    psadmin -w start -d peoplesoft

    print_summary

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}
