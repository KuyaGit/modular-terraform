module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7.0"

  name = var.name

  load_balancer_type = "application"
  internal           = var.internal

  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  security_groups = var.security_group_ids

  enable_deletion_protection = var.enable_deletion_protection

  # Enable access logs if bucket is provided
  access_logs = var.access_logs_bucket == null ? {} : {
    bucket  = var.access_logs_bucket
    prefix  = var.name
    enabled = true
  }

  # HTTP listener with fixed response
  http_tcp_listeners = [{
    port             = 80
    protocol         = "HTTP"
    target_group_arn = null
    action_type      = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      message_body = "No routes matched"
      status_code  = "404"
    }
  }]

  https_listeners = []

  tags = var.tags
}

