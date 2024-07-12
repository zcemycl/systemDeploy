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
  }
}
