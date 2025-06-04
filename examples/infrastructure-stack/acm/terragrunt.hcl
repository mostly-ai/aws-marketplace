terraform { source = "../../../modules/acm" }

locals {
  common        = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  common_secret = read_terragrunt_config(find_in_parent_folders("common-secret.hcl"))
  global        = local.common.locals
  global_secret = local.common_secret.locals
}

inputs = {
  global                  = local.global
  global_secret           = local.global_secret
  certificate_domain_name = local.global.installation_domain_name
  hosted_zone             = local.global.hosted_zone
  create_for_wildcard     = true
}
