// Outputs
output "sqs_queue_arn" {
  value = aws_sqs_queue.notification_queue.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.notification_queue.url
}

output "sqs_dlq_arn" {
  value = aws_sqs_queue.notification_dlq.arn
}
