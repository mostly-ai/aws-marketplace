terraform { source = "../../../modules/helm" }

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  global = local.common.locals
}

inputs = {
  service                     = "aws-load-balancer-controller"
  namespace                   = "kube-system"
  helm_release_deploy_enabled = true
  helm_release_chart          = "aws-load-balancer-controller"
  helm_release_repository     = "https://aws.github.io/eks-charts"
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
