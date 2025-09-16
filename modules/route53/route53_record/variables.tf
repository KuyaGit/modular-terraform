variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID for the root domain (e.g. dot.com)"
  type        = string
}

variable "record_name" {
  description = "The full DNS name to create (e.g. api.dot.com)"
  type        = string
}

variable "alb_dns_name" {
  type    = string
  default = null
}

variable "alb_zone_id" {
  type    = string
  default = null
}

variable "delegated_ns" {
  type    = list(string)
  default = []

  validation {
    condition     = length(var.delegated_ns) == 0 || length(var.delegated_ns) == 4
    error_message = "delegated_ns must be either empty or contain exactly 4 name servers."
  }
}