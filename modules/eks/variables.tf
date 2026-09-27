# ============================================================
# EKS CLUSTER
# ============================================================

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

# ============================================================
# NETWORK
# ============================================================

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = map(string)
}

variable "control_plane_subnet_ids" {
  description = "Control plane subnet IDs"
  type        = map(string)
}

# ============================================================
# EKS API ENDPOINT
# ============================================================

variable "endpoint_public_access" {
  description = "Enable public EKS API endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Enable private EKS API endpoint"
  type        = bool
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS endpoint"
  type        = list(string)
}

# ============================================================
# CLUSTER IAM
# ============================================================

variable "cluster_iam_role_arn" {
  description = "Existing EKS cluster IAM role ARN"
  type        = string
}

variable "cluster_iam_role_additional_policies" {
  description = "Additional policies for EKS cluster IAM role"
  type        = map(string)

  default = {}
}

# ============================================================
# KMS
# ============================================================

variable "create_kms_key" {
  description = "Create KMS key for EKS secrets encryption"
  type        = bool

  default = true
}

# ============================================================
# EKS ADDONS
# ============================================================

variable "cluster_addons" {
  description = "EKS cluster addons"

  type = map(object({
    most_recent = optional(bool, true)
  }))

  default = {}
}

# ============================================================
# EKS NODE GROUPS
# ============================================================

variable "node_groups" {
  description = "EKS managed node groups"

  type = map(object({

    # --------------------------------------------------------
    # CUSTOM AMI
    # --------------------------------------------------------

    ami_id = optional(string)

    # --------------------------------------------------------
    # INSTANCE
    # --------------------------------------------------------

    instance_types = list(string)

    # --------------------------------------------------------
    # SCALING
    # --------------------------------------------------------

    min_size     = number
    max_size     = number
    desired_size = number

    # --------------------------------------------------------
    # CAPACITY
    # --------------------------------------------------------

    capacity_type = string

    # --------------------------------------------------------
    # STORAGE
    # --------------------------------------------------------

    disk_size = number

    # --------------------------------------------------------
    # IAM
    # --------------------------------------------------------

    iam_role_arn = string

    iam_role_additional_policies = optional(
      map(string),
      {}
    )

    # --------------------------------------------------------
    # LAUNCH TEMPLATE
    # --------------------------------------------------------

    launch_template_name = string
  }))

  default = {}
}

# ============================================================
# EKS ACCESS ENTRIES
# ============================================================

variable "access_entries" {
  description = "EKS access entries"
  type        = any

  default = {}
}

# ============================================================
# TAGS
# ============================================================

variable "tags" {
  description = "Tags for EKS resources"
  type        = map(string)

  default = {}
}