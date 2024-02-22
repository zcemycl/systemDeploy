data "archive_file" "this_lambda" {
  type        = "zip"
  source_file = "src/lambda_function.py"
  output_path = "outputs/lambda_function.zip"
}

resource "aws_s3_bucket" "this" {
  bucket        = "leo-trial-batch-experiment"
  force_destroy = true
}

resource "aws_s3_bucket_object" "this_lambda" {
  bucket        = aws_s3_bucket.this.bucket
  key           = "lambda.zip"
  source        = data.archive_file.this_lambda.output_path
  force_destroy = true
  etag          = data.archive_file.this_lambda.output_md5
}
