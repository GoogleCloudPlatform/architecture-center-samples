#!/bin/bash
#set -x

# Variables
#LOG_DIR=/scripts/logs
#LOG_FILE=$LOG_DIR/gcp_to_exa_db_sync.$(date +%d%m%y%H%M%S).log
export GCP_DB_ENV=/u01/install/APPS/19.0.0/EBSCDB_apps.env
export EXA_OUT=/tmp/exascale_outputs.yaml
export P_KEY=/home/oracle/.ssh/exadb_private_key.pem
export log_path=/scripts/logs

# excluding bucket for now - as it's extra time to fetch - will enable if needed
# BUCKET=$(gcloud storage ls | grep oracle-ebs-toolkit-storage-bucket)

is_oracle_user() {
    if [ "$(id -un)" = "oracle" ]; then
        return 0  # true, user is oracle
    else
        echo "User is not oracle"
        return 1  # false, user is not oracle
    fi
}

is_oracle_started() {
    if [ "$(ps -fea | egrep "ora_pmon|tnslsnr" | grep -v grep | wc -l)" -ge 2 ]; then
        return 0  # true, there're pmon and lsnr proceses
    else
        echo "Either Oracle (pmon) or Listener (tnslsnr) is not running"
        return 1  # false, user is not oracle
    fi
}

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

create_exainfo() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function Fetches Exascale connection details and admin PWD 
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Fetching ExaScale details to GCP"

     if [ -f $EXA_OUT ]; then
      echo "File $EXA_OUT exists. Creating EXAINFO file."
      grep connection_strings $EXA_OUT | awk -F: '{for(i=2;i<=NF;i++) printf "%s%s", $i, (i==NF?ORS:FS)}' | jq -r '"export EXATNS=\"\(.cdbIpDefault)\""' > /scripts/EXAINFO
      grep admin_password $EXA_OUT | tr -d ' ' | awk -F: '{ print "export SYSPASS="$2 }' >> /scripts/EXAINFO
      grep node_ip $EXA_OUT  | tr -d ' ' | awk -F: '{ print "export EXA_IP="$2 }'  >> /scripts/EXAINFO
      chmod 755 /scripts/EXAINFO
    else
      echo "File $EXA_OUT Missing. Exiting."
      echo "Completed function create_exainfo at $(date +%d%m%y%H%M%S)"
      exit 1
    fi

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

test_exa_connection() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function Tests connectivity to Exascale using details from EXAINFO file
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Testing Oracle Exascale @GCP connection "

    source $GCP_DB_ENV
    source /scripts/EXAINFO
    V_OUT=$(sqlplus -s sys/$SYSPASS@$EXATNS as sysdba <<EOF | tr -d '[:space:]'
    SET HEADING OFF
    SET FEEDBACK OFF
    SELECT 2 + 2 FROM dual;
    EXIT;
EOF
)

	if [ "$V_OUT" = "4" ]; then
	  echo "Exadata connection as sys user validated successfully."
          echo "Exadata tns connection string is : $EXATNS"
	else
	  echo "Exadata connection as sys user CANNOT be validated. Exiting."
          echo "Exadata tns connection string is : $EXATNS"
	  echo "Completed function test_exa_connection at $(date +%d%m%y%H%M%S)"
	  exit 1
	fi

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


update_pass() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function updates passwords for SYS and creates password file for Exascale duplicate operation into Exascale
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Updating SYS passwords for Database duplicate opeation into Exascale "

    source $GCP_DB_ENV
      source /scripts/EXAINFO
      echo "Updating system and ebs_system password in Gcp Vision Database"
    sqlplus -s / as sysdba <<EOF
    PROMPT 'Updating SYS and SYSTEM passwords'
    ALTER USER SYS IDENTIFIED BY "$SYSPASS";
    ALTER USER SYSTEM IDENTIFIED BY "$SYSPASS";
    ALTER SESSION SET CONTAINER=EBSDB;
    PROMPT 'Updating EBS_SYSTEM password'
    ALTER USER EBS_SYSTEM IDENTIFIED BY "$SYSPASS" CONTAINER=CURRENT;
    EXIT;
EOF
    orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=$SYSPASS entries=10 force=y

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


enable_gcp_archivelog() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function Enable archivelog mode in GCP Vision Database, this is a pre-requisite for rman duplicate operation into Exascale
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Checking ARCHIVELOG mode..."

    source $GCP_DB_ENV
    source /scripts/EXAINFO
    sqlplus -s / as sysdba <<EOF
    prompt 'Setting DB_RECOVERY_FILE_DEST to /u01/install/APPS/data/archive'
    alter system set db_recovery_file_dest_size=10G;
    alter system set db_recovery_file_dest='/u01/install/APPS/data/archive';
EOF

    ARCH_MODE=$(sqlplus -s / as sysdba <<EOF | tr -d '[:space:]'
    set heading off feedback off verify off echo off
    select log_mode from v\$database;
    exit;
EOF
)

    if [ "$ARCH_MODE" = "ARCHIVELOG" ]; then
        print_task "Database is already in ARCHIVELOG mode."
    else
        print_task "Database is in NOARCHIVELOG mode. Enabling ARCHIVELOG mode..."
    sqlplus -s / as sysdba <<EOF
    shutdown immediate;
    startup mount;
    alter database archivelog;
    alter database open;
EOF
    print_task "ARCHIVELOG mode enabled."
    # Verify
    sqlplus -s / as sysdba <<EOF
    set heading off
    prompt 'Current log mode:'
    select log_mode from v\$database;
    exit;
EOF
    fi

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


find_drop_exa_pdbs() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function to drop preexisting PDB1 on CDB creation
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Drop PDBs if exists "

    source $GCP_DB_ENV
    source /scripts/EXAINFO
    V_PDB=$(sqlplus -s sys/$SYSPASS@$EXATNS as sysdba <<EOF | tr -d '[:space:]'
    SET HEADING OFF
    SET FEEDBACK OFF
    SELECT PDB_NAME FROM DBA_PDBS WHERE PDB_NAME <> 'PDB\$SEED';
    EXIT;
EOF
)

    if [ "$V_PDB" != "" ]; then
      print_task "PDBS present in Exadata Database: $V_PDB" 
      print_task "Dropping pdb $V_PDB"
    sqlplus -s sys/$SYSPASS@$EXATNS as sysdba <<EOF 
    PROMPT 'Setting REMOTE_RECOVERY_FILE_DEST to +RECOEBSCDB'
    ALTER SYSTEM SET REMOTE_RECOVERY_FILE_DEST="+RECOEBSCDB";
    PROMPT 'Setting SEC_CASE_SENSITIVE_LOGON to FALSE'
    ALTER SYSTEM SET SEC_CASE_SENSITIVE_LOGON=FALSE SCOPE=SPFILE;
    PROMPT 'PDBS BEFORE DROP'
    SHOW PDBS;
    PROMPT 'Closing PDB $V_PDB'
    ALTER PLUGGABLE DATABASE $V_PDB CLOSE;
    PROMPT 'Dropping PDB $V_PDB, this process can take a few minutes to complete...'
    DROP PLUGGABLE DATABASE $V_PDB INCLUDING DATAFILES;
    PROMPT 'PDBS AFTER DROP'
    SHOW PDBS;
    EXIT;
EOF

else
   print_task "No PDB found in Exadata Database"
fi


    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

transfer_files() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function transfers required files for Exascale Database setup
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Transferring files to Exascale Database Server"

    print_task "Setting up ssh connection for file transfer and remote command execution"

    export SSH_CMD="ssh -o StrictHostKeychecking=no"
    export SCP_CMD="scp -o StrictHostKeychecking=no"
    source $GCP_DB_ENV
    source /scripts/EXAINFO
    ${SSH_CMD} -i $P_KEY opc@$EXA_IP 'echo "SSH connection to Exascale Server is working"'
    cd /scripts
    ${SCP_CMD} -i $P_KEY exa_post_dup.sh opc@$EXA_IP:/tmp
    ${SCP_CMD} -i $P_KEY EXAINFO opc@$EXA_IP:/tmp
    cd $ORACLE_HOME
    zip -qr appsutil.zip appsutil
    zip -qr 9idata.zip nls/data/9idata
    ${SCP_CMD} -i $P_KEY $ORACLE_HOME/appsutil.zip opc@$EXA_IP:/tmp
    ${SCP_CMD} -i $P_KEY $ORACLE_HOME/9idata.zip opc@$EXA_IP:/tmp
    ${SSH_CMD} -i $P_KEY opc@$EXA_IP 'sudo chmod -v 755 /tmp/exa_post_dup.sh /tmp/appsutil.zip /tmp/EXAINFO /tmp/9idata.zip'

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

exa_rman_dup() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function Clone Vision Database PDB into Exascale using RMAN duplicate pluggable database from active database command
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Duplicating database verbose "

    source $GCP_DB_ENV
    HOST_IP=$(hostname -i)
    echo "export GCPTNS=\"(DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=$ORACLE_SID))(ADDRESS=(PROTOCOL=tcp)(HOST=$HOST_IP)(PORT=1521)))\"" >> /scripts/EXAINFO
    source /scripts/EXAINFO
    
    print_task "Running rman duplicate to clone PDB from `hostname` to EXACS"
    rman target sys/${SYSPASS}@${GCPTNS} auxiliary sys/${SYSPASS}@${EXATNS}<<EOF 
    RUN {
      # Allocate multiple channels for parallel speed
      ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c3 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c4 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c5 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c6 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c7 DEVICE TYPE DISK;
      ALLOCATE CHANNEL c8 DEVICE TYPE DISK;

      ALLOCATE AUXILIARY CHANNEL a1 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a2 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a3 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a4 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a5 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a6 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a7 DEVICE TYPE DISK;
      ALLOCATE AUXILIARY CHANNEL a8 DEVICE TYPE DISK;

      DUPLICATE PLUGGABLE DATABASE EBSDB FROM ACTIVE DATABASE NOFILENAMECHECK;
}
EOF

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

post_config_exa_db() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function Post configuration steps after database duplication into Exascale
         --------------------------------------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Running post configuration steps after database duplication into Exascale "
    export SSH_CMD="ssh -o StrictHostKeychecking=no"
    source $GCP_DB_ENV
    source /scripts/EXAINFO
    ${SSH_CMD} -i $P_KEY opc@$EXA_IP 'sudo -u oracle /tmp/exa_post_dup.sh'

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

## Shutdown GCP Vision EBS Database
shut_gcp_vision_db() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function shutsdown GCP Vision EBS Database
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Shutting down Vision Database in GCP"
source $GCP_DB_ENV
sqlplus -s / as sysdba <<EOF
shutdown immediate;
EXIT;
EOF
lsnrctl stop
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

## EBS fuctioin
apps_configure() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         EBS Vision ON EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function to update EBS context with Exascale details
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Updating Context file"
    source /u01/install/APPS/EBSapps.env run
    source /scripts/EXAINFO
    source /scripts/vision_apps_env.sh
    export P_KEY=/home/oracle/.ssh/exadb_private_key.pem

    cp $CONTEXT_FILE $CONTEXT_FILE.org

    export SSH_CMD="ssh -o StrictHostKeychecking=no"

    # SCAN  name update    
    DB_SCAN=$(${SSH_CMD} -i $P_KEY opc@$EXA_IP "sudo su - grid -c 'srvctl config scan'" | grep "SCAN name" | awk '{print $3}' | cut -d'.' -f1)
    sed -i -e "s,\([^>]*oa_var=\"s_dbhost\"[^>]*>\)[^<]*\(<.*\),\1${DB_SCAN}\2,g" $CONTEXT_FILE

    # Domain
    DB_DOM=$(${SSH_CMD} -i $P_KEY opc@$EXA_IP "sudo su - grid -c 'srvctl config scan'" | grep "SCAN name" | awk '{print $3}' | cut -d'.' -f2- | tr -d ',')
    sed -i -e "s,\([^>]*oa_var=\"s_dbdomain\"[^>]*>\)[^<]*\(<.*\),\1${DB_DOM}\2,g" $CONTEXT_FILE

    # JDBC regen
    sed -i -e "s,\([^>]*oa_var=\"s_jdbc_connect_descriptor_generation\"[^>]*>\)[^<]*\(<.*\),\1false\2,g" $CONTEXT_FILE

    # SCAN update
    sc_ip1=$(${SSH_CMD} -i $P_KEY opc@$EXA_IP "sudo su - grid -c 'srvctl config scan'"  | grep "SCAN 1" | awk '{print $5}')
    sc_ip2=$(${SSH_CMD} -i $P_KEY opc@$EXA_IP "sudo su - grid -c 'srvctl config scan'"  | grep "SCAN 2" | awk '{print $5}')
    sc_ip3=$(${SSH_CMD} -i $P_KEY opc@$EXA_IP "sudo su - grid -c 'srvctl config scan'"  | grep "SCAN 3" | awk '{print $5}')

    run_sc_name="jdbc:oracle:thin:@(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip1})(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip2})(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip3})(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=ebs_EBSDB)))"
    patch_sc_name="jdbc:oracle:thin:@(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(LOAD_BALANCE=on)(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip1})(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip2})(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=${sc_ip3})(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=EBSDB_ebs_patch)))"

    sed -i -e "s,\([^>]*oa_var=\"s_apps_jdbc_connect_descriptor\"[^>]*>\)[^<]*\(<.*\),\1${run_sc_name}\2,g" $CONTEXT_FILE
    sed -i -e "s,\([^>]*oa_var=\"s_apps_jdbc_patch_connect_descriptor\"[^>]*>\)[^<]*\(<.*\),\1${patch_sc_name}\2,g" $CONTEXT_FILE

    # APPLPTMP update
    sed -i -e "s,\([^>]*oa_var=\"s_applptmp\"[^>]*>\)[^<]*\(<.*\),\1/usr/tmp\2,g" $CONTEXT_FILE

    print_task "Show Context file changes after update:"
    #diff $CONTEXT_FILE $CONTEXT_FILE.org
    egrep "s_dbhost|s_dbdomain|s_jdbc_connect_descriptor_generation|s_apps_jdbc_connect_descriptor|s_apps_jdbc_patch_connect_descriptor" $CONTEXT_FILE

    print_task "Run Autoconfig"
    $ADMIN_SCRIPTS_HOME/adautocfg.sh -appspass=$APPS_PASS

    print_task "Start EBS"
    /scripts/vision_apps_startup_exa.sh

    # add reboot script to cron
    echo "Checking crontab for ebs apps auto startup"
    if [ $(crontab  -l | grep vision_apps_startup_exa | wc -l) -eq 0 ]; then
        echo "Add crontab: set ebs startup script";
        job="@reboot sleep 5 && /scripts/vision_apps_startup_exa.sh | tee -a /scripts/vision_apps_startup_exa.sh.log 2>&1"
        ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
    fi

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}