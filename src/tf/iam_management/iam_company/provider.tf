terraform {
    backend "s3" {
        bucket = ""
    }
}

provider "aws" {
    region = "eu-west-2"
}