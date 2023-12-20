variable "aws_region" {
  default = "eu-west-2"
}

variable "queue_for_waittime_name" {
  default = "queue_for_waittime"
}

variable "func_waittime_name" {
  default = "func_waittime"
}

variable "func_ratelimit_exec_name" {
  default = "func_ratelimit_exec"
}

variable "step_wait_exec_name" {
  default = "step_wait_exec"
}

variable "delay_interval" {
  default = 3
}

variable "dynamodb_table_name" {
  default = "Request_Order"
}
