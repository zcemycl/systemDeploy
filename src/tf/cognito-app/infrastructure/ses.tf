data "aws_route53_zone" "this" {
  name = var.domain
}

resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_route53_record" "this" {
  count   = 3 # length(aws_ses_domain_dkim.this.dkim_tokens)
  zone_id = data.aws_route53_zone.this.id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [
    aws_ses_domain_dkim.this
  ]
}

resource "aws_ses_email_identity" "this" {
  email = var.email
}
