locals {
  environment              = "mai-mplace"
  aws_region               = "us-east-1"
  hosted_zone              = "mostlyai.mydomain.com"
  installation_domain_name = "app.${local.hosted_zone}"
  allowed_access_cidrs     = ["0.0.0.0/0"]
}