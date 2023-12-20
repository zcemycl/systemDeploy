resource "aws_dynamodb_table" "request_order_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "counter_key"
  range_key    = "counter_val"
  attribute {
    name = "counter_key"
    type = "S"
  }

  attribute {
    name = "counter_val"
    type = "N"
  }
}

resource "aws_dynamodb_table_item" "default_item" {
  table_name = aws_dynamodb_table.request_order_table.name
  hash_key   = aws_dynamodb_table.request_order_table.hash_key
  range_key  = aws_dynamodb_table.request_order_table.range_key

  item = <<ITEM
  {
    "counter_key": {"S": "0"},
    "counter_val": {"N": "0"}
  }
  ITEM
}
