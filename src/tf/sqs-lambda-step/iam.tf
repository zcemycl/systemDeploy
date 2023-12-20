resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "lambda_role_policy"
  role   = aws_iam_role.lambda_role.id
  policy = file("iam/lambda_role_policy.json")
}

resource "aws_iam_role" "state_role" {
  name               = "state_role"
  assume_role_policy = file("iam/state_assume_policy.json")
}

resource "aws_iam_role_policy" "state_role_policy" {
  name   = "state_role_policy"
  role   = aws_iam_role.state_role.id
  policy = file("iam/state_role_policy.json")
}
