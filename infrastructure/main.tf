terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.77"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "terraform-112233"
    region = "ap-southeast-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1" # Replace with your desired region
}


