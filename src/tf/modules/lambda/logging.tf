resource "aws_cloudwatch_log_group" "this" {
  for_each          = var.lambda_funcs
  name              = "/aws/lambda/${aws_lambda_function.this[each.key].function_name}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}
