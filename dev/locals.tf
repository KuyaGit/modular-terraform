locals {
  name_prefix  = "${var.project}-${var.environment}"
  ssm_prefix   = "/${var.project}/${var.environment}"
  redis_prefix = "${local.ssm_prefix}/redis-cluster-1"

  subdomain    = var.environment
  cluster_name = "${local.name_prefix}-cluster-1"

  ecr_repository_name = "${var.project}-core-service"

  region = "ap-southeast-1"
}
