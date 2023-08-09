data "archive_file" "random_func" {
    type = "zip"
    source_dir = "src/s3-rds-lambda"
    output_path = "src/s3-rds-lambda.zip"
}