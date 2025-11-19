# Auto-generated Terraform configuration for bbc-news-pipeline-40
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
  #   prefix = "triggers/bbc-news-pipeline-40"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Import the existing GitHub connection that was set up via Cloud Console
# This connection should already exist in Cloud Build (2nd gen)
data "google_cloudbuildv2_connection" "github" {
  name     = var.github_connection
  location = var.region
  project  = var.project_id
}

# Import the existing GitHub repository that was linked via Cloud Console
# This repository should already exist in Cloud Build (2nd gen)
data "google_cloudbuildv2_repository" "repo" {
  name     = "${var.github_owner}-${var.github_repo}"
  location = var.region
  parent   = data.google_cloudbuildv2_connection.github.id
}

# CI Trigger - runs on all branches
# Note: Requires GitHub repository to be connected in Cloud Build first
# Setup: https://console.cloud.google.com/cloud-build/triggers/connect
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "bbc-news-pipeline-40-ci"
  description = "CI trigger for bbc-news-pipeline-40 - runs tests on all branches"
  project     = var.project_id
  location    = var.region

  repository_event_config {
    repository = data.google_cloudbuildv2_repository.repo.id

    push {
      branch = ".*"
    }
  }

  filename = "pipelines/bbc-news-pipeline-40/ci.yaml"
}

# CD Trigger - runs only on default branch (master/main)
# Note: Requires GitHub repository to be connected in Cloud Build first
resource "google_cloudbuild_trigger" "cd_trigger" {
  name        = "bbc-news-pipeline-40-cd"
  description = "CD trigger for bbc-news-pipeline-40 - deploys to Dataflow"
  project     = var.project_id
  location    = var.region

  repository_event_config {
    repository = data.google_cloudbuildv2_repository.repo.id

    push {
      branch = "^master$"
    }
  }

  filename = "pipelines/bbc-news-pipeline-40/cd.yaml"

  substitutions = {
    _PIPELINE_NAME = "bbc-news-pipeline-40"
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