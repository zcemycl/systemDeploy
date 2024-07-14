resource "aws_iam_role" "this_srv" {
  name               = "${var.prefix}-hotload-task-srv"
  assume_role_policy = file("${path.module}/iam/ecs_assume_policy.json")
}

resource "aws_iam_policy" "this_srv" {
  policy = file("${path.module}/iam/ecs_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_srv" {
  policy_arn = aws_iam_policy.this_srv.arn
  role       = aws_iam_role.this_srv.id
}

resource "aws_iam_role" "this_task_exe" {
  name               = "${var.prefix}-hotload-task-exe"
  assume_role_policy = file("${path.module}/iam/ecs-task_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_task_exe" {
  role       = aws_iam_role.this_task_exe.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "this_task" {
  name               = "${var.prefix}-hotload-task"
  assume_role_policy = file("${path.module}/iam/ecs-task_assume_policy.json")
}



resource "aws_ecs_task_definition" "this" {
  family                   = "${var.prefix}_etl2_hotload"
  execution_role_arn       = aws_iam_role.this_task_exe.arn
  task_role_arn            = aws_iam_role.this_task.arn
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    {
      name      = "etl2-container-hotload"
      image     = "${module.ecr.ecr_repo_urls["${var.prefix}-etl2-code-server"]}:latest"
      essential = true
      command   = ["dagster", "code-server", "start", "-h", "0.0.0.0", "-p", "4002", "-m", "etl2"]
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
          containerPort = 4002
          hostPort      = 4002
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.logging.log_groups["etl2-hotload"].name
          awslogs-stream-prefix = "etl2-hotload"
          awslogs-region        = var.AWS_REGION
        }
      }
    }
  ])
}

resource "aws_service_discovery_service" "this_hotload" {
  name = "etl2hotload"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = 300
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }

  lifecycle {
    ignore_changes = [health_check_custom_config]
  }
}

resource "aws_ecs_service" "this_hotload" {
  name            = "hotload-etl2"
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.this.arn

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  network_configuration {
    security_groups = [module.security_groups.sg_ids["everything"].id]
    subnets         = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this_hotload.arn
  }
}
