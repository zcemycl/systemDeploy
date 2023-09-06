provider "acme" {
  server_url = var.acme_server_url
}

provider "aws" {
  alias  = "acm_eu"
  region = "eu-west-2"
}

# resource "aws_acm_certificate" "certificate_domain" {
#   domain_name       = var.domain
#   validation_method = "DNS"
#   provider          = aws.acm_eu

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_acm_certificate" "certificate_app" {
  domain_name       = var.application_domain
  validation_method = "DNS"
  provider          = aws.acm_eu

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "app_cert" {
  certificate_arn         = aws_acm_certificate.certificate_app.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_app.fqdn]
  provider                = aws.acm_eu
}
