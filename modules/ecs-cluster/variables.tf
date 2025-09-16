variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "service_connect_cloudmap_namespace_arn" {
  description = "ARN of the Cloud Map namespace for Service Connect"
  type        = string
}

variable "enable_container_insights" {
  description = "Whether to enable Container Insights monitoring"
  type        = bool
  default     = true
}
