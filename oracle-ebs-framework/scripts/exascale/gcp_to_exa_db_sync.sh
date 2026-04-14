#!/bin/bash
#set -x

source /scripts/gcp_to_exa_db_sync_functions.sh

# checking logs directory
if [ ! -d "$log_path" ]; then  mkdir -p "$log_path"; fi

# main - call functions in order
create_exainfo;
test_exa_connection;
update_pass;
enable_gcp_archivelog;
find_drop_exa_pdbs;
transfer_files;
exa_rman_dup;
post_config_exa_db;
shut_gcp_vision_db;
apps_configure;