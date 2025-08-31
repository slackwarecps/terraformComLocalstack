# Defina o provedor AWS e a região
# Sobrescreve o provedor AWS para usar o LocalStack
provider "aws" {
  region = "us-east-1"
  access_key = "test"
  secret_key = "test"
  endpoints {
    apigateway = "http://192.168.1.100:4566"
  }
}

# Crie um API Gateway
resource "aws_api_gateway_rest_api" "olamundo_api" {
  name        = "olamundo-api"
  description = "Minha primeira API Gateway com Terraform"
}

# Crie um recurso "olamundo"
resource "aws_api_gateway_resource" "olamundo_resource" {
  rest_api_id = aws_api_gateway_rest_api.olamundo_api.id
  parent_id   = aws_api_gateway_rest_api.olamundo_api.root_resource_id
  path_part   = "olamundo"
}

# Crie um método GET para o recurso "olamundo"
resource "aws_api_gateway_method" "olamundo_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.olamundo_api.id
  resource_id   = aws_api_gateway_resource.olamundo_resource.id
  http_method   = "GET"
  authorization = "NONE" # Não precisa de autenticação por enquanto
}

# Crie a integração de método MOCK
resource "aws_api_gateway_integration" "olamundo_integration" {
  rest_api_id = aws_api_gateway_rest_api.olamundo_api.id
  resource_id = aws_api_gateway_resource.olamundo_resource.id
  http_method = aws_api_gateway_method.olamundo_get_method.http_method
  type        = "MOCK"

  # Mapeamento da resposta para retornar a mensagem
  request_templates = {
    "application/json" = "{}" # Um corpo de requisição vazio
  }
}

# Crie a resposta de método para o MOCK
resource "aws_api_gateway_method_response" "olamundo_method_response" {
  rest_api_id = aws_api_gateway_rest_api.olamundo_api.id
  resource_id = aws_api_gateway_resource.olamundo_resource.id
  http_method = aws_api_gateway_method.olamundo_get_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty" # Um modelo vazio
  }
}

# Crie a resposta de integração com o corpo JSON
resource "aws_api_gateway_integration_response" "olamundo_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.olamundo_api.id
  resource_id = aws_api_gateway_resource.olamundo_resource.id
  http_method = aws_api_gateway_method.olamundo_get_method.http_method
  status_code = aws_api_gateway_method_response.olamundo_method_response.status_code

  # Adicione esta linha para garantir a ordem correta
  depends_on = [aws_api_gateway_integration.olamundo_integration]

  response_templates = {
    "application/json" = jsonencode({ message = "ola mamae" })
  }
}

# Crie um deployment (implantação) para a API
resource "aws_api_gateway_deployment" "olamundo_deployment" {
  rest_api_id = aws_api_gateway_rest_api.olamundo_api.id
  triggers = {
    # Isso garante que a API é reimplantada se algo mudar nos recursos
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.olamundo_resource.id,
      aws_api_gateway_method.olamundo_get_method.id,
      aws_api_gateway_integration.olamundo_integration.id,
      aws_api_gateway_integration_response.olamundo_integration_response.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Crie um "stage" (estágio) para a implantação
resource "aws_api_gateway_stage" "olamundo_stage" {
  deployment_id = aws_api_gateway_deployment.olamundo_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.olamundo_api.id
  stage_name    = "dev" # O nome do seu ambiente, como dev, prod, etc.
}

# Exibe o URL do endpoint no console
output "endpoint_url" {
  value = "${aws_api_gateway_rest_api.olamundo_api.execution_arn}"
}