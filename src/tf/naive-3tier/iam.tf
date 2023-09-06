# ecs
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = file("policies/ecs-task-role.json")
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs_task_policy"
  path        = "/"
  description = "Policy for accessing resources required in ecs"

  policy = file("policies/ecs-autoscale-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = file("policies/ecs-task-role.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
