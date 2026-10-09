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

resource "null_resource" "oracle_peoplesoft_gemini_enterprise_framework" {
  triggers = {
    deploy_script_hash = filemd5("${path.module}/Agents/deploy_gcloud.sh")
    env_template_hash  = filemd5("${path.module}/Agents/PSFT_Master/env.example")
    agent_code_hash    = sha256(join("", [for f in fileset("${path.module}/Agents/PSFT_Master", "**/*.py") : filemd5("${path.module}/Agents/PSFT_Master/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      if [ ! -d ".venv" ]; then
        python3 -m venv .venv
      fi
      . .venv/bin/activate
      
      pip install -r requirements.txt
      pip install -r Agents/requirements.txt

      ACTUAL_PROJECT_NUMBER=$(gcloud projects describe ${var.project_id} --format="value(projectNumber)")

      cat <<EOF > Agents/PSFT_Master/.env
GOOGLE_CLOUD_PROJECT="${var.project_id}"
GOOGLE_CLOUD_PROJECT_NUMBER=$ACTUAL_PROJECT_NUMBER
GOOGLE_CLOUD_LOCATION="${var.region}"
MCP_SERVER_PSFT_URL="${var.mcp_server_psft_url}"
MCP_SERVER_SQL_URL="${var.mcp_server_psft_url}"
EOF

      cd Agents/

      EXISTING_ID=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        "https://${var.region}-aiplatform.googleapis.com/v1beta1/projects/${var.project_id}/locations/${var.region}/reasoningEngines" \
        | python3 -c "import sys, json; data = json.load(sys.stdin); engines = [e['name'].split('/')[-1] for e in data.get('reasoningEngines', []) if e.get('displayName') == 'PSFT_Master']; print(engines[0] if engines else '')" 2>/dev/null || true)

      AGENT_ARGS="PSFT_Master"
      if [ -n "$EXISTING_ID" ]; then
          AGENT_ARGS="PSFT_Master $EXISTING_ID"
      fi

      ./deploy_gcloud.sh $AGENT_ARGS
    EOT
  }
}
