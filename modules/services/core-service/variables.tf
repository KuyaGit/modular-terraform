variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks to run in the service"
  type        = number
}

variable "auto_scaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
}

variable "auto_scaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for auto scaling"
  type        = number
}

variable "memory_threshold" {
  description = "Memory utilization threshold for auto scaling"
  type        = number
}

variable "cpu_scale_in_cooldown" {
  description = "Cooldown period in seconds before allowing another scale in activity for CPU based scaling"
  type        = number
}

variable "cpu_scale_out_cooldown" {
  description = "Cooldown period in seconds before allowing another scale out activity for CPU based scaling"
  type        = number
}

variable "memory_scale_in_cooldown" {
  description = "Cooldown period in seconds before allowing another scale in activity for memory based scaling"
  type        = number
}

variable "memory_scale_out_cooldown" {
  description = "Cooldown period in seconds before allowing another scale out activity for memory based scaling"
  type        = number
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the service"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs to associate with the service"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "aws_cloudwatch_log_group_retention" {
  description = "Retention period for the CloudWatch log group"
  type        = number
}

variable "alb_subnets" {
  description = "List of subnet IDs to associate with the ALB"
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "region" {
  description = "Region of the AWS account"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "domain_name" {
  type        = string
  description = "Domain Name"
}

variable "zone_id" {
  description = "Zone ID of Hosted Zone"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
  nullable    = true
  default     = null
}

variable "launch_type" {
  description = "Launch type for the service"
  type        = string
  default     = "FARGATE"
}
