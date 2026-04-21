# MCP Toolkit EBS Deployment Guide

This guide provides the necessary commands to deploy the MCP Toolkit for EBS to Google Cloud Run, integrating with Secret Manager for configuration.

## Prerequisites

Before running these commands, ensure you have set the appropriate variables for your environment:

- `<PROJECT_ID>`: Your Google Cloud Project ID.
- `<SERVICE_ACCOUNT_EMAIL>`: The full email of your service account (e.g., `service-account@project-id.iam.gserviceaccount.com`).
- `<SERVICE_ACCOUNT_NAME>`: The name of your service account (e.g., `service-account`).
- `<SERVICE_NAME>`: The name for your Cloud Run service (e.g., `mcp-oracle-ebs` or `ebs-google-sql`).
- `<SECRET_NAME>`: The name of the secret in Secret Manager (e.g., `ebs-oracle-tools`).
- `<IMAGE_URL>`: The container image URL (e.g., `us-central1-docker.pkg.dev/project-id/repo/image:latest`).
- `<REGION>`: The Google Cloud region to deploy to (e.g., `us-central1`).
- `<VPC_NAME>`: The name of your VPC network.
- `<SUBNET_NAME>`: The name of your subnet.

## Deployment Steps

### 1. Grant IAM Permissions

Add the Secret Accessor role to the service account so it can read secrets from Secret Manager:

```bash
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member serviceAccount:<SERVICE_ACCOUNT_EMAIL> \
    --role roles/secretmanager.secretAccessor

export GOOGLE_CLOUD_SERVICE_ACCOUNT="<SERVICE_ACCOUNT_EMAIL>"
```

### 2. Check Existing Service Status (Optional)

You can check the status of an existing deployment to get its URL:

```bash
gcloud run services describe <SERVICE_NAME> --format 'value(status.url)'
```

### 3. Setup Secrets

Create the `tools.yaml` file locally (if you haven't already):

```bash
# create tools.yaml
```

Upload the `tools.yaml` file to Secret Manager:

```bash
gcloud secrets create <SECRET_NAME> --data-file=tools.yaml
# To add a new version later:
# gcloud secrets versions add <SECRET_NAME> --data-file=tools.yaml
```

### 4. Deploy to Cloud Run

Export your container image URL:

```bash
export IMAGE=<IMAGE_URL>
```

Deploy the service to Cloud Run:

```bash
gcloud run deploy <SERVICE_NAME> \
    --image $IMAGE \
    --service-account <SERVICE_ACCOUNT_NAME> \
    --region <REGION> \
    --set-secrets "/app/tools.yaml=<SECRET_NAME>:latest" \
    --args="--tools-file=/app/tools.yaml","--address=0.0.0.0","--port=8080" \
    --network <VPC_NAME> \
    --subnet <SUBNET_NAME> \
    --allow-unauthenticated
```

### 5. Access the Service

Once deployed, you can access the service via the provided Cloud Run URL:

```bash
# Example URL: https://<CLOUDRUN_URL>
```
