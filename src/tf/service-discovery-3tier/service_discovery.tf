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

data "dns_a_record_set" "rds_hostname" {
  host = aws_db_instance.rds.address
}

resource "aws_service_discovery_instance" "db" {
  instance_id = aws_db_instance.rds.id
  service_id  = aws_service_discovery_service.db.id

  attributes = {
    AWS_INSTANCE_IPV4 = join(",", data.dns_a_record_set.rds_hostname.addrs)
  }
}

output "rds_private_ip_addrs" {
  value = join(",", data.dns_a_record_set.rds_hostname.addrs)
}
