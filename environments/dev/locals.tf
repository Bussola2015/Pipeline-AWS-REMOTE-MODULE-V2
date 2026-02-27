locals {
  common_tags = {
    Project     = "AWS-Remote-Modules"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Junior-Bussola"
  }
}