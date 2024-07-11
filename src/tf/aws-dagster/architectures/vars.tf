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

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "alb_subnets_cidr" {
  type = list(string)
  # default = ["10.1.0.0/21", "10.1.8.0/21"]
  default = ["10.1.0.0/21"]
}

variable "openvpn_server_ami" {
  type    = string
  default = "ami-07d20571c32ba6cdc"
}

variable "domain" {
  type    = string
  default = "freecaretoday.com"
}

variable "subdomain" {
  type = string
}

variable "admin_pwd" {
  type = string
}

variable "email" {
  type    = string
  default = "lyc010197@gmail.com"
}
