locals {
  bucket_arn_list = flatten(
    [for bucket, configuration in var.s3_buckets : [
      aws_s3_bucket.main[bucket].arn, "${aws_s3_bucket.main[bucket].arn}/*"
    ]]
  )
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = local.bucket_arn_list
  }
}

resource "aws_iam_policy" "main" {
  name        = "${var.global.environment}-${var.service}"
  path        = "/"
  description = "Access Policy for ${var.global.environment}-${var.service} buckets"
  policy      = data.aws_iam_policy_document.main.json
  tags = {
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/s3-bucket",
    "Name" : "${var.global.environment}-${var.service}"
  }
}
