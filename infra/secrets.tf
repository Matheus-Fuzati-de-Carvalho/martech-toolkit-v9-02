resource "google_secret_manager_secret" "git_token_secret" {
  secret_id = "martech-v9-git-token"
  project   = local.project_id

  replication {
    auto {}
  }

  depends_on = [time_sleep.wait_api_propagation]
}

resource "google_secret_manager_secret_version" "git_token_version" {
  secret      = google_secret_manager_secret.git_token_secret.id
  secret_data = var.git_token
}

resource "google_secret_manager_secret_iam_member" "dataform_secret_accessor" {
  project   = local.project_id
  secret_id = google_secret_manager_secret.git_token_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.dataform_sa}"

  depends_on = [google_dataform_repository.martech_v9_repo]
}