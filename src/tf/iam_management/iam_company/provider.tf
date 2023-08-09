terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # add after s3 is created
  backend "s3" {
    bucket  = "leo-systemdeploy-cloudservices-tfstate"
    key     = "global/s3/corporate-structure.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-2"
}
