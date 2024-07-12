resource "aws_service_discovery_private_dns_namespace" "this" {
  name = var.cloud_map_namespace
  vpc  = aws_vpc.this.id
}

resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-cluster"
}

module "ecs_srv_task" {
  source                            = "github.com/zcemycl/systemDeploy/src/tf/modules/ecs"
  prefix                            = var.prefix
  cloudmap_private_dns_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  service_task_definitions = {

  }
}
