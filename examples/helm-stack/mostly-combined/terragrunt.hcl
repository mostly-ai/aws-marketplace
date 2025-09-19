terraform { source = "../../../modules/helm" }
dependency "s3-bucket" {
  config_path                             = "../../infrastructure-stack/s3-bucket"
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    aws_account_id        = "mock-aws-account-id"
    iam_access_key_id     = "mock-access-key-id"
    iam_secret_access_key = "mock-secret-access-key"
    bucket_name           = "mock-bucket-name"
  }
}

locals {
  extra  = read_terragrunt_config(find_in_parent_folders("extra-locals.hcl"))
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
            "alb.ingress.kubernetes.io/inbound-cidrs"            = join(", ", local.extra.locals.allowed_access_cidrs)
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
        secrets = {
          defaultSuperAdmin = {
            create = true
            value = {
              username = base64encode("superadmin@${local.global.hosted_zone}")
              password = base64encode("defaultPassword123")
            }
          }
        },
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${dependency.s3-bucket.outputs.aws_account_id}:role/${local.global.environment}-eks-auth-role"
          }
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
