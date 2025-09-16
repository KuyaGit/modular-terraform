# Create IAM user for local development
resource "aws_iam_user" "dev_api_user" {
  name = "${var.project}-${var.environment}-local-dev"
  path = "/developers/"

  tags = {
    Description = "Local development access for API"
    Environment = var.environment
    Project     = var.project
    Purpose     = "Local Development"
  }
}

# Create policy for local development
resource "aws_iam_policy" "dev_api_policy" {
  name        = "${var.project}-${var.environment}-local-dev-policy"
  description = "Policy for local development access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = [
          # Only allow access to /tara/dev/* parameters
          "arn:aws:ssm:*:*:parameter/tara/dev",
          "arn:aws:ssm:*:*:parameter/tara/dev/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "*" # Allow decryption of any KMS key used for SSM parameters
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:ListTopics",
          "sns:GetTopicAttributes",
          "sns:Publish",
          "sns:ListSubscriptions",
          "sns:ListSubscriptionsByTopic",
          "sns:GetSubscriptionAttributes"
        ]
        Resource = [
          "arn:aws:sns:*:*:notification-topic",
          "arn:aws:sns:*:*:*" # Required for ListSubscriptions
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ListQueues",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:SetQueueAttributes",
          "sqs:TagQueue"
        ]
        Resource = [
          "arn:aws:sqs:*:*:notification-queue",
          "arn:aws:sqs:*:*:notification-queue-dlq",
          "arn:aws:sqs:*:*:notification-processor-*",
          "arn:aws:sqs:*:*:notification-processor-*-dlq*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:ListVersionsByFunction",
          "lambda:ListTags",
          "lambda:GetPolicy",
          "lambda:GetRuntimeManagementConfig",
          "lambda:InvokeFunction",
          "lambda:InvokeAsync",
          "lambda:ListEventSourceMappings",
          "lambda:GetEventSourceMapping",
          "lambda:ListFunctions",
          "lambda:GetAccountSettings",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:CreateAlias",
          "lambda:DeleteAlias",
          "lambda:UpdateAlias",
          "lambda:PutFunctionConcurrency",
          "lambda:DeleteFunctionConcurrency",
          "lambda:PublishVersion",
          "lambda:DeleteFunctionEventInvokeConfig",
          "lambda:PutFunctionEventInvokeConfig"
        ]
        Resource = [
          "arn:aws:lambda:*:*:function:*",
          "arn:aws:lambda:*:*:function:*:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:ListImages",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:TagResource",
          "ecr:UntagResource"
        ]
        Resource = [
          "arn:aws:ecr:*:*:repository/*",
          "arn:aws:ecr:*:*:repository/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy",
          "logs:PutMetricFilter",
          "logs:DeleteMetricFilter",
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:*",
          "arn:aws:logs:*:*:log-group:*:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketTagging",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:GetBucketCORS",
          "s3:GetBucketWebsite",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetAccelerateConfiguration",
          "s3:GetAnalyticsConfiguration",
          "s3:GetMetricsConfiguration",
          "s3:GetInventoryConfiguration",
          "s3:GetBucketNotification",
          "s3:GetBucketLogging",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketEncryption",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectTorrent",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:PutObjectTagging",
          "s3:PutObjectRetention",
          "s3:PutObjectLegalHold",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteObjectTagging",
          "s3:RestoreObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploads",
          "s3:ListParts",
          "s3:CompleteMultipartUpload"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Resource = [
          "arn:aws:iam::*:role/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:DELETE",
          "apigateway:PATCH"
        ]
        Resource = [
          "arn:aws:apigateway:*::/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:GetTemplateSummary",
          "cloudformation:ListStacks",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate",
          "cloudformation:GetTemplate",
          "cloudformation:SetStackPolicy",
          "cloudformation:GetStackPolicy",
          "cloudformation:ListStackResources",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStackResource",
          "cloudformation:ListStackResources",
          "cloudformation:ListExports",
          "cloudformation:ListImports",
          "cloudformation:GetTemplateSummary",
          "cloudformation:EstimateTemplateCost",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:ListChangeSets"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "dev_api_user_policy" {
  user       = aws_iam_user.dev_api_user.name
  policy_arn = aws_iam_policy.dev_api_policy.arn
}

# Create access key
resource "aws_iam_access_key" "dev_api_user" {
  user = aws_iam_user.dev_api_user.name
}

# Store credentials in Secrets Manager for secure access
resource "aws_secretsmanager_secret" "dev_api_credentials" {
  name        = "${var.project}/${var.environment}/local-dev-credentials"
  description = "Local development API credentials"
}

resource "aws_secretsmanager_secret_version" "dev_api_credentials" {
  secret_id = aws_secretsmanager_secret.dev_api_credentials.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.dev_api_user.id
    secret_access_key = aws_iam_access_key.dev_api_user.secret
  })
}
