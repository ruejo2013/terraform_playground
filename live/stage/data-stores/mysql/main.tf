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

resource "aws_db_instance" "mysql_db" {
    identifier_prefix       = "terraform-playground-db"
    engine                  = var.db_engine
    allocated_storage       = 10
    instance_class          = "db.t2.micro"
    skip_final_snapshot     = true
    db_name                 = var.db_name

    # how should we set the username and password
    username                = local.db_creds.username
    password                = local.db_creds.password
}


terraform {
  backend "s3" {
    bucket  = "mena-terraform-up-and-running-bucket"
    key     = "dev/data-stores/mysql/terraform.tfstate"
    region  = "us-east-1"

    dynamodb_table = "terraform_dynamo_tf_stfile_lock"
    encrypt        = true
  }
}

data "aws_kms_secrets" "creds" {
  secret {
    name    = "db"
    payload = file("<path to .yml.encrypted file>")
  }
}


locals {
  db_creds   = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}
