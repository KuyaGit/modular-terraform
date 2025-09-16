/**
* S3 bucket for storing images privately and only
* allowing upload using presigned url
* but all images are publicly accessible
*/
resource "aws_s3_bucket" "main" {
  bucket = "${var.project}-${var.environment}-main"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

// set s3 bucket ownership and disable acl
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Enable object tagging for the main bucket
resource "aws_s3_bucket_object_lock_configuration" "main" {
  depends_on = [aws_s3_bucket_versioning.main]

  bucket = aws_s3_bucket.main.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "main" {
  depends_on = [aws_s3_bucket_public_access_block.main]

  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow public read access
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${aws_s3_bucket.main.arn}/*",
          "${aws_s3_bucket.main.arn}"
        ]
      },
      # Keep the PutObject restriction for presigned URLs
      {
        Sid       = "AllowPresignedUploadsOnly",
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:PutObject"]
        Resource  = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:signatureversion" = "AWS4-HMAC-SHA256"
          }
        }
      },
      # Allow copying objects from temp bucket to main bucket
      {
        Sid    = "AllowCopyFromTempBucket",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.main.arn}/*",
          "${aws_s3_bucket.main.arn}"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "PUT", "POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 3600
  }
}

/*
* S3 bucket for storing serverless deployment files
*/
resource "aws_s3_bucket" "serverless_deployment_bucket" {
  bucket = "${var.project}-${var.environment}-sls-deployment"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "serverless_deployment_bucket" {
  bucket = aws_s3_bucket.serverless_deployment_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "serverless_deployment_bucket" {
  bucket = aws_s3_bucket.serverless_deployment_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

// set s3 bucket ownership and disable acl
resource "aws_s3_bucket_ownership_controls" "serverless_deployment_bucket" {
  bucket = aws_s3_bucket.serverless_deployment_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Note: No Object Lock for serverless deployment bucket (deployment artifacts don't need tagging)

resource "aws_s3_bucket_public_access_block" "serverless_deployment_bucket" {
  bucket = aws_s3_bucket.serverless_deployment_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


/*
* S3 bucket for storing temp files for s3 malware scan with AWS GuardDuty enabled
* that broadcast events to EventBridge after successful scan
*/
resource "aws_s3_bucket" "s3_malware_scan_temp" {
  bucket = "${var.project}-${var.environment}-tmp"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id
  versioning_configuration {
    status = "Enabled"
  }
}

// set s3 bucket ownership and disable acl
resource "aws_s3_bucket_ownership_controls" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Enable object tagging for the malware scan temp bucket with 1-day retention
resource "aws_s3_bucket_object_lock_configuration" "s3_malware_scan_temp" {
  depends_on = [aws_s3_bucket_versioning.s3_malware_scan_temp]

  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_malware_scan_temp" {
  depends_on = [aws_s3_bucket_public_access_block.s3_malware_scan_temp]

  bucket = aws_s3_bucket.s3_malware_scan_temp.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow public read access
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${aws_s3_bucket.s3_malware_scan_temp.arn}/*",
          "${aws_s3_bucket.s3_malware_scan_temp.arn}"
        ]
      },
      # Keep the PutObject restriction for presigned URLs
      {
        Sid       = "AllowPresignedUploadsOnly",
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:PutObject"]
        Resource  = "${aws_s3_bucket.s3_malware_scan_temp.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:signatureversion" = "AWS4-HMAC-SHA256"
          }
        }
      },
      # Allow copying objects from temp bucket to main bucket
      {
        Sid    = "AllowCopyToMainBucket",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.s3_malware_scan_temp.arn}/*",
          "${aws_s3_bucket.s3_malware_scan_temp.arn}"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  cors_rule {
    allowed_methods = ["GET", "HEAD", "PUT", "POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}

# Enable GuardDuty malware protection for the temp bucket
resource "aws_s3_bucket_lifecycle_configuration" "s3_malware_scan_temp" {
  bucket = aws_s3_bucket.s3_malware_scan_temp.id

  rule {
    id     = "malware-scan-cleanup"
    status = "Enabled"

    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# Note: GuardDuty malware protection needs to be configured in AWS Console or via separate Terraform module

# Enable GuardDuty detector for malware protection
resource "aws_guardduty_detector" "s3_malware_scan_temp" {
  enable = true
}

# resource "aws_guardduty_detector_feature" "s3_malware_scan_temp" {
#   detector_id = aws_guardduty_detector.s3_malware_scan_temp.id
#   name        = "S3_DATA_EVENTS"
#   status      = "ENABLED"
# }

resource "aws_guardduty_malware_protection_plan" "s3_malware_scan_temp" {
  role = aws_iam_role.guardduty_malware_protection.arn

  protected_resource {
    s3_bucket {
      bucket_name = aws_s3_bucket.s3_malware_scan_temp.id
    }
  }

  actions {
    tagging {
      status = "ENABLED"
    }
  }

  tags = {
    "Name" = "s3_malware_scan_temp"
  }
}

# Note: S3 malware protection plan needs to be configured in AWS Console
# The detector is enabled above, but you need to manually:
# 1. Go to GuardDuty → Malware Protection
# 2. Enable S3 Malware Protection
# 3. Add the temp bucket: ${aws_s3_bucket.s3_malware_scan_temp.bucket}

# Note: EventBridge rule and Lambda permissions are handled by Serverless Framework
# See serverless.dev.yml for the event configuration

# IAM service role for GuardDuty malware protection
resource "aws_iam_role" "guardduty_malware_protection" {
  name = "${var.project}-${var.environment}-guardduty-malware-protection-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "malware-protection-plan.guardduty.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# IAM policy for GuardDuty malware protection
resource "aws_iam_role_policy" "guardduty_malware_protection" {
  name = "${var.project}-${var.environment}-guardduty-malware-protection-policy"
  role = aws_iam_role.guardduty_malware_protection.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManagedRuleToSendS3EventsToGuardDuty"
        Effect = "Allow"
        Action = [
          "events:PutRule",
          "events:DeleteRule",
          "events:PutTargets",
          "events:RemoveTargets"
        ]
        Resource = [
          "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
        Condition = {
          StringLike = {
            "events:ManagedBy" : "malware-protection-plan.guardduty.amazonaws.com"
          }
        }
      },
      {
        Sid    = "AllowGuardDutyToMonitorEventBridgeManagedRule"
        Effect = "Allow"
        Action = [
          "events:DescribeRule",
          "events:ListTargetsByRule"
        ]
        Resource = [
          "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
        ]
      },
      {
        Sid    = "AllowPostScanTag"
        Effect = "Allow"
        Action = [
          "s3:PutObjectTagging",
          "s3:GetObjectTagging",
          "s3:PutObjectVersionTagging",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [
          "${aws_s3_bucket.s3_malware_scan_temp.arn}/*"
        ]
      },
      {
        Sid    = "AllowEnableS3EventBridgeEvents"
        Effect = "Allow"
        Action = [
          "s3:PutBucketNotification",
          "s3:GetBucketNotification"
        ]
        Resource = [
          aws_s3_bucket.s3_malware_scan_temp.arn
        ]
      },
      {
        Sid    = "AllowPutValidationObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.s3_malware_scan_temp.arn}/malware-protection-resource-validation-object"
        ]
      },
      {
        Sid    = "AllowCheckBucketOwnership"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.s3_malware_scan_temp.arn
        ]
      },
      {
        Sid    = "AllowMalwareScan"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.s3_malware_scan_temp.arn}/*"
        ]
      }
    ]
  })
}

# Data sources for current region and account
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Note: Lambda permissions for EventBridge are handled by Serverless Framework
# See serverless.dev.yml for the event configuration


resource "aws_ssm_parameter" "s3_malware_scan_temp_bucket_name" {
  name  = "/${var.project}/${var.environment}/s3/temp-bucket-name"
  type  = "String"
  value = aws_s3_bucket.s3_malware_scan_temp.id
}

resource "aws_ssm_parameter" "main_s3_bucket_name" {
  name  = "/${var.project}/${var.environment}/s3/main-bucket-name"
  type  = "String"
  value = aws_s3_bucket.main.id
}

resource "aws_ssm_parameter" "serverless_deployment_bucket_name" {
  name  = "/${var.project}/${var.environment}/s3/serverless-deployment-bucket-name"
  type  = "String"
  value = aws_s3_bucket.serverless_deployment_bucket.id
}
