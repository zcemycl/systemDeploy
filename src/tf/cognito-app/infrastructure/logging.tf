resource "aws_cloudwatch_log_group" "this" {
  for_each          = local.lambda_funcs
  name              = "/aws/lambda/${aws_lambda_function.this[each.key].function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}
