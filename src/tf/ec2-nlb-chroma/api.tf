resource "aws_api_gateway_api_key" "api_key" {
  name = "chroma-api-key"
  provisioner "local-exec" {
    command = "echo ${aws_api_gateway_api_key.api_key.value} >> info.txt"
  }
}

resource "aws_api_gateway_vpc_link" "chroma_api" {
  name        = "foobar_gateway_vpclink"
  description = "Chroma Instance VPC Link. Managed by Terraform."
  target_arns = [aws_lb.lb.arn]
}

resource "aws_api_gateway_rest_api" "chroma_api" {
  name        = "chroma-api"
  description = "chroma api endpoint"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "chroma_api" {
  rest_api_id = aws_api_gateway_rest_api.chroma_api.id
  parent_id   = aws_api_gateway_rest_api.chroma_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "chroma_api" {
  rest_api_id      = aws_api_gateway_rest_api.chroma_api.id
  resource_id      = aws_api_gateway_resource.chroma_api.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "chroma_api" {
  rest_api_id             = aws_api_gateway_rest_api.chroma_api.id
  resource_id             = aws_api_gateway_resource.chroma_api.id
  http_method             = aws_api_gateway_method.chroma_api.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.lb.dns_name}:8000/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.chroma_api.id
}

resource "aws_api_gateway_deployment" "chroma_api" {
  depends_on = [
    aws_api_gateway_integration.chroma_api
  ]
  rest_api_id = aws_api_gateway_rest_api.chroma_api.id
  stage_name  = "v1"
  triggers = {
    redeployment = sha1(jsonencode(
      [
        aws_api_gateway_resource.chroma_api,
        aws_api_gateway_method.chroma_api
      ]
    ))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "api_key" {
  name = "api_key_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.chroma_api.id
    stage  = aws_api_gateway_deployment.chroma_api.stage_name
  }
  quota_settings {
    limit  = 100000
    period = "MONTH"
  }
  throttle_settings {
    burst_limit = 500
    rate_limit  = 10
  }
}

resource "aws_api_gateway_usage_plan_key" "api_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_key.id
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.main.arn
}

resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = aws_api_gateway_rest_api.chroma_api.id
  stage_name  = aws_api_gateway_deployment.chroma_api.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}
