resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = var.step_wait_exec_name
  role_arn = aws_iam_role.state_role.arn
  definition = templatefile("state/step_wait_exec.json",
    {
      funcname = var.func_ratelimit_exec_name
      queueurl = aws_sqs_queue.queue_for_assign_waittime.url
    }
  )

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_func_log_group.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}
