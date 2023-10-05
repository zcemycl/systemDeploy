resource "aws_s3_bucket" "tfendpoint" {
  bucket = "leo-leung-051023-vpc-endpt2"
  acl    = "private"

  tags = {
    Name        = "endpoint-bucket"
    Environment = "VPC_EndPoint_test"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.base_vpc.id
  service_name    = "com.amazonaws.eu-west-2.s3"
  route_table_ids = module.private_network.private_route_tables[*].id
}
