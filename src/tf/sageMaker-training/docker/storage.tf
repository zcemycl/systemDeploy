resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "./build_lambda_layer.sh ${var.PYTHON_VER}"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "null_data_source" "this" {
  inputs = {
    lambda_exporter_id = "${null_resource.this.id}"
    source_dir         = "outputs/python"
  }
}

data "archive_file" "this_lambda_layer" {
  type        = "zip"
  source_dir  = data.null_data_source.this.outputs["source_dir"]
  output_path = "outputs/lambda_layer.zip"

  depends_on = [
    null_resource.this
  ]
}

data "archive_file" "this_data" {
  type        = "zip"
  source_dir  = "${path.root}/../data"
  output_path = "outputs/data.zip"
}

data "archive_file" "this_train" {
  type        = "zip"
  source_file = "src/train.py"
  output_path = "outputs/train.zip"
}

data "archive_file" "this_lambda" {
  type        = "zip"
  source_file = "src/lambda_function.py"
  output_path = "outputs/lambda_function.zip"
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.project_prefix}-experiment"
  force_destroy = true
}

resource "aws_s3_bucket_object" "this_data" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "data.zip"
  source        = data.archive_file.this_data.output_path
  force_destroy = true
  etag          = data.archive_file.this_data.output_md5
}

resource "aws_s3_bucket_object" "this_train" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "train.zip"
  source        = data.archive_file.this_train.output_path
  force_destroy = true
  etag          = data.archive_file.this_train.output_md5
}

resource "aws_s3_bucket_object" "this_lambda" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "lambda.zip"
  source        = data.archive_file.this_lambda.output_path
  force_destroy = true
  etag          = data.archive_file.this_lambda.output_md5
}

resource "aws_s3_bucket_object" "this_lambda_layer" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "lambda_layer.zip"
  source        = data.archive_file.this_lambda_layer.output_path
  force_destroy = true
  etag          = data.archive_file.this_lambda_layer.output_md5
}

resource "aws_s3_bucket_object" "this_data_raw" {
  for_each = fileset(path.root, "../data/**/*.jpg")
  bucket   = aws_s3_bucket.this.id
  key      = replace(each.value, "../", "")
  source   = each.value
  etag     = data.archive_file.this_data.output_md5
}
