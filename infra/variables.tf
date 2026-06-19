variable "project_id" {
  type        = string
  description = "ID do projeto alvo no Google Cloud Platform configurado via pipeline"
}

variable "project_number" {
  type        = string
  description = "Numero unico identificador do projeto GCP fornecido pela esteira"
}

variable "service_region" {
  type        = string
  description = "Regiao para a execucao de servicos serverless regionais"
  default     = "us-central1"
}

variable "data_location" {
  type        = string
  description = "Localizacao geografica para armazenamento de dados no BigQuery"
  default     = "US"
}

variable "git_token" {
  type        = string
  description = "GitHub Personal Access Token para autenticacao do Dataform"
  sensitive   = true
}

variable "git_repo_url" {
  type        = string
  description = "URL do de repositorio remoto Git contendo o codigo Dataform"
  default     = "https://github.com/Matheus-Fuzati-de-Carvalho/martech-toolkit-v9-02.git"
}

variable "silver_schema" {
  type        = string
  description = "Nome do dataset para a camada Silver"
  default     = "TRUSTED"
}

variable "refined_schema" {
  type        = string
  description = "Nome do dataset para a camada Gold"
  default     = "REFINED"
}

variable "quality_schema" {
  type        = string
  description = "Nome do dataset para metadados e logs de qualidade"
  default     = "QUALITY"
}

variable "assertion_schema" {
  type        = string
  description = "Nome do dataset para isolamento de falhas de qualidade"
  default     = "QUALITY_ASSERTIONS"
}

variable "raw_ga4_dataset" {
  type        = string
  description = "Dataset contendo os eventos brutos de origem do GA4"
  default     = "RAW_SRC_GA4_EXTERNAL"
}

variable "raw_ads_dataset" {
  type        = string
  description = "Dataset contendo os dados brutos de origem de Ads"
  default     = "RAW_SRC_ADS_EXTERNAL"
}

variable "raw_ads_table" {
  type        = string
  description = "Nome da tabela de origem de Ads dentro do dataset raw"
  default     = "ad_CampaignBasicStats_987654321"
}

variable "tab_ft_ga4" {
  type        = string
  description = "Nome da tabela final consolidada de eventos GA4"
  default     = "FT_SIL_GA4_EVENTS"
}

variable "tab_ft_ads" {
  type        = string
  description = "Nome da tabela final consolidada de performance de Ads"
  default     = "FT_SIL_ADS_PERFORMANCE"
}

variable "tab_dm_mkt" {
  type        = string
  description = "Nome do Data Mart final de performance de marketing"
  default     = "DM_GOLD_MARKETING_PERFORMANCE"
}

variable "tab_dm_retail" {
  type        = string
  description = "Nome do cubo final de Retail Media"
  default     = "DM_GOLD_RETAIL_CUBE"
}

variable "flavor" {
  type        = string
  description = "Sabor/Escopo de execucao do pipeline"
  default     = "full"
}

variable "lookback_days" {
  type        = number
  description = "Janela de dias para processamento incremental"
  default     = 3
}

variable "cron_schedule" {
  type        = string
  description = "Expressao cron para agendamento diario"
  default     = "0 8 * * *"
}

variable "notification_email" {
  type        = string
  description = "E-mail de destino para alertas de falha"
  default     = "alerta@exemplo.com"
}

variable "email_user" {
  type        = string
  description = "Usuario do servidor SMTP remetente"
  default     = "alerta@exemplo.com"
}

variable "email_password" {
  type        = string
  description = "Senha ou App Password do servidor SMTP remetente"
  default     = "123456789"
  sensitive   = true
}