resource "aws_iam_role" "this" {
  assume_role_policy = file("iam/lambda_assume_policy.json")
}
