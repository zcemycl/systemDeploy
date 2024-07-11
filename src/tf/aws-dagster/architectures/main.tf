resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw"
  }
}

# public
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_subnet" "this" {
  count                                       = length(var.alb_subnets_cidr)
  vpc_id                                      = aws_vpc.this.id
  cidr_block                                  = element(var.alb_subnets_cidr, count.index)
  availability_zone                           = element(var.availability_zones, count.index)
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
}

resource "aws_route_table_association" "this" {
  count          = length(var.alb_subnets_cidr)
  subnet_id      = element(aws_subnet.this.*.id, count.index)
  route_table_id = aws_route_table.this.id
}


module "ecr" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/ecr"
  region = var.AWS_REGION

  images = [
    {
      name                 = "${var.prefix}-etl1-code-server"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    },
    {
      name                 = "${var.prefix}-etl2-code-server"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    },
    {
      name                 = "${var.prefix}-dagster-webserver"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    },
    {
      name                 = "${var.prefix}-dagster-daemon"
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

data "aws_route53_zone" "this" {
  name = var.domain
}
