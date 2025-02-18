# Test Harness

This folder contains a testing harness which creates a new Google Cloud project
in the specified organization with the specified billing account. The
defined sample is then applied and destroyed.

Requires `roles/billing.user` on a Billing Account, in a Google Cloud
organization.

Note: this cannot be run by accounts that do not have organizations.

Invocation from the base of the git repo, specifying the sample folder to be
tested.

    ```bash
    cd /path/to/git
    gcloud builds submit --config test/cloudbuild.yaml \
        --substitutions _TERRAFORM_SAMPLE=example_sample,\
            _BILLING_ACCOUNT=...,\
            _ORG_ID=...
    ```
