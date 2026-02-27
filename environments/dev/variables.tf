# Sem default para forçar o uso do .tfvars

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
  #default     = "dev"
}

variable "cidr_vpc" {
  description = "CIDR block para a VPC"
  type        = string
  #default     = "10.0.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block para a subnet pública"
  type        = string
  #default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  #default     = "t3.micro"
}

variable "admin_ip" {
  description = "IP do administrador para acesso SSH"
  type        = string
  default     = "" # Deixamos vazio para a lógica abaixo
}