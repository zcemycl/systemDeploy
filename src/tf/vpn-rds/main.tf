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
    protocol         = "udp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ingress {
  #     from_port = 0
  #     to_port = 0
  #     protocol = -1
  #     self = true
  # }

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
  client_cidr_block      = "10.1.144.0/22"
  vpc_id                 = aws_vpc.base_vpc.id

  security_group_ids = [aws_security_group.vpn_secgroup.id]
  split_tunnel       = true

  # Client authentication
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_cert.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.logging.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.logging.name
  }

  depends_on = [
    aws_acm_certificate.server_vpn_cert,
    aws_acm_certificate.client_vpn_cert
  ]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_private" {
  for_each               = toset(module.private_network.subnets.*.id)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id

  target_network_cidr  = "10.1.0.0/16"
  authorize_all_groups = true
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule_private" {
  for_each               = toset(["10.1.24.0/21", "10.1.32.0/21", "10.1.40.0/21"])
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
}
