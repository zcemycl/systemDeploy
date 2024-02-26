resource "aws_iam_role" "this_datasync" {
  assume_role_policy = file("iam/datasync_assume_policy.json")
}
