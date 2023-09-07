# resource "aws_route53_zone" "base_zone" {
#   name = var.domain
# }
data "aws_route53_zone" "base_zone" {
  name = var.domain
}

resource "aws_route53_record" "cert_validation_domain" {
  name            = tolist(aws_acm_certificate.certificate_domain.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.certificate_domain.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.base_zone.id
  records         = [tolist(aws_acm_certificate.certificate_domain.domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
  provider        = aws.acm_eu
}

resource "aws_route53_zone" "app_zone" {
  name = var.application_domain
}

resource "aws_route53_record" "cert_validation_app" {
  name            = tolist(aws_acm_certificate.certificate_app.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.certificate_app.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.app_zone.id
  records         = [tolist(aws_acm_certificate.certificate_app.domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
  provider        = aws.acm_eu
}

resource "aws_route53_record" "ns_record_sub_to_base" {
  type    = "NS"
  zone_id = data.aws_route53_zone.base_zone.id
  name    = "naive"
  ttl     = "60"
  records = aws_route53_zone.app_zone.name_servers
}

resource "aws_route53_record" "base_alb_frontend" {
  name    = var.application_domain
  type    = "A"
  zone_id = aws_route53_zone.app_zone.id

  alias {
    name                   = "dualstack.${aws_lb.alb.dns_name}"
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_frontend" {
  name    = "wwww.${var.application_domain}"
  type    = "A"
  zone_id = aws_route53_zone.app_zone.id

  alias {
    name                   = aws_route53_record.base_alb_frontend.name
    zone_id                = aws_route53_zone.app_zone.id
    evaluate_target_health = true
  }
}
