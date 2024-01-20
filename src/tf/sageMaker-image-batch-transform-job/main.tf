locals {
  prefix              = "dummy-batch-transform-job"
  lambda_zip_location = "outputs/lambda_function.zip"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "src/lambda-invoke/lambda_function.py"
  output_path = local.lambda_zip_location
}

# data "archive_file" "dummy_model" {
#   type        = "tar"
#   source_file = "src/lambda-invoke/lambda_function.py"
#   output_path = "outputs/model.tar"
# }

resource "aws_s3_bucket" "this" {
  bucket        = "${local.prefix}-bucket"
  force_destroy = false
}

resource "aws_s3_bucket_object" "this" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "model.tar.gz"
  source        = "outputs/model.tar.gz"
  force_destroy = false
}

resource "aws_s3_bucket_object" "this_jsonl" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "inputs/raw.jsonl"
  source        = "data/raw.jsonl"
  force_destroy = false
}

resource "aws_ecr_repository" "this" {
  name         = local.prefix
  force_delete = true
}

resource "null_resource" "push_docker_image" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker tag test-dummy-sagemaker-image2:latest ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  depends_on = [
    aws_ecr_repository.this
  ]
}

resource "aws_sagemaker_model" "this" {
  name               = "${local.prefix}-sagemaker-model"
  execution_role_arn = aws_iam_role.this.arn

  primary_container {
    image          = "${aws_ecr_repository.this.repository_url}:latest"
    mode           = "SingleModel"
    model_data_url = "s3://${aws_s3_bucket.this.bucket}/${aws_s3_bucket_object.this.id}"
  }

  depends_on = [
    null_resource.push_docker_image,
    aws_s3_bucket_object.this
  ]
}

resource "aws_lambda_function" "this" {
  filename         = local.lambda_zip_location
  function_name    = "${local.prefix}-sagemaker-invoke"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  runtime          = "python3.10"
  role             = aws_iam_role.this_lambda.arn
  timeout          = 900 # max

  environment {
    variables = {
      model_name = aws_sagemaker_model.this.name
    }
  }
}
