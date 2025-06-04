data "aws_route53_zone" "main" {
  name = "${var.hosted_zone}."
}

resource "aws_route53_record" "main" {
  name    = var.record_name
  type    = var.record_type
  zone_id = data.aws_route53_zone.main.zone_id
  records = var.record_value
}
