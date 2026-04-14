#!/bin/bash

# Variables
EXA_DB_ENV=/home/oracle/EBSCDB.env
LOG_DIR=~/scripts/logs
LOG_FILE=$LOG_DIR/exa_post_dup.$(date +%d%m%y%H%M%S).log

# Functions

function logme {
	# Create log directory if it does not exist
	if [ ! -d "${LOG_DIR}" ]; then
	  mkdir -p "${LOG_DIR}"
	fi
	# This function is used to log all the commands and outputs
	> ${LOG_FILE}
	exec &> >(tee -a "${LOG_FILE}")
}

function run_datapatch {
echo "Starting function run_datapatch at $(date +%d%m%y%H%M%S)"
source ${EXA_DB_ENV}

V_UNQNM=$(sqlplus -s / as sysdba <<EOF | tr -d '[:space:]'
SET HEADING OFF
SET FEEDBACK OFF
SELECT DB_UNIQUE_NAME FROM V\$DATABASE;
EXIT;
EOF
)

echo "Restarting database $V_UNQNM in upgrade mode"

sqlplus -s / as sysdba<<EOF
alter system set cluster_database=FALSE scope=spfile sid='*';
shutdown immediate;
startup upgrade;
alter pluggable database all open upgrade;
EOF

echo "Running datapatch"

time $ORACLE_HOME/OPatch/datapatch -verbose

echo "Restarting database $V_UNQNM"

sqlplus -s / as sysdba<<EOF
alter system set cluster_database=TRUE scope=spfile sid='*';
shutdown immediate;
EOF

srvctl start database -d $V_UNQNM

echo "Showing pdb status after restart"

sqlplus -s / as sysdba<<EOF
alter pluggable database all open;
alter pluggable database all save state;
show pdbs;
EOF

echo "Completed function run_datapatch at $(date +%d%m%y%H%M%S)"

}

function setup_autocfg {

echo "Starting function setup_autocfg at $(date +%d%m%y%H%M%S)"
source ${EXA_DB_ENV}
source /tmp/EXAINFO

V_UNQNM=$(sqlplus -s / as sysdba <<EOF | tr -d '[:space:]'
SET HEADING OFF
SET FEEDBACK OFF
SELECT DB_UNIQUE_NAME FROM V\$DATABASE;
EXIT;
EOF
)

SCAN_NAME=$(srvctl config scan | awk -F: '/SCAN name/ {print $2}' | awk -F, '{print $1}' | xargs)

# sqlplus / as sysdba<<EOF
# alter user system identified by "$SYSPASS";
# alter session set container=EBSDB;
# alter user ebs_system identified by "$SYSPASS" container=current;
# alter user apps identified by APPS container=current;
# EOF

echo "Running txkGenCDBTnsAdmin.pl..."
cd $ORACLE_HOME/appsutil
. txkSetCfgCDB.env dboraclehome=${ORACLE_HOME}
perl ${ORACLE_HOME}/appsutil/bin/txkGenCDBTnsAdmin.pl \
-dboraclehome=$ORACLE_HOME \
-outdir=$ORACLE_HOME/appsutil/log \
-cdbname=EBSCDB \
-cdbsid=$ORACLE_SID \
-mode=validate

echo "Running txkPostPDBCreationTasks.pl..."
{ echo APPS; echo $SYSPASS; echo $SYSPASS; } | perl ${ORACLE_HOME}/appsutil/bin/txkPostPDBCreationTasks.pl \
-dboraclehome=$ORACLE_HOME \
-outdir=$ORACLE_HOME/appsutil/log \
-dbuniquename=$V_UNQNM \
-cdbname=EBSCDB \
-cdbsid=$ORACLE_SID \
-pdbsid=EBSDB \
-appsuser=APPS \
-dbport=1521 \
-israc=yes \
-virtualhostname=$(hostname) \
-scanhostname=$SCAN_NAME \
-scanport=1521 \
-servicetype=exadatadbsystem #\
#-generatepasswordfile=no

echo "Setting ORA_NLS10 env for database..."
srvctl setenv database -d ${ORACLE_UNQNAME} -t "ORA_NLS10=${ORACLE_HOME}/nls/data/9idata"
srvctl getenv database -d ${ORACLE_UNQNAME} -t ORA_NLS10

echo "Restarting Database"
srvctl stop database -d ${ORACLE_UNQNAME}
srvctl start database -d ${ORACLE_UNQNAME}

echo "Setting up utl file..."

{ echo APPS; } | perl ${ORACLE_HOME}/appsutil/bin/txkCfgUtlfileDir.pl \
-contextfile=$CONTEXT_FILE \
-oraclehome=$ORACLE_HOME \
-outdir=$ORACLE_HOME/appsutil/log \
-mode=getUtlFileDir

utl_dir="/u02/app/oracle/product/19.0.0.0/temp/EBSDB"
mkdir -p $utl_dir	
echo "/usr/tmp" > ${ORACLE_HOME}/dbs/EBSDB_utlfiledir.txt
echo "${utl_dir}" >> ${ORACLE_HOME}/dbs/EBSDB_utlfiledir.txt

source ${ORACLE_HOME}/EBSDB_$(hostname).env
cp ${CONTEXT_FILE}  ${CONTEXT_FILE}.org

sed -i -e "s,\([^>]*oa_var=\"s_db_data_file_dir\"[^>]*>\)[^<]*\(<.*\),\1${utl_dir}\2,g" ${CONTEXT_FILE}
sed -i -e "s,\([^>]*oa_var=\"s_outbound_dir\"[^>]*>\)[^<]*\(<.*\),\1${utl_dir}\2,g" ${CONTEXT_FILE}

diff ${CONTEXT_FILE} ${CONTEXT_FILE}.org

{ echo APPS; echo $SYSPASS; } | perl $ORACLE_HOME/appsutil/bin/txkCfgUtlfileDir.pl \
-contextfile=$CONTEXT_FILE \
-oraclehome=$ORACLE_HOME \
-outdir=$ORACLE_HOME/appsutil/log \
-mode=setUtlFileDir \
-skipdirvalidation=yes \
-skipautoconfig=yes


echo "Running autoconfig..."
source ${ORACLE_HOME}/EBSDB_$(hostname).env
cd ${ORACLE_HOME}/appsutil/scripts/EBSDB_$(hostname)
{ echo APPS; } | ./adautocfg.sh
echo "Completed function setup_autocfg at $(date +%d%m%y%H%M%S)"
}

# Main
logme;

echo "Copy over appsutil to ORACLE HOME"
source $EXA_DB_ENV
cp -v /tmp/appsutil.zip ${ORACLE_HOME}
cd ${ORACLE_HOME}
unzip -qo appsutil.zip

echo "Copy over 9idata to ORACLE HOME"
cp -v /tmp/9idata.zip ${ORACLE_HOME}
cd ${ORACLE_HOME}
unzip -qo 9idata.zip

run_datapatch;

echo "Recompiling invalid objects..."
cd ${ORACLE_HOME}/rdbms/admin
time ${ORACLE_HOME}/perl/bin/perl catcon.pl -d ${ORACLE_HOME}/rdbms/admin -n 1 -b utlrp utlrp.sql

echo "Running adgrants.sql"
export ORACLE_PDB_SID=EBSDB
cd ${ORACLE_HOME}/appsutil/admin
sqlplus "/ as sysdba" @adgrants.sql APPS
unset ORACLE_PDB_SID

setup_autocfg;