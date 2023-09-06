provider "acme" {
  server_url = var.acme_server_url
}

resource "aws_acm_certificate" "certificate_app" {
  domain_name       = var.application_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "app_cert" {
  certificate_arn         = aws_acm_certificate.certificate_app.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_app.fqdn]
}
