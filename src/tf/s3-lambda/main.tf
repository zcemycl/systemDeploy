resource "null_resource" "lambda_install_require" {
  provisioner "local-exec" {
    command = "pip install -r src/requirements.txt -t src/python/lib/python3.10/site-packages/"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "null_data_source" "wait_for_lambda_exporter" {
  inputs = {
    lambda_exporter_id = "${null_resource.lambda_install_require.id}"
    source_dir         = "src/python"
  }
}

data "archive_file" "dependencies" {
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]
  output_path = "src/lambda_layer.zip"

  depends_on = [
    null_resource.lambda_install_require
  ]
}

data "archive_file" "random_func" {
  type        = "zip"
  source_dir  = "src/s3-rds-lambda"
  output_path = "src/s3-rds-lambda.zip"
}

resource "aws_s3_bucket" "lambda_functions" {
  bucket = "lambda-functions-leo-090823"
}

resource "aws_s3_object" "upload_s3_rds_lambda" {
  key    = "s3-rds-lambda.zip"
  bucket = aws_s3_bucket.lambda_functions.id
  source = data.archive_file.random_func.output_path
  etag   = data.archive_file.random_func.output_md5
}

resource "aws_s3_object" "upload_s3_rds_lambda_layer" {
  key    = "lambda_layer.zip"
  bucket = aws_s3_bucket.lambda_functions.id
  source = data.archive_file.dependencies.output_path
  etag   = data.archive_file.dependencies.output_md5
}

resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_task_role"
  assume_role_policy = file("policies/lambda-task-role.json")
}

resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.upload_s3_rds_lambda_layer.id
  layer_name       = "base_layer"
  source_code_hash = data.archive_file.dependencies.output_base64sha256

  compatible_runtimes = ["python3.10"]
}

resource "aws_lambda_function" "random_lambda" {
  function_name    = "s3-rds-connection"
  s3_bucket        = aws_s3_bucket.lambda_functions.id
  s3_key           = aws_s3_object.upload_s3_rds_lambda.id
  role             = aws_iam_role.lambda_iam.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.random_func.output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
}

resource "aws_s3_bucket" "trigger_pt" {
  bucket = "trigger-lambda"
}

resource "aws_s3_bucket_notification" "aws_lambda_trigger" {
  bucket = aws_s3_bucket.trigger_pt.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.random_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}
