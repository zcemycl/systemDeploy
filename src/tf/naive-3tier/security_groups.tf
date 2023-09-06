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
    }
  ]
}
