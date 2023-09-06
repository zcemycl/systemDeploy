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
        { "name" : "BACKEND_HOST", "value" : "http://0.0.0.0:5555" }
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
    security_groups = [module.security_groups.app_sg_id]
    subnets         = module.app_network.subnets.*.id
  }


}
