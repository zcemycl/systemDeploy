data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "src/lambda"
  output_path = "src/lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name    = "update-r53"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_function_object.id
  role             = aws_iam_role.lambda_iam.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  layers           = []
  timeout          = 120

  environment {
    variables = {
      BASE_DOMAIN = var.domain
      TABLE_NAME  = var.dynamodb_table_name
    }
  }

}
