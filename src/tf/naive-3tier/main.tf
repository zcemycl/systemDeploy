module "ecr" {
  source = "./modules/ecr"
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
  source = "./modules/logging"
  loggings = [
    {
      name              = "app"
      group_name        = "/ecs/app"
      stream_name       = "app-log-stream"
      retention_in_days = 3
    },
    {
      name              = "api"
      group_name        = "/ecs/api"
      stream_name       = "api-log-stream"
      retention_in_days = 3
    }
  ]
}

# module "secrets" {
#   source = "./modules/secrets"
#   secrets = [
#     {
#       name          = "rds"
#       group_name    = "rds-secrets"
#       secret_string = <<EOF
#             {
#                 "db_user": "postgres"
#                 "db_pwd": ""
#                 "db_host": ""
#                 "db_port": 5432
#             }
#         EOF
#     },
#     {
#       name          = "app"
#       group_name    = "app-secrets"
#       secret_string = <<EOF
#             {
#                 "app_user": "hi"
#             }
#         EOF
#     }
#   ]
# }

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
  source                     = "./modules/subnets"
  vpc_id                     = aws_vpc.base_vpc.id
  include_public_route_table = true
}

module "alb_network" {
  source                            = "./modules/subnets"
  name                              = "alb"
  subnets_cidr                      = var.alb_subnets_cidr
  vpc_id                            = aws_vpc.base_vpc.id
  subnet_map_public_ip_on_launch    = true
  availability_zones                = var.availability_zones
  include_private_route_table       = true
  map_subnet_to_public_route_tables = module.igw_public_route_table.public_route_tables
}

module "app_network" {
  source                             = "./modules/subnets"
  name                               = "app"
  subnets_cidr                       = var.app_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.alb_network.private_route_tables
}

module "api_network" {
  source                             = "./modules/subnets"
  name                               = "api"
  subnets_cidr                       = var.api_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.alb_network.private_route_tables
}

module "db_network" {
  source                             = "./modules/subnets"
  name                               = "db"
  subnets_cidr                       = var.db_subnets_cidr
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = var.availability_zones
  map_subnet_to_private_route_tables = module.alb_network.private_route_tables
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "rds_pem" {
  filename = "ssh-rds.pem"
  content  = tls_private_key.ssh_key.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ssh-rds.pem"
  }
}
