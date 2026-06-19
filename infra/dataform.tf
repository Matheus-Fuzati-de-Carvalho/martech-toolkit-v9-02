resource "google_dataform_repository" "martech_v9_repo" {
  provider = google-beta
  project  = local.project_id
  region   = var.service_region
  name     = "martech-toolkit-v9-02"

  git_remote_settings {
    url                                 = var.git_repo_url
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.git_token_version.id
  }

  workspace_compilation_overrides {
    default_database = local.project_id
  }

  depends_on = [
    google_project_service.services,
    time_sleep.wait_api_propagation
  ]
}

resource "google_dataform_repository_workspace" "dev_workspace" {
  provider   = google-beta
  project    = local.project_id
  region     = var.service_region
  repository = google_dataform_repository.martech_v9_repo.name
  name       = "dev-workspace"

  depends_on = [
    google_dataform_repository.martech_v9_repo
  ]
}

data "google_project" "project" {}

locals {
  dataform_sa = "service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dataform_bigquery_editor" {
  project    = local.project_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${local.dataform_sa}"
  depends_on = [google_dataform_repository.martech_v9_repo]
}

resource "google_project_iam_member" "dataform_bigquery_job_user" {
  project    = local.project_id
  role       = "roles/bigquery.jobUser"
  member     = "serviceAccount:${local.dataform_sa}"
  depends_on = [google_dataform_repository.martech_v9_repo]
}

resource "google_project_iam_member" "dataform_metadata_viewer" {
  project    = local.project_id
  role       = "roles/bigquery.metadataViewer"
  member     = "serviceAccount:${local.dataform_sa}"
  depends_on = [google_dataform_repository.martech_v9_repo]
}

resource "google_project_iam_member" "dataform_resource_viewer" {
  project    = local.project_id
  role       = "roles/bigquery.resourceViewer"
  member     = "serviceAccount:${local.dataform_sa}"
  depends_on = [google_dataform_repository.martech_v9_repo]
}