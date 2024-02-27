output "private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

output "public_key" {
  value     = tls_private_key.this.public_key_openssh
  sensitive = true
}

resource "local_file" "cloud_pem" {
  filename = "mykey.pem"
  content  = tls_private_key.this.private_key_pem
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "efs_dns" {
  value = aws_efs_file_system.this.dns_name
}
