output "app_image" {
  value = aws_ecr_repository.ecr["app"].repository_url
}

output "api_image" {
  value = aws_ecr_repository.ecr["api"].repository_url
}

output "app_repo_id" {
  value = aws_ecr_repository.ecr["app"].registry_id
}

output "api_repo_id" {
  value = aws_ecr_repository.ecr["api"].registry_id
}
