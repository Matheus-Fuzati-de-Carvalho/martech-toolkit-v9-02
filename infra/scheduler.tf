resource "google_cloud_scheduler_job" "workflow_trigger" {
  name             = "martech-v9-daily-schedule"
  description      = "Trigger fixo para o orquestrador Dataform v9"
  schedule         = var.cron_schedule
  time_zone        = "America/Sao_Paulo"
  attempt_deadline = "320s"
  project          = local.project_id
  region           = var.service_region

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${local.project_id}/locations/${var.service_region}/workflows/${google_workflows_workflow.dataform_orchestrator.name}/executions"
    
    oauth_token {
      service_account_email = google_service_account.workflow_sa.email
    }
    
    body = base64encode("{}")
  }

  depends_on = [
    google_workflows_workflow.dataform_orchestrator
  ]
}