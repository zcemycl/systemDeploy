resource "aws_subnet" "subnets" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.subnets_cidr, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.name}-subnet"
  }
}
