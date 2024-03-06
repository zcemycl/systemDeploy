resource "aws_cloud9_environment_ec2" "this" {
  name          = "leo-cloud9-trial"
  instance_type = "t2.micro"
  image_id      = "ubuntu-22.04-x86_64"
}

resource "aws_iam_user" "this" {
  name = "default"
}

resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9User"
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_login_profile" "this" {
  user = aws_iam_user.this.name
}

resource "aws_cloud9_environment_membership" "this" {
  environment_id = aws_cloud9_environment_ec2.this.id
  permissions    = "read-write"
  user_arn       = aws_iam_user.this.arn
}

data "aws_instance" "this" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
      aws_cloud9_environment_ec2.this.id
    ]
  }
}

resource "aws_eip" "this" {
  instance = data.aws_instance.this.id
  domain   = "vpc"
}
