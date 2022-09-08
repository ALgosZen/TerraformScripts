terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = var.aws_region
}
resource "aws_s3_bucket" "my_protected_bucket" {
  bucket = var.bucket_name

}

resource "aws_s3_bucket_acl" "my_protected_bucket_acl" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = var.bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = var.bucket_name
  versioning_configuration {
    status = "Enabled"

  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse-config" {
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "object1" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  key    = "data/customers_database/customers_csv/"
}

resource "aws_s3_object" "object2" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  key    = "temp-dir/"
}

resource "aws_s3_object" "object3" {
  bucket = aws_s3_bucket.my_protected_bucket.id
  key    = "scripts/"
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning]

  bucket = var.bucket_name

  rule {
    id = "config"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}

