resource "aws_iam_role" "this" {
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_iam_policy" "this" {
  policy = file("iam/lambda_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
