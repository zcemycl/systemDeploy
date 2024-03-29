variable "aws_region" {
  default = "eu-west-2"
  type    = string
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "alb_subnets_cidr" {
  default = ["10.1.0.0/21", "10.1.8.0/21"]
}

variable "ialb_subnets_cidr" {
  default = ["10.1.16.0/21", "10.1.24.0/21"]
}

variable "app_subnets_cidr" {
  default = ["10.1.32.0/21", "10.1.40.0/21"]
}

variable "api_subnets_cidr" {
  default = ["10.1.48.0/21", "10.1.56.0/21"]
}

variable "db_subnets_cidr" {
  default = ["10.1.64.0/21", "10.1.72.0/21"]
}

variable "vpn_cidr_block" {
  default = "10.1.144.0/22"
}

variable "internal_domain_name" {
  default = "service.internal"
}

variable "internal_serv_name" {
  default = "test"
}

variable "internal_db_name" {
  default = "db"
}

variable "acme_server_url" {
  description = "default currently set to the lets encrypt staging environment, comment below is production environment."
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "domain" {
  default = "freecaretoday.com"
}

variable "api_port" {
  default = 3000
}

variable "subdomain" {
  default = "naive"
}
