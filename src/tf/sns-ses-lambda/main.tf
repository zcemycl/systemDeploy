resource "aws_sns_topic" "leo_updates" {
  name = "leo-random-updates"
}

resource "aws_sns_topic_subscription" "lambda_target" {
  topic_arn = aws_sns_topic.leo_updates.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.test_lambda.arn
}

resource "aws_sns_topic_subscription" "leo_updates_sqs_target" {
  topic_arn = aws_sns_topic.leo_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.leo_updates_queue.arn
}

resource "aws_sns_topic_subscription" "ses_target" {
  topic_arn = aws_sns_topic.leo_updates.arn
  protocol  = "email"
  endpoint  = var.email
}
