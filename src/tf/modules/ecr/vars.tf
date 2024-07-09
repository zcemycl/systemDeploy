variable "images" {
  type = list(object({
    name                 = string
    lastn                = number
    image_tag_mutability = string
    scan_on_push         = bool
    force_delete         = bool
    enable_vpc_endpt     = bool
    vpc_id               = string
    sg_ids               = list(string)
    subnet_ids           = list(string)
    route_table_ids      = list(string)
  }))
}

variable "region" {
  type = string
}
