locals {
  nat_ec2_instance_id = [for index, arn in var.nat_ec2_instance_arn : split("/", arn)[1]]
}

resource "aws_scheduler_schedule_group" "nat_ec2" {
  name = "nat_ec2"
}

resource "aws_scheduler_schedule" "nat_ec2_start" {
  count      = var.disable_schedule_start_instance ? 0 : 1
  name       = "${var.prefix}-nat_ec2_start-schedule"
  group_name = aws_scheduler_schedule_group.nat_ec2.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 8 ? * MON-FRI *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.this.arn
    input    = jsonencode({ "InstanceIds" : local.nat_ec2_instance_id })
  }
}

resource "aws_scheduler_schedule" "nat_ec2_stop" {
  count      = var.disable_schedule_stop_instance ? 0 : 1
  name       = "${var.prefix}-nat_ec2_stop-schedule"
  group_name = aws_scheduler_schedule_group.nat_ec2.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 17 ? * MON-FRI *)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.this.arn
    input    = jsonencode({ "InstanceIds" : local.nat_ec2_instance_id })
  }
}
