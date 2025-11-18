# Auto-generated Terraform configuration for austin-311-pipeline-1
# This creates Cloud Build triggers for CI/CD

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "demo-terraform-state"
    prefix = "dataflow-pipelines/austin-311-pipeline-1"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# CI Trigger - runs on all branches
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "austin-311-pipeline-1-ci"
  description = "CI trigger for austin-311-pipeline-1 - runs tests on all branches"
  project     = var.project_id

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^.*$"  # All branches
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/austin-311-pipeline-1/**",
  ]

  filename = "pipelines/austin-311-pipeline-1/ci.yaml"

  tags = [
    "pipeline-ci",
    "austin-311-pipeline-1",
    "auto-generated"
  ]
}

# CD Trigger - runs only on default branch (master/main)
resource "google_cloudbuild_trigger" "cd_trigger" {
  name        = "austin-311-pipeline-1-cd"
  description = "CD trigger for austin-311-pipeline-1 - deploys to Dataflow"
  project     = var.project_id

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^master$"  # Change to ^main$ if your repo uses main
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/austin-311-pipeline-1/**",
  ]

  filename = "pipelines/austin-311-pipeline-1/cd.yaml"

  substitutions = {
    _PIPELINE_NAME = "austin-311-pipeline-1"
    _DATASET_ID    = "austin_311"
    _SOURCE_TABLE  = "311_service_requests"
    _DEST_TABLE    = "processed_311_requests"
  }

  tags = [
    "pipeline-cd",
    "austin-311-pipeline-1",
    "auto-generated"
  ]
}

# Outputs
output "ci_trigger_id" {
  description = "ID of the CI trigger"
  value       = google_cloudbuild_trigger.ci_trigger.id
}

output "cd_trigger_id" {
  description = "ID of the CD trigger"
  value       = google_cloudbuild_trigger.cd_trigger.id
}

output "ci_trigger_name" {
  description = "Name of the CI trigger"
  value       = google_cloudbuild_trigger.ci_trigger.name
}

output "cd_trigger_name" {
  description = "Name of the CD trigger"
  value       = google_cloudbuild_trigger.cd_trigger.name
}