output "iam_access_key_id" {
  value     = aws_iam_access_key.main.id
  sensitive = true
}

output "iam_secret_access_key" {
  value     = aws_iam_access_key.main.secret
  sensitive = true
}

output "bucket_name" {
  value = aws_s3_bucket.main[keys(aws_s3_bucket.main)[0]].bucket
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
