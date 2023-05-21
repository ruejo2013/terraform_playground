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
## create backend 
# terraform {
#   backend "s3" {
#     key     = "global/s3/terraform.tfstate"
#   }
# }

# Autoscailing group to launch mutiple EC2's

resource "aws_launch_configuration" "terra_test" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.terraform_pg_sg.id]

  user_data = templatefile("${path.module}/user-data.sh", {
      server_port = var.server_port
      db_address  = data.terraform_remote_state.db.outputs.db_address
      db_port     = data.terraform_remote_state.db.outputs.port
      server_text = var.server_text
      }
    )

  # required when using a launch configuration with an auto scaling group
  lifecycle {
    create_before_destroy = true
  }
}
# Elastic load balance auto scaling group
resource "aws_autoscaling_group" "terra_autoscaling" {
  name                    = var.cluster_name
  launch_configuration    = aws_launch_configuration.terra_test.name
  vpc_zone_identifier     = data.aws_subnets.default.ids

  target_group_arns   = [aws_lb_target_group.asg-target-gp.arn]
  health_check_type   = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  # min_elb_capacity = var.min_size

  tag {
    key                   = "Name"
    value                 = "${var.cluster_name}-autosc-target-gp"
    propagate_at_launch   = true
  }
  dynamic "tag" {
    for_each  = {
      for key, value in var.custom_tags:
      key => upper(value)
      if key != "Name"
    }
      

    content {
      key    = tag.key
      value  = tag.value
      propagate_at_launch = true
    }
  }
# using instance refresh to roll out changes to the ASG
  instance_refresh {
    strategy  = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}


# Security group
resource "aws_security_group" "terraform_pg_sg" {
  name = "${var.cluster_name}-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  tags = {
    Name = "${var.cluster_name}-sg"
  }

}

# Application load balancer 

resource "aws_lb" "alb" {
  name                = "${var.cluster_name}-alb"
  load_balancer_type  = "application"
  subnets             = data.aws_subnets.default.ids
  security_groups     = [aws_security_group.alb-sg.id]
}

# Load balancer Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn   = aws_lb.alb.arn
  port                = local.http_port
  protocol            = "HTTP"

  # by default, return a simple 400 page 
  default_action {
    type   = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Autoscaling group security group 

resource "aws_security_group" "alb-sg" {
  name    = "${var.cluster_name}-alb-sg"

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb-sg.id
  # Allow inbound HTTP requests
    from_port     = local.http_port
    to_port       = local.http_port
    protocol      = local.tcp_protocol
    cidr_blocks   = local.all_ips
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb-sg.id
  # Allow all outbount requests 
    from_port     = local.any_port
    to_port       = local.any_port
    protocol      = local.tcp_protocol
    cidr_blocks   = local.all_ips
}

# Autoscaling group target group

resource "aws_lb_target_group" "asg-target-gp" {
  name        = "${var.cluster_name}-asg-target-gp"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                 =  "/"
    protocol             =  "HTTP"
    matcher              =  "200"
    interval             =  15
    timeout              =  3
    healthy_threshold    =  2
    unhealthy_threshold  =  2
  }
}



# listener rule 
resource "aws_lb_listener_rule" "asg-listener_rule" {
  listener_arn    =  aws_lb_listener.http.arn
  priority        =  100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action  {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.asg-target-gp.arn
  }
}

# vpc data
data "aws_vpc" "default" {
  default = true
}

# subnet data, filtered with vpc data above
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket  = var.db_remote_bucket
        key     = var.db_remote_state_key
        region  = "us-east-1"
    }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}