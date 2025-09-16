variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "redis_instance_type" {
  type    = string
  default = "cache.t4g.micro"
} 