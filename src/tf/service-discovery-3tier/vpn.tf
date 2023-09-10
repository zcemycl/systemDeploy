resource "aws_ec2_client_vpn_endpoint" "my_client_vpn" {
  description            = "My client vpn"
  server_certificate_arn = aws_acm_certificate.server_vpn_cert.arn
  client_cidr_block      = var.vpn_cidr_block
  vpc_id                 = aws_vpc.base_vpc.id

  security_group_ids = [aws_security_group.vpn_secgroup.id]
  split_tunnel       = true

  dns_servers = [
    "10.1.0.2"
  ]

  # Client authentication
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_cert.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = module.logging.log_groups["vpn"].name
    cloudwatch_log_stream = module.logging.stream_groups["vpn"].name
  }

  depends_on = [
    aws_acm_certificate.server_vpn_cert,
    aws_acm_certificate.client_vpn_cert
  ]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_private" {
  count                  = length(var.api_subnets_cidr)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = module.api_network.subnets[count.index].id

  depends_on = [
    module.api_network
  ]
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id

  target_network_cidr  = "10.1.0.0/16"
  authorize_all_groups = true
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule_private" {
  for_each               = toset(var.api_subnets_cidr)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
}
