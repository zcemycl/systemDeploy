output "chroma_apikey" {
  value     = aws_api_gateway_api_key.api_key.value
  sensitive = true
}

output "chroma_base_url" {
  value = aws_api_gateway_deployment.chroma_api.invoke_url
}

output "backdoor_public_ip" {
  value = aws_instance.public_instance.public_ip
}

output "chroma_private_ip" {
  value = aws_instance.chroma_instance.private_ip
}

output "apigw_loggroup_name" {
  value = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.chroma_api.id}/${aws_api_gateway_deployment.chroma_api.stage_name}"
}
