terraform { source = "../../../modules/vpc" }

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  common_secret = read_terragrunt_config(find_in_parent_folders("common-secret.hcl"))
  global = local.common.locals
  global_secret = local.common_secret.locals
}

inputs = {
  global = local.global
  global_secret = local.global_secret
  vpc_cidr = "10.0.0.0/16"
}
