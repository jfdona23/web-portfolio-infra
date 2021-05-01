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

# Logging Bucket
resource "aws_s3_bucket" "web_logs" {
  bucket = var.bucket_web_logs
  acl    = "private"

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
