resource "aws_iam_policy" "this" {
  name   = "${var.prefix}-ecs-task-role-policy"
  policy = file("${path.module}/iam/ecs_role_policy.json")
}

resource "aws_iam_role" "this" {
  name                = "${var.prefix}-ecs-task-role"
  assume_role_policy  = file("${path.module}/iam/ecs_assume_policy.json")
  managed_policy_arns = [aws_iam_policy.this.arn]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.prefix}-ecsTaskExecutionRole"
  assume_role_policy = file("${path.module}/iam/ecs_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "this_scheduler" {
  name   = "${var.prefix}-ecs-task-scheduler-role-policy"
  policy = file("${path.module}/iam/scheduler_role_policy.json")
}

resource "aws_iam_role" "this_scheduler" {
  name                = "${var.prefix}-ecs-task-scheduler-role"
  assume_role_policy  = file("${path.module}/iam/scheduler_assume_policy.json")
  managed_policy_arns = [aws_iam_policy.this_scheduler.arn]
}
