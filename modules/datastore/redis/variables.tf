variable "cluster_id" {
  type        = string
  description = "ID for the Redis cluster"
}

variable "node_type" {
  type        = string
  description = "The compute and memory capacity of the nodes"
}

variable "num_nodes" {
  type        = number
  description = "Number of cache nodes in the cluster"
}

variable "availability_zone" {
  type        = string
  description = "The Availability Zone where Redis cluster will be created"
}

variable "subnet_group_name" {
  type        = string
  description = "Name of the subnet group to be used for the cluster"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group to be used for the cluster"
}

variable "ssm_prefix" {
  description = "SSM prefix"
  type        = string
}

variable "aws_cloudwatch_log_group_retention" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
}

variable "auth_token" {
  description = "Auth token for Redis. If not provided, a random one will be generated"
  type        = string
  default     = null
  sensitive   = true
}

variable "project" {
  type        = string
  description = "Project name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name for resource naming"
}
