resource "random_password" "aurora" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.base_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.vpn_secgroup.id
    ]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [module.private_network.subnets[0].id, module.private_network.subnets[1].id]
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "db-aurora-postgres-cluster"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
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
  skip_final_snapshot          = true
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
