terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.42.0"
    }
  }
    # backend "gcs" {
    #   bucket = "arfimm-terraform-state"
    #   prefix = "terraform/state"
    # }

}

provider "google" {
project = var.project_id

}