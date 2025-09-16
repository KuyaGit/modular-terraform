output "writer_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.cluster.cluster_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the cluster"
  value       = module.cluster.cluster_reader_endpoint
}

output "port" {
  description = "Port number for database connections"
  value       = module.cluster.cluster_port
}

output "database_name" {
  description = "Name of the default database"
  value       = module.cluster.cluster_database_name
}

output "username" {
  description = "Master username for the database"
  value       = module.cluster.cluster_master_username
}

# Add outputs for the parameter ARNs (useful for IAM policies)
output "parameter_arns" {
  description = "ARNs of the SSM parameters storing DB credentials"
  value = [
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_name.arn,
    aws_ssm_parameter.db_username.arn,
    aws_ssm_parameter.db_password.arn
  ]
}

output "cluster_id" {
  description = "ID of the cluster"
  value       = module.cluster.cluster_id
}
