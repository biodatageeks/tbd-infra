terraform {
  backend "gcs" {
     bucket  = "tbd-group-998-admin"
     prefix  = "terraform/state"
  }
  required_providers {
    google = {
      version = ">= 3.50"
      source  = "hashicorp/google"
    }

    google-beta = {
      version = ">= 3.50"
      source  = "hashicorp/google"
    }
    helm = {
      version = ">=2.0.2"
      source = "hashicorp/helm"
    }
  }
}
