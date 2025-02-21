# Architecture Center Samples

Terraform samples for [Cloud Architecture
Center](https://cloud.google.com/architecture/)


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
      terraform destory
      ```

# Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for more information how to get started.

Please note that this project is released with a Contributor Code of Conduct.
By participating in this project you agree to abide by its terms. See [Code of
Conduct](CODE_OF_CONDUCT.md) for more information.

# License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
