output "project_id" {
  value       = local.project_id
  description = "ID do projeto GCP onde os recursos foram aplicados"
}

output "dataform_repository_id" {
  value       = google_dataform_repository.martech_v9_repo.id
  description = "ID completo do repositorio Dataform provisionado"
}

output "workflow_id" {
  value       = google_workflows_workflow.dataform_orchestrator.id
  description = "ID unico do Cloud Workflow orquestrador"
}

output "workflow_name" {
  value       = google_workflows_workflow.dataform_orchestrator.name
  description = "Nome logico do Workflow para invocacao via gcloud CLI"
}

output "workflow_sa_email" {
  value       = google_service_account.workflow_sa.email
  description = "E-mail da conta de servico vinculada ao Workflow"
}

output "secret_id" {
  value       = google_secret_manager_secret.git_token_secret.id
  description = "ID do recurso armazenado no Secret Manager"
}

output "notification_topic" {
  value       = google_pubsub_topic.pipeline_alerts.id
  description = "URI do topico Pub/Sub para roteamento de falhas"
}

output "dashboard_url_hint" {
  value       = "https://console.cloud.google.com/dataplex/lakes/${google_dataplex_lake.martech_lake.name}?project=${local.project_id}"
  description = "Link direto para o Lake no Dataplex para visualizacao da linhagem"
}