data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = ["vpc-edb1c285"]
  }
}
