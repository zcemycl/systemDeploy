resource "aws_lambda_function" "this" {
  for_each         = var.lambda_funcs
  s3_bucket        = aws_s3_bucket.this.bucket
  s3_key           = aws_s3_bucket_object.this[each.key].id
  function_name    = each.key
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.this_lambda[each.key].output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.this[each.key].arn
  timeout          = 900

  vpc_config {
    subnet_ids         = each.value.subnet_ids
    security_group_ids = each.value.sg_ids
  }
}
