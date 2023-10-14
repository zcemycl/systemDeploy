output "apigateway_invoke_url" {
  value = "${aws_api_gateway_deployment.predictDeploy.invoke_url}/${var.api_path}"
}

output "apikey_value" {
  value     = aws_api_gateway_api_key.test_func_api_key.value
  sensitive = true
}
