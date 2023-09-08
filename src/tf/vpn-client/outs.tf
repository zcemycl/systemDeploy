output "rds_password" {
  value     = random_password.aurora.result
  sensitive = true
}

# output "rds_hostname" {
#   value = aws_rds_cluster_instance.rds_wr.endpoint
# }
