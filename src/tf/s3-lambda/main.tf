data "archive_file" "random_func" {
    type = "zip"
    source_dir = "src/s3-rds-lambda"
    output_path = "src/s3-rds-lambda.zip"
}

resource "aws_s3_bucket" "lambda_functions" {
    bucket = "lambda-functions-leo-090823"
}

resource "aws_s3_object" "upload_s3_rds_lambda" {
    key = "s3-rds-lambda.zip"
    bucket = aws_s3_bucket.lambda_functions.id
    source = data.archive_file.random_func.output_path
    etag = data.archive_file.random_func.output_md5
}

resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_task_role"
  assume_role_policy = file("policies/lambda-task-role.json")
}

resource "aws_lambda_function" "random_lambda" {
    function_name = "s3-rds-connection"
    s3_bucket = aws_s3_bucket.lambda_functions.id
    s3_key = aws_s3_object.upload_s3_rds_lambda.id
    role = aws_iam_role.lambda_iam.arn
    handler = "s3-rds-lambda/lambda_function.lambda_handler"
    runtime = "python3.10"
    source_code_hash = data.archive_file.random_func.output_base64sha256
}