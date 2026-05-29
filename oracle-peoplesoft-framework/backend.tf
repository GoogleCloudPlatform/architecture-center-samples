terraform {
  required_version = "~> 1.6"

  backend "gcs" {
    bucket = "dummy-bucket-name" # overridden by makefile
    prefix = "dummy-prefix"      # overridden by makefile
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.37.0, < 8.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.37.0, < 8.0.0"
    }
  }
}
