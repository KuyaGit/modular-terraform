// create a cloudfront distribution and attach it to the s3 bucket
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.main.bucket_regional_domain_name

    origin_shield {
      enabled              = true
      origin_shield_region = local.region
    }
  }

  // ordered cache behavior to serve the s3 bucket content
  ordered_cache_behavior {
    path_pattern               = "*"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = aws_s3_bucket.main.bucket_regional_domain_name
    viewer_protocol_policy     = "redirect-to-https"
    min_ttl                    = 86400
    default_ttl                = 2592000
    max_ttl                    = 31536000
    compress                   = true
    response_headers_policy_id = aws_cloudfront_response_headers_policy.image_policy.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront distribution for ${var.project}-${var.environment}-main"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.main.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"

  logging_config {
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    include_cookies = false
    prefix          = "cdn/"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

// Add headers policy for images
resource "aws_cloudfront_response_headers_policy" "image_policy" {
  name = "image-optimization-policy"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "public, max-age=31536000, immutable"
      override = true
    }
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-${var.environment}-cdn-logs"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Enable ACL for the logging bucket
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Allow CloudFront logging service to write logs
resource "aws_s3_bucket_acl" "logs" {
  depends_on = [
    aws_s3_bucket_ownership_controls.logs,
    aws_s3_bucket_public_access_block.logs
  ]

  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

# Optional but recommended: Add encryption for logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Optional but recommended: Add lifecycle policy for logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "cleanup_old_logs"
    status = "Enabled"

    expiration {
      days = 90 # Adjust retention period as needed
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontLogging"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/*"
      }
    ]
  })
}

// save domain name to ssm parameter
resource "aws_ssm_parameter" "cloudfront_domain_name" {
  name  = "/${var.project}/${var.environment}/main/cloudfront-domain-name"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
