#!/bin/bash
set -e

## initialization and variables
log_path=/scripts/logs
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi

print_task(){
    echo -e "\n\033[1m### ${1} \033[0m"    
}

is_oracle_user() {
    if [ "$(id -un)" = "oracle" ]; then
        return 0  # true, user is oracle
    else
        echo "User is not oracle"
        return 1  # false, user is not oracle
    fi
}

start_db_setup() {
 logfile=${log_path}/$(date +%Y%m%d_%H%M%S)_${FUNCNAME[0]}.log
 {
    date
    echo -e "\n\033[1m
         =========================================================================
         Peoplesoft ON GCP TOOLKIT FUNCTION: ${FUNCNAME[0]}
         =========================================================================
         Function to start database setup on Exascale Vm
         ------------------------------------------------------------------------- \033[0m"

    # Check if called by oracle
    if ! is_oracle_user; then echo "This function must be run as oracle."; return 1; fi

    ### actual function betweens these comments
    export EXA_IP=$(sed -n 's/^[[:space:]]*node_ip:[[:space:]]*"\([^"]*\)".*/\1/p' /tmp/exascale_outputs.yaml)
    export P_KEY=/home/oracle/.ssh/exadb_private_key.pem
    export SSH_CMD="ssh -o StrictHostKeychecking=no"
    
    print_task "Testing SSH connection to Exascale Server: ${EXA_IP}"

    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} 'echo "SSH connection to Exascale Server is working"'

    print_task "Setting up Peoplesoft database on Exascale Vm: ${EXA_IP}"

    ${SSH_CMD} -i ${P_KEY} opc@${EXA_IP} "sudo -u oracle bash -c /scripts/setup_db_exascale.sh"

    ### EOF actual function betweens these comments
    echo -e "\nlog: $logfile"
    date              
 } 2>&1 | tee -a ${logfile}
}

# Main
start_db_setup;
