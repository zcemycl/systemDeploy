resource "aws_vpc" "base_vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

module "igw_public_route_table" {
  source                     = "../naive-3tier/modules/subnets"
  vpc_id                     = aws_vpc.base_vpc.id
  include_public_route_table = true
}

module "public_network" {
  source                            = "../naive-3tier/modules/subnets"
  name                              = "public"
  subnets_cidr                      = ["10.1.0.0/21", "10.1.8.0/21", "10.1.16.0/21"]
  vpc_id                            = aws_vpc.base_vpc.id
  subnet_map_public_ip_on_launch    = true
  availability_zones                = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  include_private_route_table       = true
  map_subnet_to_public_route_tables = module.igw_public_route_table.public_route_tables
}

module "private_network" {
  source                             = "../naive-3tier/modules/subnets"
  name                               = "private"
  subnets_cidr                       = ["10.1.24.0/21", "10.1.32.0/21", "10.1.40.0/21"]
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  map_subnet_to_private_route_tables = module.public_network.private_route_tables
}
