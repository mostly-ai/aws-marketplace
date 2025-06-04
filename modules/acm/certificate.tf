resource "aws_acm_certificate" "main" {
  domain_name       = var.certificate_domain_name
  validation_method = "DNS"
  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/acm-public-certificate",
    "Name" : "${var.global.environment}-${var.service}"
  }
  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate" "wildcard" {
  count             = var.create_for_wildcard ? 1 : 0
  domain_name       = "*.${var.certificate_domain_name}"
  validation_method = "DNS"
  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/acm-public-certificate",
    "Name" : "${var.global.environment}-${var.service}"
  }
  lifecycle { create_before_destroy = true }
}
