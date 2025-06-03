resource "aws_s3_bucket_lifecycle_configuration" "main" {
  for_each = {
    for bucket_key, bucket_config in var.s3_buckets : bucket_key => bucket_config
    if bucket_config["lifecycle_status"] != "Disabled"
  }
  depends_on = [aws_s3_bucket.main]
  bucket     = aws_s3_bucket.main[each.key].id

  rule {
    id     = "${each.key}-lifecycle-rule"
    status = title(each.value["lifecycle_status"])
    filter {}
    expiration {
      days = each.value["lifecycle_expiration_days"]
    }
  }
}
