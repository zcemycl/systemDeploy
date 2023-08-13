variable "name" {
  type = string
}

variable "subnets_cidr" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "map_public_ip_on_launch" {
  type = bool
}

variable "availability_zones" {
  type = list(string)
}
