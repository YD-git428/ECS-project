terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket = "terra-bucket213"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}


provider "aws" {
  region = "eu-west-2"
}