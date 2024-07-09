output "ecr_repo_urls" {
  value = { for index, image in var.images : image.name => aws_ecr_repository.this[image.name].repository_url }
}
