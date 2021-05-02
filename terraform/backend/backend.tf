# This file creates S3 bucket to hold terraform states
# and DynamoDB table to keep the state locks.
resource "aws_s3_bucket" "terraform_infra" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true

  # To allow rolling back states
  versioning {
    enabled = true
  }

  # To cleanup old states eventually
  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = {
    Name        = var.bucket_name
    Description = "Bucket for terraform states"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_infra_public_block" {
  bucket = aws_s3_bucket.terraform_infra.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_dynamodb_table" "dynamodb-table" {
#   name = "jfdonadio-terraform-locks"
#   # up to 25 per account is free
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 2
#   write_capacity = 2
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "Terraform Lock Table"
#     Description = "Terraform Lock Table"
#   }
# }
