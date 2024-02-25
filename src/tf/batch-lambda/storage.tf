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

resource "aws_vpc_endpoint" "this" {
  vpc_id       = "vpc-edb1c285"
  service_name = "com.amazonaws.eu-west-2.s3"
}

resource "aws_vpc_endpoint_route_table_association" "this" {
  for_each        = { for id in data.aws_route_tables.this.ids : id => id }
  route_table_id  = each.value
  vpc_endpoint_id = aws_vpc_endpoint.this.id
}
