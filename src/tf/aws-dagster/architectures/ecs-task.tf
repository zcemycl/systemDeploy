resource "aws_iam_role" "this_task" {
  name               = "${var.prefix}-hotload-task"
  assume_role_policy = file("${path.module}/iam/ec2_assume_policy.json")
}
