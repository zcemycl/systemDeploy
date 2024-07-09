resource "aws_ecs_task_definition" "this" {
  for_each                 = var.service_task_definitions
  family                   = each.value.task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.task_cpu
  memory                   = each.value.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.this.arn

  container_definitions = jsonencode(each.value.task_container_defs)
}

resource "aws_ecs_service" "this" {
  for_each                           = { for name, def in var.service_task_definitions : name => def if def.enable_ecs_service }
  name                               = each.value.service_name
  cluster                            = each.value.cluster_id
  task_definition                    = aws_ecs_task_definition.this[each.key].arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = each.value.sg_ids
    subnets         = each.value.subnet_ids
  }

  dynamic "load_balancer" {
    for_each = { for index, value in each.value.lb_target_groups : value.lb_target_group_arn => value }
    content {
      target_group_arn = load_balancer.value.lb_target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = each.value.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.this[each.key].arn
      # port = 80
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  #   depends_on = [
  #     aws_lb_listener.http,
  #     aws_lb_target_group.app_target_group
  #   ]
}

resource "aws_scheduler_schedule_group" "this" {
  name = "ecs_task"
}

resource "aws_scheduler_schedule" "this" {
  for_each   = { for name, def in var.service_task_definitions : name => def if def.enable_task_schedule }
  name       = each.value.task_schedule_name
  group_name = aws_scheduler_schedule_group.this.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = each.value.task_schedule_expression

  target {
    arn      = each.value.cluster_arn
    role_arn = aws_iam_role.this_scheduler.arn

    ecs_parameters {
      # trimming the revision suffix here so that schedule always uses latest revision
      task_definition_arn = trimsuffix(aws_ecs_task_definition.this[each.key].arn, ":${aws_ecs_task_definition.this[each.key].revision}")
      launch_type         = "FARGATE"

      network_configuration {
        assign_public_ip = false
        security_groups  = each.value.sg_ids
        subnets          = each.value.subnet_ids
      }
    }
  }
}

resource "aws_appautoscaling_target" "this" {
  for_each           = { for name, def in var.service_task_definitions : name => def if def.enable_service_schedule }
  max_capacity       = 1
  min_capacity       = 1
  resource_id        = "service/${each.value.cluster_id}/${aws_ecs_service.this[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [min_capacity, max_capacity]
  }
}

resource "aws_appautoscaling_scheduled_action" "this_off" {
  for_each           = { for name, def in var.service_task_definitions : name => def if def.enable_service_schedule }
  name               = "ecs"
  service_namespace  = aws_appautoscaling_target.this[each.key].service_namespace
  resource_id        = aws_appautoscaling_target.this[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.this[each.key].scalable_dimension
  schedule           = "cron(0 17 ? * MON-FRI *)"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

# https://stackoverflow.com/questions/67765238/mixed-content-the-page-at-was-loaded-over-https-but-requested-an-insecure-resour
# https://stackoverflow.com/questions/74943368/fargate-errors-when-frontend-service-tries-to-communicate-with-backend-service-v
resource "aws_service_discovery_service" "this" {
  for_each = { for name, def in var.service_task_definitions : name => def if def.enable_service_discovery }
  name     = each.value.service_discovery_name
  dns_config {
    namespace_id   = var.cloudmap_private_dns_namespace_id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = each.value.service_dns_ttl
      type = each.value.service_dns_type
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }

  lifecycle {
    ignore_changes = [health_check_custom_config]
  }
}
