# Defina o provedor AWS e a região
# Sobrescreve o provedor AWS para usar o LocalStack
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"
  endpoints {
    apigateway = "http://192.168.1.100:4566"
  }
}

# Crie a API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "minha-api"
  description = "Minha API de exemplo"
}

# Crie o recurso /portobank
resource "aws_api_gateway_resource" "portobank" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "portobank"
}

# Crie o recurso /v1
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.portobank.id
  path_part   = "v1"
}

# Crie o recurso /conta-digital
resource "aws_api_gateway_resource" "conta_digital" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "conta-digital"
}

# Crie o recurso /ms-contatos
resource "aws_api_gateway_resource" "ms_contatos" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.conta_digital.id
  path_part   = "ms-contatos"
}

# Crie o recurso /ola-mundo
resource "aws_api_gateway_resource" "ola_mundo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.ms_contatos.id
  path_part   = "ola-mundo"
}


# --- INÍCIO DAS ADIÇÕES ---

# 1. Crie o método GET para o recurso /ola-mundo
resource "aws_api_gateway_method" "get_ola_mundo" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ola_mundo.id
  http_method   = "GET"
  authorization = "NONE" # Qualquer um pode chamar a API
}

# 2. Crie a integração MOCK para o método GET
#    Isso faz com que o próprio API Gateway responda, sem um backend real.
resource "aws_api_gateway_integration" "integration_get_ola_mundo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ola_mundo.id
  http_method = aws_api_gateway_method.get_ola_mundo.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

# 3. Defina a resposta que o método pode retornar (status 200)
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ola_mundo.id
  http_method = aws_api_gateway_method.get_ola_mundo.http_method
  status_code = "200"
  response_models = {
    # Define que o corpo da resposta será um JSON
    "application/json" = "Empty" 
  }
}

# 4. Crie a resposta da integração com o corpo JSON
resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ola_mundo.id
  http_method = aws_api_gateway_method.get_ola_mundo.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Define o corpo (body) da resposta como um JSON
  response_templates = {
    "application/json" = jsonencode({
      message = "ola mundo"
    })
  }
}

# 5. Crie o deployment da API para publicar as mudanças
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Garante que um novo deployment seja criado sempre que a API mudar
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ola_mundo.id,
      aws_api_gateway_method.get_ola_mundo.id,
      aws_api_gateway_integration.integration_get_ola_mundo.id,
      aws_api_gateway_integration_response.integration_response.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 6. Crie o stage para o deployment (ex: dev, prod)
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}

# --- FIM DAS ADIÇÕES ---