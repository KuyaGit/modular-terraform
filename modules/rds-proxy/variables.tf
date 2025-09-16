# Declare all variables
variable "project" {
  type        = string
  description = "The project name"
}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "database_subnets" {
  type        = list(string)
  description = "The database subnets"
}

variable "auroradb_proxy_sg_id" {
  type        = string
  description = "The aurora db proxy security group id"
}

variable "auroradb_cluster_id" {
  type        = string
  description = "The aurora db cluster id"
}
