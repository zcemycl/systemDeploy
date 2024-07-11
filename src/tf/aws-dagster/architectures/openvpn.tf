resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.private_key_pem}' > private_key.pem"
  }
}

module "openvpn" {
  source             = "github.com/zcemycl/amazon-openvpn-ddns"
  AWS_REGION         = var.AWS_REGION
  vpc_id             = aws_vpc.this.id
  prefix             = var.prefix
  openvpn_server_ami = var.openvpn_server_ami
  subnet_id          = aws_subnet.this[0].id
  instance_type      = "t2.small"
  admin_pwd          = var.admin_pwd
  email              = var.email
  subdomain          = var.subdomain
  domain             = var.domain
  public_key_openssh = tls_private_key.this.public_key_openssh
}
