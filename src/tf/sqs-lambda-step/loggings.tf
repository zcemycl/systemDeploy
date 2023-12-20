resource "aws_cloudwatch_log_group" "waittime_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.assign_waittime.id}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "api_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.call_ratelimit_api.id}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "step_func_log_group" {
  name              = "step_func_exec_loggroup"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
