resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_task_role"
  assume_role_policy = file("policies/lambda-task-role.json")
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "lambda_role_policy"
  role = aws_iam_role.lambda_iam.id

  policy = file("policies/lambda-role-policy.json")
}
