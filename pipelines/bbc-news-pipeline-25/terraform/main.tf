# Auto-generated Terraform configuration for bbc-news-pipeline-25
# This creates Cloud Build triggers for CI/CD

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Using local state for simplicity
  # For production, consider using a remote backend like GCS
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "triggers/bbc-news-pipeline-25"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Data source to look up the repository
data "google_cloudbuildv2_repository" "repo" {
  project   = var.project_id
  location  = var.region
  name      = "${var.github_owner}-${var.github_repo}"
  parent_connection = var.github_connection
}

# CI Trigger - runs on all branches
# Note: Requires GitHub repository to be connected in Cloud Build first
# Setup: https://console.cloud.google.com/cloud-build/triggers/connect
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "bbc-news-pipeline-25-ci"
  description = "CI trigger for bbc-news-pipeline-25 - runs tests on all branches"
  project     = var.project_id
  location    = var.region

  repository_event_config {
    repository = data.google_cloudbuildv2_repository.repo.id

    push {
      branch = ".*"
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/bbc-news-pipeline-25/**"
  ]

  filename = "pipelines/bbc-news-pipeline-25/ci.yaml"
}

# CD Trigger - runs only on default branch (master/main)
# Note: Requires GitHub repository to be connected in Cloud Build first
resource "google_cloudbuild_trigger" "cd_trigger" {
  name        = "bbc-news-pipeline-25-cd"
  description = "CD trigger for bbc-news-pipeline-25 - deploys to Dataflow"
  project     = var.project_id
  location    = var.region

  repository_event_config {
    repository = data.google_cloudbuildv2_repository.repo.id

    push {
      branch = "^master$"
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/bbc-news-pipeline-25/**"
  ]

  filename = "pipelines/bbc-news-pipeline-25/cd.yaml"

  substitutions = {
    _PIPELINE_NAME = "bbc-news-pipeline-25"
    _DATASET_ID    = "bbc_news"
    _SOURCE_TABLE  = "bbc_news"
    _DEST_TABLE    = "processed_bbc_news"
  }
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