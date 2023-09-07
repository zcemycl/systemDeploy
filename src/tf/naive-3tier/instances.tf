resource "aws_instance" "public_instance" {
  ami               = "ami-0a6006bac3b9bb8d3"
  availability_zone = "eu-west-2a"
  instance_type     = "t2.micro"
  subnet_id         = module.alb_network.subnets[0].id
  vpc_security_group_ids = [
    module.security_groups.jumpbox_sg_id
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
    source      = "ssh-rds.pem"
    destination = "ssh-rds.pem"
  }

  depends_on = [
    local_file.rds_pem
  ]
}
