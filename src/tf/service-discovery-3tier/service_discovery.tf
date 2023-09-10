resource "aws_service_discovery_private_dns_namespace" "backend" {
  name = var.internal_domain_name
  vpc  = aws_vpc.base_vpc.id
}

resource "aws_service_discovery_service" "backend" {
  name = var.internal_serv_name
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.backend.id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}

resource "aws_service_discovery_service" "db" {
  name = var.internal_db_name
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.backend.id
    routing_policy = "WEIGHTED"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}

# only suitable with vpn on / public hostname resolver
# data "dns_a_record_set" "rds_hostname" {
#   host = aws_db_instance.rds.address
# }
# output "rds_private_ip_addrs" {
#   value = join(",", data.dns_a_record_set.rds_hostname.addrs)
# }

data "aws_network_interface" "rds_network_interface" {
  filter {
    name   = "group-name"
    values = ["rds-sg"]
  }
}

resource "aws_service_discovery_instance" "db" {
  instance_id = aws_db_instance.rds.id
  service_id  = aws_service_discovery_service.db.id

  attributes = {
    AWS_INSTANCE_IPV4 = data.aws_network_interface.rds_network_interface.private_ip # dynamic?
  }
}

output "rds_private_ip_addrs2" {
  value = data.aws_network_interface.rds_network_interface.private_ip
}
