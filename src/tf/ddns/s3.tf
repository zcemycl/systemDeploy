resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-bucket-leo-131023"
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_block_public_access" {
  bucket                  = aws_s3_bucket.lambda_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_function_object" {
  key    = "src/lambda.zip"
  bucket = aws_s3_bucket.lambda_bucket.id
  source = data.archive_file.lambda_function.output_path
  # kms_key_id = aws_kms_key.bsc.arn
  etag = data.archive_file.lambda_function.output_md5
}
