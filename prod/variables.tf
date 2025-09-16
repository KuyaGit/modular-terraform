variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project identifier for resource tagging"
  type        = string
  default     = "tara"
}

variable "gitlab_runner_token" {
  description = "Gitlab runner token for dev environment"
  type        = string
}


variable "zone_id" {
  description = "Zone ID of Hosted Zone"
  type        = string
}

variable "domain_name" {
  type        = string
  description = "Domain Name"
}

variable "delegated_ns" {
  type        = list(string)
  description = "List of NS records from Account B for the subdomain"
}

variable "dynatrace_external_id" {
  type        = string
  description = "External ID for Dynatrace"
}
