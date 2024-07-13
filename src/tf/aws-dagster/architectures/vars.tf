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
  type    = list(string)
  default = ["10.1.0.0/21", "10.1.8.0/21"]
  # default = ["10.1.0.0/21"]
}

variable "dagster_daemon_subnets_cidr" {
  type    = list(string)
  default = ["10.1.24.0/21"]
}

variable "etl1_subnets_cidr" {
  type    = list(string)
  default = ["10.1.32.0/21"]
}

# variable "etl2_subnets_cidr" {
#   type    = list(string)
#   default = ["10.1.40.0/21"]
# }

variable "dagster_webserver_subnets_cidr" {
  type    = list(string)
  default = ["10.1.48.0/21", "10.1.40.0/21"]
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

variable "db_subnets_cidr" {
  type    = list(string)
  default = ["10.1.56.0/21", "10.1.64.0/21"]
}

variable "cloud_map_namespace" {
  type    = string
  default = "dagster.internal"
}
