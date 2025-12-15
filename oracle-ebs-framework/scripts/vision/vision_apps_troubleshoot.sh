#!/bin/bash
# troubleshooting script

echo ""
echo -e "\033[1mOracle EBS Vision deployment troubleshooting script \033[0m"

echo ""
echo "### uptime"
uptime

echo ""
echo "### List avilalble buckets"
gcloud storage ls

echo ""
echo "### Bucket for Oracle EBS Vision media"
bucket=$(gcloud storage ls | grep oracle-ebs-toolkit-storage-bucket)
echo $bucket

echo ""
echo "### Contents of bucket: $bucket - expecting Oracle vision media files in V.zip format"
gcloud storage ls $bucket

echo ""
echo "### MD5 CheckSums of Vision Media in: $bucket"
echo "### Compare with checksums from -> README_DISK -> assemble_12212.zip -> md5sumwhenshipped.txt"
for i in $(gcloud storage ls ${bucket}V*zip); do
 echo "$(gcloud storage objects describe $i  --format="value(md5Hash)" | base64 --decode | xxd -p) $i"
done

echo ""
echo "### DNF preinstalled Oracle packages"
dnf list installed oracle-database-preinstall-19c oracle-ebs-server-R12-preinstall

echo ""
echo "### /VMKD contents - expecting .vmdk file and 1.lvm file"
ls -lA /VMDK/

echo ""
echo "### /scripts contents - expecting vision_apps_fs_prepare.sh, vision_apps_startup.sh and 7zz"
ls -lA /scripts/

echo ""
echo "### root crontab - expecting script to mount LVM on reboot"
crontab  -l

echo ""
echo "### oracle crontab - expecting script to start EBS on reboot"
sudo -u oracle crontab -l

echo ""
echo "### /etc/hosts file has apps entry"
cat /etc/hosts | grep apps

echo ""
echo "### server hostaname is set to: apps"
hostname

echo ""
echo "### /u01/ Filesystem is mounted"
df -Ph /u01/

echo ""
echo "### Environment files are present"
ls -l /u01/install/APPS/EBSapps.env

echo ""
echo "### Oracle Database running"
ps -fea | grep pmon | grep -v grep

echo ""
echo "### Oracle listener running"
ps -fea | grep tnslsnr | grep -v grep

echo ""
echo "### Oracle EBS apps running"
ps -fea | egrep 'httpd|oacore'

echo ""
echo "### Call frontend"
timeout 10 curl http://apps.example.com:8000




