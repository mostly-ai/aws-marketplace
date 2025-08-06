resource "aws_iam_role" "auth" {
  name               = "${var.global.environment}-${var.service}-auth-role"
  assume_role_policy = data.aws_iam_policy_document.auth_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "auth" {
  name       = "${var.global.environment}-${var.service}-auth-policy-attachment"
  roles      = [aws_iam_role.auth.name]
  policy_arn = aws_iam_policy.auth.arn

}

data "aws_iam_policy_document" "auth_assume_role_policy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:mostly-ai:mostly-app", "system:serviceaccount:mostlyai:mostly-app"]
    }
  }
}
