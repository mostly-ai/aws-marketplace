locals {
  environment              = "mai-mplace"
  aws_region               = "us-east-1"
  hosted_zone              = "aws-marketplace.mostlylab.com"
  installation_domain_name = "app.${local.hosted_zone}"
}
