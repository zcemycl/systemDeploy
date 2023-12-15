locals {
  lambda_zip_location = "outputs/lambda_function.zip"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "test_lambda" {
  filename                       = local.lambda_zip_location
  function_name                  = var.func_name
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.lambda_function.output_base64sha256
  runtime                        = "python3.10"
  role                           = aws_iam_role.lambda_role.arn
  reserved_concurrent_executions = 1
  timeout                        = 3
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.id}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_sqs_queue" "reduce_downstream" {
  name                       = var.queue_name
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  visibility_timeout_seconds = 10

  tags = {
    owner = "Leo"
  }
}


resource "aws_sqs_queue_redrive_policy" "q" {
  queue_url = aws_sqs_queue.reduce_downstream.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reduce_downstream.arn
    maxReceiveCount     = 1000
  })
}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn                   = aws_sqs_queue.reduce_downstream.arn
  enabled                            = true
  function_name                      = aws_lambda_function.test_lambda.arn
  batch_size                         = 3
  maximum_batching_window_in_seconds = 60
}
