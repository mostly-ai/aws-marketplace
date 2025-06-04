terraform { source = "../../../modules/s3-bucket" }

locals {
  common        = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  common_secret = read_terragrunt_config(find_in_parent_folders("common-secret.hcl"))
  global        = local.common.locals
  global_secret = local.common_secret.locals
}

inputs = {
  global        = local.global
  global_secret = local.global_secret
  hosted_zone   = local.global.hosted_zone
  record_name   = local.global.installation_domain_name

  record_type  = "CNAME"
  record_value = "albaddress.eu-central-1.elb.amazonaws.com"
}
