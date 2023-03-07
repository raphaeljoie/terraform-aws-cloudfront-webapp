
resource "aws_acm_certificate" "certificate" {
  count = 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "this" {
  count = 0
  name = join(".", slice( split(".", var.domain_name), 1, length(split(".", var.domain_name))))
  private_zone = true
}

resource "aws_route53_record" "example" {
  for_each = true ? {} : {
  for dvo in aws_acm_certificate.certificate[0].domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this[0].zone_id
}
