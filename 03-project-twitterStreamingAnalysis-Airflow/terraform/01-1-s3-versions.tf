# Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.2.0"
    }
  }
}
# 리전
provider "aws" {
  region = var.aws_region
}