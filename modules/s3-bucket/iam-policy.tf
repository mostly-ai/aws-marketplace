data "aws_iam_policy_document" "main" {
  for_each = var.s3_buckets

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.main[each.key].arn,
    ]
  }
}

resource "aws_iam_policy" "main" {
  for_each    = var.s3_buckets
  name        = "${var.global.environment}-${var.service}-${each.key}"
  path        = "/"
  description = "Access Policy for ${var.global.environment}-${var.service}-${each.key} bucket"
  policy      = data.aws_iam_policy_document.main[each.key].json
  tags = {
    "ConfigLocation" : "mostly-ai/aws-marketplace/configuration/${var.service}"
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/s3-bucket",
    "Name" : "${var.global.environment}-${var.service}"
  }
}
