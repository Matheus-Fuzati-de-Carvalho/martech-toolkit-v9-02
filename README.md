# Martech Toolkit v9 - Data Platform Blueprint

Este repositório contém o blueprint de arquitetura para implantação automatizada de uma plataforma de dados moderna voltada para Martech no Google Cloud Platform (GCP).

---

## 🎯 1. Objetivo do Projeto

* **Deploy em Minutos:** Provisionar um ecossistema analítico ponta a ponta (Infraestrutura + Modelagem + Orquestração + Alertas) em menos de 5 minutos.
* **Zero Ops Manual:** Eliminar cliques no console do GCP; tudo é governado via GitOps.
* **Segurança Avançada:** Eliminar 100% o uso de Service Account Keys (arquivos JSON) utilizando autenticação federada efêmera (WIF).

---

## 🏗️ 2. Processamento de Dados (Camadas Medalhão e Qualidade)

O projeto organiza e transforma os dados analíticos dentro do BigQuery utilizando as seguintes camadas estruturadas no Dataform:

* **TRUSTED (Silver):** * Consome os dados brutos da camada operacional (`RAW`).
* Aplica limpeza de strings, padronização de caminhos (UTMs), tipagem estrita e remoção de duplicidades.


* **REFINED (Gold):**
* Consolida tabelas agregadas prontas para ferramentas de BI (Looker Studio, PowerBI).
* Entrega nativamente dois Data Marts: Performance de Marketing Omnichannel e Cubo de Retail Media.


* **QUALITY & QUALITY_ASSERTIONS:**
* **Garantia de Integridade:** Valida chaves primárias nulas, valores de receita negativos ou IDs de campanhas inválidos antes da carga final.
* **Isolamento de Falhas:** Registros que violam as regras de negócio são isolados no dataset de `QUALITY_ASSERTIONS` para auditoria, impedindo a corrupção dos painéis de produção.



---

## 📊 3. Arquitetura de Componentes

Toda a engrenagem é automatizada utilizando serviços nativos e serverless do GCP:

* **GitHub Actions:** Motor de CI/CD que dispara a convergência a cada `git push`.
* **Workload Identity Federation (WIF):** Troca chaves OIDC do GitHub por tokens temporários do GCP.
* **Terraform:** Provisiona os datasets do BigQuery, Buckets, tópicos do Pub/Sub e o orquestrador.
* **Dataform:** Compila o código SQLX, gerencia as dependências das tabelas e executa as queries no BigQuery.
* **Cloud Workflows:** Orquestrador serverless de baixo custo que aciona a API do Dataform e monitora a execução.
* **Pub/Sub & Cloud Functions:** Sistema de mensageria que captura falhas do pipeline e envia alertas de e-mail automatizados via SMTP.

---

## 📋 4. Premissas e Pré-requisitos de Dados (Camada RAW)

Para que o pipeline funcione, a esteira assume que o cliente já possui ingestões ativas (via BigQuery Data Transfer Service ou parceiros) despejando os dados brutos nos seguintes caminhos de origem dentro do mesmo projeto:

* **Dataset `RAW_SRC_GA4_EXTERNAL`:** Deve conter as tabelas nativas de exportação diária de eventos do Google Analytics 4 (`events_*`).
* **Dataset `RAW_SRC_ADS_EXTERNAL`:** Deve conter a tabela estruturada de performance de campanhas do Google Ads (ex: `ad_CampaignBasicStats_*`).

---

## 🔒 5. Requisitos para a TI (O que solicitar via Chamado)

Abra um chamado para a TI do cliente solicitando a liberação da infraestrutura base de segurança nos ambientes de **Desenvolvimento** (`dev`) e **Homologação** (`hom`).

### A. APIs a serem Ativadas

* `serviceusage.googleapis.com` / `cloudresourcemanager.googleapis.com` / `iam.googleapis.com` / `iamcredentials.googleapis.com`
* `bigquery.googleapis.com` / `dataform.googleapis.com` / `workflows.googleapis.com` / `dataplex.googleapis.com`
* `pubsub.googleapis.com` / `secretmanager.googleapis.com` / `cloudfunctions.googleapis.com`
* `cloudbuild.googleapis.com` / `artifactregistry.googleapis.com` / `run.googleapis.com` / `eventarc.googleapis.com` / `cloudscheduler.googleapis.com`

### B. Conta de Serviço e Permissões IAM

* **ID da SA:** `gh-actions-sa@<PROJECT_ID>.iam.gserviceaccount.com`
* **Roles obrigatórias no escopo do projeto:**
* `roles/editor` (Criação de recursos analíticos e serverless)
* `roles/iam.securityAdmin` (Permite amarrar acessos internos do Dataform ao BigQuery)
* `roles/iam.serviceAccountAdmin` (Permite criar as sub-contas dos orquestradores)



### C. Configuração do WIF (Workload Identity Federation)

* **Pool ID:** `gh-pool`
* **Provider ID:** `gh-provider`
* **Condição de Segurança:** Restringir estritamente ao repositório: `Matheus-Fuzati-de-Carvalho/martech-toolkit-v9-02`
* **Mapeamento:** `google.subject=assertion.sub` e `attribute.repository=assertion.repository`

### D. Armazenamento de Estado do Terraform

* Criação de dois buckets regionais (`us-central1`) denominados:
* `gs://toolkit-v9-02-dev-tfstate`
* `gs://toolkit-v9-02-hom-tfstate`



---

## 🚀 6. Script de Automação (Para ser enviado à TI)

Envie o script abaixo para a TI do cliente executar no **GCP Cloud Shell**. Ele realiza todas as configurações descritas no passo anterior automaticamente.

```bash
#!/bin/bash
set -e

# ==============================================================================
# CONFIGURAÇÕES DO REPOSITÓRIO DA CONSULTORIA
# ==============================================================================
GITHUB_REPO="Matheus-Fuzati-de-Carvalho/martech-toolkit-v9-02"
ENVIRONMENTS=("dev" "hom")
REGION="us-central1"
# ==============================================================================

for ENV in "${ENVIRONMENTS[@]}"; do
  PROJECT_ID="toolkit-v9-02-${ENV}"
  echo "🎯 [1/5] Configurando projeto: $PROJECT_ID"
  gcloud config set project "$PROJECT_ID" --quiet
  
  echo "⚙️ [2/5] Ativando APIs do ecossistema..."
  gcloud services enable \
      serviceusage.googleapis.com \
      cloudresourcemanager.googleapis.com \
      iam.googleapis.com \
      iamcredentials.googleapis.com \
      bigquery.googleapis.com \
      dataform.googleapis.com \
      workflows.googleapis.com \
      dataplex.googleapis.com \
      pubsub.googleapis.com \
      secretmanager.googleapis.com \
      cloudfunctions.googleapis.com \
      cloudbuild.googleapis.com \
      artifactregistry.googleapis.com \
      run.googleapis.com \
      eventarc.googleapis.com \
      cloudscheduler.googleapis.com --quiet

  echo "👤 [3/5] Criando Service Account de Deploy..."
  SA_EMAIL="gh-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com"
  if ! gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null; then
      gcloud iam service-accounts create "gh-actions-sa" \
          --display-name="GitHub Actions Deploy SA" --quiet
  fi

  echo "🔐 [4/5] Aplicando papeis IAM Administrativos..."
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SA_EMAIL" --role="roles/editor" --quiet
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SA_EMAIL" --role="roles/iam.securityAdmin" --quiet
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SA_EMAIL" --role="roles/iam.serviceAccountAdmin" --quiet

  echo "🤝 [5/5] Provisionando Workload Identity Federation (WIF)..."
  gcloud iam workload-identity-pools create "gh-pool" \
      --location="global" --display-name="GitHub Actions Pool" --quiet || true

  gcloud iam workload-identity-pools providers create-oidc "gh-provider" \
      --location="global" \
      --workload-identity-pool="gh-pool" \
      --display-name="GitHub Actions Provider" \
      --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
      --attribute-condition="assertion.repository == '${GITHUB_REPO}'" \
      --issuer-uri="https://token.actions.githubusercontent.com" \
      --quiet || true

  PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
  
  gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
      --project="$PROJECT_ID" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/gh-pool/attribute.repository/${GITHUB_REPO}" \
      --quiet

  echo "🪣 [EXTRA] Criando Bucket de Estado do Terraform..."
  gcloud storage buckets create "gs://${PROJECT_ID}-tfstate" --project="$PROJECT_ID" --location="$REGION" --quiet || true
done

echo "✅ [CONCLUÍDO] Setup Base homologado em todos os ambientes!"

```

---

## 🔄 7. Fluxo de Trabalho e Promoção de Ambientes (GitOps)

Após a TI liberar o setup básico, as atualizações seguem o fluxo de ramificações do Git:

1. **Desenvolvimento (`dev`):**
* Realize as alterações nos arquivos SQLX ou Terraform localmente.
* Execute `git push origin dev`. O pipeline executará o deploy automático isolado no projeto `toolkit-v9-02-dev`.


2. **Homologação (`hom`):**
* Após validar as tabelas em DEV, promova o código fazendo o merge das ramificações:
```bash
git checkout hom
git merge dev
git push origin hom

```


* O GitHub Actions redirecionará os estados para o bucket `toolkit-v9-02-hom-tfstate`, aplicando as alterações de forma transparente em homologação.
