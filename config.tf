terraform {
  required_providers {
    google = {
      version = ">= 3.50"
      source  = "hashicorp/google"
    }

    google-beta = {
      version = ">= 3.50"
      source  = "hashicorp/google"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}