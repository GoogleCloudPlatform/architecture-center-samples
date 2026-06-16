# Multi-Tenant Agentic AI Architecture (Terraform)

This repository provides the **Well-Architected Framework** for deploying a secure, multi-tenant Agentic AI platform on Google Cloud. It uses a **Hub-and-Spoke** model to provide centralized governance while maintaining "Hard Isolation" between business units (e.g., HR, Marketing, Finance).

---

## 1. Architecture Overview
The deployment automates a **"Double-Lock"** security strategy:

* **The Outer Wall (VPC Service Controls):** A single Macro-Perimeter wraps the Hub and all Spoke projects to prevent data exfiltration.
* **The Inner Handcuffs (Principal Access Boundaries):** Every tenant agent is assigned a unique Service Account restricted cryptographically to its own project.
* **The Smart Gate (Cloud Armor):** A flexible Edge Security policy supporting both **Public-Facing** and **Internal-Only** modes.

---

## 2. Prerequisites
Before you begin, ensure you have the following:

* **Google Cloud Organization:** Required for PABs and VPC-SC.
* **Permissions:** `roles/resourcemanager.projectCreator` and `roles/accesscontextmanager.policyAdmin`.
* **Information Gathering:** Collect these IDs:
    * **Organization ID** (12-digit number)
    * **Billing Account ID**
    * **Folder ID** (Where spoke projects will be created)

---

## 3. Self-Deployment Instructions

### **Step A: Clone and Initialize**
```bash
git clone <your-repo-url>
cd terraform-google-multi-tenant-agentic-ai
terraform init
```

### Step B: Configure Variables
Copy the example variable file and fill in your specific environment details:

```bash
cp terraform.tfvars.example terraform.tfvars
```

CRUCIAL: You must provide the Project Numbers (Numerical IDs) for the Hub and Spokes. PAB and VPC-SC policies do not support String IDs.

### Step C: Choose Your Connectivity Mode
In terraform.tfvars, configure trusted_corporate_ip_ranges:

For Public Access: Leave as [].

For Internal-Only: Add your VPN/Office IP ranges (e.g., ["35.2.3.4/32"]).

```bash
terraform plan   # Review the 20+ resources being created
terraform apply  # Confirm with 'yes'
```

##  🚀 4. Step-by-Step Deployment Guide

### Phase 1: Environment Preparation
Enable Required APIs:

```bash
gcloud services enable cloudresourcemanager.googleapis.com \
                       serviceusage.googleapis.com \
                       accesscontextmanager.googleapis.com \
                       billingbudgets.googleapis.com
```
Create an Access Policy (if one doesn't exist):

```bash

gcloud access-context-manager policies create \
  --organization=YOUR_ORG_ID --title="Org Policy"
```

### Phase 2: Configuration
Edit terraform.tfvars: Use vi or nano to input your specific IDs.

Find Project Numbers:

```bash
gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)"
```

### Phase 3: Execution
Plan the Deployment:

```bash
terraform plan -out=platform.tfplan
```
Apply the Changes:
```bash

terraform apply "platform.tfplan"
```
### Phase 4: Post-Deployment Verification
Verify Outer Wall (VPC-SC):

```bash

gcloud access-context-manager perimeters list --policy=YOUR_ACCESS_POLICY_ID
```

Verify Inner Handcuffs (PAB):

* **Navigate to IAM & Admin > Principal Access Boundaries in the Console.

* **Confirm the mkt-isolation-policy is correctly bound to the Marketing Agent's Service Account.

---

## 5. Security & Compliance Notes
Least Privilege: Manually bind the custom roles (GeminiAgentBuilder, etc.) to your human users/groups in the main.tf.

* **State Management: For production, move your terraform.tfstate to a secure GCS bucket with Object Versioning enabled.

* **Secrets: All API keys or sensitive strings should be moved to Google Cloud Secret Manager; do not hardcode them in .tfvars.

---

## 6. Impact & Reporting (For Stakeholders)
* **Revenue Attribution: Project IDs are exported for mapping to Cloud Billing.

* **Security Audit: Perimeter names and PAB bindings are exported for compliance reviews.

---

This section provides the custom IAM role definitions and implementation strategy to help you automate and enforce this identity-locked posture at scale, these custom roles are dynamically instantiated and bound using the platform's declarative infrastructure-as-code.
Custom Role Definitions
Here are the JSON definitions for the four custom IAM roles.
1. GeminiConsoleViewer (Project Level)

{
  "title": "Gemini Console Viewer",
  "description": "Provides read-only access to monitor agent health, logs, and service metrics via the GCP Console and CLI.",
  "stage": "GA",
  "includedPermissions": [
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "serviceusage.services.list",
    "run.services.list",
    "run.services.get",
    "run.locations.list",
    "run.revisions.list",
    "logging.logEntries.list",
    "monitoring.dashboards.list",
    "monitoring.timeSeries.list"
  ]
}
3. GeminiDataSteward (Project Level)
{
  "title": "Gemini Data Steward",
  "description": "Allows management of the data sources for a specific tenant's RAG.",
  "stage": "GA",
  "includedPermissions": [
    "bigquery.datasets.get",
    "bigquery.tables.list",
    "bigquery.tables.getData",
    "storage.buckets.list",
    "storage.objects.list"
  ]
}
4. GeminiAgentBuilder (Resource Level)
{
  "title": "Gemini Agent Builder",
  "description": "Allows for the creation and configuration of an agent within a specific tenant.",
  "stage": "GA",
  "includedPermissions": [
    "run.services.create",
    "run.services.get",
    "run.services.update",
    "run.services.delete"
  ]
}
5. GeminiAppUser (Resource Level)
{
  "title": "Gemini App User",
  "description": "Allows end-users to interact with a specific agent.",
  "stage": "GA",
  "includedPermissions": [
    "run.routes.invoke"
  ]
}

Implementation strategy: Resource-level binding
To ensure hard isolation between tenants (e.g., to prevent an agent from Tenant 1 from accessing data in Tenant 2), the GeminiAppBuilder and GeminiAppUser roles must be applied using IAM Resource-Level Bindings. Instead of granting the role on the entire project, you bind the user or group to the specific Cloud Run service:

projects/{PROJECT_ID}/locations/{REGION}/services/{SERVICE_ID}

