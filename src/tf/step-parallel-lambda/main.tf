locals {
  lambda_zip_location = "outputs/lambda_function.zip"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "src/lambda_function.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "test_lambda" {
  filename         = local.lambda_zip_location
  function_name    = "leo_func_source"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_role.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "state_parallel"
  role_arn = aws_iam_role.state_role.arn
  definition = templatefile("state/parallel.json",
    {
      funcname = "leo_func_source"
    }
  )

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_func_log_group.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}
