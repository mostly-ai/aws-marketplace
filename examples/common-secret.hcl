locals {
  aws_access_key = get_env("AWS_ACCESS_KEY_ID", "nonexistent")
  aws_secret_key = get_env("AWS_SECRET_ACCESS_KEY", "nonexistent")
  aws_session_token = get_env("AWS_SESSION_TOKEN", "nonexistent")
}
