resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "this" {
  allocated_storage   = 30
  storage_type        = "gp2"
  instance_class      = "db.t4g.micro"
  engine              = "postgres"
  engine_version      = "16.2"
  publicly_accessible = false
  identifier          = "${var.prefix}-rds-postgres"
  username            = random_string.this.result
  password            = random_password.this.result

  vpc_security_group_ids = var.sg_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name

  backup_retention_period = 0
  apply_immediately       = true
  # backup_window = "03:00-04:00"
  # maintenance_window = "mon:04:00-mon:04:30"

  skip_final_snapshot = true
  # final_snapshot_identifier = "${var.prefix}-rds-postgres-final"

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.this_monitoring.arn

  performance_insights_enabled = true
}
