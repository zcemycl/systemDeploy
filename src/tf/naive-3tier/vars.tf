variable "aws_region" {
  default = "eu-west-2"
  type    = string
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "alb_subnets_cidr" {
  default = ["10.1.0.0/21", "10.1.8.0/21", "10.1.16.0/21"]
}

variable "app_subnets_cidr" {
  default = ["10.1.24.0/21", "10.1.32.0/21", "10.1.40.0/21"]
}
