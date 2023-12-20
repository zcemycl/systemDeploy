resource "aws_sqs_queue" "leo_updates_queue" {
  name                      = "leo-updates-queue"
  policy                    = file("iam/sqs_policy.json")
  receive_wait_time_seconds = 20
  message_retention_seconds = 18400
}
