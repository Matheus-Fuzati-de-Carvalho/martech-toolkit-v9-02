terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  # ADICIONE ESTE BLOCO ABAIXO:
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.service_region
}

locals {
  project_id = var.project_id
  datasets = [
    var.silver_schema,
    var.refined_schema,
    var.quality_schema,
    var.assertion_schema
  ]
}

resource "google_project_service" "services" {
  for_each = toset([
    "dataform.googleapis.com",
    "bigquery.googleapis.com",
    "workflows.googleapis.com",
    "dataplex.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "cloudscheduler.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "time_sleep" "wait_api_propagation" {
  create_duration = "60s"
  depends_on      = [google_project_service.services]
}

resource "google_bigquery_dataset" "datasets" {
  for_each   = toset(local.datasets)
  dataset_id = each.key
  location   = var.data_location
  project    = local.project_id

  labels = {
    managed_by = "terraform"
    toolkit    = "martech-v9"
  }

  depends_on = [time_sleep.wait_api_propagation]
}