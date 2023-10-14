resource "aws_dynamodb_table" "dns_record_table" {
  name         = "dns_record_catalog"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "subdomain_name"
  attribute {
    name = "subdomain_name"
    type = "S"
  }
  # attribute {
  #   name = "zone_id"
  #   type = "S"
  # }
}

resource "aws_dynamodb_table_item" "ddns_record_items" {
  table_name = aws_dynamodb_table.dns_record_table.name
  hash_key   = aws_dynamodb_table.dns_record_table.hash_key

  for_each = {
    "${var.ddns_domain}" = {
      zone_id = "${aws_route53_zone.ddns_zone.id}"
    }
    "${var.domain}" = {
      zone_id = "${data.aws_route53_zone.base_zone.id}"
    }
  }
  item = <<ITEM
  {
    "subdomain_name": {"S": "${each.key}"},
    "zone_id": {"S": "${each.value.zone_id}"}
  }
  ITEM
}
