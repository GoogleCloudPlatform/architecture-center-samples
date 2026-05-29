#!/bin/bash
set -euo pipefail

PINNED_GCLOUD_VERSION="latest"
PINNED_MAKE_VERSION="4.3"
PINNED_PRE_COMMIT_VERSION="2.20.0"
PINNED_TERRAFORM_VERSION="1.6.6"
PINNED_TERRAFORM_DOCS_VERSION="0.16.0"
OS="$(uname -s)"
ARCH="$(uname -m)"

function version_ge() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

# Define the installation function
function install_gcloud() {
  if command -v gcloud &>/dev/null; then
    echo "gcloud already exists."
    return
  fi

  echo "Installing gcloud..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask google-cloud-sdk
    export PATH="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
  else
    curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
    export PATH="$HOME/google-cloud-sdk/bin:$PATH"
  fi

  if command -v gcloud &>/dev/null; then
    echo "gcloud installed successfully: $(gcloud --version | head -n 1)"
  else
    echo "gcloud installation failed."
    exit 1
  fi
}


function install_make() {
  echo "Installing make $PINNED_MAKE_VERSION..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install make
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y make
  else
    echo " No supported package manager for make."
    exit 1
  fi
}

# function install_pre_commit() {
#   echo "Installing pre-commit $PINNED_PRE_COMMIT_VERSION..."
#   pip3 install --upgrade "pre-commit==${PINNED_PRE_COMMIT_VERSION}"
# }

function install_terraform() {
  echo "Installing terraform $PINNED_TERRAFORM_VERSION..."
  if [[ "$OS" == "Darwin" ]]; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  else
    curl -sSLo terraform.zip \
      "https://releases.hashicorp.com/terraform/${PINNED_TERRAFORM_VERSION}/terraform_${PINNED_TERRAFORM_VERSION}_linux_amd64.zip"
    unzip -o terraform.zip -d /usr/local/bin
    rm -f terraform.zip
  fi
}

function install_terraform_docs() {
  echo "Installing terraform-docs $PINNED_TERRAFORM_DOCS_VERSION..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install terraform-docs
  else
    curl -sSLo terraform-docs.tar.gz \
      "https://github.com/terraform-docs/terraform-docs/releases/download/v${PINNED_TERRAFORM_DOCS_VERSION}/terraform-docs-v${PINNED_TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz"
    tar -xzf terraform-docs.tar.gz
    sudo mv terraform-docs /usr/local/bin/
    rm -f terraform-docs.tar.gz
  fi
}

function verify_and_install() {

  install_gcloud

  # # pre-commit
  # if command -v pre-commit &>/dev/null; then
  #   INSTALLED_VERSION=$(pre-commit --version | awk '{print $3}')
  #   if ! version_ge "$INSTALLED_VERSION" "$PINNED_PRE_COMMIT_VERSION"; then
  #     install_pre_commit
  #   fi
  # else
  #   install_pre_commit
  # fi

# Check Terraform
if command -v terraform &>/dev/null; then
  INSTALLED_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | awk '{print $2}' | sed 's/v//')
  if [[ -z "$INSTALLED_VERSION" ]] || ! version_ge "$INSTALLED_VERSION" "$PINNED_TERRAFORM_VERSION"; then
    echo "Installing/Updating Terraform..."
    install_terraform
  else
    echo "✔ Terraform already installed: $INSTALLED_VERSION"
  fi
else
  echo "Terraform not found. Installing..."
  install_terraform
fi

# Check terraform-docs
if command -v terraform-docs &>/dev/null; then
  INSTALLED_VERSION=$(terraform-docs --version 2>/dev/null | awk '{print $3}' | sed 's/v//')
  if [[ -z "$INSTALLED_VERSION" ]] || ! version_ge "$INSTALLED_VERSION" "$PINNED_TERRAFORM_DOCS_VERSION"; then
    echo "Installing/Updating terraform-docs..."
    install_terraform_docs
  else
    echo "✔ terraform-docs already installed: $INSTALLED_VERSION"
  fi
else
  echo "terraform-docs not found. Installing..."
  install_terraform_docs
fi


  echo "All tools installed and configured."
}

verify_and_install
