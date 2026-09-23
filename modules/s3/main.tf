# ============================================================
# KMS KEY
# ============================================================

resource "aws_kms_key" "this" {
  count = var.enable_encryption && var.kms_key_arn == null ? 1 : 0

  description = "KMS key for S3 bucket ${var.bucket_name}"

  enable_key_rotation = var.enable_kms_key_rotation

  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.bucket_name}-kms"
      Purpose = "S3 Encryption"
    }
  )
}


# ============================================================
# KMS ALIAS
# ============================================================

resource "aws_kms_alias" "this" {
  count = var.enable_encryption && var.kms_key_arn == null ? 1 : 0

  name = "alias/${var.bucket_name}"

  target_key_id = aws_kms_key.this[0].key_id
}


# ============================================================
# CURRENT AWS ACCOUNT
# ============================================================

data "aws_caller_identity" "current" {}


# ============================================================
# S3 BUCKET
# ============================================================

resource "aws_s3_bucket" "this" {

  bucket = var.bucket_name

  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}


# ============================================================
# S3 OWNERSHIP CONTROLS
# ============================================================

resource "aws_s3_bucket_ownership_controls" "this" {

  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# ============================================================
# S3 VERSIONING
# ============================================================

resource "aws_s3_bucket_versioning" "this" {

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}


# ============================================================
# S3 PUBLIC ACCESS BLOCK
# ============================================================

resource "aws_s3_bucket_public_access_block" "this" {

  bucket = aws_s3_bucket.this.id

  block_public_acls = var.block_public_access

  block_public_policy = var.block_public_access

  ignore_public_acls = var.block_public_access

  restrict_public_buckets = var.block_public_access
}


# ============================================================
# S3 SERVER-SIDE ENCRYPTION
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {

  bucket = aws_s3_bucket.this.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = var.enable_encryption ? "aws:kms" : "AES256"

      kms_master_key_id = (
        var.enable_encryption
        ? (
            var.kms_key_arn != null
            ? var.kms_key_arn
            : aws_kms_key.this[0].arn
          )
        : null
      )
    }

    bucket_key_enabled = (
      var.enable_encryption
      ? var.enable_bucket_key
      : false
    )
  }
}


# ============================================================
# S3 BUCKET POLICY
# ============================================================

data "aws_iam_policy_document" "bucket" {

  # ----------------------------------------------------------
  # DENY HTTP
  # ----------------------------------------------------------

  dynamic "statement" {

    for_each = var.deny_insecure_transport ? [1] : []

    content {

      sid = "DenyInsecureTransport"

      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = [
        "s3:*"
      ]

      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"

        values = [
          "false"
        ]
      }
    }
  }


  # ----------------------------------------------------------
  # DENY UNENCRYPTED UPLOAD
  # ----------------------------------------------------------

  dynamic "statement" {

    for_each = (
      var.enable_encryption && var.deny_unencrypted_uploads
      ? [1]
      : []
    )

    content {

      sid = "DenyUnencryptedObjectUploads"

      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = [
        "s3:PutObject"
      ]

      resources = [
        "${aws_s3_bucket.this.arn}/*"
      ]

      condition {

        test = "StringNotEquals"

        variable = "s3:x-amz-server-side-encryption"

        values = [
          "aws:kms"
        ]
      }
    }
  }
}


resource "aws_s3_bucket_policy" "this" {

  bucket = aws_s3_bucket.this.id

  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}


# ============================================================
# S3 LIFECYCLE
# ============================================================

resource "aws_s3_bucket_lifecycle_configuration" "this" {

  count = var.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {

    id = "manage-noncurrent-versions"

    status = "Enabled"

    noncurrent_version_expiration {

      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}