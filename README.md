# POC de TERRAFORM com LocalStack

Este projeto demonstra a criação de recursos AWS utilizando Terraform e o LocalStack para simular o ambiente da AWS localmente.

## Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

*   **Terraform:** Para gerenciar a infraestrutura como código.
*   **Docker:** Para executar o LocalStack.
*   **Docker Compose:** Para orquestrar o contêiner do LocalStack.
*   **AWS CLI:** Para interagir com os serviços AWS (e LocalStack).

## Configuração do LocalStack

O LocalStack será executado via Docker Compose.

1.  **Crie o arquivo `docker-compose.yml`** na raiz do projeto (`/Users/fabioalvaropereira/workspaces/terraform/fabao1/`) com o seguinte conteúdo:

    ```yaml
    version: '3.8'

    services:
      localstack:
        image: localstack/localstack:2.3 # Versão estável e funcional
        ports:
          - "4566:4566" # Porta padrão do LocalStack
        environment:
          - SERVICES=apigateway # Apenas o serviço de API Gateway é necessário para este projeto
          - AWS_ACCESS_KEY_ID=test
          - AWS_SECRET_ACCESS_KEY=test
          - AWS_DEFAULT_REGION=us-east-1
        volumes:
          - "${TMPDIR:-/tmp}/localstack:/var/lib/localstack" # Persistência de dados
    ```

2.  **Inicie o LocalStack:**
    ```bash
    docker-compose up -d
    ```

## Configuração do AWS CLI

Para que o AWS CLI se comunique com o LocalStack, configure as variáveis de ambiente:

```bash
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
```

## Exemplos de Terraform

Este projeto contém exemplos de configuração de API Gateway em diferentes diretórios.

### Exemplo 2 (`exemplo2/main.tf`)

Este exemplo cria uma API Gateway com duas rotas:
*   `/ms-contatos/{proxy+}`: Redireciona para um serviço local (`http://host.docker.internal:8080/ms-contatos/contatos`).
*   `/abacaxi`: Retorna uma resposta mock JSON.

**Como usar:**

1.  Navegue até o diretório `exemplo2`:
    ```bash
    cd exemplo2
    ```
2.  Inicialize o Terraform:
    ```bash
    terraform init
    ```
3.  Aplique a configuração:
    ```bash
    terraform apply
    ```
    Confirme com `yes`.

**Como testar:**

Após o `terraform apply`, o Terraform exibirá a URL de invocação da API. Você pode testar a rota `/abacaxi` com o seguinte comando (substitua `[ID_DA_API]` pelo ID real da API que o Terraform exibir):

```bash
curl -X GET http://localhost:4566/restapis/[ID_DA_API]/dev/_user_request_/abacaxi
```
*Nota: A parte `_user_request_` pode ser necessária dependendo da sua versão do LocalStack e da configuração.* 

### Exemplo 3 (`exemplo3/main.tf`)

Este exemplo cria uma API Gateway simples com uma rota `/olamundo` que retorna uma resposta mock JSON.

**Como usar:**

1.  Navegue até o diretório `exemplo3`:
    ```bash
    cd exemplo3
    ```
2.  Inicialize o Terraform:
    ```bash
    terraform init
    ```
3.  Aplique a configuração:
    ```bash
    terraform apply
    ```
    Confirme com `yes`.

**Como testar:**

Após o `terraform apply`, o Terraform exibirá a URL de invocação da API. Você pode testar a rota `/olamundo` com o seguinte comando (substitua `[ID_DA_API]` pelo ID real da API que o Terraform exibir):

```bash
curl -X GET http://localhost:4566/restapis/[ID_DA_API]/dev/_user_request_/olamundo
```
*Nota: A parte `_user_request_` pode ser necessária dependendo da sua versão do LocalStack e da configuração.* 

## Limpeza

Para destruir os recursos criados pelo Terraform em um exemplo específico:

```bash
cd [diretorio_do_exemplo] # exemplo: cd exemplo2
terraform destroy
```

Para parar e remover o contêiner do LocalStack:

```bash
cd /Users/fabioalvaropereira/workspaces/terraform/fabao1/ # Volte para a raiz do projeto
docker-compose down
```