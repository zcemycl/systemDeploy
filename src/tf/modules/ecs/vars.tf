variable "prefix" {
  type = string
}

variable "service_task_definitions" {
  # type = map(object({
  #   service_name        = optional(string, "")
  #   task_schedule_name  = optional(string, "")
  #   task_schedule_expression = optional(string, "")
  #   service_schedule_name = optional(string, "")
  #   service_schedule_expression = optional(string, "")
  #   service_discovery_name = optional(string, "")
  #   service_dns_type = optional(string, "")
  #   service_dns_ttl = optional(number, 300)
  #   task_name           = string
  #   task_cpu            = number
  #   task_container_defs = optional(list(any), [])
  #   task_memory         = number
  #   cluster_id          = optional(string. "")
  #   cluster_arn         = optional(string, "")
  #   sg_ids              = list(string)
  #   subnet_ids          = list(string)
  #   enable_ecs_service = bool
  #   enable_task_schedule = bool
  #   enable_service_schedule = bool
  #   enable_service_discovery = bool
  #   lb_target_groups = optional(list(object({
  #     lb_target_group_arn = string
  #     container_port      = number
  #     container_name      = string
  #   })), [])
  # }))
}

variable "cloudmap_private_dns_namespace_id" {
  type = string
}
