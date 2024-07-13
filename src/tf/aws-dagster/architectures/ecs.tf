locals {
  _share_postgres_env_vars = [
    {
      name  = "DAGSTER_POSTGRES_USER"
      value = random_string.this.result
    },
    {
      name  = "DAGSTER_POSTGRES_PASSWORD"
      value = random_password.this.result
    },
    {
      name  = "DAGSTER_POSTGRES_DB"
      value = aws_db_instance.this.db_name
    },
    {
      name  = "DAGSTER_POSTGRES_PORT"
      value = tostring(aws_db_instance.this.port)
    },
    {
      name  = "DAGSTER_POSTGRES_HOSTNAME"
      value = aws_db_instance.this.address
    }
  ]
  _code_locs_env_vars = [
    {
      name  = "ETL1_CODE_SERVER_HOST"
      value = "etl1.${var.cloud_map_namespace}"
    },
    {
      name  = "ETL1_CODE_SERVER_PORT"
      value = "4000"
    },
    {
      name  = "ETL1_CODE_LOC_NAME"
      value = "user_code_etl1"
    },
    {
      name  = "ETL2_CODE_SERVER_HOST"
      value = "etl2.${var.cloud_map_namespace}"
    },
    {
      name  = "ETL2_CODE_SERVER_PORT"
      value = "4001"
    },
    {
      name  = "ETL2_CODE_LOC_NAME"
      value = "user_code_etl2"
    }
  ]
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = var.cloud_map_namespace
  vpc  = aws_vpc.this.id
}

resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "ecs_srv_task" {
  source                            = "github.com/zcemycl/systemDeploy/src/tf/modules/ecs"
  prefix                            = var.prefix
  cloudmap_private_dns_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  service_task_definitions = {
    etl1 = {
      enable_ecs_service       = true
      enable_task_schedule     = false
      enable_service_schedule  = true
      enable_service_discovery = true
      service_discovery_name   = "etl1"
      service_dns_type         = "A"
      service_dns_ttl          = 300
      task_name                = "etl1-task-def"
      task_cpu                 = 512
      task_memory              = 2048
      task_container_defs = [
        {
          name      = "etl1-container"
          image     = "${module.ecr.ecr_repo_urls["${var.prefix}-etl1-code-server"]}:latest"
          essential = true
          command   = ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-m", "etl1"]
          environment = flatten([
            [
              {
                name  = "ENV"
                value = "dev"
              },
              {
                name  = "DAGSTER_CURRENT_IMAGE"
                value = "${module.ecr.ecr_repo_urls["${var.prefix}-etl1-code-server"]}:latest"
              }
            ],
            local._share_postgres_env_vars,
          ])
          portMappings = [
            {
              containerPort = 4000
              hostPort      = 4000
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.logging.log_groups["etl1"].name
              awslogs-stream-prefix = "etl1"
              awslogs-region        = var.AWS_REGION
            }
          }
        }
      ]
      service_name     = "etl1-service"
      cluster_id       = aws_ecs_cluster.this.id
      cluster_arn      = aws_ecs_cluster.this.arn
      sg_ids           = [module.security_groups.sg_ids["everything"].id]
      subnet_ids       = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
      lb_target_groups = []
    }
    etl2 = {
      enable_ecs_service       = true
      enable_task_schedule     = false
      enable_service_schedule  = true
      enable_service_discovery = true
      service_discovery_name   = "etl2"
      service_dns_type         = "A"
      service_dns_ttl          = 300
      task_name                = "etl2-task-def"
      task_cpu                 = 512
      task_memory              = 2048
      task_container_defs = [
        {
          name      = "etl2-container"
          image     = "${module.ecr.ecr_repo_urls["${var.prefix}-etl2-code-server"]}:latest"
          essential = true
          command   = ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4001", "-m", "etl2"]
          environment = flatten([
            [
              {
                name  = "ENV"
                value = "dev"
              },
              {
                name  = "DAGSTER_CURRENT_IMAGE"
                value = "${module.ecr.ecr_repo_urls["${var.prefix}-etl2-code-server"]}:latest"
              }
            ],
            local._share_postgres_env_vars,
          ])
          portMappings = [
            {
              containerPort = 4001
              hostPort      = 4001
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.logging.log_groups["etl2"].name
              awslogs-stream-prefix = "etl2"
              awslogs-region        = var.AWS_REGION
            }
          }
        }
      ]
      service_name     = "etl2-service"
      cluster_id       = aws_ecs_cluster.this.id
      cluster_arn      = aws_ecs_cluster.this.arn
      sg_ids           = [module.security_groups.sg_ids["everything"].id]
      subnet_ids       = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
      lb_target_groups = []
    }
    webserver = {
      enable_ecs_service       = true
      enable_task_schedule     = false
      enable_service_schedule  = true
      enable_service_discovery = true
      service_discovery_name   = "webserver"
      service_dns_type         = "A"
      service_dns_ttl          = 300
      task_name                = "webserver-task-def"
      task_cpu                 = 1024
      task_memory              = 2048
      task_container_defs = [
        {
          name      = "webserver-container"
          image     = "${module.ecr.ecr_repo_urls["${var.prefix}-dagster-webserver"]}:latest"
          essential = true
          command   = ["dagster-webserver", "-h", "0.0.0.0", "-p", "3000", "-w", "workspace.yaml"]
          environment = flatten([
            [
              {
                name  = "ENV"
                value = "dev"
              }
            ],
            local._share_postgres_env_vars,
            local._code_locs_env_vars
          ])
          portMappings = [
            {
              containerPort = 3000
              hostPort      = 3000
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.logging.log_groups["webserver"].name
              awslogs-stream-prefix = "webserver"
              awslogs-region        = var.AWS_REGION
            }
          }
        }
      ]
      service_name     = "webserver-service"
      cluster_id       = aws_ecs_cluster.this.id
      cluster_arn      = aws_ecs_cluster.this.arn
      sg_ids           = [module.security_groups.sg_ids["everything"].id]
      subnet_ids       = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
      lb_target_groups = []
    }
    daemon = {
      enable_ecs_service       = true
      enable_task_schedule     = false
      enable_service_schedule  = true
      enable_service_discovery = true
      service_discovery_name   = "daemon"
      service_dns_type         = "A"
      service_dns_ttl          = 300
      task_name                = "daemon-task-def"
      task_cpu                 = 1024
      task_memory              = 2048
      task_container_defs = [
        {
          name      = "daemon-container"
          image     = "${module.ecr.ecr_repo_urls["${var.prefix}-dagster-webserver"]}:latest"
          essential = true
          command   = ["dagster-daemon", "run"]
          environment = flatten([
            [
              {
                name  = "ENV"
                value = "dev"
              }
            ],
            local._share_postgres_env_vars,
            local._code_locs_env_vars
          ])
          portMappings = [
            {
              containerPort = 3000
              hostPort      = 3000
            }
          ]
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = module.logging.log_groups["daemon"].name
              awslogs-stream-prefix = "daemon"
              awslogs-region        = var.AWS_REGION
            }
          }
        }
      ]
      service_name     = "daemon-service"
      cluster_id       = aws_ecs_cluster.this.id
      cluster_arn      = aws_ecs_cluster.this.arn
      sg_ids           = [module.security_groups.sg_ids["everything"].id]
      subnet_ids       = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
      lb_target_groups = []
    }
  }
}
