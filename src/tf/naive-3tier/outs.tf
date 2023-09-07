output "jumpbox_public_ip" {
  value = aws_instance.public_instance.public_ip
}

output "rds_password" {
  value     = random_password.aurora.result
  sensitive = true
}

output "rds_hostname" {
  value = aws_rds_cluster_instance.rds_wr.endpoint
}
