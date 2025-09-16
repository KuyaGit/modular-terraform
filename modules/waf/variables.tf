variable "name" {
  description = "Name of the WAF ACL"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF ACL"
  type        = string
}

variable "enable_rate_limiting" {
  description = "Whether to enable rate limiting"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Number of requests allowed per 5-minute period per IP address"
  type        = number
  default     = 2000
}

variable "allowed_countries" {
  description = "List of country codes to allow"
  type        = list(string)
  default     = []
}

variable "blocked_ip_ranges" {
  description = "List of IP ranges to block (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF logging"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Set to true to enable WAF logging"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "log_group_name" {
  description = "Zone ID of Hosted Zone"
  type        = string
}

variable "aws_cloudwatch_log_group_retention" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
}

variable "enable_test_traffic" {
  description = "Whether to enable test traffic"
  type        = bool
  default     = false
}
