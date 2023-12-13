output "superset_data_bucket_id" {
  description = "Id of the superset data bucket"
  value       = aws_s3_bucket.superset_data_bucket.id
}

output "athena_output_bucket_id" {
  description = "Id of the superset data bucket"
  value       = aws_s3_bucket.athena_output_bucket.id
}

output "superset_kms_key_id" {
  description = "KMS encryption key id"
  value       = aws_kms_key.bucket_encryption_key.id
}

output "superset_kms_key_arn" {
  description = "KMS encryption key id"
  value       = aws_kms_key.bucket_encryption_key.arn
}
