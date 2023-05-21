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

module "webserver_cluster" {
  # source = "git@github.com:ruejo2013/terraform_modules.git//services/webserver-cluster?ref=v0.0.3"

  source        = "<path to module>"
  ami           = var.aws_ami
  server_text   = var.server_text

  cluster_name        = var.cluster_name
  db_remote_bucket    = var.bucket_name
  db_remote_state_key = "${var.env}/data-stores/${var.db_engine}/terraform.tfstate"

  instance_type       = "t2.micro"
  min_size            = 2
  max_size            = 2
  enable_autoscaling  = false
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type               = "ingress"
  from_port          = 12345
  to_port            = 12345
  protocol           = "tcp"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = module.webserver_cluster.alb_security_group_id
}