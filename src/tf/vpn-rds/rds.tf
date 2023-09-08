resource "random_password" "aurora" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.base_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.private_network.subnets.*.cidr_block
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn_secgroup.id]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = module.private_network.subnets.*.id
}

resource "aws_db_instance" "rds" {
  identifier             = "postgres"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "11.18"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  username               = "postgres"
  password               = random_password.aurora.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
}

output "db_instance_endpt" {
  value = aws_db_instance.rds.endpoint
}

# output "random_output" {
#   value =
# }

# output "db_subnet_ip" {
#   value = aws_db_subnet_group.rds_subnet_group.
# }

# resource "aws_rds_cluster" "rds_cluster" {
#   cluster_identifier = "db-aurora-postgres-cluster"
#   availability_zones = ["eu-west-2a", "eu-west-2b"]
#   database_name      = "postgres"
#   master_username    = "postgres"
#   master_password    = random_password.aurora.result
#   engine             = "aurora-postgresql"
#   engine_version     = "14.5"
#   storage_encrypted  = true

#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]

#   apply_immediately            = true
#   preferred_backup_window      = "02:00-03:00"
#   preferred_maintenance_window = "Sat:04:00-Sat:05:00"
#   skip_final_snapshot          = true
# }

# resource "aws_rds_cluster_instance" "rds_wr" {
#   identifier           = "db-aurora-postgres-eu-west-2a-writer"
#   cluster_identifier   = aws_rds_cluster.rds_cluster.id
#   instance_class       = "db.t3.medium"
#   engine               = "aurora-postgresql"
#   engine_version       = "14.5"
#   availability_zone    = "eu-west-2a"
#   publicly_accessible  = false
#   db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
# }
