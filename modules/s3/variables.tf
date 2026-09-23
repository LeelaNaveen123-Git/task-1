variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete a bucket containing objects"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Enable all S3 Block Public Access settings"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN. If null, the module creates a KMS key."
  type        = string
  default     = null
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "enable_bucket_key" {
  description = "Enable S3 Bucket Key for SSE-KMS"
  type        = bool
  default     = true
}

variable "deny_unencrypted_uploads" {
  description = "Deny PutObject requests that do not use SSE-KMS"
  type        = bool
  default     = true
}

variable "deny_insecure_transport" {
  description = "Deny S3 requests made over HTTP"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable lifecycle management"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days before noncurrent object versions are permanently deleted"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to S3 resources"
  type        = map(string)
  default     = {}
}