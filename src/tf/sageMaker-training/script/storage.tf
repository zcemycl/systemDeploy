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
  bucket        = "sagemaker-training-script-experiment"
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
