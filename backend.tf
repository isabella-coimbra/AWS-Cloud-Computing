terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "aws-dev"
    key    = "app/aws/key" #The Terraform state is written to the key
    region = "us-east-1"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}