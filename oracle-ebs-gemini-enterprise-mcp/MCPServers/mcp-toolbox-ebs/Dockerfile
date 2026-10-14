# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest

# Bake the 21 parameterized Oracle EBS MCP tool definitions into the image.
# Runtime credentials (${EBS_DB_CONNECTION_STRING}, ${EBS_DB_USER}, ${EBS_DB_PASSWORD})
# are injected at runtime via Google Cloud Secret Manager environment variables
# or mounted via /app/tools.yaml.
COPY tools.yaml /app/tools.yaml
