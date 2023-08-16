locals {
  tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "Prod"
  }
}