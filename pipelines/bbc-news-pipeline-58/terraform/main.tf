# Auto-generated Terraform configuration for bbc-news-pipeline-58
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
    bucket = "your-terraform-state-bucket"
    prefix = "dataflow-pipelines/bbc-news-pipeline-58"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# CI Trigger - runs on all branches
resource "google_cloudbuild_trigger" "ci_trigger" {
  name        = "bbc-news-pipeline-58-ci"
  description = "CI trigger for bbc-news-pipeline-58 - runs tests on all branches"
  project     = var.project_id
  location    = var.region

  # Use 2nd gen repository connection
  repository_event_config {
    repository = "projects/None/locations/us-central1/connections/ci-cd-agent/repositories/chandanacode09-dataflow-ci-cd"
    
    push {
      branch = ".*"  # All branches
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/bbc-news-pipeline-58/**",
  ]

  filename = "pipelines/bbc-news-pipeline-58/ci.yaml"
  
  service_account = "projects/None/serviceAccounts/@cloudbuild.gserviceaccount.com"

  tags = [
    "pipeline-ci",
    "bbc-news-pipeline-58",
    "auto-generated"
  ]
}

# CD Trigger - runs only on default branch (master/main)
resource "google_cloudbuild_trigger" "cd_trigger" {
  name        = "bbc-news-pipeline-58-cd"
  description = "CD trigger for bbc-news-pipeline-58 - deploys to Dataflow"
  project     = var.project_id
  location    = var.region

  # Use 2nd gen repository connection
  repository_event_config {
    repository = "projects/None/locations/us-central1/connections/ci-cd-agent/repositories/chandanacode09-dataflow-ci-cd"
    
    push {
      branch = "^master$"  # Change to ^main$ if your repo uses main
    }
  }

  # Only trigger if files in this pipeline changed
  included_files = [
    "pipelines/bbc-news-pipeline-58/**",
  ]

  filename = "pipelines/bbc-news-pipeline-58/cd.yaml"

  service_account = "projects/None/serviceAccounts/@cloudbuild.gserviceaccount.com"

  substitutions = {
    _PIPELINE_NAME = "bbc-news-pipeline-58"
    _DATASET_ID    = "bbc_news"
    _SOURCE_TABLE  = "bbc_news"
    _DEST_TABLE    = "processed_bbc_news"
  }

  tags = [
    "pipeline-cd",
    "bbc-news-pipeline-58",
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