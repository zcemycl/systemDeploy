output "hash_lambda_func_zip" {
  value = data.archive_file.random_func.output_base64sha256
}
