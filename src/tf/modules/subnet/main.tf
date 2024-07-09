locals {
  subnet_map = merge([
    for subnet_name, subnet_val in var.subnet_settings :
    merge([
      for index, cidr_block in subnet_val.subnets_cidr : {
        "${subnet_name}-${index}" = {
          availability_zone   = var.availability_zones[index]
          cidr_block          = cidr_block
          public_subnet_id    = subnet_val.public_subnet_ids[index]
          assign_eip          = subnet_val.assign_eip
          enable_nat_gateway  = subnet_val.enable_nat_gateway
          enable_nat_instance = subnet_val.enable_nat_instance
    } }]...)
    ]...
  )
}

resource "aws_subnet" "this" {
  for_each                                    = local.subnet_map
  vpc_id                                      = var.vpc_id
  cidr_block                                  = each.value.cidr_block
  availability_zone                           = each.value.availability_zone
  map_public_ip_on_launch                     = false
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "this" {
  for_each = local.subnet_map
  vpc_id   = var.vpc_id
}

resource "aws_route_table_association" "this" {
  for_each       = local.subnet_map
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_eip" "this" {
  for_each = { for name, obj in local.subnet_map : name => obj if obj.assign_eip }
  domain   = "vpc"
}

module "nat_instance" {
  for_each           = { for name, obj in local.subnet_map : name => obj if obj.enable_nat_instance }
  source             = "RaJiska/fck-nat/aws"
  version            = "1.2.0"
  vpc_id             = var.vpc_id
  name               = "nat-instance-${each.key}"
  subnet_id          = each.value.public_subnet_id
  route_table_id     = aws_route_table.this[each.key].id
  eip_allocation_ids = each.value.assign_eip ? [aws_eip.this[each.key].id] : []
  update_route_table = true
  ha_mode            = false
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each      = { for name, obj in local.subnet_map : name => obj if obj.enable_nat_gateway }
  allocation_id = aws_eip.this[each.key].id
  subnet_id     = each.value.public_subnet_id
}
