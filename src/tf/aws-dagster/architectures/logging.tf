module "logging" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/logging"
  region = var.AWS_REGION
  loggings = [
    {
      name              = "etl1"
      group_name        = "/ecs/etl1"
      stream_name       = "etl1"
      retention_in_days = 1
      enable_vpc_endpt  = false
      vpc_id            = aws_vpc.this.id
      sg_ids            = [module.security_groups.sg_ids["everything"].id]
      subnet_ids        = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*etl1_nat.*", name)) > 0]
    },
    {
      name              = "etl2"
      group_name        = "/ecs/etl2"
      stream_name       = "etl2"
      retention_in_days = 1
      enable_vpc_endpt  = false
      vpc_id            = aws_vpc.this.id
      sg_ids            = [module.security_groups.sg_ids["everything"].id]
      subnet_ids        = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*etl2_nat.*", name)) > 0]
    },
    {
      name              = "webserver"
      group_name        = "/ecs/webserver"
      stream_name       = "webserver"
      retention_in_days = 1
      enable_vpc_endpt  = false
      vpc_id            = aws_vpc.this.id
      sg_ids            = [module.security_groups.sg_ids["everything"].id]
      subnet_ids        = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*webserver_nat.*", name)) > 0]
    },
    {
      name              = "daemon"
      group_name        = "/ecs/daemon"
      stream_name       = "daemon"
      retention_in_days = 1
      enable_vpc_endpt  = false
      vpc_id            = aws_vpc.this.id
      sg_ids            = [module.security_groups.sg_ids["everything"].id]
      subnet_ids        = [for name, obj in module.private_subnet.subnets : obj.id if length(regexall(".*daemon_nat.*", name)) > 0]
    }
  ]
}
