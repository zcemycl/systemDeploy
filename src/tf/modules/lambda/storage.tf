resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-common-lambda-bucket"
  force_destroy = true
}

data "archive_file" "this_lambda" {
  for_each    = var.lambda_funcs
  type        = "zip"
  source_file = "${path.module}/src/${each.value.path}/main.py"
  output_path = "${path.module}/outputs/${each.value.path}.zip"
}

resource "aws_s3_bucket_object" "this" {
  for_each      = var.lambda_funcs
  bucket        = aws_s3_bucket.this.bucket
  key           = "${each.value.path}.zip"
  source        = data.archive_file.this_lambda[each.key].output_path
  force_destroy = true
  etag          = data.archive_file.this_lambda[each.key].output_md5
}
