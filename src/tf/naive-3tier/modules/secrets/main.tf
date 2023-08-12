resource "aws_secretsmanager_secret" "secrets" {
  for_each = {
    for secret in var.secrets : secret.name => secret
  }
  name = each.value.group_name
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = {
    for secret in var.secrets : secret.name => secret
  }
  secret_id     = aws_secretsmanager_secret.secrets[each.value.name].id
  secret_string = each.value.secret_string
}
