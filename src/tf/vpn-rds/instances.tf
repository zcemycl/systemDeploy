resource "aws_security_group" "ec2" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.base_vpc.id

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    security_groups = [
      aws_security_group.vpn_secgroup.id
    ]
  }
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

resource "aws_instance" "private_instance" {
  ami               = "ami-0a6006bac3b9bb8d3"
  availability_zone = "eu-west-2a"
  instance_type     = "t2.micro"
  subnet_id         = module.private_network.subnets[0].id
  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]
  key_name                    = aws_key_pair.ssh_key.id
  associate_public_ip_address = false

}

output "instance_private_ip" {
  value = aws_instance.private_instance.private_ip
}
