output "app_image" {
  value = aws_ecr_repository.ecr["app"].repository_url
}

output "api_image" {
  value = aws_ecr_repository.ecr["api"].repository_url
}
