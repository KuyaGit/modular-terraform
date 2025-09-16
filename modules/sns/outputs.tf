output "sns_publisher_access_key_id" {
  description = "Access Key ID for the SNS publisher IAM user"
  value       = aws_iam_access_key.appian_sns_key.id
  sensitive   = true
}

output "sns_publisher_secret_key" {
  description = "Secret Access Key for the SNS publisher IAM user"
  value       = aws_iam_access_key.appian_sns_key.secret
  sensitive   = true
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.notification_topic.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.notification_topic.name
}

output "sns_publisher_iam_user_arn" {
  description = "ARN of the SNS publisher IAM user"
  value       = aws_iam_user.appian_sns_user.arn
}

output "sns_publisher_iam_user_name" {
  description = "Name of the SNS publisher IAM user"
  value       = aws_iam_user.appian_sns_user.name
} 