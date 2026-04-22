resource "null_resource" "oracle_ebs_gemini_enterprise_framework" {
  triggers = {
    deploy_script_hash = filemd5("${path.module}/Agents/deploy_gcloud.sh")
    env_template_hash  = filemd5("${path.module}/Agents/EBS_Master/env.example")
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      python3 -m venv .venv
      source .venv/bin/activate
      
      pip install --upgrade pip
      pip install -r requirements.txt
      pip install -r Agents/requirements.txt

      ACTUAL_PROJECT_NUMBER=$(gcloud projects describe ${var.project_id} --format="value(projectNumber)")

      cp Agents/EBS_Master/env.example Agents/EBS_Master/.env
      
      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_PROJECT[[:space:]]*=.*|GOOGLE_CLOUD_PROJECT=\"${var.project_id}\"|" Agents/EBS_Master/.env
      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_PROJECT_NUMBER[[:space:]]*=.*|GOOGLE_CLOUD_PROJECT_NUMBER=$ACTUAL_PROJECT_NUMBER|" Agents/EBS_Master/.env
      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_LOCATION[[:space:]]*=.*|GOOGLE_CLOUD_LOCATION=\"${var.region}\"|" Agents/EBS_Master/.env
      sed -i.bak "s|^[[:space:]]*MCP_SERVER_EBS_URL[[:space:]]*=.*|MCP_SERVER_EBS_URL=\"${var.mcp_server_ebs_url}\"|" Agents/EBS_Master/.env
      sed -i.bak '/^[[:space:]]*GOOGLE_CLOUD_AUTH_ID[[:space:]]*=[[:space:]]*""/d' Agents/EBS_Master/.env

      if grep -q "localhost" Agents/EBS_Master/.env; then
          sed -i.bak 's/localhost/127.0.0.1/g' Agents/EBS_Master/.env
      fi

      rm -f Agents/EBS_Master/*.bak

      cd Agents/

      AGENT_ARGS="EBS_Master"
      if [ -f ".agent_id" ]; then
          RESOURCE_ID=$(cat .agent_id)
          AGENT_ARGS="EBS_Master $RESOURCE_ID"
      fi

      ./deploy_gcloud.sh $AGENT_ARGS
      
      if grep -q "Deploy failed" logs/EBS_Master_deploy.log; then
          exit 1
      fi

      EXTRACTED_ID=$(grep "reasoningEngines/" logs/EBS_Master_deploy.log | tail -n 1 | awk -F'reasoningEngines/' '{print $2}' | tr -d '\r\n ')
      
      if [ ! -z "$EXTRACTED_ID" ]; then
          echo "$EXTRACTED_ID" > .agent_id
      fi
    EOT
  }
}
