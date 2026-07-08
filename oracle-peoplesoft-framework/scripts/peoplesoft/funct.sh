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
          	gcloud compute ssh $(hostname) --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8000:localhost:8000
         -----------------------------------------
    \033[0m"    
}

print_summary_cust(){
    ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')
    echo -e "\n\033[1m
         =================================================
                 Oracle Peoplsoft Deployment: Customer Data: ${ORACLE_SID}
         =================================================
          URL                : http://$(hostname -f):8001/ps/signon.html
          User               : VP1
          Password           : ** None of the passwords was changed through the process **

          hosts file entry   : 127.0.0.1 $(hostname -f) $(hostname)
          IAP tunneling      : 
          	gcloud compute ssh $(hostname) --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8001:localhost:8001
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

############################################################
#### Peoplesoft Customer data functions here onwards ####
############################################################

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
    #gcloud storage cp ${BUCKET}/DBNAME.txt ${local_media}/app/DBNAME.txt
	
    print_task "Files on local disk: ${local_media}"
    ls -l ${local_media}/rman/*
    ls -l ${local_media}/app/*
    
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


rdbms_stage_oh() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
        echo "
         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_stage_oh
         =========================================
         Function restores RDBMS HOME from backup
         -----------------------------------------"
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi

    ### actual function betweens these comments

    # extract OH
	export ORACLE_HOME=/u02/db/oracle-server/19.3.0.0
	if [ ! -d "$ORACLE_HOME" ]; then  mkdir -p "$ORACLE_HOME"; fi
		
    print_task "Extract RDBMS Software from ${local_media}/app"
    
	OLD_OH=$(tar tvzf ${local_media}/app/RDBMS_TO_GCP.tar.gz  | head -1 | awk '{print $NF}')
	
    echo "RDBMS backup   : ${local_media}/app/RDBMS_TO_GCP.tar.gz"
    echo "Extracting non-verbose: (few mins)"

    time tar -xzf ${local_media}/app/RDBMS_TO_GCP.tar.gz -C $(dirname "$ORACLE_HOME")

    # move files
    mv $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")/{.,}* $ORACLE_HOME/
    rmdir -v $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")

    ls -ld $ORACLE_HOME
    ls -la $ORACLE_HOME/ | head -10
    echo ".."
  
    print_task "Configurting RDBMS HOME - relink"
    
	ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')
    
	print_task "Oracle SID is set to ${ORACLE_SID}"
	export ORACLE_SID=$ORACLE_SID
    export ORACLE_BASE=/u02/db/oracle
    export PATH=$ORACLE_HOME/bin:$PATH
    #export CV_ASSUME_DISTID=OEL7.9
    cd $ORACLE_HOME/bin/
    ./relink all

    print_task "Backing up existing TNS and dbs"
    cd 
    mv $ORACLE_HOME/dbs $ORACLE_HOME/dbs.$(date +%Y%m%d_%H%M%S)
    #mv $ORACLE_HOME/network/admin $ORACLE_HOME/network/admin.$(date +%F) # can't do this - relink fails
    mv $ORACLE_HOME/network/admin/listener.ora $ORACLE_HOME/network/admin/listener.ora.$(date +%Y%m%d_%H%M%S)
    mv $ORACLE_HOME/network/admin/sqlnet.ora $ORACLE_HOME/network/admin/sqlnet.ora.$(date +%Y%m%d_%H%M%S)
    mv $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora.$(date +%Y%m%d_%H%M%S)
    mkdir -p $ORACLE_HOME/dbs $ORACLE_HOME/network/admin
	
	# Create tnsnames.ora and copy it over to $ORACLE_HOME/network/admin
	print_task "Setting up tnsnames.ora and listener.ora"
	CDBNAME=$(ls ${local_media}/rman/*.bkp 2>/dev/null | tail -1 | awk -F_ '{ print $2 }')
	if [ -z "$CDBNAME" ]; then
		echo "ERROR: CDBNAME could not be determined from backup files."
		return 1
	fi
	full_hname=$(hostname -f)
	
echo "
LISTENER_${CDBNAME} =
  (ADDRESS = (PROTOCOL = TCP)(HOST = ${full_hname})(PORT = 1521))


${CDBNAME} =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${full_hname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${CDBNAME})
    )
  )
" > ${ORACLE_HOME}/network/admin/tnsnames.ora

	# Create listener.ora and copy it over to $ORACLE_HOME/network/admin and startup listener
	
echo "
psft_listener =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = ${full_hname})(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
" > ${ORACLE_HOME}/network/admin/listener.ora

	print_task "Starting up listener"	
	lsnrctl start;

	# Create init${ORACLE_SID}.ora and copy it over to $ORACLE_HOME/dbs
    print_task "Setting up pfile"	
	
	echo "db_name='$CDBNAME'" > ${ORACLE_HOME}/dbs/init${CDBNAME}.ora
	
	# Startup nomount instance
	
	print_task "Startup nomount ${ORACLE_SID}"
	
sqlplus / as sysdba <<EOF
startup nomount;
EOF

 echo -e "\nlog: $logfile"
    date       
 } 2>&1 | tee -a ${logfile}
}


## Rman restore database function

rdbms_rman_restore() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to restore database - time consuming step
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    # check if Oracle running (simple process check)
    # if ! is_oracle_started; then echo "Required Oracle and Listener to be running."; return 1; fi
    
    ### actual function betweens these comments
    print_task "RMAN: Restoring database from Backup location"
    ls ${local_media}/rman/*.bkp
	
	ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')
    
	print_task "Oracle SID is set to ${ORACLE_SID}"
	export ORACLE_SID=$ORACLE_SID
    export ORACLE_HOME=/u02/db/oracle-server/19.3.0.0
    export ORACLE_BASE=/u02/db/oracle
    export PATH=$ORACLE_HOME/bin:$PATH
	
	# Create required directories
	mkdir -p /u02/db/oradata/
	mkdir -p /u02/db/oracle-server/fast_recovery_area
	mkdir -p /u02/db/oracle-server/admin
	mkdir -p /u02/db/oradata/${ORACLE_SID}

    print_task "RMAN: creating rman_restore.rman file"
	
echo "
	run
	{
	  ALLOCATE auxiliary CHANNEL c1 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c2 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c3 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c4 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c5 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c6 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c7 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c8 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c9 DEVICE TYPE DISK;
	  ALLOCATE auxiliary CHANNEL c10 DEVICE TYPE DISK;
	  duplicate database to ${ORACLE_SID}
	  spfile
	  set db_unique_name '${ORACLE_SID}'
	  set control_files '/u02/db/oradata/${ORACLE_SID}/control01.ctl','/u02/db/oradata/${ORACLE_SID}/control02.ctl'
	  set db_create_file_dest '/u02/db/oradata/'
	  set db_create_online_log_dest_1 '/u02/db/oradata/${ORACLE_SID}'
	  set db_recovery_file_dest '/u02/db/oracle-server/fast_recovery_area'
	  set db_recovery_file_dest_size '100G'
	  set audit_file_dest '/u02/db/oracle-server/admin'
	  set core_dump_dest='/u02/db/oracle-server'
	  set diagnostic_dest '/u02/db/oracle-server'
	  set pga_aggregate_target '2g'
	  set sga_target '15g'
	  set sga_max_size '15g'
	  set sessions '2000'
	  set processes '1000'
	  set shared_pool_reserved_size '40M'
	  set shared_pool_size '400M'
	  set result_cache_max_size '300M'
	  set recyclebin 'OFF'
	  backup location '${local_media}/rman'
	  NOFILENAMECHECK;
	}
" > /scripts/rman_restore.rman

    print_task "RMAN: Starting rman restore...may take a long time..."

time rman auxiliary / cmdfile=/scripts/rman_restore.rman | tee -a /scripts/logs/rman_duplicate_from_backup_$(date +%F_%H-%M-%S).log

# Set local_listener parameter
HN=$(hostname -s)
sqlplus -s / as sysdba <<EOF
alter system set local_listener='$HN:1521' scope=both;
show parameter local_listener;
alter system register;
show pdbs;
EOF

# Check status of listener again
    lsnrctl status;
	
    print_task "RMAN: Setting up tnsnames for the application.."

	full_hname=$(hostname -f)
	
PDBNAME=$(sqlplus -s / as sysdba <<EOF
set heading off feedback off verify off pages 0 lines 200
select NAME from V\$CONTAINERS where name not like '%\$ROOT' and name not like '%\$SEED';
EOF
) 
		
echo "
${PDBNAME} =
 (DESCRIPTION =
   (ADDRESS = (PROTOCOL = TCP)(HOST = ${full_hname})(PORT = 1521))
   (CONNECT_DATA =
     (SERVER = DEDICATED)
     (SERVICE_NAME = ${PDBNAME})
   )
 )
" > /u02/db/tnsnames.ora
	
    
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


# Peoplesoft Customer Application setup on GCP

setup_cust_app() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to setup up Peoplesoft customer applications on GCP
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Setting up Peoplesoft applications..."
	print_task "Setting up Environment file.."
	mkdir -p /u02/app
	cp -fv ${local_media}/app/psft.env /u02/app
	cd /u02/app
	sed -i 's|export TNS_ADMIN=.*$|export TNS_ADMIN=/u02/db|' psft.env
	sed -i 's|export ORACLE_HOME=.*$|export ORACLE_HOME=/u02/db/oracle-server/19.3.0.0|' psft.env 
    sed -i 's|export PS_CFG_HOME=.*$|export PS_CFG_HOME=/u02/app/oldcfg|' psft.env 
	PTDIR=`dirname $(grep PS_APP_HOME psft.env | awk -F= '{ print $2 }')`
    
	print_task "Unarchiving PT directory...in ${PTDIR}"

	mkdir -p ${PTDIR}
	cd ${PTDIR}	
	tar xfz ${local_media}/app/PT_TO_GCP.tar.gz
	
	print_task "Unarchiving CFG directory..."
	
	mkdir -p /u02/app/oldcfg
	cd /u02/app/oldcfg
	tar xfz ${local_media}/app/PS_CFG_HOME_TO_GCP.tar.gz
    
	print_task "Replicating configuration home..."
	
	source /u02/app/psft.env
	export PS_CFG_HOME=/u02/app/newcfg
	which psadmin
	psadmin -replicate -ch /u02/app/oldcfg -r
	
	print_task "Updating env file with new configuration home..."
    
	sed -i 's|export PS_CFG_HOME=.*$|export PS_CFG_HOME=/u02/app/newcfg|' /u02/app/psft.env 
	
    print_task "Updating configuration.properties file with new values..."
	
	cd /u02/app/newcfg/webserv/peoplesoft/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/ps
	pwd;
	cp -v configuration.properties configuration.properties.`date +%F-%T`
	full_hname=$(hostname -f)
	sed -Ei "s|^(psserver=)[^:]+(:[0-9]+)$|\1${full_hname}\2|" configuration.properties
	
	print_task "New psserver value in configuration.properties is ..."
	
	grep "^psserver=" configuration.properties
	
	print_task "Updating setEnv.sh with new values..."
	
	cd /u02/app/newcfg/webserv/peoplesoft/bin
	pwd;
	cp -v setEnv.sh setEnv.sh.`date +%F-%T`
	shn=$(hostname -s)
	sed -i "s|ADMINSERVER_HOSTNAME=.*$|ADMINSERVER_HOSTNAME=$shn|" setEnv.sh
	
	print_task "New ADMINSERVER_HOSTNAME value in setEnv.sh is ..."
	
	grep "ADMINSERVER_HOSTNAME=" setEnv.sh
	grep "PIA_HOME=" setEnv.sh	
    source /u02/app/psft.env 
	
    WEB_DOM=$(grep "DOMAIN_NAME=" setEnv.sh | awk -F= '{ print $2 }')
	HOST_D=$(hostname -d)
	
	print_task "Configuring domain name for $WEB_DOM to $HOST_D"
	
	psadmin -w configure -d ${WEB_DOM} -c "1024m/2048m/100/${HOST_D}"
	
	print_task "Configuring http port for $WEB_DOM to 8001"
	
	psadmin -w configure -d ${WEB_DOM} -p "8001/8443"

	print_task "Starting up weblogic server domain $WEB_DOM...."
		
	psadmin -w start -d $WEB_DOM;
	
	APPD=$( grep APP_DOMAIN_NAME ${local_media}/app/domaininfo.txt | awk -F= '{ print $2 }')
	
    print_task "Starting up appserv server domain ${APPD}...."
	
	psadmin -c start -d ${APPD};	
	
	PRCSD=$( grep PRCS_DOMAIN_NAME ${local_media}/app/domaininfo.txt | awk -F= '{ print $2 }')
	
    print_task "Starting up process server domain ${PRCSD}...."
		
    psadmin -p start -d ${PRCSD};

	print_task "Status of weblogic server domain $WEB_DOM...."
	psadmin -w status -d $WEB_DOM;	
	
	print_task "Status of appserv server domain APPDOM...."
	psadmin -c status -d ${APPD};
	
    print_task "Status of process server domain PRCSDOM...."
	psadmin -p status -d ${PRCSD};	

    print_task "Creating Peoplesoft auto start script"
ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')

    print_task "Creating cron autostart"
echo "
source /u02/app/psft.env 
export ORACLE_SID=${ORACLE_SID}
export ORACLE_HOME=/u02/db/oracle-server/19.3.0.0
lsnrctl start;
sqlplus / as sysdba<<EOF
startup;
EOF
psadmin -w start -d ${WEB_DOM};
psadmin -c start -d ${APPD};
psadmin -p start -d ${PRCSD};
" > /scripts/peoplesoft_cust_start.sh 
    
    chmod u+x /scripts/peoplesoft_cust_start.sh 

    # add reboot script to cron
    if [ $(crontab -l 2>/dev/null | grep peoplesoft_cust_start | wc -l) -eq 0 ]; then
        job="@reboot /scripts/peoplesoft_cust_start.sh | tee -a /scripts/logs/peoplesoft_cust_start.sh 2>&1"
        ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
    fi
    
    print_summary_cust
	
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}