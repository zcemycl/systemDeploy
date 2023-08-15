output "igw_group" {
  value = aws_internet_gateway.igw
}

output "igw_route_tables" {
  value = aws_route_table.public_route_table
}
