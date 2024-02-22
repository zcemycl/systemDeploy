resource "aws_iam_role" "this_ecs" {
  name               = "ecs_service_role"
  assume_role_policy = file("iam/ec2_assume_policy.json")
}

resource "aws_iam_role" "this_batch" {
  name               = "batch_service_role"
  assume_role_policy = file("iam/batch_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_ecs" {
  role       = aws_iam_role.this_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "this_batch" {
  role       = aws_iam_role.this_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_instance_profile" "this_ecs" {
  name = "ecs_instance_role"
  role = aws_iam_role.this_ecs.name
}

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
