resource "aws_efs_file_system" "this" {}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.root}/../sageMaker-training/data"
  output_path = "outputs/data.zip"
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.project_name}-buckett"
  force_destroy = true
}

resource "aws_s3_bucket_object" "this" {
  for_each = fileset(path.root, "../sageMaker-training/data/**/*.jpg")
  bucket   = aws_s3_bucket.this.id
  key      = replace(each.value, "../sageMaker-training/", "")
  source   = each.value
  etag     = data.archive_file.this.output_md5
}
