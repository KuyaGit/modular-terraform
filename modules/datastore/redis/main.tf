locals {
  port = 6379
}

resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7"
  name   = "${var.cluster_id}-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

resource "aws_elasticache_cluster" "cluster" {
  cluster_id = var.cluster_id

  engine          = "redis"
  node_type       = var.node_type
  num_cache_nodes = var.num_nodes

  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "7.1"
  port                 = local.port

  availability_zone  = var.availability_zone
  subnet_group_name  = var.subnet_group_name
  security_group_ids = [var.security_group_id]

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.log_group.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  apply_immediately = true
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.cluster_id}-log-group"
  retention_in_days = var.aws_cloudwatch_log_group_retention
}

# SSM Parameters for Redis connection details
resource "aws_ssm_parameter" "redis_host" {
  name  = "/${var.project}/${var.environment}/redis/host"
  type  = "String"
  value = aws_elasticache_cluster.cluster.cache_nodes[0].address
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_ssm_parameter" "redis_port" {
  name  = "/${var.project}/${var.environment}/redis/port"
  type  = "String"
  value = tostring(local.port)
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_ssm_parameter" "redis_connection_string" {
  name  = "/${var.project}/${var.environment}/redis/connection_string"
  type  = "String"
  value = "redis://${aws_elasticache_cluster.cluster.cache_nodes[0].address}:${local.port}"
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
