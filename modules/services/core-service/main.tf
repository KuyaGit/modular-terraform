locals {
  service_name = "${var.project}-${var.environment}-core-service"
}

resource "aws_ecs_service" "service" {
  name            = local.service_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = local.service_name
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

# task definition
resource "aws_ecs_task_definition" "service" {
  family                   = local.service_name
  task_role_arn            = aws_iam_role.task_execution_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = local.service_name
      image     = "${var.ecr_repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-region"        = var.region
        }
      }
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = [
      cpu,
      memory,
      container_definitions
    ]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.service_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role_ecs_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_ssm_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "task_execution_role_ecr_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Add this policy to allow ECS task execution role to policies:
# 1. Aurora secrets
# 2. S3 Bucket
resource "aws_iam_role_policy" "ecs_task_execution_nodejs_policies" {
  name = "EcsTaskNodeJsPolicies"
  role = aws_iam_role.task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      // Aurora secrets
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "*"
        ]
      },
      // S3 Bucket
      {

        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${var.bucket_arn}",
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.auto_scaling_max_capacity
  min_capacity       = var.auto_scaling_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# --- Average CPU Step Scaling ---
# Scale Out
resource "aws_appautoscaling_policy" "avg_cpu_scale_out" {
  name               = "${local.service_name}-avg-cpu-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"
    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
    }
  }
}
# Scale In
resource "aws_appautoscaling_policy" "avg_cpu_scale_in" {
  name               = "${local.service_name}-avg-cpu-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}
# Alarms
resource "aws_cloudwatch_metric_alarm" "ecs_avg_cpu_high" {
  alarm_name          = "${local.service_name}-avg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_description = "Alarm when average ECS service CPU exceeds 60%"
  alarm_actions     = [aws_appautoscaling_policy.avg_cpu_scale_out.arn]
}
resource "aws_cloudwatch_metric_alarm" "ecs_avg_cpu_low" {
  alarm_name          = "${local.service_name}-avg-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_description = "Alarm when average ECS service CPU is below 30% for 2 minutes"
  alarm_actions     = [aws_appautoscaling_policy.avg_cpu_scale_in.arn]
}

# --- Max CPU Step Scaling ---
# Scale Out
resource "aws_appautoscaling_policy" "max_cpu_scale_out" {
  name               = "${local.service_name}-max-cpu-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60 # Short cooldown for fast scale out
    metric_aggregation_type = "Maximum"
    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
    }
  }
}

# Scale In
resource "aws_appautoscaling_policy" "max_cpu_scale_in" {
  name               = "${local.service_name}-max-cpu-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600 # 10 minutes to avoid thrashing
    metric_aggregation_type = "Maximum"
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

# Alarms
# High-resolution max CPU alarm for rapid scaling
resource "aws_cloudwatch_metric_alarm" "ecs_max_cpu_high_res" {
  alarm_name          = "${local.service_name}-max-cpu-high-res"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 10
  statistic           = "Maximum"
  threshold           = 60
  datapoints_to_alarm = 1
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_description  = "High-resolution alarm for rapid scaling when any ECS task CPU exceeds 80%"
  alarm_actions      = [aws_appautoscaling_policy.max_cpu_scale_out.arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "ecs_max_cpu_low" {
  alarm_name          = "${local.service_name}-max-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 40
  datapoints_to_alarm = 1
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.service.name
  }
  alarm_description  = "Alarm when ECS task max CPU is below 40% for 5 minutes"
  alarm_actions      = [aws_appautoscaling_policy.max_cpu_scale_in.arn]
  treat_missing_data = "notBreaching"
}

# --- Memory Target Tracking Scaling ---
# (Removed memory autoscaling as requested)

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${local.service_name}-log-group"
  retention_in_days = var.aws_cloudwatch_log_group_retention
}

resource "aws_lb" "lb" {
  name               = "${local.service_name}-lb"
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = var.alb_security_group_ids
  client_keep_alive  = 60
  idle_timeout       = 40
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      # optional: path and query can be preserved automatically, so you don't need to set them unless you want to rewrite
      # path        = "/"
      # query       = "#{query}"
    }
  }
}

resource "aws_lb_listener" "https" {
  # depends_on = [aws_acm_certificate_validation.this]

  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.cert[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb_listener_certificate" "ssl_cert_For_dns" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.cert[0].arn
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "${local.service_name}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    interval            = "15"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "4"
    path                = "/api/health"
  }

  deregistration_delay = "180"
}

resource "aws_cloudwatch_log_group" "migration_log_group" {
  name              = "${local.service_name}-migration-log-group"
  retention_in_days = var.aws_cloudwatch_log_group_retention
}

#ACM Cert for Domain of API
resource "aws_acm_certificate" "cert" {
  count             = var.certificate_arn == null ? 1 : 0
  domain_name       = "api-${var.environment}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Step 2: Create Route53 validation record
resource "aws_route53_record" "cert_validation" {
  for_each = var.certificate_arn == null ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Step 3: Validate the certificate
resource "aws_acm_certificate_validation" "this" {
  count = var.certificate_arn == null ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_ssm_parameter" "core_service_alb_url" {
  name      = "/${var.project}/${var.environment}/core-service-alb-url"
  type      = "String"
  value     = "http://${aws_lb.lb.dns_name}"
  overwrite = true
}
