resource "aws_scheduler_schedule" "this" {
  for_each = { for name, obj in var.lambda_funcs : name => obj if obj.enable_schedule }
  name     = "${var.prefix}-${each.key}-schedule"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = each.value.schedule_expression
  target {
    arn      = aws_lambda_function.this[each.key].arn
    role_arn = aws_iam_role.this_schedule[each.key].arn
    input    = jsonencode({ "input" : "" })
  }

  #   network_configuration {
  #     subnets         = each.value.subnet_ids
  #     security_groups = each.value.sg_ids
  #   }
}
