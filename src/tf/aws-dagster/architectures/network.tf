# private
module "private_subnet" {
  source             = "github.com/zcemycl/systemDeploy/src/tf/modules/subnet"
  vpc_id             = aws_vpc.this.id
  availability_zones = var.availability_zones
  subnet_settings = {
    db_nat = {
      subnets_cidr        = var.db_subnets_cidr
      assign_eip          = false
      enable_nat_instance = false
      enable_nat_gateway  = false
      public_subnet_ids   = aws_subnet.this.*.id
    }
    etl1_nat = {
      subnets_cidr        = var.etl1_subnets_cidr
      assign_eip          = false
      enable_nat_instance = true
      enable_nat_gateway  = false
      public_subnet_ids   = aws_subnet.this.*.id
    }
    etl2_nat = {
      subnets_cidr        = var.etl2_subnets_cidr
      assign_eip          = false
      enable_nat_instance = true
      enable_nat_gateway  = false
      public_subnet_ids   = aws_subnet.this.*.id
    }
    webserver_nat = {
      subnets_cidr        = var.dagster_webserver_subnets_cidr
      assign_eip          = false
      enable_nat_instance = true
      enable_nat_gateway  = false
      public_subnet_ids   = aws_subnet.this.*.id
    }
    daemon_nat = {
      subnets_cidr        = var.dagster_daemon_subnets_cidr
      assign_eip          = false
      enable_nat_instance = true
      enable_nat_gateway  = false
      public_subnet_ids   = aws_subnet.this.*.id
    }
  }
}
