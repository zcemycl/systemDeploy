resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-storage"
  force_destroy = true
}

resource "aws_s3_object" "this" {
  bucket       = aws_s3_bucket.this.id
  key          = "some-key"
  content_type = "application/x-directory"
}
