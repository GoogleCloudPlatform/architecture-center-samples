#!/bin/bash
set -e

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi

# paths
local_media=/buckets

# Exa info
export EXA_DB_NAME=$(sed -n 's/^[[:space:]]*cdb_name:[[:space:]]*"\([^"]*\)".*/\1/p' /tmp/exascale_outputs.yaml)
export EXA_DB_NAME=${EXA_DB_NAME:-PSFTCDB}
export EXA_PROFILE="/home/oracle/${EXA_DB_NAME}.env"
export EXA_PDB_NAME=PDB1
export EXA_PASS=$(sed -n 's/^[[:space:]]*admin_password:[[:space:]]*"\([^"]*\)".*/\1/p' /tmp/exascale_outputs.yaml)

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

## COMMON FUCNTIONS
function_example() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         Peoplesoft on EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
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

rdbms_setup_aux() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
        echo "
         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION ${FUNCNAME[0]}
         =========================================
         Function to startup up AUX instance on Exascale vm
         -----------------------------------------"
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi

    ### actual function betweens these comments
    mkdir -p /home/oracle/scripts
	source ${EXA_PROFILE}
	
	# Drop existing PDB in Exa Database using dbaascli
	
    print_task "Dropping existing PDB ${EXA_PDB_NAME}:"
	print_task "Running command: 	dbaascli pdb delete --dbName ${EXA_DB_NAME} --pdbName ${EXA_PDB_NAME}"
    dbaascli pdb delete --dbName ${EXA_DB_NAME} --pdbName ${EXA_PDB_NAME} || true

	# Setup Aux instance
    print_task "Setting up Aux instance on Exascale vm"
    AUX_ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')

    print_task "Creating initaux.ora file for Aux instance"
	# Create Aux instance init file
echo "
*.db_name=${AUX_ORACLE_SID}
*.db_unique_name=${AUX_ORACLE_SID}
*.compatible=19.0.0
*.db_create_file_dest='+DATA${EXA_DB_NAME}'
*.enable_pluggable_database=true
*.db_create_online_log_dest_1='+LOG${EXA_DB_NAME}'
*.control_files='+DATA${EXA_DB_NAME}'
*.db_recovery_file_dest_size=75G
*.db_recovery_file_dest='+RECO${EXA_DB_NAME}'
" > /scripts/initaux.ora

    # Create audit directory
	mkdir -p /u02/app/oracle/admin/${AUX_ORACLE_SID}/adump	

	# Startup nomount instance
	export ORACLE_SID=${AUX_ORACLE_SID}
	print_task "Aux Oracle SID is set to ${AUX_ORACLE_SID}"

	print_task "Startup nomount ${AUX_ORACLE_SID}"
	
sqlplus / as sysdba <<EOF
whenever sqlerror exit failure
startup nomount pfile='/scripts/initaux.ora';
EOF

 echo -e "\nlog: $logfile"
    date       
 } 2>&1 | tee -a ${logfile}
}


aux_rman_restore() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft on EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to restore Aux database - time consuming step
         ------------------------------------------------------------------------- \033[0m"
    
    # Check if called by root
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    # check if Oracle running (simple process check)
    
    ### actual function betweens these comments
    print_task "RMAN: Restoring database from Backup location"
    ls ${local_media}/rman/*.bkp
	source ${EXA_PROFILE}
	
	ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')
	
	export ORACLE_SID=$ORACLE_SID
	    
	print_task "Oracle SID is set to ${ORACLE_SID}"
	
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
	  duplicate database to ${ORACLE_SID} backup location '${local_media}/rman' NOFILENAMECHECK;
	}
" > /scripts/rman_restore.rman

    print_task "RMAN: Starting rman restore...may take a long time..."

time rman auxiliary / cmdfile=/scripts/rman_restore.rman | tee -a /scripts/rman_duplicate_from_backup_$(date +%F_%H-%M-%S).log;

# Find Pdb name

PDBNAME=$(sqlplus -s / as sysdba <<EOF
set heading off feedback off verify off pages 0 lines 200
select NAME from V\$CONTAINERS where name not like '%\$ROOT' and name not like '%\$SEED';
EOF
)


    export PDBNAME=${PDBNAME}
	
	print_task "PDB Name is : ${PDBNAME}"
	
	# Unplug pdb from Aux instances
	
    print_task "Unplugging PDB ${PDBNAME} from ${ORACLE_SID}"
	
sqlplus -s / as sysdba <<EOF
ALTER PLUGGABLE DATABASE $PDBNAME CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE $PDBNAME UNPLUG INTO '/scripts/newpdb.xml';
DROP PLUGGABLE DATABASE $PDBNAME KEEP DATAFILES;
EOF
	
	# Switch to OCI DB environment
	source ${EXA_PROFILE}
	
	# Create New PDB in Exa
    print_task "Plugging PDB ${PDBNAME} into ${ORACLE_SID}"
	
sqlplus -s / as sysdba <<EOF
create pluggable database $PDBNAME using '/scripts/newpdb.xml' NOCOPY TEMPFILE REUSE;
alter pluggable database $PDBNAME open read write;
EOF

    # Running datapatch
	print_task "Running datapatch on ${PDBNAME}"
	
	cd $ORACLE_HOME/OPatch
	
    ./datapatch -verbose
	
    # Recompile Invalids
	print_task "Recompile Invalids on ${PDBNAME}"
	
sqlplus -s / as sysdba <<EOF
@$ORACLE_HOME/rdbms/admin/utlrp.sql;
alter session set container=$PDBNAME;
@$ORACLE_HOME/rdbms/admin/utlrp.sql;
EOF
	
    print_task "Generate sql for encrypting tablespaces in ${PDBNAME}"

sqlplus -s / as sysdba <<EOF
alter session set container=${PDBNAME};
set heading off feedback off verify off pages 0 lines 200;
spool /scripts/enc_tbs.sql;
SELECT 'ALTER TABLESPACE ' || tablespace_name || ' ENCRYPTION ONLINE USING ''AES128'' ENCRYPT;' FROM dba_tablespaces WHERE (contents = 'PERMANENT' or contents = 'UNDO') AND tablespace_name NOT IN ('SYSTEM', 'SYSAUX') ORDER BY tablespace_name;
EOF

    print_task "Setup encryption keys in ${PDBNAME}"
	
DTS="${PDBNAME}_$(date +%Y%m%d_%H%M%S)"
sqlplus -s / as sysdba <<EOF
alter session set container=$PDBNAME;
administer key management create encryption key using tag '$DTS' force keystore identified by "$EXA_PASS" with backup;
EOF

KEYNAME=$(sqlplus -s / as sysdba <<EOF
set heading off feedback off verify off pages 0 lines 200
alter session set container=$PDBNAME;
select KEY_ID from v\$encryption_keys where TAG='$DTS';
EOF
)
    
	print_task "Encrypt tablespaces in ${PDBNAME} using ${KEYNAME}"
	
sqlplus -s / as sysdba <<EOF
alter session set container=$PDBNAME;
administer key management use encryption key '$KEYNAME' force keystore identified by "$EXA_PASS" with backup;
@/scripts/enc_tbs.sql;
@/scripts/tmp_recreate.sql;
EOF

	print_task "Restart pdb ${PDBNAME}"
	
sqlplus -s / as sysdba <<EOF
alter pluggable database $PDBNAME close immediate;
alter pluggable database $PDBNAME open read write;
show pdbs;
EOF
	
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

drop_aux() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
        echo "
         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION ${FUNCNAME[0]}
         =========================================
         Function to drop AUX instance on Exadata
         -----------------------------------------"
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi

    ### actual function betweens these comments
    
	source ${EXA_PROFILE}
	
	# Setup Aux instance
    export ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')

	print_task "Aux Oracle SID is set to ${ORACLE_SID}"
	print_task "Shutting down and dropping ${ORACLE_SID}"
	
sqlplus -s / as sysdba <<EOF
shutdown immediate;
startup mount exclusive restrict;
drop database;
EOF

 echo -e "\nlog: $logfile"
    date       
 } 2>&1 | tee -a ${logfile}
}

# Main
rdbms_setup_aux;
aux_rman_restore;
drop_aux;
