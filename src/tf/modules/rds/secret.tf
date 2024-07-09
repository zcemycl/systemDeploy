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

resource "aws_secretsmanager_secret" "this" {
  name = "${var.prefix}-postgres-creds"
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
  })
}
