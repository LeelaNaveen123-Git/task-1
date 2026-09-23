# ============================================================
# GLOBAL VARIABLES
# ============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}


# ============================================================
# COMMON TAGS
# ============================================================

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)

  default = {}
}


# ============================================================
# VPC
# ============================================================

variable "vpcs" {
  description = "VPC configuration"

  type = map(object({

    cidr_block = string

    azs = list(string)

    public_subnets = map(string)

    private_subnets = map(string)

    enable_nat_gateway = optional(bool, true)

    single_nat_gateway = optional(bool, true)

    enable_dns_support = optional(bool, true)

    enable_dns_hostnames = optional(bool, true)
  }))

  default = {}
}


# ============================================================
# SECURITY GROUPS
# ============================================================

variable "security_groups" {
  description = "Security group configuration"

  type = map(object({

    description = string

    vpc_name = string

    ingress_rules = optional(map(object({

      description = optional(string)

      from_port = number

      to_port = number

      protocol = string

      cidr_blocks = optional(list(string), [])

    })), {})

    egress_rules = optional(map(object({

      description = optional(string)

      from_port = number

      to_port = number

      protocol = string

      cidr_blocks = optional(list(string), [])

    })), {})
  }))

  default = {}
}


# ============================================================
# S3
# ============================================================

variable "s3_buckets" {
  description = "S3 bucket configuration"

  type = map(object({

    bucket_name = string

    enable_versioning = optional(bool, true)

    kms_key_arn = optional(string, null)

    noncurrent_version_expiration_days = optional(number, 90)
  }))

  default = {}
}


# ============================================================
# IAM
# ============================================================

variable "iam_roles" {
  description = "IAM role configuration"

  type = map(object({

    description = optional(string, null)

    trusted_services = list(string)

    managed_policy_arns = optional(
      list(string),
      []
    )
  }))

  default = {}
}


# ============================================================
# EC2
# ============================================================

variable "ec2_instances" {
  description = "EC2 instance configuration"

  type = map(object({

    ami_id = string

    instance_type = string

    vpc_name = string

    subnet_type = string

    availability_zone = string

    security_groups = list(string)

    associate_public_ip = bool

    key_name = optional(string, null)

    iam_role_name = optional(string, null)

    root_volume_size = number

    root_volume_type = string

    monitoring = bool
  }))

  default = {}
}


# ============================================================
# EKS
# ============================================================

variable "eks_clusters" {
  description = "EKS cluster configuration"

  type = map(object({

    kubernetes_version = string

    vpc_name = string

    endpoint_public_access = bool

    endpoint_private_access = bool

    public_access_cidrs = list(string)

    cluster_iam_role_arn = string

    cluster_iam_role_additional_policies = optional(
      map(string),
      {}
    )

    create_kms_key = bool

    cluster_addons = map(object({
      most_recent = optional(bool, true)
    }))

    node_groups = map(object({

      instance_types = list(string)

      min_size = number

      max_size = number

      desired_size = number

      capacity_type = string

      disk_size = number

      iam_role_arn = string

      iam_role_additional_policies = optional(
        map(string),
        {}
      )

      launch_template_name = string
    }))

    access_entries = any
  }))

  default = {}
}