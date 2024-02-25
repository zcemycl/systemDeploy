# batch compute env
resource "aws_iam_role" "this_ecs" {
  name               = "ecs_service_role"
  assume_role_policy = file("iam/ec2_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_ecs" {
  role       = aws_iam_role.this_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "this_ecs" {
  name = "ecs_instance_role"
  role = aws_iam_role.this_ecs.name
}

# batch compute env, and avoid deletion sequence bug
resource "aws_iam_role" "this_batch" {
  name               = "batch_service_role"
  assume_role_policy = file("iam/batch_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_batch" {
  role       = aws_iam_role.this_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "this_batch_s3" {
  role       = aws_iam_role.this_batch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# lambda function
resource "aws_iam_role" "this_lambda" {
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_policy" "this_lambda" {
  policy = file("iam/lambda_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_lambda" {
  role       = aws_iam_role.this_lambda.name
  policy_arn = aws_iam_policy.this_lambda.arn
}

# batch job def
resource "aws_iam_role" "this_batch_ecs_task_execution" {
  name               = "batch_ecs_execution_role"
  assume_role_policy = file("iam/ecs_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_batch_ecs_task_execution" {
  role       = aws_iam_role.this_batch_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "this_batch_ecs_task_execution_s3" {
  role       = aws_iam_role.this_batch_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role" "this_batch_ecs_task" {
  name               = "batch_ecs_role"
  assume_role_policy = file("iam/ecs_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_batch_ecs_task_s3" {
  role       = aws_iam_role.this_batch_ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
