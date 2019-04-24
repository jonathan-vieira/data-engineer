## Execução do projeto

clonar o repositório

`git clone git@github.com:jonathan-vieira/data-engineer.git` 

exportar as chaves da aws

```
export AWS_ACCESS_KEY_ID=XXXXX
export AWS_SECRET_ACCESS_KEY=XxxXXxxxx

```

adicionar variáveis do twitter no arquivo `vars.tf`


deploy do terraform

```
cd terraform
terraform init
terraform plan -out terraform.plan
terraform apply terrafrom.plan

```

