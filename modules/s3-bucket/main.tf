terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0"
    }
  }
  required_version = ">= 1.9.0"
}

provider "aws" {
  access_key = var.global_secret.aws_access_key
  secret_key = var.global_secret.aws_secret_key
  token      = var.global_secret.aws_session_token
  region     = var.global.aws_region
}
