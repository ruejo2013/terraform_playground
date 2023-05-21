terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider "aws" {
#   region = "us-east-1"
# }

resource "aws_iam_user" "iam_user" {
    name = var.user_name
}