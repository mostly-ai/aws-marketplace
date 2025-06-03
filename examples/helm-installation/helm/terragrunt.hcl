terraform { source = "../../../modules/helm" }
dependency "s3-bucket" {
  config_path  = "../../infrastructure-stack/s3-bucket"
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    iam_access_key_id = "mock-access-key-id"
    iam_secret_access_key = "mock-secret-access-key"
    bucket_name = "mock-bucket-name"
  }
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  global = local.common.locals
}

inputs = {
  helm_release_values = {
    values = {
      mostlyConfigurations = {
        configMap = {
          keys = {
            STORAGE_S3_MOSTLY_APP_BUCKET   = dependency.s3-bucket.outputs.bucket_name
            STORAGE_S3_MOSTLY_APP_ENDPOINT = "https://s3.${local.global.aws_region}.amazonaws.com"
          }
        }
      }
    }
  }
  helm_release_secret_values = {
    values = {
      mostlyConfigurations = {
        secrets = {
          s3Storage = {
            values = {
              access_key = dependency.s3-bucket.outputs.iam_access_key_id
              secret_key = dependency.s3-bucket.outputs.iam_secret_access_key
            }
          }
        }
      }
    }
  }
}
