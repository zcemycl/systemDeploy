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

resource "aws_instance" "this" {
  ami                         = var.openvpn_server_ami
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.this[0].id
  security_groups             = [module.security_groups.sg_ids["openvpn"].id]
  associate_public_ip_address = true
}
