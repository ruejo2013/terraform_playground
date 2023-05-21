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

resource "aws_db_instance" "postgres_db" {
    identifier_prefix       = "terraform-playground-db"
    engine                  = var.db_engine
    engine_version          = "14.1"
    allocated_storage       = 10
    instance_class          = "db.t3.micro"
    skip_final_snapshot     = true
    db_name                 = var.db_name

    # how should we set the username and password
    username                = var.db_username
    password                = var.db_password
}


terraform {
  backend "s3" {
    bucket  = var.bucket_name
    key     = "${var.env}/data-stores/${var.db_engine}/terraform.tfstate"
    region  = "us-east-1"

    dynamodb_table = var.dynamodb_lock
    encrypt        = true
  }
}