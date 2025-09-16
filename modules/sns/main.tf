// Create SNS Topic
resource "aws_sns_topic" "notification_topic" {
  name = var.sns_topic_name

  // Enable server-side encryption
  kms_master_key_id = "alias/aws/sns"

  // Add FIFO support if needed
  fifo_topic = false

  tags = {
    Name        = var.sns_topic_name
    Environment = var.environment
    Purpose     = "appian-notifications"
  }
}

// Create HTTPS subscription endpoint for SQS
resource "aws_sns_topic_subscription" "sqs_target" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "sqs"
  endpoint  = var.sqs_queue_arn

  // Enable raw message delivery for simpler message format
  raw_message_delivery = true
}

// Create IAM user for Appian to access SNS
resource "aws_iam_user" "appian_sns_user" {
  name = "appian-sns-publisher"
  path = "/appian/"

  tags = {
    Name        = "appian-sns-publisher"
    Environment = var.environment
    Purpose     = "appian-integration"
  }
}

// Create IAM access key for the user
resource "aws_iam_access_key" "appian_sns_key" {
  user = aws_iam_user.appian_sns_user.name
}

// Create IAM policy for SNS publish access
resource "aws_iam_user_policy" "appian_sns_policy" {
  name = "appian-sns-publish-policy"
  user = aws_iam_user.appian_sns_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes",
          "sns:ListTopics"
        ]
        Resource = [
          aws_sns_topic.notification_topic.arn
        ]
      }
    ]
  })
}

// SNS Topic policy to allow IAM user publish
resource "aws_sns_topic_policy" "notification_topic_policy" {
  arn = aws_sns_topic.notification_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAppianPublish"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.appian_sns_user.arn
        }
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes"
        ]
        Resource = aws_sns_topic.notification_topic.arn
      }
    ]
  })
}

// Add SQS queue permission to allow SNS to send messages
resource "aws_sqs_queue_policy" "allow_sns_to_sqs" {
  queue_url = var.sqs_queue_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = var.sqs_queue_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : aws_sns_topic.notification_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_ssm_parameter" "sns_topic_arn" {
  name        = "/${var.project}/${var.environment}/${var.sns_topic_name}/sns-topic-arn"
  description = "SNS Topic ARN for notifications"
  type        = "String"
  value       = aws_sns_topic.notification_topic.arn

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
resource "aws_ssm_parameter" "sns_access_key_id" {
  name        = "/${var.project}/${var.environment}/${var.sns_topic_name}/sns-access-key-id"
  description = "SNS Publisher Access Key ID"
  type        = "SecureString"
  value       = aws_iam_access_key.appian_sns_key.id
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_ssm_parameter" "sns_secret_key" {
  name        = "/${var.project}/${var.environment}/${var.sns_topic_name}/sns-secret-key"
  description = "SNS Publisher Secret Access Key"
  type        = "SecureString"
  value       = aws_iam_access_key.appian_sns_key.secret

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

