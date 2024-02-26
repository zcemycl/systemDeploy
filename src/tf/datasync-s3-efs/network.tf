data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = ["vpc-edb1c285"]
  }
}

data "aws_subnet" "this" {
  for_each = toset(data.aws_subnets.this.ids)
  id       = each.value
}
