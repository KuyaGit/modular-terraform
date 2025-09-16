// define variables for the sqs queue
variable "sqs_queue_name" {
  type        = string
  description = "The name of the SQS queue to create"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "environment" {
  type        = string
  description = "Environment name for resource tagging"
}
