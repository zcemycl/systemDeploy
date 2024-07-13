data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}
# ami-00877cb58e935baf9

# data "templatefile" "user_data" {
#   template = file("${path.module}/user_data.sh")

#   vars = {
#     ecs_cluster_name = aws_ecs_cluster.this.name
#   }
# }

resource "aws_iam_role" "this_ecs_ec2" {
  name               = "${var.prefix}-hotload-etl2"
  assume_role_policy = file("${path.module}/iam/ec2_ecs_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_ecs_ec2" {
  role       = aws_iam_role.this_ecs_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this_ecs_ec2.name
  name = "${var.prefix}-profile-hotload"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.prefix}-hotload-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_launch_template" "this" {
  name          = "${var.prefix}-launch-template-hotload"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.this.key_name
  user_data = templatefile("${path.module}/user_data.sh", {
    ecs_cluster_name = aws_ecs_cluster.this.name
  })
  vpc_security_group_ids = [module.security_groups.sg_ids["everything"].id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  monitoring {
    enabled = true
  }
}

# resource "aws_ecs_service" "this" {
#     name = "${var.prefix}-ecs-hotload"
#     iam_role = aws_iam_role.this_ecs_ec2.arn
#     cluster = aws_ecs_cluster.this.id

# }
