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
  s3_buckets = {
    "mostlyai-data" = {
      acl                       = "private"
      force_destroy             = false
      lifecycle_status          = "Disabled"
      lifecycle_expiration_days = -1
      block_public_acls         = true
      block_public_policy       = true
      ignore_public_acls        = true
      restrict_public_buckets   = true
    }
  }
}
