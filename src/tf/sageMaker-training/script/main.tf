resource "aws_lambda_layer_version" "this" {
  s3_bucket        = aws_s3_bucket.this.id
  s3_key           = aws_s3_bucket_object.this_lambda_layer.id
  layer_name       = "sagemaker_layer"
  source_code_hash = data.archive_file.this_lambda_layer.output_base64sha256

  compatible_runtimes = [var.PYTHON_VER]
}

resource "aws_lambda_function" "this" {
  s3_bucket        = aws_s3_bucket.this.bucket
  s3_key           = aws_s3_bucket_object.this_lambda.id
  function_name    = "sagemaker_training_script_invoke"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.this_data.output_base64sha256
  runtime          = var.PYTHON_VER
  role             = aws_iam_role.this.arn
  timeout          = 900 # max
  layers           = [aws_lambda_layer_version.this.arn]

  environment {
    variables = {
      script_s3_key      = aws_s3_bucket_object.this_train.id
      script_s3_bucket   = aws_s3_bucket.this.bucket
      sagemaker_role_arn = aws_iam_role.this_sagemaker.arn
    }
  }
}

resource "aws_sagemaker_notebook_instance" "ni" {
  name          = "sagemaker-training-script-invoke-notebook-instance"
  role_arn      = aws_iam_role.this_sagemaker.arn
  instance_type = "ml.t2.medium"
}
