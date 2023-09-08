module "security_groups" {
  source = "./modules/security_groups"
  security_groups = [
    {
      name        = "app"
      description = "app security group"
      vpc_id      = aws_vpc.base_vpc.id
      ingress_rules = [
        {
          protocol    = "tcp"
          from_port   = 80
          to_port     = 80
          cidr_blocks = var.alb_subnets_cidr
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
    },
    {
      name        = "api"
      description = "api security group"
      vpc_id      = aws_vpc.base_vpc.id
      ingress_rules = [
        {
          protocol    = "tcp"
          from_port   = 80
          to_port     = 80
          cidr_blocks = var.alb_subnets_cidr
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
    },
    {
      name        = "alb"
      description = "alb security group"
      vpc_id      = aws_vpc.base_vpc.id
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

    },
    {
      name        = "jumpbox"
      description = "jumpbox ec2 security group"
      vpc_id      = aws_vpc.base_vpc.id
      ingress_rules = [
        {
          protocol    = "tcp"
          from_port   = 22
          to_port     = 22
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

    }
  ]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.base_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      module.security_groups.api_sg_id,
      module.security_groups.jumpbox_sg_id
    ]
  }
}
