resource "aws_lambda_function" "this" {
  s3_bucket        = aws_s3_bucket.this.bucket
  s3_key           = aws_s3_bucket_object.this_lambda.id
  function_name    = "sagemaker_training_script_invoke"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.this_data.output_base64sha256
  runtime          = "python3.10"
  role             = aws_iam_role.this.arn
  timeout          = 900 # max
}
