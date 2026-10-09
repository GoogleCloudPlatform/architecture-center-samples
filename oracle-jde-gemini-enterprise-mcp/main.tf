# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "null_resource" "oracle_jde_gemini_enterprise_framework" {
  triggers = {
    deploy_script_hash = filemd5("${path.module}/Agents/deploy_gcloud.sh")
    env_template_hash  = filemd5("${path.module}/Agents/JDE_Master/env.example")
    agent_code_hash    = sha256(join("", [for f in fileset("${path.module}/Agents/JDE_Master", "**/*.py") : filemd5("${path.module}/Agents/JDE_Master/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      if [ ! -d ".venv" ]; then
        python3 -m venv .venv
      fi
      . .venv/bin/activate

      pip install --upgrade pip
      pip install -r requirements.txt
      pip install -r Agents/requirements.txt

      ACTUAL_PROJECT_NUMBER=$(gcloud projects describe ${var.project_id} --format="value(projectNumber)")

      cp Agents/JDE_Master/env.example Agents/JDE_Master/.env

      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_PROJECT[[:space:]]*=.*|GOOGLE_CLOUD_PROJECT=\"${var.project_id}\"|" Agents/JDE_Master/.env
      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_PROJECT_NUMBER[[:space:]]*=.*|GOOGLE_CLOUD_PROJECT_NUMBER=$ACTUAL_PROJECT_NUMBER|" Agents/JDE_Master/.env
      sed -i.bak "s|^[[:space:]]*GOOGLE_CLOUD_LOCATION[[:space:]]*=.*|GOOGLE_CLOUD_LOCATION=\"${var.region}\"|" Agents/JDE_Master/.env
      sed -i.bak "s|^[[:space:]]*MCP_SERVER_JDE_URL[[:space:]]*=.*|MCP_SERVER_JDE_URL=\"${var.mcp_server_jde_url}\"|" Agents/JDE_Master/.env
      sed -i.bak '/^[[:space:]]*GOOGLE_CLOUD_AUTH_ID[[:space:]]*=[[:space:]]*""/d' Agents/JDE_Master/.env

      if grep -q "localhost" Agents/JDE_Master/.env; then
          sed -i.bak 's/localhost/127.0.0.1/g' Agents/JDE_Master/.env
      fi

      rm -f Agents/JDE_Master/*.bak

      cd Agents/

      EXISTING_ID=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        "https://${var.region}-aiplatform.googleapis.com/v1beta1/projects/${var.project_id}/locations/${var.region}/reasoningEngines" \
        | python3 -c "import sys, json; data = json.load(sys.stdin); engines = [e['name'].split('/')[-1] for e in data.get('reasoningEngines', []) if e.get('displayName') == 'JDE_Master']; print(engines[0] if engines else '')" 2>/dev/null || true)

      AGENT_ARGS="JDE_Master"
      if [ -n "$EXISTING_ID" ]; then
          AGENT_ARGS="JDE_Master $EXISTING_ID"
      fi

      ./deploy_gcloud.sh $AGENT_ARGS
    EOT
  }
}
