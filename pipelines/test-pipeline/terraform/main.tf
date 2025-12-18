# Auto-generated Terraform configuration for test-pipeline
# This creates Cloud Build triggers for CI/CD

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend configuration is passed via CLI during terraform init
  # Example: terraform init -backend-config=bucket=my-bucket -backend-config=prefix=pipelines/my-pipeline
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# CI Trigger - runs on Pull Requests
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "test-pipeline-ci"
  description = "CI trigger for test-pipeline - runs tests on PRs"
  project     = var.project_id
  location    = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    pull_request {
      branch = "^(main|master)$"
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/test-pipeline/**",
  ]

  filename = "pipelines/test-pipeline/ci.yaml"

  service_account = "projects/${var.project_id}/serviceAccounts/ci-cd-pipeline-sa@${var.project_id}.iam.gserviceaccount.com"

  tags = [
    "pipeline-ci",
    "test-pipeline",
    "auto-generated",
    "terraform-managed"
  ]
}

# CD Trigger - runs on push to main/master branch
resource "google_cloudbuild_trigger" "cd_trigger" {
  name        = "test-pipeline-cd"
  description = "CD trigger for test-pipeline - deploys to Dataflow"
  project     = var.project_id
  location    = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "^(main|master)$"
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/test-pipeline/**",
  ]

  filename = "pipelines/test-pipeline/cd.yaml"

  substitutions = {
    _PIPELINE_NAME = "test-pipeline"
    _DATASET_ID    = "test_dataset"
    _SOURCE_TABLE  = "source_table"
    _DEST_TABLE    = "dest_table"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/ci-cd-pipeline-sa@${var.project_id}.iam.gserviceaccount.com"

  tags = [
    "pipeline-cd",
    "test-pipeline",
    "auto-generated",
    "terraform-managed"
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