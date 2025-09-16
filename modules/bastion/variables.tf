variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the bastion host will be created"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID where the bastion host will be created"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to SSH to the bastion host"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use for the bastion host"
}
