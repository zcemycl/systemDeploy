module "security_groups" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/security_groups"
  security_groups = [
    {
      name        = "everything"
      description = "everything security group"
      vpc_id      = aws_vpc.this.id
      ingress_rules = [
        {
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
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
