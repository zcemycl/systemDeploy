module "security_groups" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/security_groups"
  security_groups = [
    {
      name        = "openvpn"
      description = "openvpn security group"
      vpc_id      = aws_vpc.this.id
      ingress_rules = [
        {
          protocol    = "tcp"
          from_port   = 80
          to_port     = 80
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "tcp"
          from_port   = 443
          to_port     = 443
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "tcp"
          from_port   = 22
          to_port     = 22
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "tcp"
          from_port   = 943
          to_port     = 943
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "tcp"
          from_port   = 1194
          to_port     = 1194
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
  }]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.prefix}-openvpn-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_pem}' > private_key.pem"
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.prefix}-openvpn-server-role"
  assume_role_policy = file("iam/ec2_assume_policy.json")
}

resource "aws_iam_policy" "this" {
  policy = file("iam/ec2_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.prefix}-openvpn-server-role-profile"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                         = var.openvpn_server_ami
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = aws_subnet.this[0].id
  security_groups             = [module.security_groups.sg_ids["openvpn"].id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data = templatefile("./setup.sh", {
    admin_password = var.admin_pwd
    email          = var.email
    domain         = var.domain
    subdomain      = "${var.subdomain}.${var.domain}"
  })
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain
  type    = "A"
  ttl     = 60
  records = [aws_instance.this.public_ip]
}
