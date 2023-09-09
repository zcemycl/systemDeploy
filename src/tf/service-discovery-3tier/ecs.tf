resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
}

resource "aws_ecs_task_definition" "app_task_definition" {
  family                   = "app-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "${module.ecr.app_image}:latest"
      essential = true
      environment = [
        { "name" : "APP_PORT", "value" : "80" },
        {
          "name" : "BACKEND_HOST",
          "value" : "http://${var.internal_serv_name}.${var.internal_domain_name}:${var.api_port}"
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.logging.app_log_group
          awslogs-stream-prefix = "app"
          awslogs-region        = var.aws_region
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app_ecs_service" {
  name                               = "app-service"
  cluster                            = aws_ecs_cluster.app_cluster.id
  task_definition                    = aws_ecs_task_definition.app_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = [module.security_groups.sg_ids["app"].id]
    subnets         = module.app_network.subnets.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name   = "app-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_target_group.app_target_group
  ]
}

# ----------------------------------------------------------- #
# api
resource "aws_ecs_cluster" "api_cluster" {
  name = "api-cluster"
}

resource "aws_ecs_task_definition" "api_task_definition" {
  family                   = "api-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "api-container"
      image     = "${module.ecr.api_image}:latest"
      essential = true
      environment = [
        { "name" : "APP_PORT", "value" : "${tostring(var.api_port)}" },
        { "name" : "APP_LISTEN_IP", "value" : "0.0.0.0" },
        { "name" : "RDS_HOST", "value" : "" },
        { "name" : "RDS_PWD", "value" : "" }
      ]
      portMappings = [
        {
          containerPort = var.api_port
          hostPort      = var.api_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.logging.api_log_group
          awslogs-stream-prefix = "api"
          awslogs-region        = var.aws_region
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api_ecs_service" {
  name                               = "api-service"
  cluster                            = aws_ecs_cluster.api_cluster.id
  task_definition                    = aws_ecs_task_definition.api_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = [module.security_groups.sg_ids["api"].id]
    subnets         = module.api_network.subnets.*.id
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }
}
