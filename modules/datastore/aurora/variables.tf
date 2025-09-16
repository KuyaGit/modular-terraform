variable "name" {
  description = "Name of the cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnets" {
  description = "Subnets"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "Subnet group name from VPC"
  type        = string
}

variable "security_group_id" {
  description = "Security group id"
  type        = string
}

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
}

variable "scaling_max_capacity" {
  description = "ServerlessV2 scaling max capacity"
  type        = number
  default     = 1
}

variable "db_name" {
  description = "Name of the main database to create"
  type        = string
  default     = null # Will use project name if not specified
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = null # Will use project name if not specified
}

variable "instances" {
  description = "Map of instance configurations for the cluster. Set to { 1 = {} } for single instance, { 1 = {}, 2 = {} } for multi-AZ"
  type        = map(any)
  default     = { 1 = {} } # Default to single instance
}

variable "scaling_min_capacity" {
  description = "ServerlessV2 scaling min capacity"
  type        = number
  default     = 0.5
}
