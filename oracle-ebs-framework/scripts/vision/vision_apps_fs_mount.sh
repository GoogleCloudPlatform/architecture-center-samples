#!/bin/bash
# automatic FS mount
# check to get OS commands in

# source env
. /scripts/vision_apps_env.sh

# PATH
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin/:$PATH
echo "PATH: $PATH"

# Wait until losetup is available, max 5 minutes (30 attempts)
max_attempts=30
count=0

while true; do
    if which losetup >/dev/null 2>&1; then
        echo "### step: losetup found at $(which losetup) - proceeding with VG scan"
        break
    else
        count=$((count+1))
        echo "[$count/$max_attempts] losetup not available yet, waiting 10s..." =
        if [ $count -ge $max_attempts ]; then
            echo "ERROR: losetup not available after $((max_attempts*10)) seconds. Exiting."
            exit 1
        fi
        sleep 10
    fi
done

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

MNT_LVM_PATH=$(lvdisplay | grep "LV Path" | grep home | awk '{print$3}')
echo "Mounting $MNT_LVM_PATH"
mount -t xfs  ${MNT_LVM_PATH} /u01

echo "Verifying /u01 mount"
df -Ph /u01