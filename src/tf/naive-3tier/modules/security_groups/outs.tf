output "app_sg_id" {
  value = aws_security_group.sg["app"].id
}

output "api_sg_id" {
  value = aws_security_group.sg["api"].id
}

output "alb_sg_id" {
  value = aws_security_group.sg["alb"].id
}

# output "rds_sg_id" {
#   value = aws_security_group.sg["rds"].id
# }

output "jumpbox_sg_id" {
  value = aws_security_group.sg["jumpbox"].id
}
