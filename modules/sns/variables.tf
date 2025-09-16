// define variables for the sns topic
variable "sns_topic_name" {
  type        = string
  description = "The name of the SNS topic to create"
}

variable "sqs_queue_arn" {
  type        = string
  description = "The ARN of the SQS queue to subscribe to the SNS topic"
}

variable "sqs_queue_url" {
  type        = string
  description = "The URL of the SQS queue for setting queue policy"
}

variable "environment" {
  type        = string
  description = "Environment name for resource tagging"
  default     = "dev"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

