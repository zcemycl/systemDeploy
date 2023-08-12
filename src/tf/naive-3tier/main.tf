module "ecr" {
  source = "./modules/ecr"
  ecr_repositories = [
    {
      name                 = "app"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "api"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    }
  ]
}

module "logging" {
  source = "./modules/logging"
  loggings = [
    {
      name              = "app"
      group_name        = "/ecs/app"
      stream_name       = "app-log-stream"
      retention_in_days = 3
    },
    {
      name              = "api"
      group_name        = "/ecs/api"
      stream_name       = "api-log-stream"
      retention_in_days = 3
    }
  ]
}
