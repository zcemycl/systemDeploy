locals {
  lambda_zip_location = "outputs/lambda_function.zip"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "src/random_func/lambda_function.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "test_lambda" {
  filename         = local.lambda_zip_location
  function_name    = "leo_func_sns_source"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = "python3.10"
  role             = aws_iam_role.lambda_role.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.leo_updates.arn
}
