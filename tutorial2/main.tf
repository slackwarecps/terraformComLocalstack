# =================================================================================
# SCRIPT DIDÁTICO PARA CRIAR UMA API GATEWAY SIMPLES NO LOCALSTACK
#
# Objetivo: Criar um endpoint GET que responde com uma mensagem JSON fixa.
# Este script é intencionalmente explícito e verboso para fins de aprendizado.
# =================================================================================

# --- 1. CONFIGURAÇÃO DO PROVEDOR ---
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"
  endpoints {
    apigateway = "http://192.168.1.100:4566"
  }
}


# --- 2. CRIAÇÃO DA API E DA ESTRUTURA DA URL ---
resource "aws_api_gateway_rest_api" "minha_api" {
  name        = "minha-api-didatica"
  description = "API de exemplo para aprendizado"
}

resource "aws_api_gateway_resource" "recurso_portobank" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_rest_api.minha_api.root_resource_id
  path_part   = "portobank"
}

resource "aws_api_gateway_resource" "recurso_v1" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_resource.recurso_portobank.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "recurso_conta_digital" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_resource.recurso_v1.id
  path_part   = "conta-digital"
}

resource "aws_api_gateway_resource" "recurso_ms_contatos" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_resource.recurso_conta_digital.id
  path_part   = "ms-contatos"
}

resource "aws_api_gateway_resource" "recurso_ola_mundo" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  parent_id   = aws_api_gateway_resource.recurso_ms_contatos.id
  path_part   = "ola-mundo"
}


# --- 3. LÓGICA DO ENDPOINT (/ola-mundo) ---
resource "aws_api_gateway_method" "metodo_get" {
  rest_api_id   = aws_api_gateway_rest_api.minha_api.id
  resource_id   = aws_api_gateway_resource.recurso_ola_mundo.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integracao_mock" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  resource_id = aws_api_gateway_resource.recurso_ola_mundo.id
  http_method = aws_api_gateway_method.metodo_get.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "resposta_200" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  resource_id = aws_api_gateway_resource.recurso_ola_mundo.id
  http_method = aws_api_gateway_method.metodo_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "conteudo_da_resposta" {
  rest_api_id = aws_api_gateway_rest_api.minha_api.id
  resource_id = aws_api_gateway_resource.recurso_ola_mundo.id
  http_method = aws_api_gateway_method.metodo_get.http_method
  status_code = aws_api_gateway_method_response.resposta_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      mensagem = "Ola Mundo, agora de forma simples e didatica!"
    })
  }
  depends_on = [aws_api_gateway_integration.integracao_mock]
}


# --- 4. PUBLICAÇÃO DA API ---
resource "aws_api_gateway_deployment" "meu_deployment" {
  # --- CORREÇÃO APLICADA AQUI ---
  # A referência foi trocada de ".api.id" para ".minha_api.id"
  rest_api_id = aws_api_gateway_rest_api.minha_api.id # <-- CORRIGIDO

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.minha_api.body))
  }
  
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_integration_response.conteudo_da_resposta]
}

resource "aws_api_gateway_stage" "meu_stage" {
  deployment_id = aws_api_gateway_deployment.meu_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.minha_api.id
  stage_name    = "dev"
}


# --- 5. SAÍDAS (OUTPUTS) ---


output "lembrete_localstack" {
  description = "Lembrete sobre a URL para LocalStack"
  value       = "Lembre-se: como estamos usando LocalStack, talvez você precise adicionar '/_user_request_' na URL, entre o stage ('dev') e o início do caminho ('portobank')."
}

output "sequencia1" {
  description = "Sequencia"
  value       = "Meu texto 1. http://192.168.1.100:4566/restapis/${aws_api_gateway_rest_api.minha_api.id}/dev/_user_request_/portobank/v1/conta-digital/ms-contatos/ola-mundo"
}