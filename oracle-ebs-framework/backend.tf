terraform {
  required_version = "~> 1.6"

  backend "gcs" {
    bucket = "dummy-bucket-name" # overridden by makefile
    prefix = "dummy-prefix"      # overridden by makefile
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.43.0, < 6.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "< 8.0.0"
    }
  }
}
