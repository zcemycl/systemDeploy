resource "aws_instance" "this" {
  ami           = "ami-034c41324368ae0b4"
  instance_type = "t3.micro"

  key_name                    = aws_key_pair.this.key_name
  security_groups             = [aws_security_group.this.name]
  associate_public_ip_address = true
  availability_zone           = data.aws_subnet.this[data.aws_subnets.this.ids[0]].availability_zone
  iam_instance_profile        = aws_iam_instance_profile.this_ec2.name

  provisioner "local-exec" {
    command = "echo ${aws_instance.this.public_ip} > info.txt"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem
      timeout     = "10m"
    }
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install git binutils",
      "git clone https://github.com/aws/efs-utils",
      "cd efs-utils",
      "./build-deb.sh",
      "sudo apt-get -y install ./build/amazon-efs-utils*deb",
      "sudo apt-get update",
      "sudo apt-get -y install nfs-common",
      "sudo apt-get -y install ./build/amazon-efs-utils*deb",
      "sudo mkdir data",
      # "sudo su -c  'echo '${aws_efs_file_system.this.id}:/ /data efs _netdev,tls 0 0' >> /etc/fstab'",
      # "sleep 120",
      # "sudo mount /data",
      # "df -k"
      "sudo mount -t efs -o tls ${aws_efs_file_system.this.dns_name} data"
    ]
  }

  depends_on = [
    aws_efs_mount_target.this
  ]
}
