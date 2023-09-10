provider "acme" {
  server_url = var.acme_server_url
}

provider "aws" {
  alias  = "acm_eu"
  region = "eu-west-2"
}

resource "aws_acm_certificate" "certificate_domain" {
  domain_name       = var.domain
  validation_method = "DNS"
  provider          = aws.acm_eu

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "certificate_app" {
  domain_name       = "${var.subdomain}.${var.domain}"
  validation_method = "DNS"
  provider          = aws.acm_eu

  subject_alternative_names = [
    "*.${var.subdomain}.${var.domain}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "root_cert" {
  certificate_arn         = aws_acm_certificate.certificate_domain.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_domain.fqdn]
  provider                = aws.acm_eu
}

resource "aws_acm_certificate_validation" "app_cert" {
  certificate_arn         = aws_acm_certificate.certificate_app.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_app.fqdn]
  provider                = aws.acm_eu
}

resource "aws_acm_certificate" "server_vpn_cert" {
  certificate_body  = file("~/my-vpn-files/server.crt")
  private_key       = file("~/my-vpn-files/server.key")
  certificate_chain = file("~/my-vpn-files/ca.crt")
}

resource "aws_acm_certificate" "client_vpn_cert" {
  certificate_body  = file("~/my-vpn-files/client1.domain.tld.crt")
  private_key       = file("~/my-vpn-files/client1.domain.tld.key")
  certificate_chain = file("~/my-vpn-files/ca.crt")
}
