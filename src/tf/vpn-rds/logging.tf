resource "aws_cloudwatch_log_group" "logging" {
  name              = "/vpc/vpn"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_stream" "logging" {
  name           = "log-vpn"
  log_group_name = aws_cloudwatch_log_group.logging.name
}
