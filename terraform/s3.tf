# Create S3 Policy to allow Cloudfront OAI to read the bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

# Attach the above policy to the bucket
resource "aws_s3_bucket_policy" "web_s3" {
  bucket = aws_s3_bucket.web_s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# The bucket itself
resource "aws_s3_bucket" "web_s3" {
  bucket = var.bucket_web
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    "Name"        = var.bucket_web
    "Description" = "Storage for ${var.domain}"
  }
}

# Restrict Public access
resource "aws_s3_bucket_public_access_block" "web_s3_public_block" {
  bucket = aws_s3_bucket.web_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket for web access logs
data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "web_logs" {
  bucket = var.bucket_web_logs

  grant {
    id          = data.aws_canonical_user_id.current.id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  grant {
    # Grant CloudFront logs access to your Amazon S3 Bucket
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = 90
    }
  }

  tags = {
    "Name"        = var.bucket_web_logs
    "Description" = "Logs for ${var.domain}"
  }
}

# Restrict Public access
resource "aws_s3_bucket_public_access_block" "web_logs_public_block" {
  bucket = aws_s3_bucket.web_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}