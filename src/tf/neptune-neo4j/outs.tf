output "neptune_endpoint" {
  description = "The connection endpoint for the Neptune DB instance"
  value       = aws_neptune_cluster_instance.this.endpoint
}

output "neptune_reader_endpoint" {
  description = "The reader endpoint for the Neptune DB instance"
  value       = aws_neptune_cluster.this.reader_endpoint
}
