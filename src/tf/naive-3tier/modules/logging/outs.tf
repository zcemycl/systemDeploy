output "app_log_group" {
  value = aws_cloudwatch_log_group.logging["app"].name
}

output "api_log_group" {
  value = aws_cloudwatch_log_group.logging["api"].name
}

output "log_groups" {
  value = aws_cloudwatch_log_group.logging
}

output "stream_groups" {
  value = aws_cloudwatch_log_stream.logging
}
