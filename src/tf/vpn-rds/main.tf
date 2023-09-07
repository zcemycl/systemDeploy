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

resource "aws_acm_certificate" "server_vpn_cert" {
  certificate_body  = file("~/my-vpn-files/server.crt")
  private_key       = file("~/my-vpn-files/server.key")
  certificate_chain = file("~/my-vpn-files/ca.crt")
}

resource "aws_acm_certificate" "client_vpn_cert" {
  certificate_body  = file("~/my-vpn-files/client1.domain.tld.crt")
  private_key       = file("~/my-vpn-files/client1.domain.tld.key")
  certificate_chain = file("~/my-vpn-files/ca.crt")
}

resource "aws_security_group" "vpn_secgroup" {
  name        = "vpn-sg"
  vpc_id      = aws_vpc.base_vpc.id
  description = "Allow inbound traffic from port 443, to the VPN"

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ec2_client_vpn_endpoint" "my_client_vpn" {
  description            = "My client vpn"
  server_certificate_arn = aws_acm_certificate.server_vpn_cert.arn
  client_cidr_block      = "10.100.0.0/22"
  vpc_id                 = aws_vpc.base_vpc.id

  security_group_ids = [aws_security_group.vpn_secgroup.id]
  split_tunnel       = true

  # Client authentication
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_cert.arn
  }

  connection_log_options {
    enabled = false
  }

  depends_on = [
    aws_acm_certificate.server_vpn_cert,
    aws_acm_certificate.client_vpn_cert
  ]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_private" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = module.private_network.subnets[0].id
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_public" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = module.public_network.subnets[1].id
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id

  target_network_cidr  = "10.1.0.0/16"
  authorize_all_groups = true
}
