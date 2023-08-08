output "rds_endpoint" {
    value = aws_rds_cluster_instance.rds_wr.endpoint
}

output "rds_password" {
    value = random_password.aurora.result
    sensitive = true
}