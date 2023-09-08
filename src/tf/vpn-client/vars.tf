variable "aws_region" {
  default = "eu-west-2"
  type    = string
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "base_cidr_block" {
  default = "10.1.0.0/16"
}

variable "vpn_cidr_block" {
  default = "10.1.144.0/22"
}

variable "public_subnets_cidr" {
  default = ["10.1.0.0/21", "10.1.8.0/21"]
}

variable "private_subnets_cidr" {
  default = ["10.1.24.0/21", "10.1.32.0/21"]
}
