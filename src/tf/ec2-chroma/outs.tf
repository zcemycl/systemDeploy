output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value     = tls_private_key.ssh_key.public_key_openssh
  sensitive = true
}

resource "local_file" "cloud_pem" {
  filename = "ssh-chroma.pem"
  content  = tls_private_key.ssh_key.private_key_pem
}

output "chroma_apikey" {
  value     = aws_api_gateway_api_key.api_key.value
  sensitive = true
}

output "chroma_base_url" {
  value = aws_api_gateway_deployment.chroma_api.invoke_url
}

output "chroma_public_ip" {
  value = aws_instance.chroma_instance.public_ip
}
