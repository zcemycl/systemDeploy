resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.id}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "step_func_log_group" {
  name              = "step_func_exec_loggroup"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}
