terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "iam_users" {
  source     = "<path-to-file>/modules/landing_zone/iam_user"
  count      = length(var.user_names)
  user_name  = var.user_names[count.index]
}
