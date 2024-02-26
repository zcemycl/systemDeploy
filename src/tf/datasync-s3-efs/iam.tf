resource "aws_iam_role" "this_datasync" {
  assume_role_policy = file("iam/datasync_assume_policy.json")
}

resource "aws_iam_policy" "this_datasync" {
  policy = file("iam/datasync_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_datasync" {
  role       = aws_iam_role.this_datasync.name
  policy_arn = aws_iam_policy.this_datasync.arn
}
