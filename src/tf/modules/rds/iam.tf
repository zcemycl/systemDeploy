resource "aws_iam_role" "this" {
  name               = "${var.prefix}-rds-proxy-role"
  assume_role_policy = file("${path.module}/iam/rds_assume_policy.json")
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.prefix}-rds-proxy-role-policy"
  role   = aws_iam_role.this.id
  policy = file("${path.module}/iam/rds_role_policy.json")
}

resource "aws_iam_role" "this_monitoring" {
  name               = "${var.prefix}-rds-monitoring-role"
  assume_role_policy = file("${path.module}/iam/monitoring_rds_assume_policy.json")
}

resource "aws_iam_role_policy_attachment" "this_monitoring" {
  role       = aws_iam_role.this_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
