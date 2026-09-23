variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = map(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnets for the EKS control plane"
  type        = map(string)
}

variable "endpoint_public_access" {
  description = "Enable public EKS API endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Enable private EKS API endpoint"
  type        = bool
}

variable "public_access_cidrs" {
  description = "Allowed CIDRs for public EKS API endpoint"
  type        = list(string)
}

# ------------------------------------------------------------
# Existing EKS cluster IAM role
# ------------------------------------------------------------

variable "cluster_iam_role_arn" {
  description = "Existing IAM role ARN used by the EKS control plane"
  type        = string
}

variable "cluster_iam_role_additional_policies" {
  description = "Additional IAM policies for the EKS cluster role"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------
# EKS encryption
# ------------------------------------------------------------

variable "create_kms_key" {
  description = "Create KMS key for EKS secrets encryption"
  type        = bool
  default     = true
}

# ------------------------------------------------------------
# EKS Add-ons
# ------------------------------------------------------------

variable "cluster_addons" {
  description = "EKS managed add-ons"
  type = map(object({
    most_recent = optional(bool, true)
  }))
  default = {}
}

# ------------------------------------------------------------
# EKS managed node groups
# ------------------------------------------------------------

variable "node_groups" {
  description = "EKS managed node groups"

  type = map(object({
    instance_types = list(string)

    min_size     = number
    max_size     = number
    desired_size = number

    capacity_type = string

    disk_size = number

    # Existing IAM role ARN
    iam_role_arn = string

    iam_role_additional_policies = optional(map(string), {})

    launch_template_name = string
  }))

  default = {}
}

# ------------------------------------------------------------
# EKS access entries
# ------------------------------------------------------------

variable "access_entries" {
  description = "EKS access entries"
  type        = any
  default     = {}
}

# ------------------------------------------------------------
# Tags
# ------------------------------------------------------------

variable "tags" {
  description = "Tags for EKS resources"
  type        = map(string)
  default     = {}
}