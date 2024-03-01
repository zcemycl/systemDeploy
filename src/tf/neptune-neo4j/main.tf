resource "aws_neptune_cluster_parameter_group" "this" {
  family = "neptune1.2"

  parameter {
    name  = "neptune_query_timeout"
    value = "25"
  }
}

resource "aws_neptune_parameter_group" "this" {
  family = "neptune1.2"

  parameter {
    name  = "neptune_query_timeout"
    value = "25"
  }
}

resource "aws_neptune_cluster" "this" {
  cluster_identifier                   = "neptune-cluster-demo"
  engine                               = "neptune"
  engine_version                       = "1.2.0.1"
  backup_retention_period              = 2
  preferred_backup_window              = "07:00-09:00"
  skip_final_snapshot                  = true
  iam_database_authentication_enabled  = true
  apply_immediately                    = true
  vpc_security_group_ids               = [aws_security_group.this.id]
  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.this.name
}

resource "aws_neptune_cluster_instance" "this" {
  cluster_identifier           = aws_neptune_cluster.this.cluster_identifier
  instance_class               = "db.r5.large"
  engine                       = "neptune"
  apply_immediately            = true
  neptune_parameter_group_name = aws_neptune_parameter_group.this.name
}

resource "aws_neptune_cluster_endpoint" "this" {
  cluster_identifier          = aws_neptune_cluster.this.cluster_identifier
  cluster_endpoint_identifier = "example"
  endpoint_type               = "ANY"
}
