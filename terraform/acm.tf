resource "aws_acm_certificate" "harbor" {
  domain_name       = local.harbor_endpoint
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "harbor_validation" {
  for_each = {
    for dvo in aws_acm_certificate.harbor.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.intermediate_domain.zone_id
}

resource "aws_acm_certificate_validation" "harbor" {
  certificate_arn         = aws_acm_certificate.harbor.arn
  validation_record_fqdns = [for record in aws_route53_record.harbor_validation : record.fqdn]
}
