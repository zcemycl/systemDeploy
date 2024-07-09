variable "prefix" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "sg_ids" {
  type = list(string)
}

variable "cloudmap_private_dns_namespace_id" {
  type = string
}

variable "enable_proxy" {
  type = bool
}
