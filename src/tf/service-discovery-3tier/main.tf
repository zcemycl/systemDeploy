module "ecr" {
  source = "../naive-3tier/modules/ecr"
  ecr_repositories = [
    {
      name                 = "app"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
    },
    {
      name                 = "api"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
    }
  ]
}

module "logging" {
  source = "../naive-3tier/modules/logging"
  loggings = [
    {
      name              = "app"
      group_name        = "/ecs/app"
      stream_name       = "app-log-stream"
      retention_in_days = 1
    },
    {
      name              = "api"
      group_name        = "/ecs/api"
      stream_name       = "api-log-stream"
      retention_in_days = 1
    }
  ]
}

resource "aws_vpc" "base_vpc" {
  cidr_block           = var.vpc_cidr
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

module "alb_network" {
  source                            = "../naive-3tier/modules/subnets"
  name                              = "alb"
  subnets_cidr                      = var.alb_subnets_cidr
  vpc_id                            = aws_vpc.base_vpc.id
  subnet_map_public_ip_on_launch    = true
  availability_zones                = var.availability_zones
  include_private_route_table       = true
  map_subnet_to_public_route_tables = module.igw_public_route_table.public_route_tables
}

module "app_network" {
  source                             = "../naive-3tier/modules/subnets"
  name                               = "app"
  subnets_cidr                       = var.app_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.alb_network.private_route_tables
}

module "ialb_network" {
  source                             = "../naive-3tier/modules/subnets"
  name                               = "ialb"
  subnets_cidr                       = var.ialb_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  include_private_route_table        = true
  map_subnet_to_private_route_tables = module.alb_network.private_route_tables
}

module "api_network" {
  source                             = "../naive-3tier/modules/subnets"
  name                               = "api"
  subnets_cidr                       = var.api_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.ialb_network.private_route_tables
}

# :) overcomplicated networks
