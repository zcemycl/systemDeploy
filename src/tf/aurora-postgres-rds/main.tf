resource "random_password" "aurora" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds_sg" {
  name = "aurora-postgres-rds-sg"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "aurora-postgres-rds-cluster"
  availability_zones = var.availability_zones
  database_name      = "postgres"
  master_username    = "postgres"
  master_password    = random_password.aurora.result
  engine             = "aurora-postgresql"
  engine_version     = "14.3"
  storage_encrypted  = true

  # db_subnet_group_name =
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  apply_immediately            = true
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "Sat:04:00-Sat:05:00"
  skip_final_snapshot          = true
}

resource "aws_rds_cluster_instance" "rds_wr" {
  identifier          = "aurora-postgres-rds-writer"
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-postgresql"
  engine_version      = "14.3"
  availability_zone   = "eu-west-2a"
  publicly_accessible = true
  # db_subnet_group_name =
}
