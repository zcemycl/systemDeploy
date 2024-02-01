resource "aws_ecr_repository" "this" {
  name         = "sagemaker_training_docker_invoke"
  force_delete = true
}

resource "null_resource" "this_docker" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker tag ${var.local_docker_name}:latest ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  depends_on = [
    aws_ecr_repository.this
  ]

  triggers = {
    always_run = "${timestamp()}"
  }
}

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
      container_image_uri = aws_ecr_repository.this.repository_url
      script_s3_bucket    = aws_s3_bucket.this.bucket
      sagemaker_role_arn  = aws_iam_role.this_sagemaker.arn
    }
  }
}

resource "aws_sagemaker_notebook_instance" "this" {
  name                  = "sagemaker-training-script-invoke-notebook-instance"
  role_arn              = aws_iam_role.this_sagemaker.arn
  instance_type         = "ml.t2.medium"
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.this.name
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "this" {
  name = "sagemaker-training-script-invoke-notebook-instance-config"
  on_create = base64encode(templatefile(
    "notebooks/on_start.sh",
    {
      container_image_uri = aws_ecr_repository.this.repository_url
      script_s3_bucket    = aws_s3_bucket.this.id
      sagemaker_role_arn  = aws_iam_role.this_sagemaker.arn
    }
  ))
  on_start = base64encode(templatefile(
    "notebooks/on_start.sh",
    {
      container_image_uri = aws_ecr_repository.this.repository_url
      script_s3_bucket    = aws_s3_bucket.this.id
      sagemaker_role_arn  = aws_iam_role.this_sagemaker.arn
    }
  ))
}
