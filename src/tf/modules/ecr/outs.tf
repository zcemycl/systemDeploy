output "ecr_repo_urls" {
  value = { for index, image in var.images : image.name => aws_ecr_repository.this[image.name].repository_url }
}

output "ecr_registry_ids" {
  value = { for index, image in var.images : image.name => aws_ecr_repository.this[image.name].registry_id }
}
