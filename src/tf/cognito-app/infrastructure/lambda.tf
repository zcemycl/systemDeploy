resource "aws_lambda_function" "this" {
  for_each         = local.lambda_funcs
  s3_bucket        = aws_s3_bucket.this.bucket
  s3_key           = aws_s3_bucket_object.this[each.key].id
  function_name    = each.key
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.this_lambda[each.key].output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.this.arn
  timeout          = 900
  layers           = []

  environment {
    variables = {
      DOMAIN_NAME    = var.domain
      AUTH_CODE_SALT = var.auth_code_salt
    }
  }
}

resource "aws_lambda_permission" "allow_execution_from_user_pool" {
  for_each      = local.lambda_funcs
  statement_id  = "AllowExecutionFromUserPool"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
