# Architecture Center Samples

This repo contains supporting code artifacts for [Cloud Architecture
Center](https://cloud.google.com/architecture/) references.

> [!NOTE]
> The code in this repo is not intended for production use.

# Running samples

Each folder in this repo holds a self-contained sample, implemented in
[Terraform](https://www.terraform.io/).

## Setup

We recommend using [Cloud
Shell](https://cloud.google.com/docs/terraform/install-configure-terraform#cloud-shell),
which comes pre-configured with Terraform and automatic authentication.

To run a sample:

 1. Clone this repo:

      ```bash
      git clone https://github.com/GoogleCloudPlatform/architecture-center-samples
      ```

 1. Go to the sample directory:

      ```bash
      cd architecture-center-samples/[SAMPLE]/
      ```

 1. Enable any required APIs as defined in the sample's README.
 1. Initialize and view the planned deployed resources:

      ```bash
      terraform init
      terraform plan
      ```

1. Apply the configuration, entering `yes` at the prompt:

      ```bash
      terraform apply
      ```

> [!NOTE]
> While every effort is taken to ensure the Terraform deploys first time,
> some resources may take time to become ready for additional configuration.
> If the first `terraform apply` fails due to resources not existing, wait a
> few minutes and try again.

Learn more about [Terraform
commands](https://cloud.google.com/docs/terraform/basic-commands).

## Cleanup

 * Remove the resources that were created, entering `yes` at the prompt:

      ```bash
      terraform destroy
      ```

# Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for more information how to get started.

Please note that this project is released with a Contributor Code of Conduct.
By participating in this project you agree to abide by its terms. See [Code of
Conduct](CODE_OF_CONDUCT.md) for more information.

# License

Apache 2.0 - See [LICENSE](LICENSE) for more information.

This section provides the custom IAM role definitions and implementation strategy to help you automate and enforce this identity-locked posture at scale, these custom roles are dynamically instantiated and bound using the platform's declarative infrastructure-as-code.
Custom Role Definitions

Here are the JSON definitions for the four custom IAM roles.

1. GeminiConsoleViewer (Project Level)
```json
{
  "title": "Gemini Console Viewer",
  "description": "Provides read-only access to monitor agent health, logs, and service metrics via the GCP Console and CLI.",
  "stage": "GA",
  "includedPermissions": [
    "resourcemanager.projects.get",
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
```

2. GeminiDataSteward (Project Level)
```json
{
  "title": "Gemini Data Steward",
  "description": "Allows management of the data sources for a specific tenant's RAG.",
  "stage": "GA",
  "includedPermissions": [
    "bigquery.datasets.get",
    "bigquery.tables.list",
    "bigquery.tables.getData",
    "storage.buckets.list",
    "storage.objects.list",
    "storage.objects.get"
  ]
}
```

3. GeminiAgentBuilder (Resource Level)
```json
{
  "title": "Gemini Agent Builder",
  "description": "Allows for the creation and configuration of an agent within a specific tenant.",
  "stage": "GA",
  "includedPermissions": [
    "run.services.create",
    "run.services.get",
    "run.services.list",
    "run.services.update",
    "run.services.delete",
    "run.configurations.get",
    "run.revisions.list"
  ]
}
```

4. GeminiAppUser (Resource Level)
```json
{
  "title": "Gemini App User",
  "description": "Allows end-users to interact with a specific agent.",
  "stage": "GA",
  "includedPermissions": [
    "run.routes.invoke"
  ]
}
```
Implementation strategy: Resource-level binding
To ensure hard isolation between tenants (e.g., to prevent an agent from Tenant 1 from accessing data in Tenant 2), the GeminiAppBuilder and GeminiAppUser roles must be applied using IAM Resource-Level Bindings. Instead of granting the role on the entire project, you bind the user or group to the specific Cloud Run service:Collapse comment

```projects/{PROJECT_ID}/locations/{REGION}/services/{SERVICE_ID}```
