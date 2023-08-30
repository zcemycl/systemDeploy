resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "cloud_pem" {
  filename = "ssh-chroma.pem"
  content  = tls_private_key.ssh_key.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ssh-chroma.pem"
  }
}

resource "aws_vpc" "base_vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}

module "public_access_network" {
  source                     = "./modules/subnets"
  vpc_id                     = aws_vpc.base_vpc.id
  include_public_route_table = true
}

module "security_groups" {
  source = "./modules/security_groups"
  security_groups = [
    {
      name        = "ec2-chroma"
      description = "Chroma instance security group"
      vpc_id      = aws_vpc.base_vpc.id
      ingress_rules = [
        {
          protocol    = "tcp"
          from_port   = 22
          to_port     = 22
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "tcp"
          from_port   = 8000
          to_port     = 8000
          cidr_blocks = [aws_vpc.base_vpc.cidr_block]
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

module "nlb_network" {
  source                            = "./modules/subnets"
  name                              = "nlb"
  subnets_cidr                      = ["10.1.0.0/21"]
  vpc_id                            = aws_vpc.base_vpc.id
  subnet_map_public_ip_on_launch    = true
  availability_zones                = ["eu-west-2a"]
  include_private_route_table       = true
  map_subnet_to_public_route_tables = module.public_access_network.public_route_tables
}

module "chroma_network" {
  source                             = "./modules/subnets"
  name                               = "chroma"
  subnets_cidr                       = ["10.1.16.0/21"]
  vpc_id                             = aws_vpc.base_vpc.id
  availability_zones                 = ["eu-west-2a"]
  map_subnet_to_private_route_tables = module.nlb_network.private_route_tables
}

resource "aws_instance" "chroma_instance" {
  ami               = "ami-0a6006bac3b9bb8d3"
  availability_zone = "eu-west-2a"
  instance_type     = "t3.small"
  vpc_security_group_ids = [
    module.security_groups.chroma_instance_sg_id
  ]
  key_name = aws_key_pair.ssh_key.id
  # associate_public_ip_address = true # commentable?

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 24
  }

  user_data = <<EOF
#!/bin/bash
curl -L https://raw.githubusercontent.com/zcemycl/systemDeploy/main/src/tf/ec2-nlb-chroma/docker-compose.yml -o /home/ec2-user/docker-compose.yml
curl -L https://raw.githubusercontent.com/zcemycl/systemDeploy/main/src/tf/ec2-nlb-chroma/setup-docker.sh -o setup-docker.sh
chmod +x setup-docker.sh
sudo ./setup-docker.sh
EOF
  subnet_id = module.chroma_network.subnet_ids[0]

  tags = {
    Name   = "Leo -- Chroma: Compute"
    Author = "Leo"
    Topic  = "Chroma"
  }
}

resource "aws_instance" "public_instance" {
  ami               = "ami-0a6006bac3b9bb8d3"
  availability_zone = "eu-west-2a"
  instance_type     = "t2.micro"
  subnet_id         = module.nlb_network.subnet_ids[0]
  vpc_security_group_ids = [
    module.security_groups.chroma_instance_sg_id
  ]
  key_name                    = aws_key_pair.ssh_key.id
  associate_public_ip_address = true # commentable?

  connection {
    host        = self.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.ssh_key.private_key_pem
    timeout     = "10m"
  }

  provisioner "file" {
    source      = "ssh-chroma.pem"
    destination = "ssh-chroma.pem"
  }

  depends_on = [
    local_file.cloud_pem
  ]
}
