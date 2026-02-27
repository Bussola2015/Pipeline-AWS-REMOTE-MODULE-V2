# Data source para descobrir o IP de quem executa o Terraform
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Definição do container do Security Group
resource "aws_security_group" "sg" {
  name        = "${var.environment}-sg"
  description = "Security Group gerenciado via Terraform para acesso controlado"

  # ATENÇÃO: Referência ao ID da VPC que vem do MÓDULO
  vpc_id = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${var.environment}-sg" })
}

# Regra de Entrada: SSH restrito ao seu IP
resource "aws_security_group_rule" "allow_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  #cidr_blocks       = ["${chomp(data.http.my_ip.response_body)}/32"]
  # Lógica: Se var.admin_ip existir, usa ele. Se não, usa o data source.
  cidr_blocks       = [var.admin_ip != "" ? "${var.admin_ip}" : "${chomp(data.http.my_ip.response_body)}/32"]  #tirei o /32 do var.admin_ip porque ele já vem com mascara
  security_group_id = aws_security_group.sg.id
  description       = "Acesso SSH restrito ao IP publico do administrador"
}

# Regra de Saída: Tudo Liberado
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
  description       = "Permitir toda saida de trafego da instancia"
}