module "core_service" {
  source = "../modules/services/core-service"

  project     = var.project
  environment = var.environment
  region      = local.region

  launch_type = "FARGATE"

  # Service configuration
  desired_count = 1

  # Auto scaling configuration
  auto_scaling_max_capacity = 2
  auto_scaling_min_capacity = 1

  # Scaling thresholds
  cpu_threshold    = 60
  memory_threshold = 60

  # Cooldown periods (in seconds)
  cpu_scale_in_cooldown     = 600
  cpu_scale_out_cooldown    = 180
  memory_scale_in_cooldown  = 900
  memory_scale_out_cooldown = 300

  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_cluster_id   = module.ecs_cluster.cluster_id

  security_group_ids = [module.private_services_sg.security_group_id]

  # Subnet for ECS tasks should be private
  subnets = module.vpc.private_subnets

  # Subnet for ALB should be public
  alb_subnets            = module.vpc.public_subnets
  alb_security_group_ids = [module.load_balancer_sg.security_group_id]

  ecr_repository_url = module.ecr.repository_url

  vpc_id = module.vpc.vpc_id

  aws_cloudwatch_log_group_retention = 14

  bucket_arn      = aws_s3_bucket.main.arn
  domain_name     = var.domain_name
  zone_id         = var.zone_id
  certificate_arn = "arn:aws:acm:ap-southeast-1:637423402313:certificate/1447f631-ccdf-4a82-984e-8db75edbfd9f"
}

# resource "aws_ssm_parameter" "core_service_alb_url" {
#   name  = "${local.ssm_prefix}/core-service-alb-url"
#   type  = "String"
#   value = "http://${module.alb.alb_dns_name}"
# }

module "waf_ecs" {
  source  = "../modules/waf"
  name    = "${var.project}-${var.environment}-ECS-WAF"
  alb_arn = module.core_service.alb_arn

  # Enable/Disable 
  enable_rate_limiting = true

  # Allow Request per IP 
  rate_limit = 3000

  # Allowed Country ISO
  # allowed_countries = ["PH"]

  # BLOCKED IP'S
  # blocked_ip_ranges = var.blocked_ip_ranges

  #Enable waf LOGGING
  enable_logging = true

  #WHen enable logging create log_group_name
  log_group_name = "${var.environment}-${var.project}"

  # Number of days to retain CloudWatch logs
  aws_cloudwatch_log_group_retention = 14

  # Enable test traffic
  enable_test_traffic = true

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
