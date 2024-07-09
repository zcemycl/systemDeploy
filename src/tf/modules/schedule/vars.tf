variable "prefix" {
  type = string
}

variable "nat_ec2_instance_arn" {
  type = list(string)
}

variable "disable_schedule_start_instance" {
  type = bool
}

variable "disable_schedule_stop_instance" {
  type = bool
}
