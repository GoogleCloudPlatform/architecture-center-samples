#!/bin/bash
#set -e

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi

print_task(){
    echo -e "\n\033[1m### ${1} \033[0m"    
}

is_root_user() {
    if [ "$(id -un)" = "root" ]; then
        return 0  # true, user is root
    else
        echo "User is not root"
        return 1  # false, user is not root
    fi
}

setup_nfs_sharing() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function setting up NFS sharing b/w apps and database nodes
         ------------------------------------------------------------------------- \033[0m"

    # Check if called by root
    if ! is_root_user; then echo "This function must be run as root."; return 1; fi

    ### actual function betweens these comments
    print_task "Setting up hostname for apps node"
    hostnamectl set-hostname apps.example.com
    if ! grep -q "apps.example.com" /etc/hosts; then
        echo "$(hostname -i)     apps.example.com apps" >> /etc/hosts
    fi

    print_task "Setting up /etc/exports for NFS sharing"
    
    export EXA_IP=$(sed -n 's/^[[:space:]]*node_ip:[[:space:]]*"\([^"]*\)".*/\1/p' /tmp/exascale_outputs.yaml)
    if [ -z "$EXA_IP" ]; then
        echo "Error: EXA_IP could not be determined from /tmp/exascale_outputs.yaml"
        exit 1
    fi
    export P_KEY=/home/oracle/.ssh/exadb_private_key.pem
    export SSH_CMD="ssh -o StrictHostKeychecking=no"
    
    if ! grep -q '^/u01\b' /etc/exports; then
        echo "/u01  ${EXA_IP}(rw,async,insecure,no_subtree_check,fsid=241,no_root_squash)" >> /etc/exports
    fi
    
    print_task "Contents of /etc/exports for NFS sharing"
    cat /etc/exports

    print_task "Restarting nfs server service"

    systemctl stop nfs-server
    systemctl start nfs-server
    exportfs -ra
    
    print_task "Testing SSH connection to Exascale Server: ${EXA_IP}"

    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} 'echo "SSH connection to Exascale Server is working"'

        export APPS_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

    print_task "Mounting /buckets on Exascale Vm: ${EXA_IP}"

    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} "sudo mkdir -v /buckets; sudo mount -t nfs -o rsize=1048576,actimeo=3600,nconnect=8,noatime,nodiratime ${APPS_IP}:/u01 /buckets;  sudo ls -l /buckets/"

    print_task "Status of /buckets on Exascale Vm: ${EXA_IP}"
    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} 'df -hP | grep /buckets'

    print_task "Sending /tmp/exascale_outputs.yaml to Exascale Vm: ${EXA_IP}"
    export SCP_CMD="scp -o StrictHostKeychecking=no"
    ${SCP_CMD} -i ${P_KEY} /tmp/exascale_outputs.yaml opc@${EXA_IP}:/tmp

    print_task "Setting up script directory on Exascale Vm: ${EXA_IP}"
    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} 'sudo mkdir /scripts && sudo chown -Rfv root:root /scripts && sudo chmod -Rfv 777 /scripts'

    print_task "Copying scripts on Exascale Vm: ${EXA_IP}"
    ${SCP_CMD} -i ${P_KEY} /scripts/* opc@${EXA_IP}:/scripts

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

# Main
setup_nfs_sharing;
