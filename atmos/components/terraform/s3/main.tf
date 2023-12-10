resource "aws_kms_key" "bucket_encryption_key" {
  description             = "KMS key for encrypting S3 buckets"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "${var.tenant}-${var.environment}-${var.stage}-superset"
  }
}

resource "aws_kms_alias" "bucket_encryption_key_alias" {
  name          = "alias/${var.tenant}-${var.environment}-${var.stage}"
  target_key_id = aws_kms_key.bucket_encryption_key.key_id
}

resource "aws_s3_bucket" "superset_data_bucket" {
  bucket = "${var.tenant}-${var.environment}-${var.stage}-superset-data"
  tags = var.tags
}

resource "aws_s3_bucket" "athena_output_bucket" {
  bucket = "${var.tenant}-${var.environment}-${var.stage}-athena-output"
  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "superset_data_bucket_config" {
  bucket = aws_s3_bucket.superset_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "superset_bucket_versioning" {
  bucket = aws_s3_bucket.superset_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_output_bucket_config" {
  bucket = aws_s3_bucket.superset_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "athena_output_bucket_versionig" {
  bucket = aws_s3_bucket.athena_output_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
