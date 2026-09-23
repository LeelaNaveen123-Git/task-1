output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "kms_key_id" {
  description = "KMS key ID used for bucket encryption"
  value = (
    var.enable_encryption
    ? (
        var.kms_key_arn != null
        ? var.kms_key_arn
        : aws_kms_key.this[0].key_id
      )
    : null
  )
}

output "kms_key_arn" {
  description = "KMS key ARN used for bucket encryption"
  value = (
    var.enable_encryption
    ? (
        var.kms_key_arn != null
        ? var.kms_key_arn
        : aws_kms_key.this[0].arn
      )
    : null
  )
}