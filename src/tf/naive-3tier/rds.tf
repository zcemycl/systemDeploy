resource "random_password" "aurora" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.db_network.subnets.*.id
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "db-aurora-postgres-cluster"
  availability_zones = var.availability_zones
  database_name      = "postgres"
  master_username    = "postgres"
  master_password    = random_password.aurora.result
  engine             = "aurora-postgresql"
  engine_version     = "14.5"
  storage_encrypted  = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  apply_immediately            = true
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "Sat:04:00-Sat:05:00"
}

resource "aws_rds_cluster_instance" "rds_wr" {
  identifier           = "db-aurora-postgres-eu-west-2a-writer"
  cluster_identifier   = aws_rds_cluster.rds_cluster.id
  instance_class       = "db.t3.medium"
  engine               = "aurora-postgresql"
  engine_version       = "14.5"
  availability_zone    = "eu-west-2a"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
}
