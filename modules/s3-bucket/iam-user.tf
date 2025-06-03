resource "aws_iam_user" "main" {
  name = "${var.global.environment}-${var.service}-iam-user"
  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/s3-bucket",
    "Name" : "${var.global.environment}-${var.service}"
  }
}

resource "aws_iam_user_policy_attachment" "main" {
  user       = aws_iam_user.main.name
  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}
