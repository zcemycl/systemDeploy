locals {
  storage_subfolders = flatten([
    for bucket_name, bucket_folder in var.list_bucket_names : [
      for bucket_folder_name, bucket_folder_att in bucket_folder : {
        bucket_name = bucket_name
        folder_key  = "${bucket_folder_name}/"
      }
    ]
  ])
}

resource "aws_s3_bucket" "this" {
  for_each      = var.list_bucket_names
  bucket        = "${each.key}-bucket"
  force_destroy = true
}

resource "aws_s3_object" "this_subfolder" {
  for_each     = { for index, item in local.storage_subfolders : index => item }
  bucket       = aws_s3_bucket.this[each.value.bucket_name].id
  key          = each.value.folder_key
  content_type = "application/x-directory"
}
