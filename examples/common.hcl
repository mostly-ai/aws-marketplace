locals {
  environment              = "mostlyai"
  aws_region               = "eu-central-1"
  hosted_zone              = "example.com"
  installation_domain_name = "mostlyai.${local.hosted_zone}"
}
