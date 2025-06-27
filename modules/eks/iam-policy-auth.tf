# * This IAM Policy is simplified and translated from the official AWS ALB Ingress Controller documentation:
#   https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/deploy/installation/
data "aws_iam_policy_document" "auth" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "license-manager:ListReceivedLicenses",
      "license-manager:CheckoutLicense",
      "license-manager:GetLicense",
      "license-manager:CheckInLicense",
      "license-manager:ExtendLicenseConsumption"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "auth" {
  name        = "${var.global.environment}-${var.service}-auth-policy"
  path        = "/"
  description = "Access Policy for ${var.global.environment}-${var.service} Service Authorization"
  policy      = data.aws_iam_policy_document.auth.json
  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/eks",
    "Name" : "${var.global.environment}-${var.service}"
  }
}
