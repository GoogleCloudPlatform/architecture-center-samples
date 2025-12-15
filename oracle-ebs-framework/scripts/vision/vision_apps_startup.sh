#!/bin/bash
set -e

# source env
. /scripts/vision_apps_env.sh

# set hostname to apps
# hostnamectl set-hostname apps

# vision_apps_startup.sh
# step 3: start Oracle (run as osuser: oracle)

# Wait until /u01/install/APPS is available, max 5 minutes (30 attempts)
FS_BASE=/u01/install/APPS
max_attempts=30
count=0

while true; do
    if [ -d "$FS_BASE" ]; then
        echo "Directory $FS_BASE is available." 
        break
    else
        count=$((count+1))
        echo "[$count/$max_attempts] Directory $FS_BASE not available yet, waiting 10s..." 
        if [ $count -ge $max_attempts ]; then
            echo "ERROR: Directory $FS_BASE not available after $((max_attempts*10)) seconds. Exiting." 
            exit 1
        fi
        sleep 10
    fi
done

# check if APPS fs mounted - if NO - pausing here
if [ ! -d $FS_BASE ]; then
    echo "### ERROR: APPS FS not mounted. Please mount the APPS FS first."
    exit;
fi

# add reboot script to cron
 if [ $(crontab  -l | grep vision_apps_startup | wc -l) -eq 0 ]; then
    echo "Add crontab";
    job="@reboot bash /scripts/vision_apps_startup.sh | tee -a /scripts/vision_apps_startup.sh.crontab.log 2>&1"
    ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
 fi

# changin dir to FS_BASE - so below commands doens't report permission denied issue for default home dir
cd $FS_BASE

# find EBS_DB ENV file (CDB)
db_env=$(find /u01/install/APPS/  -mindepth 2 -maxdepth 2 -name "*CDB*.env")
. $db_env

### DATABASE
# check if not started
echo "shut abort" | sqlplus / as sysdba

# move SQLnet.ora
mv $(find $TNS_ADMIN -name *sqlnet*ifile*) $(find $TNS_ADMIN -name *sqlnet*ifile*).org

# start listener
$ORACLE_HOME/appsutil/scripts/*_apps/addlnctl.sh start $ORACLE_SID

# startup database
echo "startup" | sqlplus / as sysdba
echo "alter system register;" | sqlplus / as sysdba

# verify
$ORACLE_HOME/appsutil/scripts/*_apps/addlnctl.sh status $ORACLE_SID

### APPLICAITON - statup
unset ORACLE_UNQNAME ORA_NLS10 ORACLE_SID ORACLE_HOME

cd $FS_BASE
. /u01/install/APPS/EBSapps.env run
echo "$WEBLOGIC_PASS" | $ADMIN_SCRIPTS_HOME/adstrtal.sh $APPS_USER/$APPS_PASS

# chagne sysadmin pass: 
FNDCPASS $APPS_USER/$APPS_PASS 0 Y $APPS_USER/$APPS_PASS USER "SYSADMIN" $SYSADMIN_PASS

#echo ""
#echo -e "\033[1m>>> ########## SUMMARY: ########## \033[0m"
#echo " > SYSADMIN PASSWORD: $SYSADMIN_PASS (case sensitive)"
#url=$(sed -n 's/.*<login_page[^>]*>\(.*\)<\/login_page>.*/\1/p' "$CONTEXT_FILE" | sed -u 's,/OA_HTML/AppsLogin,,g')
#echo " > Applicaiton URL: $url"
#echo " "
#echo "Use command to port forward port 8000 from GCP: >" 
#echo "gcloud compute ssh --zone <zone> oracle-vision --tunnel-through-iap --project <gcp_project> -- -L 8000:localhost:8000"
#echo ""
#echo "add line to local machien hosts file: 127.0.0.1 apps.example.com apps"

url=$(sed -n 's/.*<login_page[^>]*>\(.*\)<\/login_page>.*/\1/p' "$CONTEXT_FILE" | sed -u 's,/OA_HTML/AppsLogin,,g')
echo "

         =========================================
                 Oracle Vision Deployment
         =========================================
          URL                : http://apps.example.com:8000
          User               : SYSADMIN
          Password           : ${SYSADMIN_PASS} (case sensitive)

          hosts file entry   : 127.0.0.1 apps.example.com apps
          IAP tunneling      : 
          	gcloud compute ssh "oracle-vision" --tunnel-through-iap --project $(gcloud config get-value project) -- -L 8000:localhost:8000
         -----------------------------------------
"