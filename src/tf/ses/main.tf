data "aws_route53_zone" "base_zone" {
  name = var.domain
}

resource "aws_ses_domain_identity" "example" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "example" {
  domain = aws_ses_domain_identity.example.domain
}

resource "aws_route53_record" "example_amazonses_dkim_record" {
  count   = length(aws_ses_domain_dkim.example.dkim_tokens)
  zone_id = data.aws_route53_zone.base_zone.id
  name    = "${aws_ses_domain_dkim.example.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.example.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_ses_email_identity" "example" {
  email = var.email
}
