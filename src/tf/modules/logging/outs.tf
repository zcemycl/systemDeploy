output "log_groups" {
  value = aws_cloudwatch_log_group.logging
}

output "stream_groups" {
  value = aws_cloudwatch_log_stream.logging
}
