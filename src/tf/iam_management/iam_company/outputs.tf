output "service_publisher_access_key_id" {
  value = aws_iam_access_key.service_publisher.id
}

output "service_publisher_access_key_secret" {
  value     = aws_iam_access_key.service_publisher.secret
  sensitive = true
}

output "dev_access_key_ids" {
  value = zipmap(
    [for u in aws_iam_user.developers : u.name],
    [for i in aws_iam_access_key.dev_users : i.id]
  )
}

output "dev_access_secret_key" {
  value = zipmap(
    [for u in aws_iam_user.developers : u.name],
    [for i in aws_iam_access_key.dev_users : i.secret]
  )
  sensitive = true
}

# output "dev_user_passwords" {
#   value = [for p in aws_iam_user_login_profile.dev-users: p.encrypted_password]
# }
# password for users
output "dev_user_passwords" {
  value = [for p in aws_iam_user_login_profile.dev-users : p.password]
}
