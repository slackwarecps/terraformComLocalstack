# CODIGO


DOCKER
```
version: '3.8'

services:
  localstack:
    image: localstack/localstack:2.3
    ports:
      - "4566:4566"
    environment:
      - SERVICES=apigateway
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_DEFAULT_REGION=us-east-1
    volumes:
      - "${TMPDIR:-/tmp}/localstack:/var/lib/localstack"
```


SAIDA
```
  Enter a value: yes      

aws_api_gateway_rest_api.olamundo_api: Creating...
aws_api_gateway_rest_api.olamundo_api: Creation complete after 0s [id=xe7m719htk]
aws_api_gateway_resource.olamundo_resource: Creating...
aws_api_gateway_resource.olamundo_resource: Creation complete after 0s [id=w503tiocma]
aws_api_gateway_method.olamundo_get_method: Creating...
aws_api_gateway_method.olamundo_get_method: Creation complete after 0s [id=agm-xe7m719htk-w503tiocma-GET]
aws_api_gateway_method_response.olamundo_method_response: Creating...
aws_api_gateway_integration.olamundo_integration: Creating...
aws_api_gateway_method_response.olamundo_method_response: Creation complete after 0s [id=agmr-xe7m719htk-w503tiocma-GET-200]
aws_api_gateway_integration.olamundo_integration: Creation complete after 0s [id=agi-xe7m719htk-w503tiocma-GET]
aws_api_gateway_integration_response.olamundo_integration_response: Creating...
aws_api_gateway_integration_response.olamundo_integration_response: Creation complete after 0s [id=agir-xe7m719htk-w503tiocma-GET-200]
aws_api_gateway_deployment.olamundo_deployment: Creating...
aws_api_gateway_deployment.olamundo_deployment: Creation complete after 0s [id=ms5w8cy2bw]
aws_api_gateway_stage.olamundo_stage: Creating...
aws_api_gateway_stage.olamundo_stage: Creation complete after 0s [id=ags-xe7m719htk-dev]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

endpoint_url = "arn:aws:execute-api:us-east-1:000000000000:xe7m719htk"
```



## URL
http://192.168.1.100:4566/restapis/xe7m719htk/dev/_user_request_/olamundo

http://192.168.1.100:4566/restapis/crfsuyvx9s/dev/portobank/v1/conta-digital/ms-contatos/ola-mundo


http://192.168.1.100:4566/restapis/bk2ymi5lw3/dev/_user_request_/portobank/v1/conta-digital/ms-contatos/ola-mundo

http://192.168.1.100:4566/restapis/
bk2ymi5lw3
/dev/_user_request_
/portobank/v1/conta-digital/ms-contatos/ola-mundo



## CONFIGURANDO O AWS CLI
```
[profile localstack]
region = us-east-1
endpoint_url = http://localhost:4566
s3 =
  addressing_style = path
  signature_version = s3v4


[profile fabaolocalsvr]
region = us-east-1
endpoint_url = http://192.168.1.100:4566
s3 =
  addressing_style = path
  signature_version = s3v4
```
