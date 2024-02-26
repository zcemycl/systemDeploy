resource "aws_datasync_location_efs" "this" {
  efs_file_system_arn = aws_efs_file_system.this.arn
  access_point_arn    = aws_efs_access_point.this.arn

  ec2_config {
    security_group_arns = [aws_security_group.this.arn]
    subnet_arn          = data.aws_subnet.this[data.aws_subnets.this.ids[0]].arn
  }
  in_transit_encryption       = "TLS1_2"
  subdirectory                = "/"
  file_system_access_role_arn = aws_iam_role.this_datasync.arn

  depends_on = [
    aws_efs_mount_target.this
  ]
}

resource "aws_datasync_location_s3" "this" {
  s3_bucket_arn = aws_s3_bucket.this.arn
  subdirectory  = "/data/" ##sub folder in s3 bucket where are objects should store
  s3_config {
    bucket_access_role_arn = aws_iam_role.this_datasync.arn
  }
  s3_storage_class = "STANDARD" #"DEEP_ARCHIVE"
}

resource "aws_datasync_task" "this" {
  source_location_arn      = aws_datasync_location_s3.this.arn
  destination_location_arn = aws_datasync_location_efs.this.arn

  options {
    atime                  = "BEST_EFFORT"
    overwrite_mode         = "ALWAYS"
    bytes_per_second       = "-1"
    preserve_deleted_files = "PRESERVE"
    task_queueing          = "ENABLED"
    transfer_mode          = "ALL"
    verify_mode            = "POINT_IN_TIME_CONSISTENT"
  }

  schedule {
    schedule_expression = "cron(0 12 ? * SUN,WED *)"
  }
}
