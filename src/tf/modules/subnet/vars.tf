variable "vpc_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "subnet_settings" {
  type = map(object({
    subnets_cidr        = list(string)
    assign_eip          = bool
    enable_nat_instance = bool
    enable_nat_gateway  = bool
    public_subnet_ids   = list(string)
  }))
}
