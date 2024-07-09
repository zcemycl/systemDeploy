resource "aws_cloudwatch_log_group" "logging" {
  for_each = {
    for log in var.loggings : log.name => log
  }
  name              = each.value.group_name
  retention_in_days = each.value.retention_in_days
}

resource "aws_cloudwatch_log_stream" "logging" {
  for_each = {
    for log in var.loggings : log.name => log
  }
  name           = each.value.stream_name
  log_group_name = aws_cloudwatch_log_group.logging[each.value.name].name
}

resource "aws_vpc_endpoint" "this" {
  for_each = {
    for log in var.loggings : log.name => log if log.enable_vpc_endpt
  }
  vpc_id              = each.value.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = each.value.sg_ids
  subnet_ids          = each.value.subnet_ids
}
