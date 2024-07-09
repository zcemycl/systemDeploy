resource "aws_ecr_repository" "this" {
  for_each = {
    for index, image in var.images : image.name => image
  }
  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = {
    for index, image in var.images : image.name => image
  }
  repository = aws_ecr_repository.this[each.key].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${each.value.lastn} images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": ${each.value.lastn}
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 5 untagged images",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  for_each = {
    for index, image in var.images : image.name => image if image.enable_vpc_endpt
  }
  vpc_id              = each.value.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = each.value.sg_ids
  subnet_ids         = each.value.subnet_ids
}

resource "aws_vpc_endpoint" "ecr_api" {
  for_each = {
    for index, image in var.images : image.name => image if image.enable_vpc_endpt
  }
  vpc_id              = each.value.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = each.value.sg_ids
  subnet_ids         = each.value.subnet_ids
}

resource "aws_vpc_endpoint" "s3" {
  for_each = {
    for index, image in var.images : image.name => image if image.enable_vpc_endpt
  }
  vpc_id            = each.value.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = each.value.route_table_ids
}
