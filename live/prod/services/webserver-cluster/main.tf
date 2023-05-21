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
  source = "git@github.com:ruejo2013/terraform_modules.git//services/webserver-cluster?ref=v0.0.4"

  cluster_name        = var.cluster_name
  db_remote_bucket    = var.bucket_name
  db_remote_state_key = "${var.env}/data-stores/${var.db_engine}/terraform.tfstate"

  instance_type       = "m4.large"
  min_size            = 2
  max_size            = 10
  enable_autoscaling  = true

  custom_tags         = {
    Owner     = "${var.env}-prod"
    ManagedBy = "Patrick"
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name   = "scale-out-during-business-hours"
    min_size                = 2
    max_size                = 10
    desired_capacity        = 10
    recurrence              = "0 9 * * *"

    autoscaling_group_name  = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_nigth" {
    scheduled_action_name   = "scale-in_at_nigth"
    min_size                = 2
    max_size                = 10
    desired_capacity        = 2
    recurrence              = "0 17 * * *"

    autoscaling_group_name  = module.webserver_cluster.asg_name
}