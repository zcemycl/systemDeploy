resource "aws_dynamodb_table" "dns_record_table" {
  name         = "dns_record_catalog"
  billing_mode = "PAY_PER_REQUEST"
  # read_capacity    = 1
  # write_capacity   = 1
  hash_key = "subdomain_name"
  attribute {
    name = "subdomain_name"
    type = "S"
  }
  # attribute {
  #   name = "zone_id"
  #   type = "S"
  # }
}
