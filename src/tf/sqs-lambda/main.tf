locals {
  lambda_zip_location = "outputs/lambda_function.zip"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = local.lambda_zip_location
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = file("iam/lambda_assume_policy.json")
}

resource "aws_lambda_function" "test_lambda" {
  filename                       = local.lambda_zip_location
  function_name                  = "func_test"
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.lambda_function.output_base64sha256
  runtime                        = "python3.10"
  role                           = aws_iam_role.lambda_role.arn
  reserved_concurrent_executions = 1
}

resource "aws_sqs_queue" "reduce_downstream" {
  name                       = "leo-downstream-control"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 20

  tags = {
    owner = "Leo"
  }
}


resource "aws_sqs_queue_redrive_policy" "q" {
  queue_url = aws_sqs_queue.reduce_downstream.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.reduce_downstream.arn
    maxReceiveCount     = 4
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_sqs_queue_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn                   = aws_sqs_queue.reduce_downstream.arn
  enabled                            = true
  function_name                      = aws_lambda_function.test_lambda.arn
  batch_size                         = 3
  maximum_batching_window_in_seconds = 60
}
