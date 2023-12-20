locals {
  assign_waittime_lambda_location    = "outputs/assign_waittime/lambda_function.zip"
  call_ratelimit_api_lambda_location = "outputs/call_ratelimit_api/lambda_function.zip"
}

data "archive_file" "assign_waittime" {
  type        = "zip"
  source_file = "src/assign_waittime/lambda_function.py"
  output_path = local.assign_waittime_lambda_location
}

data "archive_file" "call_ratelimit_api" {
  type        = "zip"
  source_file = "src/call_ratelimit_api/lambda_function.py"
  output_path = local.call_ratelimit_api_lambda_location
}

resource "aws_lambda_function" "assign_waittime" {
  filename                       = local.assign_waittime_lambda_location
  function_name                  = var.func_waittime_name
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.assign_waittime.output_base64sha256
  runtime                        = "python3.10"
  role                           = aws_iam_role.lambda_role.arn
  reserved_concurrent_executions = 1
  timeout                        = 3

  environment {
    variables = {
      delay_interval = var.delay_interval
      step_arn       = aws_sfn_state_machine.sfn_state_machine.arn
      TABLE_NAME     = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "call_ratelimit_api" {
  filename                       = local.call_ratelimit_api_lambda_location
  function_name                  = var.func_ratelimit_exec_name
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.call_ratelimit_api.output_base64sha256
  runtime                        = "python3.10"
  role                           = aws_iam_role.lambda_role.arn
  reserved_concurrent_executions = 1
  timeout                        = 3

  environment {
    variables = {
      step_arn = aws_sfn_state_machine.sfn_state_machine.arn
    }
  }
}

resource "aws_sqs_queue" "queue_for_assign_waittime" {
  name                       = var.queue_for_waittime_name
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  visibility_timeout_seconds = 10
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn                   = aws_sqs_queue.queue_for_assign_waittime.arn
  enabled                            = true
  function_name                      = aws_lambda_function.assign_waittime.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 30
}
