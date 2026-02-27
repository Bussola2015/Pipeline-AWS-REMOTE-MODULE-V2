# 1. IP Público da Instância (O que você mais vai usar)
output "instance_public_ip" {
  description = "IP público da instância EC2 para acesso SSH"
  value       = aws_instance.vm.public_ip
}

# 2. ID da VPC (Extraído do módulo remoto)
output "vpc_id" {
  description = "ID da VPC criada pelo módulo oficial"
  value       = module.vpc.vpc_id
}

# 3. ID da Subnet Pública
output "public_subnet_id" {
  description = "ID da subnet pública onde a VM foi alocada"
  value       = module.vpc.public_subnets[0]
}

# 4. Comando SSH "Mastigado"
# Esse output já gera o comando prontinho para você copiar e colar no terminal
output "ssh_command" {
  description = "Comando pronto para acessar a instância via SSH"
  value       = "ssh -i ${local_file.private_key.filename} admin@${aws_instance.vm.public_ip}"
}