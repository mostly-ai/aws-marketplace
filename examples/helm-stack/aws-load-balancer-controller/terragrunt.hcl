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
  service                 = "aws-load-balancer-controller"
  namespace               = "kube-system"
  helm_release_chart      = "aws-load-balancer-controller"
  helm_release_repository = "https://aws.github.io/eks-charts"
  helm_release_values = {
    values = {
      clusterName       = local.global.environment
      defaultTargetType = "ip"
      ingressClassConfig = {
        default = true
      }
      enableShield = false
      enableWaf    = true
      enableWafv2  = true
    }
  }
}
