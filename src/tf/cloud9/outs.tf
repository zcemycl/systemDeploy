output "cloud9_url" {
  value = "https://${var.AWS_REGION}.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.this.id}"
}

output "cloud9_public_ip" {
  value = aws_eip.this.public_ip
}

output "default_access_key" {
  value = aws_iam_access_key.this.id
}

output "default_secret_access_key" {
  value     = aws_iam_access_key.this.secret
  sensitive = true
}

output "password" {
  value = aws_iam_user_login_profile.this.password
}
