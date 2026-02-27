terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }

  backend "s3" {
    bucket       = "s3bucket-juniorbussola"
    key          = "dev-v2/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    #dynamodb_table = "terraform-locks" #controle de concorrência ao arquivo terraform.tfstate

  }
}

provider "aws" {
  region = "us-east-1"

  # Essas tags são herdadas por TODOS os recursos criados diretamente na raiz
  default_tags {
    tags = local.common_tags
  }
}
# Busco as zonas de disponibilidade disponíveis na região configurada no provider AWS (direto API da AWS)
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "vpc-${var.environment}"
  cidr = var.cidr_vpc

  #opções de zonas de disponibilidade (AZs) para os subnets, pode ser uma lista de AZs ou um slice do data source aws_availability_zones
  #azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  #azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  # Selecionando apenas a PRIMEIRA zona disponível
  # Para escalar, basta adicionar mais itens à lista: [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  azs = [data.aws_availability_zones.available.names[0]]

  # Como você passou 1 zona, passa 1 subnet. 
  # Se escalar para 2 zonas, adicione mais um CIDR aqui: [var.cidr_subnet, "10.0.10.0/24"]
  public_subnets = [var.cidr_subnet]

  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  #public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = local.common_tags #somente legibilidade, pois as tags já são herdadas por default_tags do provider AWS

  # Opcional: Tags específicas para as subnets públicas que o módulo permite
  public_subnet_tags = {
    Type = "Public"
  }

}