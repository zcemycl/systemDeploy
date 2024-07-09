variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "prefix" {
  default = "aws-dagster"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}
