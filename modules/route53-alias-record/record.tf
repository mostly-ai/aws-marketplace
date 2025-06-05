data "aws_route53_zone" "main" {
  name = "${var.hosted_zone}."
}

locals {
  alb_zone_ids = {
    "us-east-1"      = "Z35SXDOTRQ7X7K"
    "us-west-1"      = "Z368ELLRRE2KJ0"
    "us-west-2"      = "Z1H1FL5HABSF5"
    "eu-west-1"      = "Z32O12XQL9TSWT"
    "eu-central-1"   = "Z1U9ULNL0V5AJ3"
    "ap-northeast-1" = "Z1YTCN8TZHMT1"
    "ap-southeast-1" = "Z1LMS91P8CMK55"
    "ap-southeast-2" = "Z1GM3OXH4ZPM65"
    "sa-east-1"      = "Z2P70J7HTTTPLU"
  }
}


resource "aws_route53_record" "main" {
  name    = var.record_name
  zone_id = data.aws_route53_zone.main.zone_id
  type    = "A"

  alias {
    name                   = var.record_value
    zone_id                = local.alb_zone_ids[var.global.aws_region]
    evaluate_target_health = true
  }
}
