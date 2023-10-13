data "aws_route53_zone" "base_zone" {
  name = var.domain
}

resource "aws_route53_zone" "ddns_zone" {
  name = var.ddns_domain
}

resource "aws_route53_record" "ns_record_sub_to_base" {
  type    = "NS"
  zone_id = data.aws_route53_zone.base_zone.id
  name    = var.subdomain
  ttl     = "60"
  records = aws_route53_zone.ddns_zone.name_servers
}

resource "aws_route53_record" "base_ddns" {
  name    = var.ddns_domain
  type    = "A"
  zone_id = aws_route53_zone.ddns_zone.id
  ttl     = 300

  records = [var.target_isp_ip]
}
