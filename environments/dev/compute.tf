# --- SEGURANÇA E CHAVES ---
# 1. Gera a chave (em memória)
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# 2. Envia a chave para a nuvem
resource "aws_key_pair" "key" {
  key_name   = "aws-key-${var.environment}"
  public_key = tls_private_key.rsa_key.public_key_openssh
}
# 3. Salva a chave privada no seu PC (Substitui os provisioners!)
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "./aws-key-${var.environment}.pem"
  file_permission = "0400"
}

# --- BUSCA DE IMAGEM (AMI) ---

data "aws_ami" "debian_13" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["136693071363"]
}

# --- INSTÂNCIA EC2 ---

resource "aws_instance" "vm" {
  ami           = data.aws_ami.debian_13.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key.key_name

  # Pegamos a Subnet do módulo e o SG do nosso security.tf
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.sg.id]

  associate_public_ip_address = true #pode ser removido pois já tem 'map_public_ip_on_launch = true' no module network

  tags = merge(local.common_tags, {
    Name = "server-debian-${var.environment}"
  })
}