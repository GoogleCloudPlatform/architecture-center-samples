#!/bin/bash
set -e 

# source env
. /scripts/vision_apps_env.sh

# vision_apps_fs_prepare.sh
# step2: get the Oracle Vision FS from Media

# vars
VISION_MEDIA_ZIP_PATTERN="V*-*.zip"
SERVER_MEDIA_PATH="/VMDK"

### as a pipeline (No checks / no verificaitions)
# create path on server
echo ""
echo "### step: creating dir on server: ${SERVER_MEDIA_PATH}"
mkdir -p ${SERVER_MEDIA_PATH}

# ADDING MD5 Checksum on Bucket
echo ""
echo "### step: File Checksums of GCP BUCKET:"
for i in $(gcloud storage ls ${BUCKET_NAME}${VISION_MEDIA_ZIP_PATTERN}); do
 echo "$(gcloud storage objects describe $i  --format="value(md5Hash)" | base64 --decode | xxd -p) $i"
done

# fetch the media using gcloud storage cp
# usual speed 70G -> ~ 4mins
echo ""
echo "### step: transfering Vision zip files to server"
time gcloud storage cp ${BUCKET_NAME}${VISION_MEDIA_ZIP_PATTERN} ${SERVER_MEDIA_PATH}

# ADDING MD5 Checksum on Storage
echo ""
echo "### step: File Checksums after local copy at $SERVER_MEDIA_PATH "
time md5sum $SERVER_MEDIA_PATH/*

# Unzip 
# GCP disk troughput ~500MB/s
echo ""
echo "### step: Extract zip files"
cd ${SERVER_MEDIA_PATH}
for f in ${VISION_MEDIA_ZIP_PATTERN}; do
    unzip -o $f 
done
# remove ZIP's from server
rm -rfv ${SERVER_MEDIA_PATH}/${VISION_MEDIA_ZIP_PATTERN}

# merge OVA files | ~2 mins
echo ""
echo "### step: Merge OVA's"
cd ${SERVER_MEDIA_PATH}
time ls -1 Oracle*.ova.* | sort -V | xargs cat > VISION_INSTALL.ova
# remove OVA's megrge
rm -rfv ${SERVER_MEDIA_PATH}/*ova.[0-9]*

# extract OVA | ~3 min
echo ""
echo "### step: Extract OVA"
cd ${SERVER_MEDIA_PATH}
time tar -xvf VISION_INSTALL.ova
VMDK_FILE=$(ls -1 *.vmdk)
echo $VMDK_FILE
# remove OVA
rm -rfv VISION_INSTALL.ova

# get 7Z | moved file to git repo (avoid extra )
#echo "### step: Get 7zip"
#cd ${SERVER_MEDIA_PATH}
#time timeout 120  wget -qO- https://www.7-zip.org/a/7z2501-linux-x64.tar.xz > /tmp/7zip.tar.xz
#tar -xvf/tmp/7zip.tar.xz 7zz

# extract from VMDK | 25 min
echo ""
echo "### step: Extract VMDK (using 7zz) - this takes time ~25 min"
cd ${SERVER_MEDIA_PATH}
time /scripts/7zz x -y ${VMDK_FILE}

# Get and attach LVM
echo ""
echo "### step: Get and Attach LVM"
SERVER_MEDIA_PATH="/VMDK"
cd ${SERVER_MEDIA_PATH}
LVM_FILE=$(ls -1 *.lvm)
echo $LVM_FILE
losetup -fP $LVM_FILE
losetup -a
vgscan
vgchange -ay
lvdisplay

# mount LVM 
MNT_LVM_PATH=$(lvdisplay | grep "LV Path" | grep home | awk '{print$3}')
echo "Mounting $MNT_LVM_PATH"
mount -t xfs  ${MNT_LVM_PATH}  /u01
set -e 

# source env
. /scripts/vision_apps_env.sh

# vision_apps_fs_prepare.sh
# step2: get the Oracle Vision FS from Media

# vars
VISION_MEDIA_ZIP_PATTERN="V*-*.zip"
SERVER_MEDIA_PATH="/VMDK"



# skipping data copy out - direct mount works fine
        # # mount
        # echo "### step: Mount LVM"
        # MNT_LVM_PATH=$(lvdisplay | grep "LV Path" | grep home | awk '{print$3}')
        # mkdir -pv /mnt/vision
        # mount ${MNT_LVM_PATH} /mnt/vision
        # df -Ph /mnt/vision/
        # ls -l /mnt/vision/*

        # # copy out Vision Data to FS | 20 min + 3min
        # echo "### step: Copy Data out to /u01"
        # time cp -Rf /mnt/vision/install /u01/
        # time chown -Rf oracle:oinstall /u01/install
        # umount /mnt/vision

        # # result
        # echo "### step: Filesystem extract - completed" 
        # ls -alrt /u01/install/APPS/


# update /etc/hosts
echo ""
echo "### step: /etc/hosts update"
v_ip=$(cat /etc/hosts | grep -v localhost | grep -v metadata)
cat /etc/hosts | grep -v $(echo $v_ip | awk '{print $1}') > /etc/hosts.new
echo $v_ip | awk '{print $1 " apps.example.com apps " $2 " " $3} '  >> /etc/hosts.new
mv -v /etc/hosts /etc/hosts.org
mv -v /etc/hosts.new /etc/hosts

# adding reboot cront to ROOT user

# add reboot script to cron
 if [ $(crontab  -l | grep vision_apps_fs_mount | wc -l) -eq 0 ]; then
    echo "Add crontab: mount FS on startup";
    job="@reboot bash /scripts/vision_apps_fs_mount.sh | tee -a /scripts/vision_apps_fs_mount.sh.log 2>&1"
    ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
 fi


# update /etc/hosts
echo ""
echo "### step: hostname update to apps"
hostnamectl set-hostname apps
hostname

# add reboot script to cron
 if [ $(crontab  -l | grep vision_apps_fs_mount | wc -l) -eq 0 ]; then
    echo "Add crontab: set hostname on startup";
    job="@reboot hostnamectl set-hostname apps"
    ( crontab -l 2>/dev/null; echo "$job" ) | crontab -
 fi


# trigger startup
echo ""
echo "### step: Oracle EBS Vision startup"
sudo -u oracle "/scripts/vision_apps_startup.sh"