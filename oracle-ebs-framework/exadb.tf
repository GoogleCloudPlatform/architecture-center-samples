resource "tls_private_key" "exadb_ssh_key" {
  count     = var.oracle_ebs_exascale ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "exadb_private_key" {
  count           = var.oracle_ebs_exascale ? 1 : 0
  content         = tls_private_key.exadb_ssh_key[0].private_key_pem
  filename        = "${path.module}/exadb_private_key.pem"
  file_permission = "0600"
}

resource "local_file" "exadb_public_key" {
  count           = var.oracle_ebs_exascale ? 1 : 0
  content         = tls_private_key.exadb_ssh_key[0].public_key_openssh
  filename        = "${path.module}/exadb_public_key.pub"
  file_permission = "0644"
}

resource "google_oracle_database_exadb_vm_cluster" "exadb_vm_cluster" {
  count               = var.oracle_ebs_exascale ? 1 : 0
  provider            = google-beta
  exadb_vm_cluster_id = var.exadb_vm_cluster_id
  display_name        = var.exadb_display_name
  location            = var.region
  project             = var.project_id

  odb_network       = try(google_oracle_database_odb_network.odb_network[0].id, "")
  odb_subnet        = try(google_oracle_database_odb_subnet.client_subnet[0].id, "")
  backup_odb_subnet = try(google_oracle_database_odb_subnet.backup_subnet[0].id, "")

  labels = {
    "deployment" = "demo"
  }

  properties {
    ssh_public_keys = [try(tls_private_key.exadb_ssh_key[0].public_key_openssh, "")]
    time_zone {
      id = var.exascale_time_zone
    }

    grid_image_id               = var.exascale_grid_image_id
    node_count                  = var.exascale_node_count
    enabled_ecpu_count_per_node = var.exascale_enabled_ecpu_count_per_node

    vm_file_system_storage {
      size_in_gbs_per_node = var.exascale_vm_file_system_storage_size_gb
    }

    exascale_db_storage_vault = try(google_oracle_database_exascale_db_storage_vault.exascale_vault[0].id, "")

    hostname_prefix        = var.exascale_hostname_prefix
    shape_attribute        = var.exascale_shape_attribute
    cluster_name           = var.exascale_cluster_name
    license_model          = var.exascale_license_model
    scan_listener_port_tcp = 1521

    data_collection_options {
      is_diagnostics_events_enabled = "true"
      is_health_monitoring_enabled  = "true"
      is_incident_logs_enabled      = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      properties[0].hostname_prefix,
      properties[0].additional_ecpu_count_per_node,
      properties[0].ssh_public_keys
    ]
  }

  timeouts {
    create = "180m"
    update = "180m"
    delete = "180m"
  }

  depends_on = [google_oracle_database_odb_subnet.client_subnet, google_oracle_database_odb_subnet.backup_subnet, google_oracle_database_odb_network.odb_network]

  deletion_protection = false
}

resource "google_oracle_database_exascale_db_storage_vault" "exascale_vault" {
  count                        = var.oracle_ebs_exascale ? 1 : 0
  provider                     = google-beta
  exascale_db_storage_vault_id = var.exascale_storage_vault_id
  display_name                 = var.exascale_storage_vault_display_name
  location                     = var.exascale_location
  project                      = var.project_id

  properties {
    exascale_db_storage_details {
      total_size_gbs = var.exascale_storage_vault_size_gb
    }
  }

  deletion_protection = false
}

resource "null_resource" "exascale_ingress_rules" {
  count      = var.oracle_ebs_exascale ? 1 : 0
  depends_on = [null_resource.exascale_db_provisioning]

  triggers = {
    cluster_uri     = try(google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0].properties[0].oci_uri, "")
    vpc_cidr        = try(var.subnets[0].subnet_ip, "")
    oci_api_version = var.oci_api_version
  }

  provisioner "local-exec" {
    when        = create
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e

      if ! command -v jq &> /dev/null; then
        exit 1
      fi

      CLUSTER_URI="${self.triggers.cluster_uri}"
      CLUSTER_OCID=$(echo "$CLUSTER_URI" | grep -oE 'ocid1\.[^/?&]+' | head -1)
      OCI_REGION=$(echo "$CLUSTER_OCID" | cut -d'.' -f4)

      if [ -z "$CLUSTER_OCID" ] || [ -z "$OCI_REGION" ]; then
        exit 1
      fi

      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/exadbVmClusters/$CLUSTER_OCID" | grep -v "ServiceError")
      SUBNET_OCID=$(echo "$CLUSTER_JSON" | jq -r '.data.subnetId // empty')

      if [ -z "$SUBNET_OCID" ]; then
        exit 1
      fi

      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri "https://iaas.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/subnets/$SUBNET_OCID" | grep -v "ServiceError")
      VCN_OCID=$(echo "$SUBNET_JSON" | jq -r '.data.vcnId // empty')
      COMPARTMENT_OCID=$(echo "$SUBNET_JSON" | jq -r '.data.compartmentId // empty')

      TARGET_NSG_OCID=$(oci network nsg list \
        --compartment-id "$COMPARTMENT_OCID" \
        --vcn-id "$VCN_OCID" \
        --all | jq -r '
          .data[] 
          | select(.["display-name"] | endswith("_NSG")) 
          | select(.["display-name"] | contains("BCKP") | not) 
          | .id
        ' | head -n 1)

      if [ -z "$TARGET_NSG_OCID" ]; then
        exit 1
      fi

      oci network nsg rules add \
        --nsg-id "$TARGET_NSG_OCID" \
        --region "$OCI_REGION" \
        --security-rules '[
          {
            "direction": "INGRESS",
            "protocol": "6",
            "source": "${self.triggers.vpc_cidr}",
            "sourceType": "CIDR_BLOCK",
            "tcpOptions": {
              "destinationPortRange": {"max": 1521, "min": 1521}
            }
          },
          {
            "direction": "INGRESS",
            "protocol": "6",
            "source": "${self.triggers.vpc_cidr}",
            "sourceType": "CIDR_BLOCK",
            "tcpOptions": {
              "destinationPortRange": {"max": 22, "min": 22}
            }
          }
        ]' > /dev/null
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e

      if ! command -v jq &> /dev/null; then
        exit 0
      fi

      CLUSTER_URI="${self.triggers.cluster_uri}"
      if [ -z "$CLUSTER_URI" ]; then
        exit 0
      fi

      CLUSTER_OCID=$(echo "$CLUSTER_URI" | grep -oE 'ocid1\.[^/?&]+' | head -1)
      OCI_REGION=$(echo "$CLUSTER_OCID" | cut -d'.' -f4)

      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/exadbVmClusters/$CLUSTER_OCID" 2>/dev/null || true)
      SUBNET_OCID=$(echo "$CLUSTER_JSON" | jq -r '.data.subnetId // empty')

      if [ -z "$SUBNET_OCID" ]; then
        exit 0
      fi

      SUBNET_JSON=$(oci raw-request --http-method GET --target-uri "https://iaas.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/subnets/$SUBNET_OCID" 2>/dev/null || true)
      VCN_OCID=$(echo "$SUBNET_JSON" | jq -r '.data.vcnId // empty')
      COMPARTMENT_OCID=$(echo "$SUBNET_JSON" | jq -r '.data.compartmentId // empty')

      if [ -z "$VCN_OCID" ] || [ -z "$COMPARTMENT_OCID" ]; then
        exit 0
      fi

      TARGET_NSG_OCID=$(oci network nsg list \
        --compartment-id "$COMPARTMENT_OCID" \
        --vcn-id "$VCN_OCID" \
        --all 2>/dev/null | jq -r '
          .data[] 
          | select(.["display-name"] | endswith("_NSG")) 
          | select(.["display-name"] | contains("BCKP") | not) 
          | .id
        ' | head -n 1)

      if [ -z "$TARGET_NSG_OCID" ]; then
        exit 0
      fi

      RULE_IDS=$(oci network nsg rules list --nsg-id "$TARGET_NSG_OCID" --all 2>/dev/null | jq -r --arg cidr "${self.triggers.vpc_cidr}" '.data[] | select(.source == $cidr) | .id')

      if [ -n "$RULE_IDS" ]; then
        for id in $RULE_IDS; do
          oci network nsg rules remove --nsg-id "$TARGET_NSG_OCID" --security-rule-ids "[\"$id\"]" --force || true
        done
      fi
    EOT
  }
}

resource "null_resource" "exascale_db_provisioning" {
  count = var.oracle_ebs_exascale ? 1 : 0

  triggers = {
    cluster_uri     = try(google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0].properties[0].oci_uri, "")
    cdb_name        = var.cdb_name
    oci_api_version = var.oci_api_version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e

      CLUSTER_URI="${self.triggers.cluster_uri}"
      CLUSTER_OCID=$(echo "$CLUSTER_URI" | grep -oE 'ocid1\.[^/?&]+' | head -1)
      OCI_REGION=$(echo "$CLUSTER_OCID" | cut -d'.' -f4)

      if [ -z "$CLUSTER_OCID" ] || [ -z "$OCI_REGION" ]; then
        exit 1
      fi

      CDB_NAME_RAW="${self.triggers.cdb_name}"
      DB_NAME_CLEAN=$(echo "$CDB_NAME_RAW" | sed 's/[-_]//g')
      DISPLAY_NAME="Home_19c_$CDB_NAME_RAW"

      API_URL="https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/dbHomes"

      LIST_URL="$API_URL?vmClusterId=$CLUSTER_OCID&displayName=$DISPLAY_NAME"
      
      LIST_RESULT=$(oci raw-request --http-method GET --target-uri "$LIST_URL" 2>/dev/null || true)
      
      EXISTING_STATE=$(echo "$LIST_RESULT" | grep -io '"lifecycle-state": *"[^"]*"' | head -1 | cut -d'"' -f4)

      if [ -n "$EXISTING_STATE" ] && [ "$EXISTING_STATE" != "TERMINATED" ] && [ "$EXISTING_STATE" != "FAILED" ]; then
        exit 0
      fi

      BODY_FILE=$(mktemp /tmp/dbhome_body_XXXXXX.json)
      trap 'rm -f "$BODY_FILE"' EXIT

      cat <<EOF > "$BODY_FILE"
{
  "vmClusterId": "$CLUSTER_OCID",
  "displayName": "Home_19c_$CDB_NAME_RAW",
  "dbVersion": "19.30.0.0",
  "source": "VM_CLUSTER_NEW",
  "database": {
    "adminPassword": "${try(random_password.admin_password[0].result, "")}",
    "dbName": "$DB_NAME_CLEAN",
    "characterSet": "AL32UTF8",
    "ncharacterSet": "AL16UTF16",
    "dbWorkload": "OLTP",
    "pdbName": "pdb1",
    "storageSizeDetails": {
      "dataStorageSizeInGBs": 650,
      "recoStorageSizeInGBs": 150
    },
    "dbBackupConfig": {
      "autoBackupEnabled": false
    }
  }
}
EOF

      RAW_RESULT=$(oci raw-request \
        --http-method POST \
        --target-uri "$API_URL" \
        --request-body "file://$BODY_FILE" 2>&1)

      if echo "$RAW_RESULT" | grep -q "Already a database home"; then
        exit 0
      fi

      if echo "$RAW_RESULT" | grep -q "ServiceError\|InvalidParameter\|NotAuthorized"; then
        exit 1
      fi

      WORK_REQUEST_ID=$(echo "$RAW_RESULT" | grep -io '"opc-work-request-id": *"[^"]*"' | head -1 | cut -d'"' -f4)

      if [ -z "$WORK_REQUEST_ID" ]; then
        exit 1
      fi

      POLL_COUNT=0
      MAX_POLLS=240

      while [ $POLL_COUNT -lt $MAX_POLLS ]; do
        POLL_COUNT=$((POLL_COUNT + 1))
        sleep 60

        WR_RESULT=$(oci work-requests work-request get --work-request-id "$WORK_REQUEST_ID" 2>&1)
        WR_STATUS=$(echo "$WR_RESULT" | grep -o '"status": *"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ "$WR_STATUS" = "SUCCEEDED" ]; then
          exit 0
        fi

        if [ "$WR_STATUS" = "FAILED" ]; then
          exit 1
        fi
      done

      exit 1
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e

      if ! command -v jq &> /dev/null; then
        exit 0
      fi

      CLUSTER_URI="${self.triggers.cluster_uri}"
      if [ -z "$CLUSTER_URI" ]; then
        exit 0
      fi

      CLUSTER_OCID=$(echo "$CLUSTER_URI" | grep -oE 'ocid1\.[^/?&]+' | head -1)
      OCI_REGION=$(echo "$CLUSTER_OCID" | cut -d'.' -f4)

      if [ -z "$CLUSTER_OCID" ] || [ -z "$OCI_REGION" ]; then
        exit 0
      fi

      CDB_NAME_RAW="${self.triggers.cdb_name}"
      DB_NAME_CLEAN=$(echo "$CDB_NAME_RAW" | sed 's/[-_]//g')

      DB_LIST=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/databases?systemId=$CLUSTER_OCID" 2>/dev/null || true)
      DB_OCID=$(echo "$DB_LIST" | jq -r --arg dbname "$DB_NAME_CLEAN" '.data[] | select((.dbName | ascii_downcase) == ($dbname | ascii_downcase)) | .id' | head -1)

      if [ -n "$DB_OCID" ] && [ "$DB_OCID" != "null" ]; then
        oci raw-request --http-method DELETE --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/databases/$DB_OCID" 2>/dev/null || true
        sleep 60
      fi

      DISPLAY_NAME="Home_19c_$CDB_NAME_RAW"
      API_URL="https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/dbHomes"
      LIST_URL="$API_URL?vmClusterId=$CLUSTER_OCID&displayName=$DISPLAY_NAME"
      LIST_RESULT=$(oci raw-request --http-method GET --target-uri "$LIST_URL" 2>/dev/null || true)
      DB_HOME_OCID=$(echo "$LIST_RESULT" | jq -r --arg dname "$DISPLAY_NAME" '.data[] | select(.displayName == $dname) | .id' | head -1)

      if [ -n "$DB_HOME_OCID" ] && [ "$DB_HOME_OCID" != "null" ]; then
        oci raw-request --http-method DELETE --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/dbHomes/$DB_HOME_OCID" 2>/dev/null || true
      fi
    EOT
  }
}

resource "null_resource" "exascale_configure_and_upload" {
  count = var.oracle_ebs_exascale ? 1 : 0

  triggers = {
    vm_id           = try(google_compute_instance.exascale_vision[0].id, "")
    password        = try(random_password.admin_password[0].result, "")
    cdb_name        = var.cdb_name
    oci_api_version = var.oci_api_version
  }

  depends_on = [
    null_resource.exascale_db_provisioning,
    google_compute_instance.exascale_vision
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e

      if ! command -v jq &> /dev/null; then
        exit 1
      fi

      CLUSTER_URI="${try(google_oracle_database_exadb_vm_cluster.exadb_vm_cluster[0].properties[0].oci_uri, "")}"
      CLUSTER_OCID=$(echo "$CLUSTER_URI" | grep -oE 'ocid1\.[^/?&]+' | head -1)
      COMPARTMENT_OCID=$(echo "$CLUSTER_URI" | grep -oE 'compartmentId=[^&]+' | cut -d'=' -f2)
      OCI_REGION=$(echo "$CLUSTER_OCID" | cut -d'.' -f4)
      
      CDB_NAME_CLEAN=$(echo "${self.triggers.cdb_name}" | sed 's/[-_]//g')

      CLUSTER_JSON=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/exadbVmClusters/$CLUSTER_OCID" 2>&1)
      CLUSTER_NAME=$(echo "$CLUSTER_JSON" | jq -r '.data.clusterName // .data.displayName // "null"')
      SCAN_DNS=$(echo "$CLUSTER_JSON" | jq -r '.data.scanDnsName // "null"')

      DB_LIST=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/databases?compartmentId=$COMPARTMENT_OCID&systemId=$CLUSTER_OCID" 2>&1)
      DB_OCID=$(echo "$DB_LIST" | jq -r --arg dbname "$CDB_NAME_CLEAN" '.data[] | select((.dbName | ascii_downcase) == ($dbname | ascii_downcase)) | .id' | head -1)

      if [ -z "$DB_OCID" ]; then
        exit 1
      fi

      DB_DETAILS=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/databases/$DB_OCID" 2>&1)
      TNS_DATA=$(echo "$DB_DETAILS" | jq -c '.data.connectionStrings // {}')

      DB_NODES_JSON=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/dbNodes?compartmentId=$COMPARTMENT_OCID&exadbVmClusterId=$CLUSTER_OCID" 2>/dev/null || true)
      
      HOST_IP_OCID=$(echo "$DB_NODES_JSON" | jq -r '.data[]? | .hostIpId' 2>/dev/null | head -1 || true)

      if [ -z "$HOST_IP_OCID" ]; then
        DB_NODES_JSON=$(oci raw-request --http-method GET --target-uri "https://database.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/dbNodes?compartmentId=$COMPARTMENT_OCID&vmClusterId=$CLUSTER_OCID" 2>/dev/null || true)
        HOST_IP_OCID=$(echo "$DB_NODES_JSON" | jq -r '.data[]? | .hostIpId' 2>/dev/null | head -1 || true)
      fi

      NODE_IP=""
      if [ -n "$HOST_IP_OCID" ]; then
        IP_JSON=$(oci raw-request --http-method GET --target-uri "https://iaas.$${OCI_REGION}.oraclecloud.com/${self.triggers.oci_api_version}/privateIps/$HOST_IP_OCID" 2>/dev/null || true)
        NODE_IP=$(echo "$IP_JSON" | jq -r '.data.ipAddress // empty')
      fi

      if [ -z "$NODE_IP" ]; then
        NODE_IP=$(echo "$DB_DETAILS" | grep -o 'HOST=[0-9.]*' | head -1 | cut -d= -f2)
      fi

      cat <<EOF > ./exascale_outputs.yaml
cluster_name: "$CLUSTER_NAME"
scan_dns: "$SCAN_DNS"
node_ip: "$NODE_IP"
admin_password: "${self.triggers.password}"
connection_strings: $TNS_DATA
EOF

      max_retries=10
      retry_count=0
      
      while ! gcloud compute scp ./exascale_outputs.yaml \
        ${try(google_compute_instance.exascale_vision[0].name, "placeholder")}:/tmp/exascale_outputs.yaml \
        --zone="${var.zone}" \
        --project="${var.project_id}" \
        --tunnel-through-iap \
        --quiet; do
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -ge $max_retries ]; then
          exit 1
        fi
        sleep 15
      done
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ./exascale_outputs.yaml"
  }
}
