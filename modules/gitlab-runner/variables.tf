variable "name_prefix" {
  description = "Prefix for all object names"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "ssm_prefix" {
  description = "SSM prefix for parameters"
  type        = string
}

variable "gitlab_url" {
  description = "URL of the gitlab instance to connect to."
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_runner_token" {
  description = "Gitlab runner authentication token"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the gitlab runner"
  type        = string
}

variable "vpc_subnet_id" {
  description = "VPC subnet ID for the gitlab runner"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for the gitlab runner"
  type        = list(string)
}
