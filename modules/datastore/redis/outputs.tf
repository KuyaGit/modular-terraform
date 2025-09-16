output "redis_host" {
  value       = aws_elasticache_cluster.cluster.cache_nodes[0].address
  description = "Redis cluster host address"
}

output "redis_port" {
  value       = local.port
  description = "Redis cluster port"
}

output "redis_connection_string" {
  value       = "rediss://${aws_elasticache_cluster.cluster.cache_nodes[0].address}:${local.port}"
  description = "Redis connection string with SSL"
}
