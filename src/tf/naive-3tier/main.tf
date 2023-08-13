module "ecr" {
  source = "./modules/ecr"
  ecr_repositories = [
    {
      name                 = "app"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
    },
    {
      name                 = "api"
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
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

module "secrets" {
  source = "./modules/secrets"
  secrets = [
    {
      name          = "rds"
      group_name    = "rds-secrets"
      secret_string = <<EOF
            {
                "db_user": "postgres"
                "db_pwd": ""
                "db_host": ""
                "db_port": 5432
            }
        EOF
    },
    {
      name          = "app"
      group_name    = "app-secrets"
      secret_string = <<EOF
            {
                "app_user": "hi"
            }
        EOF
    }
  ]
}

resource "aws_vpc" "base_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "base_igw" {
  vpc_id = aws_vpc.base_vpc.id

  tags = {
    Name = "vpc-igw"
  }
}

resource "aws_route_table" "base_public_route_table" {
  vpc_id = aws_vpc.base_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.base_igw.id
  }
  tags = {
    Name = "base-public-route-table"
  }
}

module "alb_network" {
  source                  = "./modules/subnets"
  name                    = "alb"
  subnets_cidr            = var.alb_subnets_cidr
  vpc_id                  = aws_vpc.base_vpc.id
  map_public_ip_on_launch = true
  availability_zones      = var.availability_zones
}
