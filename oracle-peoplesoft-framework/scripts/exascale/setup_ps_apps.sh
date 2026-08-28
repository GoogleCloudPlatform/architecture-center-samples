#!/bin/bash
#set -e

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi
if [ -z "$BUCKET" ]; then BUCKET=$(gcloud storage ls | grep oracle-peoplesoft-toolkit-storage-bucket); fi

# paths
export local_media=/u01
export EXA_OUT=/tmp/exascale_outputs.yaml

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
          	gcloud compute ssh oracle-exascale-peoplesoft-app --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8001:localhost:8001
         -----------------------------------------
    \033[0m"    
}

rdbms_stage_oh() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
        echo "
         =========================================
         Peoplesoft on EXASCALE@GCP TOOLKIT: FUNCTION rdbms_stage_oh
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

    # move files including hidden files safely
    (shopt -s dotglob; mv $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")/* $ORACLE_HOME/)
    rmdir -v $(dirname "$ORACLE_HOME")/$(basename "$OLD_OH")

    ls -ld $ORACLE_HOME
    ls -la $ORACLE_HOME/ | head -10
    echo ".."
  
    print_task "Configurting RDBMS HOME - relink"
    
	ORACLE_SID=$(ls ${local_media}/rman/*.bkp | tail -1 | awk -F_ '{ print $2 }')
    
	#print_task "Oracle SID is set to ${ORACLE_SID}"
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

 echo -e "\nlog: $logfile"
    date       
 } 2>&1 | tee -a ${logfile}
}

setup_tnsnames() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo "
         ====================================================================
         Peoplesoft on EXASCALE@GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         ====================================================================
         Function to setup tnsnames.ora for Peoplesoft on Exascale vm
         --------------------------------------------------------------------"
    
    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi
    
    ### actual function betweens these comments
    print_task "Setting up tnsnames.ora..."

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

    print_task "Testing Oracle Exascale @GCP connection "

    export ORACLE_HOME=/u02/db/oracle-server/19.3.0.0
    export PATH=$ORACLE_HOME/bin:$PATH
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

    print_task "Finding Pdb name in Exasxcale database..."

PDBNAME=$(sqlplus -s sys/$SYSPASS@$EXATNS as sysdba <<EOF
set heading off feedback off verify off pages 0 lines 200
select NAME from V\$CONTAINERS where name not like '%\$ROOT' and name not like '%\$SEED';
EOF
)

    print_task "Pdb name in Exasxcale database is: ${PDBNAME}"


    print_task "Finding service name in Exasxcale database for ${PDBNAME}"

SVCNAME=$(sqlplus -s sys/$SYSPASS@$EXATNS as sysdba <<EOF
set heading off feedback off verify off pages 0 lines 200
alter session set container=$PDBNAME;
SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name FROM dual;
EOF
)

    print_task "Service name in Exasxcale database for ${PDBNAME} is: ${SVCNAME}"

    print_task "Setting up tnsnames.ora for Peoplesoft apps tier..."
    cd /u02/db
    export PDBTNS=$(echo $EXATNS | sed "s/\(SERVICE_NAME=\)[^)]*/\1${SVCNAME}/")
	echo "$PDBNAME = $PDBTNS" > tnsnames.ora
    echo "tnsnames.ora for Peoplesoft apps tier is: "
    cat tnsnames.ora
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

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
	# Strip carriage returns to prevent issues if files were uploaded from Windows
	tr -d '\r' < ${local_media}/app/psft.env > /u02/app/psft.env
	tr -d '\r' < ${local_media}/app/domaininfo.txt > /tmp/domaininfo.txt && mv /tmp/domaininfo.txt ${local_media}/app/domaininfo.txt
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
	
	source /u02/app/psft.env || true
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
    source /u02/app/psft.env || true
	
    WEB_DOM=$(grep "DOMAIN_NAME=" setEnv.sh | awk -F= '{ print $2 }')
	HOST_D=$(hostname -d)
	HOST_D=${HOST_D:-example.com}
	
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

    print_task "Creating cron autostart"
echo "
sleep 10
source /u02/app/psft.env || true
cd /u02/app/newcfg/webserv/peoplesoft/bin
WEB_DOM=$(grep "DOMAIN_NAME=" setEnv.sh | awk -F= '{ print $2 }')
APPD=$( grep APP_DOMAIN_NAME /u01/app/domaininfo.txt | awk -F= '{ print $2 }')
PRCSD=$( grep PRCS_DOMAIN_NAME  /u01/app/domaininfo.txt | awk -F= '{ print $2 }')
psadmin -w start -d ${WEB_DOM};
psadmin -c start -d ${APPD};
psadmin -p start -d ${PRCSD};
" > /scripts/peoplesoft_cust_start.sh 
    
    chmod u+x /scripts/peoplesoft_cust_start.sh 

    # add reboot script to cron
    if [ $(crontab -l 2>/dev/null | grep peoplesoft_cust_start | wc -l) -eq 0 ]; then
        job="@reboot /scripts/peoplesoft_cust_start.sh | tee -a /scripts/logs/peoplesoft_cust_start.sh.log 2>&1"
        ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
    fi
	
    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}


# Main
rdbms_stage_oh;
setup_tnsnames;
setup_cust_app;
print_summary_cust;
