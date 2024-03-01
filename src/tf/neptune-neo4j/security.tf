resource "aws_security_group" "this" {
  #Incoming traffic
  ingress {
    from_port   = 8182
    to_port     = 8182
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
