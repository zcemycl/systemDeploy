output "service_publisher_access_key_id" {
    value = aws_iam_access_key.service_publisher.id
}

output "service_publisher_access_key_secret" {
    value = aws_iam_access_key.service_publisher.secret
    sensitive = true
}