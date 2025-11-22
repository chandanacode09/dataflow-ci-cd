# Terraform variables for bbc-news-pipeline-35

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_connection" {
  description = "GitHub connection name in Cloud Build (required - set up via Cloud Console)"
  type        = string
  default     = "ci-cd-agent"
}