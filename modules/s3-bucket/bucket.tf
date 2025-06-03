resource "aws_s3_bucket" "main" {
  for_each      = var.s3_buckets
  bucket        = "${var.global.environment}-${var.service}-${each.key}"
  force_destroy = each.value["force_destroy"]
  tags = {
    "ConfigLocation" : "mostly-ai/aws-marketplace/configuration/${var.service}"
    "Environment" : var.global.environment
    "ManagedBy" : "Terraform"
    "ModuleLocation" : "mostly-ai/aws-marketplace/modules/s3-bucket",
    "Name" : "${var.global.environment}-${var.service}"
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  for_each   = var.s3_buckets
  depends_on = [aws_s3_bucket.main]
  bucket     = aws_s3_bucket.main[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "main" {
  for_each   = var.s3_buckets
  depends_on = [time_sleep.wait_for_access_block_to_take_effect]

  bucket = aws_s3_bucket.main[each.key].id
  acl    = lower(each.value["acl"])
}

resource "time_sleep" "wait_for_access_block_to_take_effect" {
  depends_on      = [aws_s3_bucket_public_access_block.main]
  create_duration = "5s"
}


resource "aws_s3_bucket_public_access_block" "main" {
  for_each   = var.s3_buckets
  depends_on = [aws_s3_bucket.main]

  bucket                  = aws_s3_bucket.main[each.key].id
  block_public_acls       = each.value["block_public_acls"]       # Disables Public Access Control Lists.
  block_public_policy     = each.value["block_public_policy"]     # Disables Policies with Public Access
  ignore_public_acls      = each.value["ignore_public_acls"]      # Forces bucket to ignore any request with a Public ACL.
  restrict_public_buckets = each.value["restrict_public_buckets"] # Disables anonymous AND cross-account requests.
}

resource "aws_s3_bucket_policy" "main" {
  for_each = { for k, v in var.s3_buckets : k => v if v.bucket_policy != null }

  bucket = aws_s3_bucket.main[each.key].bucket
  policy = each.value["bucket_policy"]
}
