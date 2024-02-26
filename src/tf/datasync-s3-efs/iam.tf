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

data "aws_iam_policy_document" "this_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this_ec2" {
  assume_role_policy = data.aws_iam_policy_document.this_ec2.json
}

resource "aws_iam_role_policy_attachment" "this_ec2" {
  role       = aws_iam_role.this_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemsUtils"
}

resource "aws_iam_instance_profile" "this_ec2" {
  role = aws_iam_role.this_ec2.name
}
