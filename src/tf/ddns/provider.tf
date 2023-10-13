# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.11.1"
    }
  }
}
