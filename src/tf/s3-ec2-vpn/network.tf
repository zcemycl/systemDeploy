resource "aws_vpc" "base_vpc" {
  cidr_block           = var.base_cidr_block
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
  subnets_cidr                      = var.public_subnets_cidr
  vpc_id                            = aws_vpc.base_vpc.id
  subnet_map_public_ip_on_launch    = true
  availability_zones                = var.availability_zones
  include_private_route_table       = true
  map_subnet_to_public_route_tables = module.igw_public_route_table.public_route_tables
}

module "private_network" {
  source                             = "../naive-3tier/modules/subnets"
  name                               = "private"
  subnets_cidr                       = var.private_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.public_network.private_route_tables
}
