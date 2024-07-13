resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*dagster_nat.*", name)) > 0]
}

resource "aws_db_instance" "this" {
  allocated_storage   = 30
  db_name             = "postgres"
  storage_type        = "gp2"
  instance_class      = "db.t4g.micro"
  engine              = "postgres"
  engine_version      = "16.2"
  publicly_accessible = false
  identifier          = "${var.prefix}-rds-postgres"
  username            = random_string.this.result
  password            = random_password.this.result

  vpc_security_group_ids = [module.security_groups.sg_ids["everything"].id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  backup_retention_period = 0
  apply_immediately       = true
  # backup_window = "03:00-04:00"
  # maintenance_window = "mon:04:00-mon:04:30"

  skip_final_snapshot = true
  # final_snapshot_identifier = "${var.prefix}-rds-postgres-final"

  #   monitoring_interval = 60
  #   monitoring_role_arn = aws_iam_role.this_monitoring.arn

  #   performance_insights_enabled = true
}

resource "random_string" "this" {
  length  = 16
  special = false
  numeric = false
}

resource "random_password" "this" {
  length  = 32
  special = false
  numeric = true
}

resource "random_uuid" "uuid" {}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.prefix}-creds-${random_uuid.uuid.result}"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    "username"             = random_string.this.result
    "password"             = random_password.this.result
    "engine"               = "aurora-postgresql"
    "host"                 = aws_db_instance.this.address
    "port"                 = 5432
    "dbInstanceIdentifier" = aws_db_instance.this.id
    "dbname"               = aws_db_instance.this.db_name
  })
}


resource "aws_service_discovery_service" "this" {
  name = "db"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = 300
      type = "CNAME"
    }
  }
}

resource "aws_service_discovery_instance" "this" {
  instance_id = aws_db_instance.this.id
  service_id  = aws_service_discovery_service.this.id

  attributes = {
    AWS_INSTANCE_CNAME = aws_db_instance.this.address
    AWS_INSTANCE_PORT  = aws_db_instance.this.port
  }
}
