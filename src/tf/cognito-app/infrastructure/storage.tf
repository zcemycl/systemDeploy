locals {
  lambda_funcs = {
    "create_auth_challenge" : {}
    "define_auth_challenge" : {}
    "verify_auth_challenge" : {}
  }
}

data "archive_file" "this_lambda" {
  for_each    = local.lambda_funcs
  type        = "zip"
  source_file = "src/${each.key}/main.py"
  output_path = "outputs/${each.key}.zip"
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.project_name}-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_object" "this" {
  for_each      = local.lambda_funcs
  bucket        = aws_s3_bucket.this.bucket
  key           = "${each.key}.zip"
  source        = data.archive_file.this_lambda[each.key].output_path
  force_destroy = true
  etag          = data.archive_file.this_lambda[each.key].output_md5
}
