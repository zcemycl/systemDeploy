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

module "secrets" {
  source = "./modules/secrets"
  secrets = [
    {
      name          = "rds"
      group_name    = "rds-secrets"
      secret_string = <<EOF
            {
                "db_user": "postgres"
                "db_pwd": ""
                "db_host": ""
                "db_port": 5432
            }
        EOF
    },
    {
      name          = "app"
      group_name    = "app-secrets"
      secret_string = <<EOF
            {
                "app_user": "hi"
            }
        EOF
    }
  ]
}
