terraform { source = "../../../modules/helm" }
dependency "s3-bucket" {
  config_path                             = "../../infrastructure-stack/s3-bucket"
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    iam_access_key_id     = "mock-access-key-id"
    iam_secret_access_key = "mock-secret-access-key"
    bucket_name           = "mock-bucket-name"
  }
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  global = local.common.locals
}

inputs = {
  service                       = "mostlyai"
  namespace                     = "mostlyai"
  helm_release_chart            = "mostly-combined"
  helm_release_repository       = "oci://709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
  helm_release_timeout          = 300
  helm_repository_auth_user     = "AWS"
  helm_repository_auth_password = get_env("AWS_ECR_AUTH_TOKEN", "nonexistent")
  helm_release_values = {
    values = {
      global = {
        mostly = {
          fqdn = local.global.installation_domain_name
        }
        image = {
          mostlyRegistry = "709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform"
        },
        ingress = {
          annotations = {
            "alb.ingress.kubernetes.io/group.name"               = "${local.global.environment}-ingress"
            "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\":80},{\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=600"
            "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
            "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
          }
        }
      },
      mostlyConfigurations = {
        configMap = {
          keys = {
            STORAGE_S3_MOSTLY_APP_BUCKET   = dependency.s3-bucket.outputs.bucket_name
            STORAGE_S3_MOSTLY_APP_ENDPOINT = "https://s3.${local.global.aws_region}.amazonaws.com"
          }
        }
      },
      mostlyApp = {
        deployment = {
          awsProductCode = "7lynt012mo78turu5n6s8kbbc"
        }
      },
      combinedChart = {
        minio = {
          enabled = false
        }
      },
      mostlyPsql = {
        persistentVolumeClaim = {
          storageClassName = "gp2"
        },
        deployment = {
          enableEbsPVCBasedPermissions = true
        }
      },
      mostlyJupyterhub = {
        persistentVolumeClaim = {
          enabled = false
        }
      },
    }
  }
  helm_release_secret_values = {
    values = {
      mostlyConfigurations = {
        secrets = {
          s3Storage = {
            values = {
              access_key = base64encode(dependency.s3-bucket.outputs.iam_access_key_id)
              secret_key = base64encode(dependency.s3-bucket.outputs.iam_secret_access_key)
            }
          }
        }
      }
    }
  }
}
