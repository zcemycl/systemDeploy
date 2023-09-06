resource "aws_ecr_repository" "ecr" {
  for_each = {
    for repo in var.ecr_repositories : repo.name => repo
  }
  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}
