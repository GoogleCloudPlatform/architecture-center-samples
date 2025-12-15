#!/bin/bash

# This script contains utility functions for the EBS project

#Source Env
if [ -f ~/scripts/environment ]; then
    source /home/oracle/scripts/environment
else     
    source /scripts/environment
fi


log_path=/home/oracle/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi

BUCKET=$(gcloud storage ls | grep oracle-ebs-toolkit-storage-bucket)

## COMMON FUCNTIONS
function_example() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    # Check if OS is ready
    if ! os_ready_to_start; then echo "Required package oracle-database-preinstall-19c is not installed."; return 1; fi

    ### actual function betweens these comments
    print_task "Doing Stuff - function "


    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

os_ready_to_start () {
    if [ "$(rpm -q oracle-database-preinstall-19c | wc -l)" -gt 0 ]; then
        return 0  # true
    else
        return 1  # false
    fi
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

## DB PART
rdbms_root_init() {
 logfile="rdbms_root_init"
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${logfile}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_root_init
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------"
    # Check if called by root
    if ! is_root_user; then
        echo "This function must be run as root."
        date
        return 1
    fi

    # Check if OS is ready
    if ! os_ready_to_start; then
        echo "Required package oracle-database-preinstall-19c is not installed."
        date
        return 1
    fi

    # Directories to create
    dirs=(/home/oracle/scripts /home/oracle/scripts/logs /backup /u01/app/oracle/oraInventory /u01/app/oracle/admin /u01/oradata/EBSDB/arch $ORACLE_HOME /u01/app/oracle/temp/EBSDB)

    print_task "Creating Directories"

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            chown oracle:oinstall "$dir"
            echo "Created $dir and set owner to oracle:oinstall"
        else
            echo "$dir already exists"
        fi
    done

    # stage scripts
    print_task "Stage Scripts to Oracle user"
    
    \cp -Rfv /scripts/* /home/oracle/scripts/
    chown -Rv oracle:oinstall /home/oracle/scripts/*

    # oraInst
    print_task "Creating /etc/oraInst.loc"
    
    if [ ! -f /etc/oraInst.loc ]; then
        echo " 
inventory_loc=/u01/app/oracle/oraInventory
inst_group=dba        
" > /etc/oraInst.loc
    fi

    ls -l /etc/oraInst.loc
    cat /etc/oraInst.loc

    # stage Media | THIS IS TIME CONSUMING
    # gcloud storage cp ${BUCKET}${ORACLE_RDBMS_ARCHIVE} /backup/
    # gcloud storage cp -r ${BUCKET}RMAN_TO_GCP /backup/

    # take ownership
    print_task "Ownerships"
    chown -Rv oracle:oinstall /backup/* /u01/* /home/oracle/*

    if [ ! "$(cat /home/oracle/.bash_profile | grep "scripts/funct.sh" | wc -l)" -eq 1 ]; then
        echo "source scripts/funct.sh" >> /home/oracle/.bash_profile
    fi

    print_task "Enable Huge pages if RAM > 20GB"
    # huge pages

    total_ram_gb=$(free -g | awk '/^Mem:/ {print $2}')

    # If hugepages were set, also persist in /etc/sysctl.conf and reload
    if (( total_ram_gb > 20 )); then
        hugepages=$(( (total_ram_gb * 1024 * 1024 / 2) / 2048 ))
        sed -i '/^vm.nr_hugepages/d' /etc/sysctl.conf
        echo "vm.nr_hugepages = $hugepages" >> /etc/sysctl.conf
        sysctl -p
        sleep 5
        sysctl -p
    fi

    echo -e "\nlog: $logfile"
    date
 
 } 2>&1 | tee -a ${logfile}
}

rdbms_stage_backup() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT: FUNCTION rdbms_stage_backup
         =========================================
         Function copies data from bucket ($BUCKET) to  ${ORACLE_BACKUP_LOC} for furhter processing
         -----------------------------------------"

    # Check if called by oracle
    if ! is_oracle_user; then
        echo "This function must be run as oracle."
        return 1
    fi

    # Check if OS is ready
    if ! os_ready_to_start; then
        echo "Required package oracle-database-preinstall-19c is not installed."
        return 1
    fi

    # copying data from bucket to server
    print_task "Stage RDBMS Software backup"
    time gcloud storage cp ${BUCKET}${ORACLE_RDBMS_ARCHIVE} ${ORACLE_BACKUP_LOC}/

    print_task "Stage RMAN cold backup: Note: time comsuming step - depends on backups"
    time gcloud storage cp -r ${BUCKET}${ORACLE_RMAN_ARCHIVE} ${ORACLE_BACKUP_LOC}/

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
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    # Check if OS is ready
    if ! os_ready_to_start; then echo "Required package oracle-database-preinstall-19c is not installed."; return 1; fi

    ### actual function betweens these comments

    # extract OH
    print_task "Extract RDBMS Software from ${ORACLE_BACKUP_LOC}/"
    OLD_OH=$(tar tvzf ${ORACLE_BACKUP_LOC}/${ORACLE_RDBMS_ARCHIVE}  | head -1 | awk '{print $NF}')

    echo "RDBMS backup   : ${ORACLE_BACKUP_LOC}/${ORACLE_RDBMS_ARCHIVE}"
    echo "Oracle Home    : $ORACLE_HOME"
    echo "Old home base  : $OLD_OH"
    echo "Extracting non-verbose: (few mins)"

    time tar -xzf ${ORACLE_BACKUP_LOC}/${ORACLE_RDBMS_ARCHIVE} -C $(dirname "$ORACLE_HOME")

    # move files
    mv $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")/{.,}* $ORACLE_HOME/
    rmdir -v $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")

    ls -ld $ORACLE_HOME
    ls -la $ORACLE_HOME/ | head -10
    echo ".."
  
    print_task "Configurting RDBMS HOME - relink"
    
    export ORACLE_SID=$ORACLE_SID
    export ORACLE_HOME=$ORACLE_HOME
    export ORACLE_BASE=/u01/app/oracle
    export PATH=$ORACLE_HOME/bin:$PATH
    #export CV_ASSUME_DISTID=OEL7.9
    cd $ORACLE_HOME/bin/
    ./relink all

    print_task "Backing up existing TNS and dbs"
    cd 
    mv $ORACLE_HOME/dbs $ORACLE_HOME/dbs.$(date +%Y%m%d_%H%M%S)
    #mv $ORACLE_HOME/network/admin $ORACLE_HOME/network/admin.$(date +%F) # can't do this - relink fails
    mv $ORACLE_HOME/network/admin/listener.ora mv $ORACLE_HOME/network/admin/listener.ora.$(date +%Y%m%d_%H%M%S)
    mv $ORACLE_HOME/network/admin/sqlnet.ora mv $ORACLE_HOME/network/admin/sqlnet.ora.$(date +%Y%m%d_%H%M%S)
    mv $ORACLE_HOME/network/admin/tnsnames.ora mv $ORACLE_HOME/network/admin/tnsnames.ora.$(date +%Y%m%d_%H%M%S)
    mkdir -p $ORACLE_HOME/dbs $ORACLE_HOME/network/admin 

    # put static files in place for now
    cp -v ~/scripts/initEBSCDB.ora $ORACLE_HOME/dbs/
    cp -v ~/scripts/listener.ora $ORACLE_HOME/network/admin/

    print_task "Startup nomount EBSCBD & listener"

    lsnrctl start $ORACLE_SID``
    echo "startup nomount" | sqlplus / as sysdba

    echo -e "set pages 1000 lines 1000 tab off \n select INSTANCE_NAME, HOST_NAME, VERSION_FULL,STARTUP_TIME, STATUS from v\$instance;" | sqlplus -s / as sysdba

 echo -e "\nlog: $logfile"
    date       
 } 2>&1 | tee -a ${logfile}
}

rdbms_rman_restore() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================
         Function to restore database - time consuming step
         -----------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    # Check if OS is ready
    if ! os_ready_to_start; then echo "Required package oracle-database-preinstall-19c is not installed."; return 1; fi
    # check if Oracle running (simple process check)
    if ! is_oracle_started; then echo "Required Oracle and Listener to be running."; return 1; fi

    ### actual function betweens these comments
    print_task "RMAN: Restoring database from Backup location"

    ls -l /backup/RMAN_TO_GCP/
    
    # to be 100% sure that directories are created before RMAN starts
    mkdir -p /u01/oradata/EBSCDB/arch /u01/app/oracle/admin

    # set env
    export ORACLE_SID=$ORACLE_SID
    export ORACLE_HOME=$ORACLE_HOME
    export ORACLE_BASE=/u01/app/oracle
    export PATH=$ORACLE_HOME/bin:$PATH

    time rman auxiliary / cmdfile=~/scripts/rman_restore.rman | tee -a ~/scripts/logs/rman_duplicate_from_backup_$(date +%F_%H-%M-%S).log
   
    # deal with PDB 
    PDB_NAME=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF FEEDBACK OFF VERIFY OFF ECHO OFF
SELECT name FROM v\$pdbs WHERE name != 'PDB\$SEED';
EXIT;
EOF
) 

    print_task "RMAN: PDB: $PDB_NAME rename to EBSDB"

    sqlplus -s / as sysdba <<EOF
SET HEADING on FEEDBACK on VERIFY on ECHO on
show pdbs;
ALTER PLUGGABLE DATABASE $PDB_NAME CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE $PDB_NAME OPEN RESTRICTED;
alter session set container=$PDB_NAME;
alter pluggable database rename global_name to EBSDB;
alter pluggable database close immediate;
alter pluggable database open;
ALTER PLUGGABLE DATABASE SAVE STATE;
EXIT;
EOF

sqlplus -s / as sysdba <<EOF
SET HEADING on FEEDBACK on VERIFY on ECHO on
alter system register;
show pdbs;
EXIT;
EOF

    lsnrctl status $ORACLE_SID

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date       
       
 } 2>&1 | tee -a ${logfile}
}

rdbms_ebs_configure() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================
         Function run post-restore EBS specific DB tasks, adcfglone, utlfiledirs, autoconfig, etc
         -----------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    # Check if OS is ready
    if ! os_ready_to_start; then echo "Required package oracle-database-preinstall-19c is not installed."; return 1; fi
    # check if Oracle running (simple process check)
    
    # set env
    export ORACLE_SID=$ORACLE_SID
    export ORACLE_HOME=$ORACLE_HOME
    export ORACLE_BASE=/u01/app/oracle
    export PATH=$ORACLE_HOME/bin:$PATH

    ### actual function betweens these comments
    print_task "Configuring EBSCDB database for EBS usage"

     sqlplus -s / as sysdba <<EOF
SET HEADING on FEEDBACK on VERIFY on ECHO on
show pdbs;
alter session set container=EBSDB;
GRANT INHERIT PRIVILEGES ON USER SYS TO APPS;
alter session set current_schema=apps;
exec fnd_conc_clone.setup_clean;

EXIT;
EOF

    print_task "Cloning Techstack for EBSDB database"

    # stop listener to avoid having port conflict
    lsnrctl stop $ORACLE_SID
    
    # need to prepare and replace domain for (must match /etc/hosts)
    # ~/scripts/EBSDB_oracle-ebs-db.xml
    dom=$(cat /etc/hosts | grep oracle-ebs-db | awk '{print $2}')
    dom=${dom#oracle-ebs-db.}
    sed -i "s/_replace_domain_/${dom}/g" ~/scripts/EBSDB_oracle-ebs-db.xml
    
    # move files around to be able to repeat the process
    mv /u01/app/oracle/oraInventory/ContentsXML /u01/app/oracle/oraInventory/ContentsXML.$(date +%Y%m%d_%H%M%S)
    mv $ORACLE_HOME/oraInst.loc $ORACLE_HOME/oraInst.loc.back
    echo -e "inventory_loc=/u01/app/oracle/oraInventory \ninst_group=dba" > $ORACLE_HOME/oraInst.loc
    
    export CV_ASSUME_DISTID=OEL7.9
    cd $ORACLE_HOME/appsutil/clone/bin
    { echo $APPS_PASSWORD; } | perl adcfgclone.pl dbTechStack ~/scripts/EBSDB_oracle-ebs-db.xml

    print_task "Post Cloning tasks"

    ln -s $ORACLE_HOME/EBSDB_oracle-ebs-db.env ~/EBSDB_oracle-ebs-db.env
    ln -s $ORACLE_HOME/EBSCDB_oracle-ebs-db.env ~/EBSCDB_oracle-ebs-db.env
    ln -s /u01/app/oracle/diag/rdbms/ebscdb/EBSCDB/trace/alert_EBSCDB.log ~/alert_EBSCDB.log

    # start Listener and autoconfig
    source ~/EBSCDB_oracle-ebs-db.env
    $ORACLE_HOME/appsutil/scripts/*_$(hostname -s)/addlnctl.sh start $ORACLE_SID

    sqlplus -s / as sysdba <<EOF
SET HEADING on FEEDBACK on VERIFY on ECHO on
show pdbs;
alter session set container=EBSDB;
exec dbms_service.start_service('ebs_EBSDB');
alter system register;
EXIT;
EOF

    # UTL File dir setup
    # change SYSTEM pass
    source ~/EBSCDB_oracle-ebs-db.env
    #echo "alter user system identified by $SYSTEM_PASS;" | sqlplus -s  / as sysdba
    sqlplus -s / as sysdba <<EOF
SET HEADING on FEEDBACK on VERIFY on ECHO on
show pdbs;
alter user system identified by $SYSTEM_PASS;
alter session set container=EBSDB;
alter user ebs_system identified by $SYSTEM_PASS;
EXIT;
EOF

    # set UTL file dirs
    source ~/EBSDB_oracle-ebs-db.env
    echo "/u01/app/oracle/temp" > $ORACLE_HOME/dbs/EBSDB_utlfiledir.txt
    mkdir -p /u01/app/oracle/product/temp/EBSDB

    egrep "s_db_util_filedir|s_ecx_log_dir|s_bis_debug_log_dir|s_outbound_dir" /$CONTEXT_FILE| sed -n 's/.*>\(.*\)<.*/\1/p' | sort | uniq >> $ORACLE_HOME/dbs/EBSDB_utlfiledir.txt
    
    echo "UTL File Dirs:"
    cat $ORACLE_HOME/dbs/EBSDB_utlfiledir.txt
    { echo $APPS_PASSWORD; echo $SYSTEM_PASS; } | perl $ORACLE_HOME/appsutil/bin/txkCfgUtlfileDir.pl -contextfile=$CONTEXT_FILE -oraclehome=$ORACLE_HOME -outdir=$ORACLE_HOME/appsutil/log -mode=setUtlFileDir

    # AutoConfig
    source ~/EBSDB_oracle-ebs-db.env
    $ORACLE_HOME/appsutil/scripts/*_$(hostname -s)/adautocfg.sh appspass=$APPS_PASSWORD

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

## APPS PART
ebs_root_init() {
 logfile="ebs_root_init"
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${logfile}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT: FUNCTION ebs_root_init
         =========================================
         Function precreates dirs, files, ownership and other root activites
         -----------------------------------------"
    # Check if called by root
    if ! is_root_user; then
        echo "This function must be run as root."
        date
        return 1
    fi

    # Check if OS is ready
    if ! os_ready_to_start; then
        echo "Required package oracle-database-preinstall-19c is not installed."
        date
        return 1
    fi

    # Directories to create
    dirs=(/home/oracle/scripts /home/oracle/scripts/logs /backup /u01/ebs122/oraInventory /u01/ebs122 /u01/install/APPS/temp/EBSDB)

    print_task "Creating Directories"

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            chown oracle:oinstall "$dir"
            echo "Created $dir and set owner to oracle:oinstall"
        else
            echo "$dir already exists"
        fi
    done

    # stage scripts
    print_task "Stage Scripts to Oracle user"
    
    \cp -Rfv /scripts/* /home/oracle/scripts/
    chown -Rv oracle:oinstall /home/oracle/scripts/*

    # oraInst
    print_task "Creating /etc/oraInst.loc"
    
    if [ ! -f /etc/oraInst.loc ]; then
        echo "inventory_loc=/u01/ebs122/oraInventory
inst_group=dba" > /etc/oraInst.loc
    fi

    ls -l /etc/oraInst.loc
    cat /etc/oraInst.loc

    # stage Media | THIS IS TIME CONSUMING
    # gcloud storage cp ${BUCKET}${ORACLE_RDBMS_ARCHIVE} /backup/
    # gcloud storage cp -r ${BUCKET}RMAN_TO_GCP /backup/

    # take ownership
    print_task "Ownerships"
    chown -Rv oracle:oinstall /backup/* /u01/* /home/oracle/*

    if [ ! "$(cat /home/oracle/.bash_profile | grep "scripts/funct.sh" | wc -l)" -eq 1 ]; then
        echo "source scripts/funct.sh" >> /home/oracle/.bash_profile
    fi

    echo -e "\nlog: $logfile"
    date
 
 } 2>&1 | tee -a ${logfile}
}

ebs_stage_backup() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT: FUNCTION ebs_stage_backup
         =========================================
         Function copies data from bucket ($BUCKET) to  ${ORACLE_BACKUP_LOC} and unarchive for further processing
         -----------------------------------------"

    # Check if called by oracle
    if ! is_oracle_user; then
        echo "This function must be run as oracle."
        return 1
    fi

    # Check if OS is ready
    if ! os_ready_to_start; then
        echo "Required package oracle-database-preinstall-19c is not installed."
        return 1
    fi

    # copying data from bucket to server
    print_task "Stage EBS Software backup"
    time gcloud storage cp ${BUCKET}${ORACLE_EBS_ARCHIVE} ${ORACLE_BACKUP_LOC}/

    
    log=/u01/ebs122/fs_restore_$(date +%F_%H-%M-%S).log 
    print_task "Extract EBS Software (silent): log -> $log"
    time tar -xvzf ${ORACLE_BACKUP_LOC}/${ORACLE_EBS_ARCHIVE} -C /u01/ebs122 > ${log} 2>&1
    echo "Done. FS restore log ->  ${log}"

    echo -e "\nlog: $logfile"
    date
 
 } 2>&1 | tee -a ${logfile}
}

ebs_post_step_wf_user_update(){
    source ~/scripts/environment

    print_task "EBS POST CLONE TASK: Update WF user preferences to 'Do not send emails'"

    . /u01/ebs122/EBSapps.env run >> /dev/null 2>&1
    sqlplus $APPS_USER/$APPS_PASSWORD <<EOF

    DECLARE
        --get users with email style other then 'Do not send emails'
        cursor c1 is
        select u.user_name
        from fnd_user u, wf_local_roles r
        where r.name = u.user_name
        and notification_preference != 'QUERY';
    BEGIN
    for c in c1 loop
        --change user preference to 'Do not send emails'
        fnd_preference.put(c.user_name, 'WF', 'MAILTYPE', 'QUERY');
    end loop;
    --commit changes
    commit;
    END;  
    /

EOF
}

ebs_post_step_alerts_update(){
    source ~/scripts/environment

    print_task "EBS POST CLONE TASK: Disable Alerts"

    . /u01/ebs122/EBSapps.env run >> /dev/null 2>&1
    sqlplus $APPS_USER/$APPS_PASSWORD <<EOF
    set pages 1000 lines 1000 tab off
    SELECT 'DISABLING BELOW ALERTS' from dual;
    select ALERT_NAME, enabled_flag from ALR_ALERTS where enabled_flag = 'Y';
    update ALR_ALERTS set enabled_flag = 'N' where enabled_flag = 'Y';
    commit;

EOF
}

ebs_post_step_conc_on_hold(){
    source ~/scripts/environment

    print_task "EBS POST CLONE TASK: Put Concurrents on Hold"

    . /u01/ebs122/EBSapps.env run >> /dev/null 2>&1
    sqlplus $APPS_USER/$APPS_PASSWORD <<EOF
    set pages 1000 lines 1000 tab off
    SELECT 'Putting below Cconcurrent Requests on hold' from dual;

    select r.request_id
       ,(select user_name from apps.fnd_user where user_id = r.requested_by) as User_name
       ,(select user_concurrent_program_name from apps.fnd_concurrent_programs_tl where language = 'US' and concurrent_program_id = r.concurrent_program_id and rownum=1) as Conc_program
       ,r.phase_code
       ,r.status_code
       ,r.hold_flag
       ,r.argument_text
  from apps.fnd_concurrent_requests r
 where r.phase_code = 'P' AND r.hold_flag != 'Y' and r.requested_by != 0
   order by actual_completion_date desc;

   UPDATE APPS.FND_CONCURRENT_REQUESTS r SET r.hold_flag = 'Y', r.last_update_date = TO_DATE('1990.01.01_0000','YYYY.MM.DD_HH24MI') WHERE
    r.phase_code = 'P' AND r.hold_flag != 'Y' and r.requested_by != 0;
    commit;

EOF
}

ebs_post_step_wf_unsent(){
    source ~/scripts/environment

    print_task "EBS POST CLONE TASK: Marking unsent emails as sent"

    . /u01/ebs122/EBSapps.env run >> /dev/null 2>&1
    sqlplus $APPS_USER/$APPS_PASSWORD <<EOF
    update WF_NOTIFICATIONS set mail_status = 'SENT' where status = 'OPEN' and mail_status = 'MAIL';
    commit;

EOF
}

ebs_post_step_info(){
    source ~/scripts/environment

    print_task "EBS POST CLONE TASK: Some Generic Info on Specific HTTP and Path Setup"

    . /u01/ebs122/EBSapps.env run >> /dev/null 2>&1
    sqlplus $APPS_USER/$APPS_PASSWORD <<EOF
    set pages 50000 lines 32000 tab off ver off feed on echo on trimspool on
    col OWNER for a10
    col DIRECTORY_NAME for a35
    col DIRECTORY_PATH for a70
    select 'dba_directories' from dual;
    select * from dba_directories;


    col OWNER    for a10
    col DB_LINK  for a30
    col USERNAME for a30
    col HOST     for a70
    select 'dba_db_links' from dual;
    select * from dba_db_links;


    -- fnd_profile_options
    select 'profile_option_value not having http://oracle-ebs-apps setup' from dual;
    column USER_PROFILE_OPTION_NAME for a40
    column PROFILE_OPTION_VALUE for a90
    column PROFILE_OPTION_NAME for a30
    COL LEVEL_VALUE for 999
    select O.user_profile_option_name,
        O.profile_option_id,
        O.Profile_option_name,
        v.level_id,
        decode(to_char(v.level_id),
                '10001', 'SITE',
                '10002', 'APP',
                '10003', 'RESP',
                '10005', 'SERVER',
                '10006', 'ORG',
                '10004', 'USER', '???') "LEVEL",
        V.LEVEL_VALUE as LV,
        v.profile_option_value
    from apps.fnd_profile_options_vl O, apps.fnd_profile_option_values V
    where 1 = 1
    and V.profile_option_id = O.profile_option_id  and v.level_id = 10001
    and upper(V.profile_option_value) like upper('%http%')
    and upper(V.profile_option_value) not like upper('%oracle-ebs-apps%')
    order by v.PROFILE_OPTION_VALUE;


    -- fnd_profile_options
    select 'profile_option_value with PATH in it' from dual;
    column USER_PROFILE_OPTION_NAME for a40
    column PROFILE_OPTION_VALUE for a90
    column PROFILE_OPTION_NAME for a30
    COL LEVEL_VALUE for 999
    select O.user_profile_option_name,
        O.profile_option_id,
        O.Profile_option_name,
        v.level_id,
        decode(to_char(v.level_id),
                '10001', 'SITE',
                '10002', 'APP',
                '10003', 'RESP',
                '10005', 'SERVER',
                '10006', 'ORG',
                '10004', 'USER', '???') "LEVEL",
        V.LEVEL_VALUE as LV,
        v.profile_option_value
    from apps.fnd_profile_options_vl O, apps.fnd_profile_option_values V
    where 1 = 1
    and V.profile_option_id = O.profile_option_id  and v.level_id = 10001
    and (upper(O.Profile_option_name) like upper('%DIR%') or upper(O.Profile_option_name) like upper('%PATH%'))
    order by v.PROFILE_OPTION_VALUE;


EOF
}

ebs_configure() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         =========================================
         EBS ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================
         Function to configure EBS
         -----------------------------------------"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as root."; return 1; fi
    # Check if OS is ready
    if ! os_ready_to_start; then echo "Required package oracle-database-preinstall-19c is not installed."; return 1; fi

    ### actual function betweens these comments
    print_task "Cloning EBS APPS Tier for EBSDB database"

    # for repeatable process removing old stuff not required for clone    
    rm -Rf /u01/ebs122/fs2
    rm -Rf /u01/ebs122/fs1/FMW_Home /u01/ebs122/fs2 /u01/ebs122/oraInventory/ContentsXML /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps

    # clone using CONTEXT_FILE
    #{ echo $APPS_PASSWORD; echo $WLS_PASSWORD; $APPS_PASSWORD; } | perl /u01/ebs122/fs1/EBSapps/comn/clone/bin/adcfgclone.pl appsTier ~/scripts/EBSDB_oracle-ebs-apps.xml
    
    # Fix: update domain from default in pairsfile to domain (region) host deployed
    dom=$(grep $(hostname) /etc/hosts | awk '{print $2}' | cut -d'.' -f2-)
    sed -i "s/us-west2-a.c.oracle-ebs-toolkit.internal/$dom/g" ~/scripts/ebs_apps_pairfile.txt

    # check IF SOA registered
    if [ $(cat /u01/ebs122/fs1/EBSapps/comn/clone/FMW/dsstagefile.txt | grep ISGDatasource | wc -l) -eq 1 ]; then 
        { echo $APPS_PASSWORD; echo $WLS_PASSWORD; $APPS_PASSWORD; echo "n"; } | /u01/ebs122/fs1/EBSapps/comn/clone/bin/adcfgclone.pl component=appsTier pairsfile=~/scripts/ebs_apps_pairfile.txt
    else 
        { echo $APPS_PASSWORD; echo $WLS_PASSWORD; echo "n"; } | /u01/ebs122/fs1/EBSapps/comn/clone/bin/adcfgclone.pl component=appsTier pairsfile=~/scripts/ebs_apps_pairfile.txt
    fi
    
    # adding TNS (temporary step)-to troubleshoot
    # echo "EBSDB=(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-ebs-db)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ebs_EBSDB)))" >> /u01/ebs122/fs1/inst/apps/EBSDB_oracle-ebs-apps/ora/10.1.2/network/admin/EBSDB_oracle-ebs-apps_ifile.ora

    # add custom post-clone functiosn
    
    # SSO/OID removeal ref (txk scripts serSSOREG remove refrences) - done by Clone
    # fnd_conc_nodes (set target and node2_ to null)
    # OPP dev parameters FND_CP_SERVICES

    # run Post tasks
    ebs_post_step_wf_user_update
    ebs_post_step_alerts_update
    ebs_post_step_conc_on_hold
    ebs_post_step_wf_unsent
    ebs_post_step_info

    # profile options url check
    # DBA_DIRS
    # DB links

    # change sysadmin pass:
    source ~/scripts/environment
    . /u01/ebs122/EBSapps.env run 
    FNDCPASS $APPS_USER/$APPS_PASSWORD 0 Y $APPS_USER/$APPS_PASSWORD USER "SYSADMIN" $SYSADMIN_PASSWORD

    # AutoConfig
    . /u01/ebs122/EBSapps.env run
    $ADMIN_SCRIPTS_HOME/adautocfg.sh -appspass=$APPS_PASSWORD

    # Startup
    . /u01/ebs122/EBSapps.env run
    echo "$WLS_PASSWORD" | $ADMIN_SCRIPTS_HOME/adstrtal.sh $APPS_USER/$APPS_PASSWORD

    # Generate and show access details
    url=$(sed -n 's/.*<login_page[^>]*>\(.*\)<\/login_page>.*/\1/p' "$CONTEXT_FILE" | sed -u 's,/OA_HTML/AppsLogin,,g')
    dom=$(cat /etc/hosts | grep oracle-ebs-apps | awk '{print $2}')
    dom=${dom#oracle-ebs-apps.}
    
echo "

         =========================================
                 Oracle Customer Deployment
         =========================================
          URL                : ${url}
          User               : SYSADMIN
          Password           : ${SYSADMIN_PASSWORD} (case sensitive)

          hosts file entry   : 127.0.0.1 oracle-ebs-apps.${dom} oracle-ebs-apps
          IAP tunneling      : 
          	gcloud compute ssh "oracle-ebs-apps" --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8000:localhost:8000
         -----------------------------------------
"

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}