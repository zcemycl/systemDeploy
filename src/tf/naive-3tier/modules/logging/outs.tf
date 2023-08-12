output "app_log_group" {
  value = aws_cloudwatch_log_group.logging["app"].name
}

output "api_log_group" {
  value = aws_cloudwatch_log_group.logging["api"].name
}
