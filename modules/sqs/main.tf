// Create the main SQS queue for notifications
resource "aws_sqs_queue" "notification_queue" {
  name                       = var.sqs_queue_name
  delay_seconds              = 0
  max_message_size           = 262144 // 256 KB
  message_retention_seconds  = 345600 // 4 days
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30

  // Enable server-side encryption
  sqs_managed_sse_enabled = true

  // Create a dead letter queue for failed messages
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Environment = "dev"
    Purpose     = "notification-processing"
  }
}

// Dead Letter Queue for failed messages
resource "aws_sqs_queue" "notification_dlq" {
  name                      = "${var.sqs_queue_name}-dlq"
  delay_seconds             = 0
  max_message_size          = 262144  // 256 KB
  message_retention_seconds = 1209600 // 14 days
  receive_wait_time_seconds = 0

  // Enable server-side encryption
  sqs_managed_sse_enabled = true

  tags = {
    Environment = "dev"
    Purpose     = "failed-notification-messages"
  }
}

// save to ssm
resource "aws_ssm_parameter" "sqs_queue_arn" {
  name        = "/${var.project}/${var.environment}/${var.sqs_queue_name}/sqs-queue-arn"
  description = "SQS Queue ARN for notifications"
  type        = "String"
  value       = aws_sqs_queue.notification_queue.arn
}

resource "aws_ssm_parameter" "sqs_queue_url" {
  name        = "/${var.project}/${var.environment}/${var.sqs_queue_name}/sqs-queue-url"
  description = "SQS Queue URL for notifications"
  type        = "String"
  value       = aws_sqs_queue.notification_queue.url
}
