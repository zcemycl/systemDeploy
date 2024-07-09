resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}


module "ecr" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/ecr"
  region = var.AWS_REGION

  images = [
    {
      name                 = "${var.prefix}-code-server"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    }
  ]
}
