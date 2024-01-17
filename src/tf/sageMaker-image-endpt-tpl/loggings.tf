resource "aws_cloudwatch_log_group" "endpt" {
  name              = "/aws/sagemaker/Endpoints/${aws_sagemaker_endpoint.this.name}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}
