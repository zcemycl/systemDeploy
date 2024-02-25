data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = ["vpc-edb1c285"]
  }
}

data "aws_route_tables" "this" {
  filter {
    name   = "vpc-id"
    values = ["vpc-edb1c285"]
  }
}
